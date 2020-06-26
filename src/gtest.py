#!/usr/bin/env python3
import jinja2, json, os, shutil, sys, math
from itertools import tee, zip_longest, product, chain, zip_longest
from functools import update_wrapper
from typing import List
from collections import namedtuple, defaultdict

#
#  __                                      _          _
# /__ |  _  |_   _. |     | o ._  o  _.   /   _  ._ _|_ o  _
# \_| | (_) |_) (_| |   \_| | | | | (_|   \_ (_) | | |  | (_|
#                                _|                        _|
#
dirname = os.path.dirname(__file__)
templateLoader = jinja2.FileSystemLoader(searchpath=os.path.join(dirname, "template"))
templateEnv = jinja2.Environment(loader=templateLoader)
templateEnv.globals.update(zip=zip)
templateEnv.globals.update(zip_longest=zip_longest)

#
# | | _|_ o |  _
# |_|  |_ | | _>
#
try:
    from functools import cached_property
except ImportError:

    class cached_property(object):
        def __init__(self, func):
            update_wrapper(self, func)
            self.func = func

        def __get__(self, obj, cls):
            if obj is None:
                return self
            value = obj.__dict__[self.func.__name__] = self.func(obj)
            return value


def pairwise(iterable):
    "s -> (s0,s1), (s1,s2), (s2, s3), ..."
    a, b = tee(iterable)
    next(b, None)
    return zip(a, b)


def format_template(str_, language):
    """
    - Remove empty line.
    - right strip
    - Split Fortran line 
    """

    def split_fortran_line(line, max_width=100):
        '''
        To be improved and cleaned.
        Don't work if we need to split one line in more than one line
        '''
        prefix = "&\n!$OMP&" if line.lstrip().startswith("!$OMP") else "&\n&"
        l_chunk = range(len(line) // max_width)

        l = list(line)
        for i in l_chunk:
            l.insert((i + 1) * max_width + 3 * i, prefix)
        return "".join(l)

    l_line = [line.rstrip() for line in str_.split("\n") if line.strip()]
    l_result = l_line if language == "cpp" else map(split_fortran_line, l_line)
    return "\n".join(l_result) + "\n"


#  _        _    ___
# / \ |\/| |_)    | ._ _   _
# \_/ |  | |      | | (/_ (/_
#

# Need to refractor this one... Too ugly or too smart
def combinations_construct(tree_config_path, path=["root"]) -> List[List[str]]:
    """
    >>> combinations_construct({"root": ["target", "target teams"], "target": ["teams"], "target teams": [], "teams": []})
    [['target'], ['target', 'teams'], ['target teams']]
    """
    tails = [path[1:]] if len(path[1:]) else []

    for children in tree_config_path[path[-1]]:
        tails += combinations_construct(tree_config_path, path + [children])
    return tails


# ___
#  |     ._   _    | | _|_ o |  _
#  | |_| |_) (/_   |_|  |_ | | _>
#        |


class TypeSystem:
    def __init__(self, T):
        self.T = T

    @cached_property
    def serialized(self):
        """
        >>> TypeSystem("REAL").serialized
        'real'
        >>> TypeSystem("DOUBLE PRECISION").serialized
        'double_precision'
        >>> TypeSystem("complex<long double>").serialized
        'complex_long_double'
        >>> TypeSystem("*double").serialized
        'double'
        """
        return "_".join(self.T.lower().translate(str.maketrans("<>*", "   ")).split())

    @cached_property
    def without_pointer(self):
        """
        >>> TypeSystem("*complex<float>").without_pointer
        'complex<float>'
        """
        return self.T.replace("*", "")

    @cached_property
    def category(self):
        """
        >>> TypeSystem("complex<long double>").category
        'complex'
        >>> TypeSystem("REAL").category
        'float'
        """
        if self.without_pointer in ("long int", "int", "long long int", "unsigned", "INTEGER"):
            return "integer"
        elif self.without_pointer in ("REAL", "DOUBLE PRECISION", "float", "double", "long double"):
            return "float"
        elif self.without_pointer in ("COMPLEX", "DOUBLE COMPLEX", "complex<float>", "complex<double>", "complex<long double>"):
            return "complex"
        elif self.without_pointer in ("bool",):
            return "bool"
        raise NotImplementedError(f"Datatype ({self.T}) is not yet supported.")

    @cached_property
    def is_long(self):
        return "long" in self.without_pointer

    @cached_property
    def is_complex(self):
        return self.category == "complex"

    @cached_property
    def internal(self):
        """
        >>> TypeSystem("complex<float>").internal
        'float'
        >>> TypeSystem("DOUBLE COMPLEX").internal
        'DOUBLE'
        >>> TypeSystem("COMPLEX").internal
        'REAL'
        """
        if self.category != "complex":
            return self.without_pointer
        elif self.T == "DOUBLE COMPLEX":
            return "DOUBLE"
        elif self.T == "COMPLEX":
            return "REAL"
        elif self.category == "complex":  # Only the C++ type are left
            return self.without_pointer.split("<")[1][:-1]
        else:
            raise NotImplementedError("Datatype ({self.T}) is not yet supported")

    @cached_property
    def is_pointer(self):
        """
        >>> TypeSystem("complex<float>").is_pointer
        False
        >>> TypeSystem("*complex<float>").is_pointer
        True
        """
        return "*" in self.T

    @cached_property
    def language(self):
        """
        >>> TypeSystem("*complex<float>").language
        'cpp'
        >>> TypeSystem("REAL").language
        'fortran'
        """
        # Warning, just rely on the capitalization.
        # Not robust, but good enought
        if self.without_pointer.islower():
            return "cpp"
        else:
            return "fortran"

    def __str__(self):
        return self.T


class Pragma(str):
    def __init__(self, pragma):
        self.pragma = pragma

    def has(self,str_):
        """
        >>> Pragma("target teams distribute").has("implicit_goto")
        True
        >>> Pragma("target teams distribute").has("target")
        True
        >>> Pragma("target teams distribute").has("loop")
        False
        """

        # Naming is hard. I want to know if y have a C++/Fortran loop in my kernel
        # Loop is a omp construct...
        # So let's got for `implicit_goto`
        if str_ == "implicit_goto":
            return any(p in self.pragma for p in ("distribute", "for", "loop", "simd"))
        elif str_ == "worksharing":
            return any(p in self.pragma for p in ("distribute", "for", "loop"))
        elif str_ == "generator":
            return any(p in self.pragma for p in ("teams", "parallel"))
        else:
            return str_ in self.pragma

    @cached_property
    def can_be_reduced(self):
        return any(p in self.pragma for p in ("teams", "parallel", "simd"))

    def __repr__(self):
        return self.pragma


# ___                               _
#  |  _   _ _|_   |_   _.  _  _ __ |_ _.  _ _|_  _  ._
#  | (/_ _>  |_   |_) (_| _> (/_   | (_| (_  |_ (_) | \/
#                                                     /


class Path:
    def __init__(self, path_raw, d_arg):
        self.path_raw = path_raw

        # Explicit is better than implicit.
        # So this is ugly... But really usefull when testing
        # d_args keys containt [data_type, test_type, avoid_user_defined_reduction, paired_pragmas, loop_pragma, collapse]
        for k, v in d_arg.items():
            setattr(self, k, v)

    @cached_property
    def T(self):
        return TypeSystem(self.data_type)

    @cached_property
    def language(self):
        """
        >>> Path(None, {"data_type": "float"}).language
        'cpp'
        >>> Path(None, {"data_type": "REAL"}).language
        'fortran'
        """
        return self.T.language

    @cached_property
    def path(self):
        """
        >>> Path(["parallel for"], {}).path
        [parallel for]
        >>> Path(["parallel", "loop_for"], {}).path
        [parallel, loop]
        """
        # To facilitate the recursion. Loop are encoded as "loop_distribute" and "loop_for".
        def sanitize(combined_pragma):
            l_pragma = combined_pragma.split()
            head = lambda p : p.split('_').pop(0)  
            return Pragma(" ".join(map(head,l_pragma)))

        return [sanitize(p) for p in self.path_raw]

    @cached_property
    def flatten_target_path(self):
        """
        >>> Path(["parallel for", "simd"], {}).flatten_target_path
        [parallel, for, simd]
        """
        l = list(map(Pragma,chain.from_iterable(map(str.split, self.path))))
        try:
            idx = l.index("target")
        except ValueError:
            return l
        else:
            return l[idx:]

    @cached_property
    def name(self):
        """
        >>> Path(["parallel", "for"], {"data_type": "float"}).name
        'parallel__for'
        >>> Path(["parallel for", "simd"], {"data_type": "REAL"}).name
        'parallel_do__simd'
        """
        l_node_serialized = ("_".join(node.split()) for node in self.path)

        n = "__".join(l_node_serialized)
        if self.language == "cpp":
            return n
        elif self.language == "fortran":
            return n.replace("for", "do")
        return NotImplementedError

    @cached_property
    def ext(self):
        """
        >>> Path(None, {"data_type": "float"}).ext
        'cpp'
        >>> Path(None, {"data_type": "DOUBLE PRECISION"}).ext
        'F90'
        """
        if self.language == "cpp":
            return "cpp"
        elif self.language == "fortran":
            return "F90"
        return NotImplementedError

    @cached_property
    def filename(self):
        """
        >>> Path(["parallel", "for"], {"data_type": "float"}).filename
        'parallel__for.cpp'
        >>> Path(["parallel", "loop_for"], {"data_type": "float"}).filename
        'parallel__loop.cpp'
        >>> Path(["parallel for", "simd"], {"data_type": "REAL"}).filename
        'parallel_do__simd.F90'
        """
        return f"{self.name}.{self.ext}"

    @cached_property
    def only_teams(self):
        """
        >>> Path(["teams", "distribute"], {}).only_teams
        False
        >>> Path(["teams", "parrallel", "loop"], {}).only_teams
        True
        >>> Path(["distribute"], {}).only_teams
        False
        >>> Path(["teams"], {}).only_teams
        True
        """
        # Because of `loop` we need to check pair-wize
        return any(i == "teams" and not j in ("distribute", "loop") for i, j in pairwise(self.flatten_target_path + [None]))

    @cached_property
    def only_parallel(self):
        """
        >>> Path(["target parallel", "for"], {}).only_parallel
        False
        >>> Path(["target parallel", "for"], {}).only_parallel
        False
        >>> Path(["target teams", "loop", "parallel"], {}).only_parallel
        True
        >>> Path(["parallel for", "target parallel"], {}).only_parallel
        True
        """
        return any(i == "parallel" and not j in ("for", "loop") for i, j in pairwise(self.flatten_target_path + [None]))

    @cached_property
    def balenced(self):
        """
        >>> Path(["parallel", "for"], {}).balenced
        True
        >>> Path(["teams", "loop", "parallel"], {}).balenced
        False
        """
        return not self.only_parallel and not self.only_teams

    @cached_property
    def loop_construct_number(self):
        """
        >>> Path(["distribute"], {"collapse": 1}).loop_construct_number
        1
        >>> Path(["distribute"], {"collapse": 0}).loop_construct_number
        1
        >>> Path(["distribute"], {"collapse": 2}).loop_construct_number
        2
        >>> Path(["teams", "distribute", "parallel", "for"], {"collapse": 2}).loop_construct_number
        4
        >>> Path(["teams distribute parallel for"], {"collapse": 2}).loop_construct_number
        2
        >>> Path(["teams", "parallel"], {"collapse": 2}).loop_construct_number
        0
        """
        loop_pragma_number = sum(Pragma(p).has("implicit_goto") for p in self.path)
        if self.collapse:
            return loop_pragma_number * self.collapse
        else:
            return loop_pragma_number

    @cached_property
    def loop_tripcount(self):
        """
        >>> Path(["distribute"], {"collapse": 0}).loop_tripcount
        262144
        >>> Path(["distribute"], {"collapse": 1}).loop_tripcount
        262144
        >>> Path(["distribute"], {"collapse": 2}).loop_tripcount
        512
        >>> Path(["teams distribute paralel for simd"], {"collapse": 0}).loop_tripcount
        262144
        >>> Path(["teams", "distribute", "paralel", "for", "simd"], {"collapse": 0}).loop_tripcount
        64
        >>> Path(["teams"], {"collapse": 0}).loop_tripcount
        """
        if not self.loop_construct_number:
            return None

        return max(1, math.ceil(math.pow(64 * 64 * 64, 1.0 / self.loop_construct_number)))

    @cached_property
    def regions(self):
        """
        >>> Path(["target"], {}).regions
        [[target]]
        >>> Path(["target teams distribute"], {}).regions
        [[target teams distribute]]
        >>> Path(["target", "teams", "distribute"], {}).regions
        [[target, teams, distribute]]
        >>> Path(["target", "teams", "distribute", "parallel", "for", "simd"], {}).regions
        [[target, teams, distribute], [parallel, for], [simd]]
        >>> Path(["target teams", "parallel"], {}).regions
        [[target teams], [parallel]]
        >>> Path(["target", "parallel", "for"], {}).regions
        [[target, parallel, for]]
        >>> Path(["parallel", "for", "target", "teams"], {}).regions
        [[parallel, for], [target, teams]]
        >>> Path(["target", "teams", "loop", "parallel", "loop", "simd"], {}).regions
        [[target, teams, loop], [parallel, loop], [simd]]
        >>> Path(["target", "teams", "parallel", "simd"], {"collapse": 0}).regions
        [[target, teams], [parallel], [simd]]
        """

        l, l_tmp = [], []
        for i, j in pairwise(self.path + ["sentinel"]):
            tail_i = Pragma(i.split()[-1])
            head_j = Pragma(j.split()[0])

            l_tmp.append(Pragma(i))
            if (tail_i.has("implicit_goto") or (tail_i.has("generator") and not head_j.has("worksharing"))) or (tail_i.has("target") and head_j == "sentinel"):
                l.append(l_tmp[:])
                l_tmp = []

        return l

    @cached_property
    def region_counters(self):
        """
        >>> Path(["target teams distribute"], {"collapse": 0, "intermediate_result": False}).region_counters
        ['counter_N0']
        >>> Path(["target"], {"collapse": 0, "intermediate_result": False}).region_counters
        ['counter_target']
        >>> Path(["target teams"], {"collapse": 0, "intermediate_result": False}).region_counters
        ['counter_teams']
        >>> Path(["target", "teams", "parallel"], {"collapse": 0, "intermediate_result": True}).region_counters
        ['counter_teams', 'counter_parallel']
        >>> Path(["target", "teams", "parallel for"], {"collapse": 0, "intermediate_result": True}).region_counters
        ['counter_teams', 'counter_N0']
        >>> Path(["target teams distribute", "parallel for"], {"collapse": 0, "intermediate_result": True}).region_counters
        ['counter_N0', 'counter_N1']
        >>> Path(["target teams distribute", "parallel for"], {"collapse": 2, "intermediate_result": True}).region_counters
        ['counter_N0', 'counter_N2']
        """
        l, i = [], 0
        for region in self.regions:
            tail = region[-1]
            if tail.has("implicit_goto"):
                l.append(f"counter_N{i}")
                i += max(self.collapse, 1)
            else:
                l.append(f"counter_{tail.split().pop()}")

        # In the case of local tests,  we will use only one variable to do our work.
        # All the counter should refer to the first one
        if not self.intermediate_result:
            return [l[0]] * len(self.regions)
        return l

    @cached_property
    def region_loop_construct(self):
        """
        >>> Path(["target teams distribute"], {"collapse": 0}).region_loop_construct
        [[Idx(i='i0', N='N0', v=262144)]]
        >>> Path(["target teams distribute", "parallel"], {"collapse": 0}).region_loop_construct
        [[Idx(i='i0', N='N0', v=262144)], []]
        >>> Path(["target teams distribute", "parallel for"], {"collapse": 0}).region_loop_construct
        [[Idx(i='i0', N='N0', v=512)], [Idx(i='i1', N='N1', v=512)]]
        >>> Path(["target teams distribute"], {"collapse": 2}).region_loop_construct
        [[Idx(i='i0', N='N0', v=512), Idx(i='i1', N='N1', v=512)]]
        """
        n_collapse = max(self.collapse, 1)
        i = 0
        l = []
        Idx = namedtuple("Idx", "i N v")
        for region in self.regions:
            tail = region[-1]

            l_tmp = []
            if tail.has("implicit_goto"):
                for j in range(n_collapse):
                    l_tmp.append(Idx(f"i{i}", f"N{i}", self.loop_tripcount))
                    i += 1
            else:
                l_tmp = []

            l.append(l_tmp)
        return l

    @cached_property
    def regions_increment(self):
        """
        >>> Path(["target"], {"collapse": 0, "intermediate_result": False}).regions_increment
        [Inc(v='counter_target', i='1.', j=None)]
        >>> Path(["target teams distribute"], {"collapse": 0, "intermediate_result": False}).regions_increment
        [Inc(v='counter_N0', i='1.', j=None)]
        >>> Path(["target teams distribute", "parallel", "for"], {"collapse": 2, "intermediate_result": True}).regions_increment
        [Inc(v='counter_N0', i='counter_N2', j=None), Inc(v='counter_N2', i='1.', j=None)]
        >>> Path(["target teams"], {"collapse": 0, "intermediate_result": False}).regions_increment
        [Inc(v='counter_teams', i='1.', j='omp_get_num_teams()')]
        """

        l = []
        Inc = namedtuple("Inc", "v i j")
        for (counter, counter_next), region in zip(pairwise(self.region_counters + ["1."]), self.regions):
            tail = region[-1]
            if not self.intermediate_result and self.only_teams and self.only_parallel:
                l.append(Inc(counter, counter_next, "( omp_get_num_teams() * omp_get_num_threads() )"))
            elif not self.intermediate_result and self.only_teams:
                l.append(Inc(counter, counter_next, "omp_get_num_teams()"))
            elif not self.intermediate_result and self.only_parallel:
                l.append(Inc(counter, counter_next, "omp_get_num_threads()"))
            elif tail.has("implicit_goto"):
                l.append(Inc(counter, counter_next, None))
            elif tail.has("teams"):
                l.append(Inc(counter, counter_next, "omp_get_num_teams()"))
            elif tail.has("parallel"):
                l.append(Inc(counter, counter_next, "omp_get_num_threads()"))
            elif tail.has("target"):
                l.append(Inc(counter, counter_next, None))
            else:
                raise ValueError(tail)

        return l

    @cached_property
    def regions_additional_pragma(self):
        """
        >>> Path(["target teams"], {"test_type": "atomic", "intermediate_result": False, "collapse": 0}).regions_additional_pragma
        [['map(tofrom: counter_teams)']]
        >>> Path(["target teams"], {"test_type": "memcopy", "intermediate_result": False, "collapse": 0, "data_type": "float"}).regions_additional_pragma
        [['map(to: pS[0:size]) map(from: pD[0:size])']]
        >>> Path(["target teams"], {"test_type": "memcopy", "intermediate_result": False, "collapse": 0, "data_type": "REAL"}).regions_additional_pragma
        [['map(to: src) map(from: dst)']]
        >>> Path(["target teams distribute"], {"test_type": "reduction", "intermediate_result": False, "collapse": 3}).regions_additional_pragma
        [['map(tofrom: counter_N0) reduction(+: counter_N0) collapse(3)']]
        """
        l = []
        for counter, region in zip(self.region_counters, self.regions):
            l_tmp = []
            for pragma in region:
                construct = []
                if pragma.has("target"):
                    if "memcopy" in self.test_type:
                        if self.language == "cpp":
                            construct += ["map(to: pS[0:size]) map(from: pD[0:size])"]
                        elif self.language == "fortran":
                            construct += ["map(to: src) map(from: dst)"]
                    else:
                        construct += [f"map(tofrom: {counter})"]
                if "reduction" in self.test_type and pragma.can_be_reduced:
                    construct += [f"reduction(+: {counter})"]
                if self.collapse and pragma.has("implicit_goto"):
                    construct += [f"collapse({self.collapse})"]

                l_tmp.append(" ".join(construct))
            l.append(l_tmp[:])
        return l

    @cached_property
    def is_valid_common_test(self):
        """
        >>> Path(["for"], {"collapse": 0, "loop_pragma": False, "intermediate_result": False}).is_valid_common_test
        True
        >>> Path(["for"], {"collapse": 0, "loop_pragma": True, "intermediate_result": False}).is_valid_common_test
        False
        >>> Path(["loop"], {"collapse": 0, "loop_pragma": False, "intermediate_result": False}).is_valid_common_test
        False
        >>> Path(["loop"], {"collapse": 0, "loop_pragma": True, "intermediate_result": False}).is_valid_common_test
        True
        >>> Path(["loop"], {"collapse": 1, "loop_pragma": True, "intermediate_result": False}).is_valid_common_test
        True
        >>> Path(["loop"], {"collapse": 0, "loop_pragma": True, "intermediate_result": False}).is_valid_common_test
        True
        >>> Path(["teams"], {"collapse": 0, "loop_pragma": False, "intermediate_result": False}).is_valid_common_test
        True
        >>> Path(["teams"], {"collapse": 1, "loop_pragma": False, "intermediate_result": False}).is_valid_common_test
        False
        """
        # If we don't ask for loop pragma we don't want to generate with tests who containt omp loop construct
        if self.loop_pragma ^ any(p.has("loop") for p in self.path):
            return False
        # If people want collapse, we will print only the test with loop
        if self.collapse and not self.loop_construct_number:
            return False
        # If people whant some intermediate_result we need at least to have 2 regions inside the target
        # Because when we do `host_threaded` we add only one region. The following hack is working
        if self.intermediate_result and len(self.regions) < (2 + self.host_threaded):
            return False

        return True

    @cached_property
    def template_rendered(self):

        if not (self.is_valid_common_test and self.is_valid_test):
            return None

        template = templateEnv.get_template(self.template_location)
        str_ = template.render(**{p: getattr(self, p) for p in dir(self) if p != "template_rendered"})
        return format_template(str_, self.language)

    def write_template_rendered(self, folder):
        if self.template_rendered:
            with open(os.path.join(folder, self.filename), "w") as f:
                f.write(self.template_rendered)


#                                        _
# |_| o  _  ._ _. ._ _ |_  o  _  _. |   |_) _. ._ _. | |  _  | o  _ ._ _
# | | | (/_ | (_| | (_ | | | (_ (_| |   |  (_| | (_| | | (/_ | | _> | | |
#


class Fold(Path):
    @cached_property
    def expected_value(self):
        """
        >>> Fold(["teams", "distribute"], {"collapse": 0}).expected_value
        'N0'
        >>> Fold(["teams", "distribute"], {"collapse": 2}).expected_value
        'N0*N1'
        >>> Fold(["teams", "parallel"], {"collapse": 1}).expected_value
        '1'
        """

        if not self.loop_construct_number:
            return "1"

        return "*".join(l.N for l in chain.from_iterable(self.region_loop_construct))

    @cached_property
    def is_valid_test(self):
        """
        >>> Fold(["teams", "distribute"], {"collapse": 0, "test_type": "atomic"}).is_valid_test
        True
        >>> Fold(["teams", "distribute", "simd"], {"collapse": 0, "test_type": "atomic"}).is_valid_test
        False
        """
        # Cannot use atomic inside simd
        return not (self.test_type == "atomic" and any(p.has("simd") for p in self.path))

    @cached_property
    def template_location(self):
        return f"hierarchical_parallelism.{self.ext}.jinja2"


class Memcopy(Path):
    @cached_property
    def index(self):
        """
        >>> Memcopy(["for"], {"data_type": "float", "collapse": 1}).index
        'i0'
        >>> Memcopy(["for"], {"data_type": "float", "collapse": 2}).index
        'i1+N1*(i0)'
        >>> Memcopy(["for"], {"data_type": "float", "collapse": 3}).index
        'i2+N2*(i1+N1*(i0))'
        >>> Memcopy(["for"], {"data_type": "float", "collapse": 4}).index
        'i3+N3*(i2+N2*(i1+N1*(i0)))'
        >>> Memcopy(["for"], {"data_type": "REAL", "collapse": 0}).index
        'i0-1+1'
        >>> Memcopy(["for"], {"data_type": "REAL", "collapse": 2}).index
        'i1-1+N1*(i0-1)+1'
        """

        def fma_idx(n, offset=0):
            idx = f"i{n}-{offset}" if offset else f"i{n}"

            if n == 0:
                return idx
            return f"{idx}+N{n}*({fma_idx(n-1,offset)})"

        if self.language == "cpp":
            return fma_idx(self.loop_construct_number - 1)
        else:
            return f"{fma_idx(self.loop_construct_number-1,1)}+1"

    @cached_property
    def problem_size(self):
        """
        >>> Memcopy(["teams", "distribute"], {"collapse": 0}).problem_size
        'N0'
        >>> Memcopy(["teams", "distribute"], {"collapse": 2}).problem_size
        'N0*N1'
        """

        return "*".join(l.N for l in chain.from_iterable(self.region_loop_construct))

    @cached_property
    def is_valid_test(self):
        """
        >>> Memcopy(["teams", "distribute"], {"collapse": 0}).is_valid_test
        True
        >>> Memcopy(["teams", "parallel"], {"collapse": 0}).is_valid_test
        False
        """

        if not self.balenced or not self.loop_construct_number:
            return False
        return True

    @cached_property
    def template_location(self):
        return f"hierarchical_parallelism.{self.ext}.jinja2"


#                                                  _
# |\/|  _. _|_ |_   _  ._ _   _. _|_ o  _  _. |   |_    ._   _ _|_ o  _  ._
# |  | (_|  |_ | | (/_ | | | (_|  |_ | (_ (_| |   | |_| | | (_  |_ | (_) | |
#
class ccomplex(object):
    def __init__(self, a, b):
        self.real = a
        self.img = b

    def __str__(self):
        return f"{self.real}, {self.img}"


class Argv:
    def __init__(self, t, attr, argv):
        self.T = TypeSystem(t)
        self.attr = attr
        self.name = argv
        self.val = None

    @cached_property
    def is_argv(self):
        return self.attr == "in" or (self.attr == "out" and self.T.is_pointer)

    def argv_name(self, suffix):
        if self.attr == "in":
            return self.name
        elif self.attr == "out" and self.T.is_pointer:
            return f"&{self.name}_{suffix}"
        else:
            raise NotImplemented(f"{self.name} is not yet implemented as parameters of function")

    @cached_property
    def name_host(self):
        return f"{self.name}_host"

    @cached_property
    def name_device(self):
        return f"{self.name}_device"

    @cached_property
    def argv_host(self):
        return self.argv_name("host")

    @cached_property
    def argv_device(self):
        return self.argv_name("device")

    @cached_property
    def is_output(self):
        return self.attr == "out"

    @cached_property
    def is_input(self):
        return self.attr == "in"


class Math:

    T_to_values = {
        "bool": [True],
        "float": [0.42, 4.42],
        "REAL": [0.42, 4.42],
        "long int": [1],
        "unsigned": [1],
        "double": [0.42, 4.42],
        "DOUBLE PRECISION": [0.42, 4.42],
        "int": [1, 0, 2],
        "INTEGER": [1, 0, 2],
        "long long int": [1],
        "long double": [0.42, 4.42],
        "complex<float>": [ccomplex(0.42, 0.0), ccomplex(4.42, 0.0)],
        "COMPLEX": [ccomplex(0.42, 0.0), ccomplex(4.42, 0.0)],
        "complex<double>": [ccomplex(0.42, 0.0), ccomplex(4.42, 0.0)],
        "DOUBLE COMPLEX": [ccomplex(0.42, 0.0), ccomplex(4.42, 0.0)],
        "complex<long double>": [ccomplex(0.42, 0.0), ccomplex(4.42, 0.0)],
        "const char*": [None],
    }

    def __init__(self, name, T, attr, argv, domain, language="cpp"):
        self.name = name
        if not argv:
            argv = [f"{j}{i}" for i, j in enumerate(attr)]
        self.language = language
        self.l = self.create_l(T, attr, argv, domain)

    @cached_property
    def ext(self):
        if self.language == "cpp":
            return "cpp"
        elif self.language == "fortran":
            return "F90"
        return NotImplementedError

    def create_l(self, T, attr, argv, domain):
        l = [Argv(t, a, b) for t, a, b in zip(T, attr, argv)]

        l_input = [t for t in l if t.is_input]
        # Got all the possible value of the input
        l_input_name = [t.name for t in l_input]
        l_input_values = [Math.T_to_values[t.T.T] for t in l_input]

        from itertools import product

        for l_input_value in product(*l_input_values):
            if not domain:
                break

            d = {name: value for name, value in zip(l_input_name, l_input_value)}
            from math import isinf, isnan

            d["isinf"] = isinf
            d["isnan"] = isnan

            if eval(domain, d):
                break

        for t, v in zip(l_input, l_input_value):
            t.val = v
        return l

    @cached_property
    def filename(self):
        n = "_".join([self.name] + [t.T.serialized for t in self.l])
        return f"{n}.{self.ext}"

    @cached_property
    def scalar_output(self):
        os = [l for l in self.l if l.is_output and not l.T.is_pointer]
        if os:
            assert len(os) == 1
            return [l for l in self.l if l.is_output and not l.T.is_pointer].pop()
        else:
            return None

    @cached_property
    def use_long(self):
        return any(t.T.is_long for t in self.l)

    @cached_property
    def have_complex(self):
        return any(t.T.category == "complex" for t in self.l)

    @cached_property
    def template_rendered(self):

        # We don't handle in pointer
        if any(t.T.is_pointer and t.is_input for t in self.l):
            return None

        template = templateEnv.get_template(f"mathematical_function.{self.ext}.jinja2")

        str_ = template.render(name=self.name, l_argv=self.l, scalar_output=self.scalar_output, have_complex=self.have_complex)
        return format_template(str_, self.language)


#  -
# /   _   _|  _     _   _  ._   _  ._ _. _|_ o  _  ._
# \_ (_) (_| (/_   (_| (/_ | | (/_ | (_|  |_ | (_) | |
#                   _|
#


def gen_mf(d_arg):

    std = d_arg["standart"]
    cmplx = d_arg["complex"]

    if std.startswith("cpp") or std == "gnu":
        language = "cpp"
        if cmplx:
            f = "cmath_complex_synopsis.json"
        else:
            f = "cmath_synopsis.json"
    elif std.startswith("F"):
        language = "fortran"
        f = "f77math_synopsis.json"

    with open(os.path.join(dirname, "config", f), "r") as f:
        math_json = json.load(f)

    if d_arg["long"] and language == "fortran":
        return False

    name_folder = [std] + [k for k, v in d_arg.items() if v == True]
    folder = os.path.join("test_src", language, "mathematical_function", "-".join(name_folder))
    print(f"Generating {folder}")

    os.makedirs(folder, exist_ok=True)

    with open(os.path.join(folder, "Makefile"), "w") as f:
        f.write(templateEnv.get_template(f"Makefile.jinja2").render(ext="cpp" if language == "cpp" else "F90"))

    std = f"{std}_complex" if cmplx else std
    if std not in math_json:
        return False

    for name, Y in math_json[std].items():
        lattribute = Y["attribute"]
        lT = Y["type"]
        largv = Y["name"] if "name" in Y else []
        ldomain = Y["domain"] if "domain" in Y else []

        for T, attr, argv, domain in zip_longest(lT, lattribute, largv, ldomain):
            m = Math(name, T, attr, argv, domain, language)
            if ((m.use_long and d_arg["long"]) or (not m.use_long and not d_arg["long"])) and m.template_rendered:
                with open(os.path.join(folder, m.filename), "w") as f:
                    f.write(m.template_rendered)


def gen_hp(d_arg, omp_construct, asked_combinaison):
    if not asked_combinaison(d_arg):
        return False

    t = TypeSystem(d_arg["data_type"])
    # Avoid the user reduction is only valid for cpp complex reduction code
    if d_arg["no_user_defined_reduction"]:
        if t.language != "cpp" or t.category != "complex" or d_arg["test_type"] != "reduction":
            return False

    # Paired_pragmas only valid for fortran code
    if d_arg["paired_pragmas"] and t.language != "fortran":
        return False

    # OpenMP doesn't support Complex Atomic
    if t.category == "complex" and d_arg["test_type"] == "atomic":
        return False

    name_folder = [d_arg["test_type"], t.serialized] + sorted([k for k, v in d_arg.items() if v is True])
    if d_arg["collapse"] != 0:
        name_folder += [f"collapse_n{d_arg['collapse']}"]

    folder = os.path.join("test_src", t.language, "hierarchical_parallelism", "-".join(name_folder))
    print(f"Generating {folder}")
    os.makedirs(folder, exist_ok=True)

    with open(os.path.join(folder, "Makefile"), "w") as f:
        f.write(templateEnv.get_template(f"Makefile.jinja2").render(ext="cpp" if t.language == "cpp" else "F90"))

    if d_arg["test_type"] in ("reduction", "atomic"):
        Constructor = Fold
    elif d_arg["test_type"] in ("memcopy",):
        Constructor = Memcopy

    for path in omp_construct:
        if d_arg["host_threaded"]:
            path = ["parallel for"] + path
        Constructor(path, d_arg).write_template_rendered(folder)


#
# ___
#  |  ._  ._     _|_   |   _   _  o  _
# _|_ | | |_) |_| |_   |_ (_) (_| | (_
#         |                    _|
#
def check_validy_arguments(possible_values, values, type_):
    wrong_value = set(values) - set(possible_values)
    if wrong_value:
        print(ovo_usage)
        print(f"{wrong_value} are not valid {type_}. Please choose in {possible_values}")
        sys.exit()


import argparse


class EmptyIsTrue(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        if len(values) == 0:
            values = [True]
        setattr(namespace, self.dest, values)


class EmptyIsAllTestType(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        possible_values = ["atomic", "reduction", "memcopy"]
        if len(values) == 0:
            values = possible_values
        check_validy_arguments(possible_values, values, "test type")
        setattr(namespace, self.dest, values)


class EmptyIsSinglePrecision(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        possible_values = ["float", "complex<float>", "double", "complex<double>", "REAL", "COMPLEX", "DOUBLE PRECISION", "DOUBLE COMPLEX"]
        if len(values) == 0:
            values = ["float", "REAL"]
        check_validy_arguments(possible_values, values, "data type")
        setattr(namespace, self.dest, values)


class EmptyIsOldStandart(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        possible_values = ["cpp11", "cpp17", "cpp20", "F77"]
        if len(values) == 0:
            values = ["cpp11", "F77"]
        check_validy_arguments(possible_values, values, "Standart")
        setattr(namespace, self.dest, values)


class EmptyIsOne(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        if not values:
            values = [1]
        setattr(namespace, self.dest, values)


def EvalArg(v, msg="Boolean value expected."):
    try:
        return eval(v)
    except:
        raise argparse.ArgumentTypeError(msg)


if __name__ == "__main__":
    with open(os.path.join(dirname, "template", "ovo_usage.txt")) as f:
        ovo_usage = f.read()

    parser = argparse.ArgumentParser(usage=ovo_usage)

    action_parsers = parser.add_subparsers(dest="command")

    # ~
    # tiers
    # ~
    tiers_parser = action_parsers.add_parser("tiers")
    tiers_parser.add_argument("tiers", type=int, nargs="+")

    # ~
    # hierarchical_parallelism
    # ~
    hp_parser = action_parsers.add_parser("hierarchical_parallelism")

    hp_parser.add_argument("--test_type", nargs="*", action=EmptyIsAllTestType)
    hp_parser.add_argument("--data_type", nargs="*", action=EmptyIsSinglePrecision)
    hp_parser.add_argument("--collapse", nargs="*", action=EmptyIsOne, type=lambda l: EvalArg(l, "integer value is expected"))
    hp_parser.add_argument("--append", action="store_true")
    # Boolean test
    for opt in ("loop_pragma", "paired_pragmas", "no_user_defined_reduction", "host_threaded", "intermediate_result"):
        hp_parser.add_argument(f"--{opt}", nargs="*", action=EmptyIsTrue, type=EvalArg)

    # ~
    # mathematical_function
    # ~
    mf_parser = action_parsers.add_parser("mathematical_function")
    mf_parser.add_argument("--standart", nargs="*", action=EmptyIsOldStandart)

    mf_parser.add_argument("--complex", nargs="*", action=EmptyIsTrue, type=EvalArg)
    mf_parser.add_argument("--long", nargs="*", action=EmptyIsTrue, type=EvalArg)
    mf_parser.add_argument("--append", action="store_true")

    # ~
    # Default
    # ~
    d_hp = {
        "test_type": {"atomic", "reduction", "memcopy"},
        "data_type": {"float", "REAL"},
        "loop_pragma": {False},
        "paired_pragmas": {False},
        "no_user_defined_reduction": {False},
        "host_threaded": {False},
        "intermediate_result": {False},
        "collapse": {0},
        "append": False,
    }

    d_mf = {"standart": {"cpp11", "F77"}, "complex": {True, False}, "long": {False}, "append": False}

    # ~
    # Parsing logic
    # ~
    p = parser.parse_args()

    # By default we use 'tiers 1'
    if not p.command:
        p.command = "tiers"
        p.tiers = [1]

    # The asked_combinaison, is a function used to filter in the caraterion product of argument
    # We use it in Tiers 2 to limite the number of product.

    # Tiers logic
    if p.command == "tiers":
        if p.tiers[0] >= 1:
            d_hp["data_type"] |= {"complex<double>", "DOUBLE COMPLEX"}
            asked_combinaison = lambda d: True

        if p.tiers[0] >= 2:
            d_hp["intermediate_result"] |= {True}
            d_hp["collapse"] |= {
                2,
            }
            d_hp["host_threaded"] |= {True}
            d_hp["paired_pragmas"] |= {True}

            def asked_combinaison(d):
                if d["intermediate_result"] and d["test_type"] != "atomic":
                    return False
                elif d["collapse"] and d["test_type"] != "memcopy":
                    return False
                elif d["host_threaded"] and (d["intermediate_result"] or d["collapse"]):
                    return False
                elif d["paired_pragmas"] and ( d["test_type"] != "reduction" or d["data_type"] != "REAL" or d["host_threaded"] ):
                    return False
                else:
                    return True

        if p.tiers[0] >= 3:
            d_hp["loop_pragma"] |= {True}
            d_hp["data_type"] |= {"double", "complex<float>", "DOUBLE PRECISION", "COMPLEX"}
            d_mf["standart"] |= {"cpp17"}
            asked_combinaison = lambda d: True

        l_args = [("hierarchical_parallelism", d_hp), ("mathematical_function", d_mf)]

    # Overwrite the default with the user values
    elif p.command in ("hierarchical_parallelism", "mathematical_function"):
        d = d_hp if p.command == "hierarchical_parallelism" else d_mf

        for k, v in vars(p).items():
            if k in d and v is not None:
                d[k] = v
        l_args = [(p.command, d)]
        asked_combinaison = lambda d: True

    # ~
    # Generate tests for cartesian product of options
    # ~
    with open(os.path.join(dirname, "config", "omp_struct.json"), "r") as f:
        omp_construct = combinations_construct(json.load(f))

    for type_, d_args in l_args:

        if not d_args.pop("append"):
            print(f"Removing ./tests_src/{{cpp,fortram}}/{type_} tests ...")
            shutil.rmtree(f"./test_src/cpp/{type_}", ignore_errors=True)
            shutil.rmtree(f"./test_src/fortran/{type_}", ignore_errors=True)

        k = d_args.keys()
        for p in product(*d_args.values()):
            d = {k: v for k, v in zip(k, p)}
            if type_ == "hierarchical_parallelism":
                gen_hp(d, omp_construct, asked_combinaison)

            else:
                gen_mf(d)
