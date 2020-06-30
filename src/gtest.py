#!/usr/bin/env python3
import jinja2, json, os, shutil, sys, math
from itertools import tee, zip_longest, product, chain, zip_longest
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

    from functools import update_wrapper

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
    '''
    >>> list(pairwise(['a','b','c']))
    [('a', 'b'), ('b', 'c')]
    '''
    a, b = tee(iterable)
    next(b, None)
    return zip(a, b)


def format_template(str_, language):
    """
    - Remove empty line.
    - Right strip
    - Split Fortran line 
    """

    def split_fortran_line(line, max_width=100):
        '''
        To be improved and cleaned.
        Don't work if we need to split line in more than one line
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
def combinations_construct(tree_config_path, path=["root"]):
    """
    >>> combinations_construct({"root": ["target", "target teams"], 
    ...                         "target": ["teams"], 
    ...                         "target teams": [], "teams": []})
    [['target'], ['target', 'teams'], ['target teams']]
    """

    # Remove the 'root' path
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

    def has_construct(self,str_):
        """
        >>> Pragma("target teams distribute").has_construct("loop-associated")
        True
        >>> Pragma("target teams distribute").has_construct("target")
        True
        >>> Pragma("target teams distribute").has_construct("loop")
        False
        """

        if str_ == "loop-associated":
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


#                                        _
# |_| o  _  ._ _. ._ _ |_  o  _  _. |   |_) _. ._ _. | |  _  | o  _ ._ _
# | | | (/_ | (_| | (_ | | | (_ (_| |   |  (_| | (_| | | (/_ | | _> | | |
#

class HP: #^(;,;)^
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
        >>> HP(None, {"data_type": "float"}).language
        'cpp'
        >>> HP(None, {"data_type": "REAL"}).language
        'fortran'
        """
        return self.T.language

    @cached_property
    def path(self):
        """
        >>> HP(["parallel for"], {}).path
        [parallel for]
        >>> HP(["parallel", "loop_for"], {}).path
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
        >>> HP(["parallel for", "simd"], {}).flatten_target_path
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
        >>> HP(["parallel", "for"], {"data_type": "float"}).name
        'parallel__for'
        >>> HP(["parallel for", "simd"], {"data_type": "REAL"}).name
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
        >>> HP(None, {"data_type": "float"}).ext
        'cpp'
        >>> HP(None, {"data_type": "DOUBLE PRECISION"}).ext
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
        >>> HP(["parallel", "for"], {"data_type": "float"}).filename
        'parallel__for.cpp'
        >>> HP(["parallel", "loop_for"], {"data_type": "float"}).filename
        'parallel__loop.cpp'
        >>> HP(["parallel for", "simd"], {"data_type": "REAL"}).filename
        'parallel_do__simd.F90'
        """
        return f"{self.name}.{self.ext}"


    def single(self,p):
        '''
        >>> HP(["teams", "distribute"], {}).single("teams")
        False
        >>> HP(["teams", "parallel", "loop"], {}).single("teams")
        True
        >>> HP(["parallel for", "target parallel"], {}).single("parallel")
        True
        >>> HP(["target teams", "parallel loop"], {}).single("parallel")
        False
        '''

        if p == "teams":
            spouses = ("distribute", "loop")
        elif p == "parallel":
            spouses = ("for", "loop")

        # Because of `loop` we need to check pair-wize
        return any(i.has_construct(p) and not j in spouses for i, j in pairwise(self.flatten_target_path + [None]))

    @cached_property
    def balenced(self):
        """
        >>> HP(["parallel", "for"], {}).balenced
        True
        >>> HP(["teams", "loop", "parallel"], {}).balenced
        False
        """
        return not any(map(self.single,("teams","parallel")))

    @cached_property
    def unroll_factor(self):
        return max(1,self.collapse)

    @cached_property
    def associated_loops_number(self):
        """
        >>> HP(["teams distribute parallel for"], {"collapse": 0}).associated_loops_number
        1
        >>> HP(["teams", "parallel"], {"collapse": 0}).associated_loops_number
        0
        >>> HP(["teams distribute", "parallel for"], {"collapse": 2}).associated_loops_number
        4
        """
        return sum(p.has_construct("loop-associated") for p in self.path) * self.unroll_factor

    @cached_property
    def l_nested_constructs(self):
        """
        >>> HP(["target"], {}).l_nested_constructs
        [[target]]
        >>> HP(["target teams distribute"], {}).l_nested_constructs
        [[target teams distribute]]
        >>> HP(["target", "teams", "distribute"], {}).l_nested_constructs
        [[target, teams, distribute]]
        >>> HP(["target", "teams", "distribute", "parallel", "for", "simd"], {}).l_nested_constructs
        [[target, teams, distribute], [parallel, for], [simd]]
        >>> HP(["target teams", "parallel"], {}).l_nested_constructs
        [[target teams], [parallel]]
        >>> HP(["target", "parallel", "for"], {}).l_nested_constructs
        [[target, parallel, for]]
        >>> HP(["parallel", "for", "target", "teams"], {}).l_nested_constructs
        [[parallel, for], [target, teams]]
        >>> HP(["target", "teams", "loop", "parallel", "loop", "simd"], {}).l_nested_constructs
        [[target, teams, loop], [parallel, loop], [simd]]
        >>> HP(["target", "teams", "parallel", "simd"], {"collapse": 0}).l_nested_constructs
        [[target, teams], [parallel], [simd]]
        """

        l, l_tmp = [], []
        for i, j in pairwise(self.path + ["sentinel"]):
            tail_i = Pragma(i.split()[-1])
            head_j = Pragma(j.split()[0])

            l_tmp.append(i)
            if (tail_i.has_construct("loop-associated") or (tail_i.has_construct("generator") and not head_j.has_construct("worksharing"))) or (tail_i.has_construct("target") and head_j == "sentinel"):
                l.append(l_tmp[:])
                l_tmp = []

        return l

    @cached_property
    def regions_counter(self):
        """
        >>> HP(["target teams distribute"], {"collapse": 0, "intermediate_result": False}).regions_counter
        ['counter_N0']
        >>> HP(["target"], {"collapse": 0, "intermediate_result": False}).regions_counter
        ['counter_target']
        >>> HP(["target teams"], {"collapse": 0, "intermediate_result": False}).regions_counter
        ['counter_teams']
        >>> HP(["target", "teams", "parallel"], {"collapse": 0, "intermediate_result": True}).regions_counter
        ['counter_teams', 'counter_parallel']
        >>> HP(["target", "teams", "parallel for"], {"collapse": 0, "intermediate_result": True}).regions_counter
        ['counter_teams', 'counter_N0']
        >>> HP(["target teams distribute", "parallel for"], {"collapse": 0, "intermediate_result": True}).regions_counter
        ['counter_N0', 'counter_N1']
        >>> HP(["target teams distribute", "parallel for"], {"collapse": 2, "intermediate_result": True}).regions_counter
        ['counter_N0', 'counter_N2']
        """
        l, i = [], 0
        for *_, tail in self.l_nested_constructs:
            if tail.has_construct("loop-associated"):
                l.append(f"counter_N{i}")
                i += self.unroll_factor
            else:
                l.append(f"counter_{tail.split().pop()}")

        # In the case of local tests,  we will use only one variable to do our work.
        # All the counter should refer to the first one
        if not self.intermediate_result:
            return [l[0]] * len(self.l_nested_constructs)
        return l

    @cached_property
    def regions_associated_loop(self):
        """
        >>> HP(["target teams distribute"], {"collapse": 0}).regions_associated_loop
        [[Idx(i='i0', N='N0', v=262144)]]
        >>> HP(["target teams distribute", "parallel"], {"collapse": 0}).regions_associated_loop
        [[Idx(i='i0', N='N0', v=262144)], []]
        >>> HP(["target teams distribute", "parallel for"], {"collapse": 0}).regions_associated_loop
        [[Idx(i='i0', N='N0', v=512)], [Idx(i='i1', N='N1', v=512)]]
        >>> HP(["target teams distribute"], {"collapse": 2}).regions_associated_loop
        [[Idx(i='i0', N='N0', v=512), Idx(i='i1', N='N1', v=512)]]
        """

        # Try to event out the loop iteration number
        if self.associated_loops_number:
            loop_tripcount = max(1, math.ceil(math.pow(64 * 64 * 64, 1.0 / self.associated_loops_number)))
        else:
            loop_tripcount = None

        l, i = [], 0
        Idx = namedtuple("Idx", "i N v")
        for *_, tail in self.l_nested_constructs:

            l_tmp = []
            if tail.has_construct("loop-associated"):
                for j in range(self.unroll_factor):
                    l_tmp.append(Idx(f"i{i}", f"N{i}", loop_tripcount))
                    i += 1

            l.append(l_tmp)
        return l

    @cached_property
    def regions_increment(self):
        """
        >>> HP(["target"], {"collapse": 0, "intermediate_result": False}).regions_increment
        [Inc(v='counter_target', i='1.', j=None)]
        >>> HP(["target teams distribute"], {"collapse": 0, "intermediate_result": False}).regions_increment
        [Inc(v='counter_N0', i='1.', j=None)]
        >>> HP(["target teams distribute", "parallel", "for"], {"collapse": 2, "intermediate_result": True}).regions_increment
        [Inc(v='counter_N0', i='counter_N2', j=None), Inc(v='counter_N2', i='1.', j=None)]
        >>> HP(["target teams"], {"collapse": 0, "intermediate_result": False}).regions_increment
        [Inc(v='counter_teams', i='1.', j='omp_get_num_teams()')]
        """

        l = []
        Inc = namedtuple("Inc", "v i j")
        for (counter, counter_next), region in zip(pairwise(self.regions_counter + ["1."]), self.l_nested_constructs):
            tail = region[-1]
            if not self.intermediate_result and self.single("teams") and self.single("parallel"):
                j = "( omp_get_num_teams() * omp_get_num_threads() )"
            elif not self.intermediate_result and self.single("teams"):
                j = "omp_get_num_teams()"
            elif not self.intermediate_result and self.single("parallel"):
                j = "omp_get_num_threads()"
            elif tail.has_construct("loop-associated"):
                j = None
            elif tail.has_construct("teams"):
                j = "omp_get_num_teams()"
            elif tail.has_construct("parallel"):
                j = "omp_get_num_threads()"
            elif tail.has_construct("target"):
                j = None
            else:
                raise ValueError(tail)
            l.append(Inc(counter,counter_next,j))
        return l

    @cached_property
    def regions_additional_pragma(self):
        """
        >>> HP(["target teams"], {"test_type": "atomic", "intermediate_result": False, "collapse": 0}).regions_additional_pragma
        [['map(tofrom: counter_teams)']]
        >>> HP(["target teams"], {"test_type": "memcopy", "intermediate_result": False, "collapse": 0, "data_type": "float","host_threaded": False}).regions_additional_pragma
        [['map(to: pS[0:size]) map(from: pD[0:size])']]
        >>> HP(["target teams"], {"test_type": "memcopy", "intermediate_result": False, "collapse": 0, "data_type": "REAL", "host_threaded": True}).regions_additional_pragma
        [['map(to: src) map(tofrom: dst)']]
        >>> HP(["target teams distribute"], {"test_type": "reduction", "intermediate_result": False, "collapse": 3}).regions_additional_pragma
        [['map(tofrom: counter_N0) reduction(+: counter_N0) collapse(3)']]
        """

        def additional_pragma(counter, pragma):
            construct = []
            if pragma.has_construct("target"):
                if "memcopy" in self.test_type:
                    dst_pragma = "from" if not self.host_threaded  else 'tofrom'
                    if self.language == "cpp":
                        construct += [f"map(to: pS[0:size]) map({dst_pragma}: pD[0:size])"]
                    elif self.language == "fortran":
                        construct += [f"map(to: src) map({dst_pragma}: dst)"]
                else:
                        construct += [f"map(tofrom: {counter})"]
            if "reduction" in self.test_type and pragma.can_be_reduced:
                construct += [f"reduction(+: {counter})"]
            if self.collapse and pragma.has_construct("loop-associated"):
                construct += [f"collapse({self.collapse})"]
            return " ".join(construct)

        l = []
        for counter, region in zip(self.regions_counter, self.l_nested_constructs):
            l.append( [additional_pragma(counter,pragma) for pragma in region] )
        return l

    @cached_property
    def tripcount(self):
        """
        >>> HP(["teams", "distribute"], {"collapse": 0}).tripcount
        'N0'
        >>> HP(["teams", "distribute"], {"collapse": 2}).tripcount
        'N0*N1'
        >>> HP(["teams", "parallel"], {"collapse": 1}).tripcount
        '1'
        """

        if not self.associated_loops_number:
            return "1"

        return "*".join(l.N for l in chain.from_iterable(self.regions_associated_loop))

    @cached_property
    def inner_index(self):
        """
        >>> HP(["for"], {"data_type": "float", "collapse": 1}).inner_index
        'i0'
        >>> HP(["for"], {"data_type": "float", "collapse": 2}).inner_index
        'i1+N1*(i0)'
        >>> HP(["for"], {"data_type": "float", "collapse": 3}).inner_index
        'i2+N2*(i1+N1*(i0))'
        >>> HP(["for"], {"data_type": "float", "collapse": 4}).inner_index
        'i3+N3*(i2+N2*(i1+N1*(i0)))'
        >>> HP(["for"], {"data_type": "REAL", "collapse": 0}).inner_index
        'i0-1+1'
        >>> HP(["for"], {"data_type": "REAL", "collapse": 2}).inner_index
        'i1-1+N1*(i0-1)+1'
        """

        def fma_idx(n, offset=0):
            idx = f"i{n}-{offset}" if offset else f"i{n}"
            if n == 0:
                return idx
            return f"{idx}+N{n}*({fma_idx(n-1,offset)})"

        idx_loop = self.associated_loops_number - 1 
        if idx_loop < 0:
            return None
        elif self.language == "cpp":
            return fma_idx(idx_loop)
        else:
            return f"{fma_idx(idx_loop,1)}+1"


    @cached_property
    def is_valid_test(self):
        """
        >>> d = {"test_type":"atomic",
        ...      "collapse": 0, 
        ...      "loop_pragma": False, 
        ...      "intermediate_result": False,
        ...      "host_threaded": False}

        >>> HP(["target for"], {**d, 'loop_pragma': True} ).is_valid_test
        False
        >>> HP(["target for"], {**d} ).is_valid_test
        True
        >>> HP(["target teams"], {**d, 'collapse': 2} ).is_valid_test
        False
        >>> HP(["parallel for target teams distribute parallel for"], {**d, 'intermediate_result': True} ).is_valid_test
        False
        >>> HP(["target teams", "parallel loop"], {**d, 'loop_pragma': True} ).is_valid_test
        False
        >>> HP(["target teams", "parallel loop"], {**d, 'loop_pragma': True, 'intermediate_result': True} ).is_valid_test
        True
        >>> HP(["target teams"], d).is_valid_test
        False
        >>> HP(["target teams", "parallel"], {**d, 'test_type':'memcopy'} ).is_valid_test
        False
        """

        # Based on section 2.23 -- Nesting of Regions of the openmp v5.0 specification 
        # We also try to do duplicate tests.

        # If we don't ask for loop pragma we don't want to generate tests who doesn't containt omp loop construct
        if self.loop_pragma ^ any(p.has_construct("loop") for p in self.path):
            return False

        # If people want collapse, we will generate only the test with loop
        elif self.collapse and not self.associated_loops_number:
            return False

        # If people whant some intermediate_result we need at least two 2 l_nested_constructs inside the target
        # Because when we do `host_threaded` we add only one region. The following hack is working
        elif self.intermediate_result and len(self.l_nested_constructs) < (2 + self.host_threaded):
            return False
        
        #>> A loop region corresponding to a loop construct may not contain calls to the OpenMP Runtime API
        elif self.loop_pragma and not any([self.balenced,self.intermediate_result,self.single("parallel")]):
            return False

        # >> distribute, distribute simd, distribute parallel worksharing-loop, 
        #    distribute parallel worksharing-loop SIMD, parallel regions, including any parallel regions arising from combined constructs,
        #    omp_get_num_teams() regions, and omp_get_team_num() regions 
        #    are the only OpenMP regions that may be strictly nested inside the teams region. 
        # That mean atomic cannot be stricly nested inside "teams"...
        elif self.test_type == "atomic" and self.flatten_target_path[-1] == 'teams':
            return False

        # need to have at least one loop and be balenced
        elif self.test_type == "memcopy" and not (self.associated_loops_number and self.balenced):
            return False

        return True

    @cached_property
    def template_rendered(self):

        if not self.is_valid_test:
            return None

        template = templateEnv.get_template(f"hierarchical_parallelism.{self.ext}.jinja2")
        str_ = template.render(**{p: getattr(self, p) for p in dir(self) if p != "template_rendered"})
        return format_template(str_, self.language)

    def write_template_rendered(self, folder):
        if self.template_rendered:
            with open(os.path.join(folder, self.filename), "w") as f:
                f.write(self.template_rendered)

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
        f = "fmath_synopsis.json"

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
    if d_arg["no_user_defined_reduction"] and (t.language != "cpp" or t.category != "complex" or d_arg["test_type"] != "reduction"):
        return False

    # Paired_pragmas only valid for fortran code
    if d_arg["paired_pragmas"] and t.language != "fortran":
        return False

    # OpenMP doesn't support Complex Atomic
    if t.category == "complex" and d_arg["test_type"] == "atomic":
        return False


    '''
    >> The only constructs that may be nested inside a loop region are the loop construct, the parallel construct, 
    the simd construct, and combined constructs for which the first construct is a parallel construct.

    That mean no atomic with loop
    '''
    if d_arg["test_type"] == "atomic" and d_arg["loop_pragma"]:
        return False

    name_folder = [d_arg["test_type"], t.serialized] + sorted([k for k, v in d_arg.items() if v is True])
    if d_arg["collapse"]:
        name_folder += [f"collapse_n{d_arg['collapse']}"]

    folder = os.path.join("test_src", t.language, "hierarchical_parallelism", "-".join(name_folder))
    print(f"Generating {folder}")
    os.makedirs(folder, exist_ok=True)

    with open(os.path.join(folder, "Makefile"), "w") as f:
        f.write(templateEnv.get_template(f"Makefile.jinja2").render(ext="cpp" if t.language == "cpp" else "F90"))

    for path in omp_construct:
        if d_arg["host_threaded"]: path = ["parallel for"] + path
        HP(path, d_arg).write_template_rendered(folder)


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
