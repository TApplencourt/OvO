#!/usr/bin/env python3
import jinja2, json, os, shutil, sys, math
from itertools import tee, product, chain, zip_longest, count
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
#templateEnv.filters.update(any=any)
# Custom filter method
def get_idx(s, idx, attribute=None):
    if not attribute:
        return f"{s}[{idx}]"
    else:
        return f"{getattr(s,attribute)}[{idx}]"

def in_region(p,region):
    return any(p in ps for ps in region)
templateEnv.globals.update(in_region=in_region)
templateEnv.filters['get_idx']=get_idx
#templateEnv.filters['in_region']=in_region

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
    """
    >>> list(pairwise(['a','b','c']))
    [('a', 'b'), ('b', 'c')]
    """
    a, b = tee(iterable)
    next(b, None)
    return zip(a, b)


def format_template(str_, language):
    """
    - Remove empty line.
    - Right strip
    - Split Fortran line
    - Remove double space
    """
    import re

    def split_fortran_line(line, max_width=100):
        """
        To be improved and cleaned.
        Don't work if we need to split line in more than one line
        """
        prefix = "&\n!$OMP&" if line.lstrip().startswith("!$OMP") else "&\n&"
        l_chunk = range(len(line) // max_width)

        l = list(line)
        for i in l_chunk:
            l.insert((i + 1) * max_width + 3 * i, prefix)
        return "".join(l)


    l_line = [line.rstrip() for line in str_.split("\n") if line.strip()]
    l_line = [re.sub(r"(\S) {2,}",r"\1 ",line) for line in l_line]
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

    def has_construct(self, str_):
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
        elif str_ == "concurency-associated":
            return any(p in self.pragma for p in ("distribute", "for", "loop"))
        elif str_ == "ordered":
            # Only `!$omp distribute parallel do` and `!$omp distribute parallel do simd` cannot have  ordered
            #!$omp team distribute parallel do` can
            return "for" in self.pragma and ('teams' in self.pragma or not 'distribute' in self.pragma)
        elif str_ == "generator":
            return any(p in self.pragma for p in ("teams", "parallel"))
        else:
            return str_ in self.pragma

    @cached_property
    def can_be_reduced(self):
        return any(p in self.pragma for p in ("teams", "parallel", "simd"))

    @cached_property
    def can_be_privatized(self):
        return any(p in self.pragma for p in ("target", "teams", "parallel", "simd"))

    def __repr__(self):
        return self.pragma


#                                        _
# |_| o  _  ._ _. ._ _ |_  o  _  _. |   |_) _. ._ _. | |  _  | o  _ ._ _
# | | | (/_ | (_| | (_ | | | (_ (_| |   |  (_| | (_| | | (/_ | | _> | | |
#


class HP:  # ^(;,;)^
    def __init__(self, path_raw, d_arg):
        self.path_raw = path_raw

        # Explicit is better than implicit.
        # So this is ugly... But really usefull when testing
        # hp_d_possible_value is a global variable who contain as a key all the possible option
        for k in hp_d_possible_value:
            setattr(self, k, False)

        setattr(self, "collapse", 0)
        setattr(self, "tripcount", 9)

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
            head = lambda p: p.split("_").pop(0)
            return Pragma(" ".join(map(head, l_pragma)))

        return [sanitize(p) for p in self.path_raw]

    @cached_property
    def flatten_target_path(self):
        """
        >>> HP(["parallel for", "simd"], {}).flatten_target_path
        [parallel, for, simd]
        """
        l = list(map(Pragma, chain.from_iterable(map(str.split, self.path))))
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

    def single(self, p):
        """
        >>> HP(["teams", "distribute"], {}).single("teams")
        False
        >>> HP(["teams", "parallel", "loop"], {}).single("teams")
        True
        >>> HP(["parallel for", "target parallel"], {}).single("parallel")
        True
        >>> HP(["target teams", "parallel loop"], {}).single("parallel")
        False
        """

        if p == "teams":
            spouses = ("distribute", "loop")
        elif p == "parallel":
            spouses = ("for", "loop")

        # Because of `loop` we need to check pair-wize
        return any(i.has_construct(p) and not j in spouses for i, j in pairwise(self.flatten_target_path + [None]))

    @cached_property
    def single_number(self):
        """
        >>> HP(["parallel", "for"], {}).single_number
        0
        >>> HP(["teams", "loop", "parallel"], {}).single_number
        1
        """
        return sum(map(self.single, ("teams", "parallel")))

    @cached_property
    def balenced(self):
        """
        >>> HP(["parallel", "for"], {}).balenced
        True
        >>> HP(["teams", "loop", "parallel"], {}).balenced
        False
        """
        return single_number == 0

    @cached_property
    def balenced(self):
        """
        >>> HP(["parallel", "for"], {}).balenced
        True
        >>> HP(["teams", "loop", "parallel"], {}).balenced
        False
        """
        return not any(map(self.single, ("teams", "parallel")))

    @cached_property
    def unroll_factor(self):
        return max(1, self.collapse)

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
    def total_loops_number(self):
        """
        >>> HP(["teams distribute parallel for"], {"collapse": 0}).total_loops_number
        1
        >>> HP(["teams", "parallel"], {"collapse": 0}).total_loops_number
        2
        >>> HP(["teams distribute", "parallel"], {"collapse": 2}).total_loops_number
        3
        """
        return self.associated_loops_number + self.single_number

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
            if (tail_i.has_construct("loop-associated") or (tail_i.has_construct("generator") and not head_j.has_construct("concurency-associated"))) or (
                tail_i.has_construct("target") and head_j == "sentinel"
            ):
                l.append(l_tmp[:])
                l_tmp = []

        return l

    @cached_property
    def l_nested_constructs_ironed_out(self):
        # This property will be used to generate the pragma.
        # In the case of on multiple_devices, we don't want so replace it with an empty region
        if self.multiple_devices and not self.host_threaded:
            head, *tail = self.l_nested_constructs
            return [[]] * len(head) + tail
        else:
            return self.l_nested_constructs

    @cached_property
    def regions_counter(self):
        """
        >>> HP(["target teams distribute"], {"collapse": 0}).regions_counter
        ['counter_N0']
        >>> HP(["target"], {"collapse": 0,}).regions_counter
        ['counter_target']
        >>> HP(["target teams"], {"collapse": 0}).regions_counter
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
    def loop_tripcount(self):
        if self.total_loops_number:
            # The total tripcount depend of the number of thread and teams.
            return max(1, math.ceil(math.pow(self.tripcount, 1.0 / self.total_loops_number)))
        else:
            return None

    @cached_property
    def regions_associated_loop(self):
        """
        >>> HP(["target teams distribute"], {"collapse": 0, 'tripcount':4} ).regions_associated_loop
        [[Idx(i='i0', N='N0', v=4)]]
        >>> HP(["target teams distribute", "parallel"], {"collapse": 0, 'tripcount':1}).regions_associated_loop
        [[Idx(i='i0', N='N0', v=1)], []]
        >>> HP(["target teams distribute", "parallel for"], {"collapse": 0, 'tripcount':4}).regions_associated_loop
        [[Idx(i='i0', N='N0', v=2)], [Idx(i='i1', N='N1', v=2)]]
        >>> HP(["target teams", "parallel for"], {"collapse": 0, 'tripcount':4}).regions_associated_loop
        [[], [Idx(i='i0', N='N0', v=2)]]
        >>> HP(["target teams distribute"], {"collapse": 2, 'tripcount':5}).regions_associated_loop
        [[Idx(i='i0', N='N0', v=3), Idx(i='i1', N='N1', v=3)]]
        """
        l, i = [], 0
        Idx = namedtuple("Idx", "i N v")
        for *_, tail in self.l_nested_constructs:

            l_tmp = []
            if tail.has_construct("loop-associated"):
                for j in range(self.unroll_factor):
                    l_tmp.append(Idx(f"i{i}", f"N{i}", self.loop_tripcount))
                    i += 1

            l.append(l_tmp)
        return l

    @cached_property
    def regions_increment(self):
        """
        >>> HP(["target"], {"collapse": 0}).regions_increment
        [Inc(v='counter_target', i='1.', j=None)]
        >>> HP(["target teams distribute"], {"collapse": 0}).regions_increment
        [Inc(v='counter_N0', i='1.', j=None)]
        >>> HP(["target teams distribute", "parallel", "for"], {"collapse": 2, "intermediate_result": True}).regions_increment
        [Inc(v='counter_N0', i='counter_N2', j=None), Inc(v='counter_N2', i='1.', j=None)]
        >>> HP(["target teams"], {"collapse": 0}).regions_increment
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
            l.append(Inc(counter, counter_next, j))
        return l

    @cached_property
    def regions_additional_pragma(self):
        """
        >>> # HP(["target teams"], {"test_type": "atomic_add", "collapse": 0}).regions_additional_pragma
        [['num_teams(9) map(tofrom: counter_teams)']]
        >>> # HP(["target teams","parallel"], {"test_type": "atomic_add", "collapse": 0}).regions_additional_pragma
        [['num_teams(3) map(tofrom: counter_teams)'], ['num_threads(3)']]
        >>> HP(["target teams distribute parallel for"], {"test_type": "ordered", "collapse": 0, "data_type": "float"}).regions_additional_pragma
        [['map(tofrom: counter_N0) ordered']]
        >>> # HP(["target teams"], {"test_type": "reduction_add", "collapse": 0}).regions_additional_pragma
        [['num_teams(9) reduction(+: counter_teams)']]
        >>> HP(["target","teams distribute"], {"test_type": "reduction_add", "collapse": 0}).regions_additional_pragma
        [['map(tofrom: counter_N0)', 'reduction(+: counter_N0)']]
        >>> HP(["target teams distribute"], {"test_type": "reduction_min", "collapse": 0}).regions_additional_pragma
        [['reduction(min: counter_N0)']]
        >>> HP(["target teams distribute"], {"test_type": "reduction_max", "collapse": 0}).regions_additional_pragma
        [['reduction(max: counter_N0)']]
        >>> # HP(["target teams"], {"test_type": "reduction_add", "collapse": 0, "no_implicit_mapping": True}).regions_additional_pragma
        [['num_teams(9) map(tofrom: counter_teams) reduction(+: counter_teams)']]
        >>> # HP(["target teams"], {"test_type": "memcopy", "collapse": 0, "data_type": "float"}).regions_additional_pragma
        [['num_teams(9) map(to: pS[0:size]) map(from: pD[0:size])']]
        >>> HP(["parallel for", "target teams distribute"], {"test_type": "memcopy", "collapse": 0, "data_type": "float", "multiple_devices": True}).regions_additional_pragma
        [[''], ['map(to: pS[(i0)*N1:N1]) map(from: pD[(i0)*N1:N1]) device((i0)%omp_get_num_devices())']]
        >>> HP(["parallel for", "target"], {"test_type": "memcopy", "collapse": 0, "data_type": "float", "multiple_devices": True}).regions_additional_pragma
        [[''], ['map(to: pS[(i0)*1:1]) map(from: pD[(i0)*1:1]) device((i0)%omp_get_num_devices())']]
        >>> HP(["parallel for", "target"], {"test_type": "memcopy", "collapse": 0, "data_type": "REAL", "multiple_devices": True}).regions_additional_pragma
        [[''], ['map(to: src(i0-1+1:i0-1+1)) map(from: dst(i0-1+1:i0-1+1)) device(MOD(i0-1+1,omp_get_num_devices()))']]
        >>> HP(["parallel for", "target teams distribute"], {"test_type": "memcopy", "collapse": 0, "data_type": "REAL", "multiple_devices": True}).regions_additional_pragma
        [[''], ['map(to: src((i0-1+1)*N1:(i0-1+1)*2*N1)) map(from: dst((i0-1+1)*N1:(i0-1+1)*2*N1)) device(MOD(i0-1+1,omp_get_num_devices()))']]
        >>> HP(["parallel for", "target teams distribute"], {"test_type": "memcopy", "collapse": 2, "data_type": "float", "multiple_devices": True}).regions_additional_pragma
        [['collapse(2)'], ['map(to: pS[(i1+N1*(i0))*N2*N3:N2*N3]) map(from: pD[(i1+N1*(i0))*N2*N3:N2*N3]) device((i1+N1*(i0))%omp_get_num_devices()) collapse(2)']]
        >>> HP(["target teams distribute"], {"test_type": "reduction_add", "collapse": 3}).regions_additional_pragma
        [['reduction(+: counter_N0) collapse(3)']]
        """

        def device_directive(i, counter, pragma):
            if pragma.has_construct("target") and self.multiple_devices:
                idx = self.running_index(i * self.unroll_factor)
                if self.language == "cpp":
                    yield f"device(({idx})%omp_get_num_devices())"
                elif self.language == "fortran":
                    yield f"device(MOD({idx},omp_get_num_devices()))"

        def mapping_directive(i, counter, pragma):
            # If we use `target_data` we still map in target
            # This is because of sclalar mapping who are first private by default.
            if not pragma.has_construct("target"):
                return

            if self.test_type.startswith('atomic') or self.test_type == 'ordered':
                yield f"map(tofrom: {counter})"
            elif 'reduction' in self.test_type:
                if pragma == 'target' or self.no_implicit_mapping:
                    yield f"map(tofrom: {counter})"
            else:
                if not (self.host_threaded or self.multiple_devices):
                    if self.language == "cpp":
                        borns = "[0:size]"
                    elif self.language == "fortran":
                        borns = ""
                else:
                    size = self.host_chunk_size(i)
                    idx = self.running_index(i * self.unroll_factor)
                    if self.language == "cpp":
                        size = size if size else "1"
                        borns = f"[({idx})*{size}:{size}]"
                    elif self.language == "fortran":
                        borns = f"(({idx})*{size}:({idx})*2*{size})" if size else f"({idx}:{idx})"

                if self.language == "cpp":
                    yield f"map(to: pS{borns}) map(from: pD{borns})"
                elif self.language == "fortran":
                    yield f"map(to: src{borns}) map(from: dst{borns})"

        def reduction_directive(counter, pragma):
            if "reduction_add" in self.test_type and pragma.can_be_reduced:
                yield f"reduction(+: {counter})"
            elif "reduction_min" in self.test_type and pragma.can_be_reduced:
                yield f"reduction(min: {counter})"
            elif "reduction_max" in self.test_type and pragma.can_be_reduced:
                yield f"reduction(max: {counter})"

        def ordered_directive(pragma):
            if "ordered" in self.test_type and pragma.has_construct("ordered"):
                yield "ordered"

        def collapse_directive(pragma):
            if self.collapse and pragma.has_construct("loop-associated"):
                yield f"collapse({self.collapse})"

        def limit_directive(pragma):
            # We don't sepcify num_teams for now.
            # Indeed it not yet support by the vast majority of compiler
            # When it will be the case, we will remove the call to `omp_set_num_teams` 
            # and use this function            

            #if self.single('teams') and 'teams' in pragma:
            #    yield f"num_teams(1,{self.loop_tripcount})"

            if self.single('parallel') and 'parallel' in pragma:
                yield f"num_threads({self.loop_tripcount})"

        def additional_pragma(i, counter, pragma):
            construct = chain(limit_directive(pragma), mapping_directive(i, counter, pragma), device_directive(i, counter, pragma), reduction_directive(counter, pragma), ordered_directive(pragma), collapse_directive(pragma))
            return " ".join(construct)

        map_region = lambda i, c, r: [additional_pragma(i, c, pragma) for pragma in r]
        return [map_region(i, c, r) for i, c, r in zip(count(), self.regions_counter, self.l_nested_constructs)]

    @cached_property
    def expected_value(self):
        """
        >>> HP(["teams", "distribute"], {"collapse": 0}).expected_value
        'N0'
        >>> HP(["teams", "distribute"], {"collapse": 2}).expected_value
        'N0*N1'
        >>> HP(["teams", "parallel"], {"collapse": 1}).expected_value
        '1'
        """

        if not self.associated_loops_number:
            return "1"

        return "*".join(l.N for l in chain.from_iterable(self.regions_associated_loop))

    def running_index(self, i):
        def fma_idx(n, offset=0):
            idx = f"i{n}-{offset}" if offset else f"i{n}"
            if n == 0:
                return idx
            return f"{idx}+N{n}*({fma_idx(n-1,offset)})"

        idx_loop = i - 1
        if idx_loop < 0:
            return None
        elif self.language == "cpp":
            return fma_idx(idx_loop)
        else:
            return f"{fma_idx(idx_loop,1)}+1"

    def host_chunk_size(self, i):
        return "*".join(l.N for l in chain.from_iterable(self.regions_associated_loop[i:]))

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
        if self.associated_loops_number:
            return self.running_index(self.associated_loops_number)
        else:
            return '0'

    @cached_property
    def is_valid_test(self):
        """
        >>> d = {"test_type":"atomic_add",
        ...      "collapse": 0 }

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
        False
        >>> HP(["target teams"], d).is_valid_test
        False
        >>> HP(["target teams", "parallel"], {**d, 'test_type':'memcopy'} ).is_valid_test
        False
        """

        # Based on section 2.23 -- Nesting of Regions of the openmp v5.0 specification
        # We also try to not duplicate tests.

        # If we don't ask for loop pragma we don't want to generate tests who doesn't containt omp loop construct
        if self.loop_pragma ^ any(p.has_construct("loop") for p in self.path):
            return False

        # If people want collapse, we will generate only the test with for/do loop
        elif self.collapse and not self.associated_loops_number:
            return False

        # If people whant some intermediate_result we need at least two 2 l_nested_constructs inside the target
        # Because when we do `host_threaded` we add only one region. The following hack is working
        elif self.intermediate_result and len(self.l_nested_constructs) < (2 + self.host_threaded):
            return False

        # >> A loop region corresponding to a loop construct may not contain calls to the OpenMP Runtime API
        elif self.loop_pragma and not any([self.balenced, self.intermediate_result, self.single("parallel")]):
            return False

        # >> distribute, distribute simd, distribute parallel worksharing-loop,
        #    distribute parallel worksharing-loop SIMD, parallel regions, including any parallel regions arising from combined constructs,
        #    omp_get_num_teams() regions, and omp_get_team_num() regions
        #    are the only OpenMP regions that may be strictly nested inside the teams region.
        # That mean atomic cannot be stricly nested inside "teams"...
        elif self.test_type.startswith("atomic") and self.flatten_target_path[-1] == "teams":
            return False
        elif self.test_type.startswith("atomic") and self.intermediate_result and self.single("teams"):
            return False

        # Ordered need to have a worksharing or simd pragma in every region and be balenced
        elif self.test_type == "ordered" and not self.intermediate_result and not (all(any(p.has_construct("ordered") for p in r) for r in self.l_nested_constructs) and self.balenced):
            return False
        elif self.test_type == "ordered" and self.intermediate_result:
            return False
        # need to have at least one loop and be balenced
        elif self.test_type == "memcopy" and not (self.associated_loops_number and self.balenced):
            return False

        return True

    @cached_property
    def openmp_api_call(self):
        """
        >>> HP(["target parallel"], {'test_type': 'reduction_add'}).openmp_api_call
        True
        >>> HP(["target parallel for"], {'test_type': 'reduction_add'}).openmp_api_call
        False
        >>> HP(["target parallel"], {'test_type': 'reduction_min'}).openmp_api_call
        False
        """
        return not ( self.test_type in ['reduction_min','reduction_max','atomic_max','atomic_min'] or self.balenced)

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
    def __init__(self, t, attr, argv, simdize):
        self.T = TypeSystem(t)
        self.attr = attr
        self.name = argv
        self.val = None
        self.simdize = simdize

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
    def name_idx(self):
        return f"{self.name}(i)"

    @cached_property
    def name_host(self):
        return f"{self.name}_host"

    @cached_property
    def name_host_idx(self):
        str_ = f"{self.name}_host"
        if not self.simdize:
            return str_
        else:
            return f"{str_}[i]"

    @cached_property
    def name_device(self):
        return f"{self.name}_device"

    @cached_property
    def name_device_idx(self):
        str_ = f"{self.name}_device"
        if not self.simdize:
            return str_
        else:
            return f"{str_}[i]"

    @cached_property
    def map_clause_from(self):
        str_ = f"{self.name}_device"
        if not self.simdize:
            return str_
        else:
            return f"{str_}[0:size]"

    @cached_property
    def map_clause_to(self):
        str_ = f"{self.name}"
        if not self.simdize:
            return str_
        else:
            return f"{str_}[0:size]"

    @cached_property
    def argv_host(self):
        str_ = self.argv_name("host")
        if not self.simdize:
            return str_
        else:
            return f"{str_}[i]"

    @cached_property
    def argv_device(self):
        str_ = self.argv_name("device")
        if not self.simdize:
            return str_
        else:
            return f"{str_}[i]"

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

    def __init__(self, name, T, attr, argv, domain, size, reciprocal, language="cpp", path_raw=['target']):
        self.name = name
        if not argv:
            argv = [f"{j}{i}" for i, j in enumerate(attr)]
        self.language = language
        self.l_argv = self.create_l(T, attr, argv, size != 0, domain)
        self.size = size
        self.reciprocal = reciprocal
        self.path_raw = path_raw

    @cached_property
    def ext(self):
        if self.language == "cpp":
            return "cpp"
        elif self.language == "fortran":
            return "F90"
        return NotImplementedError

    def create_l(self, T, attr, argv, simdsize, domain):
        l = [Argv(t, a, b, simdsize) for t, a, b in zip(T, attr, argv)]

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
        n = "_".join([self.name] + [t.T.serialized for t in self.l_argv])
        return f"{n}.{self.ext}"

    @cached_property
    def scalar_output(self):
        os = [l for l in self.l_argv if l.is_output and not l.T.is_pointer]
        if os:
            assert len(os) == 1
            return [l for l in self.l_argv if l.is_output and not l.T.is_pointer].pop()
        else:
            return None

    @cached_property
    def use_long(self):
        return any(t.T.is_long for t in self.l_argv)

    @cached_property
    def have_complex(self):
        return any(t.T.category == "complex" for t in self.l_argv)

    @cached_property
    def template_rendered(self):

        # We don't handle in pointer
        if any(t.T.is_pointer and t.is_input for t in self.l_argv):
            return None

        template = templateEnv.get_template(f"mathematical_function.{self.ext}.jinja2")
        str_ = template.render(**{p: getattr(self, p) for p in dir(self) if p != "template_rendered"})
        return format_template(str_, self.language)


    @cached_property
    def regions_associated_loop(self):
        return HP(self.path_raw, {}).regions_associated_loop

    @cached_property
    def inner_index(self):
        return HP(self.path_raw, {"language": self.language}).inner_index

    @cached_property
    def l_nested_constructs_ironed_out(self):
        # Pragma only in the first elements. Then empty
        return HP(self.path_raw, {} ).l_nested_constructs_ironed_out        

    @cached_property
    def expected_value(self):
        return  HP(self.path_raw, {} ).expected_value

    @cached_property            
    def regions_additional_pragma(self):
        l_output = [argv.map_clause_from for argv in self.l_argv if argv.is_output]
        l_input = [argv.map_clause_to for argv in self.l_argv if argv.is_output]
        str_ = f"map(tofrom: {', '.join(l_output)})"
        if self.size:
            str_ += f" map(tofrom: {', '.join(l_input)})"
        #We put only pragma on target 
        l = [ ['']*len(i) for i in self.l_nested_constructs_ironed_out ]
        l[0][0] = str_ 
        return l
#  -
# /   _   _|  _     _   _  ._   _  ._ _. _|_ o  _  ._
# \_ (_) (_| (/_   (_| (/_ | | (/_ | (_|  |_ | (_) | |
#                   _|
#


def gen_mf(d_arg):

    std = d_arg["standard"]
    cmplx = d_arg["complex"]
    size = d_arg["simdize"]
 
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

    name_folder = [std] + sorted([k for k, v in d_arg.items() if v is True])
    if d_arg["simdize"]:
        name_folder += [f"simdize_{d_arg['simdize']}"]

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
        reciprocal = Y["reciprocal"] if "reciprocal" in Y else False
        ldomain = Y["domain"] if "domain" in Y else []
        for T, attr, argv, domain in zip_longest(lT, lattribute, largv, ldomain):
            m = Math(name, T, attr, argv, domain, size, reciprocal, language)
            if ((m.use_long and d_arg["long"]) or (not m.use_long and not d_arg["long"])) and m.template_rendered:
                with open(os.path.join(folder, m.filename), "w") as f:
                    f.write(m.template_rendered)


def gen_hp(d_arg, omp_construct):
    t = TypeSystem(d_arg["data_type"])
    # Avoid 'user reduction' is only valid for cpp complex reduction code
    if d_arg["no_user_defined_reduction"] and (t.language != "cpp" or t.category != "complex" or not "reduction" in d_arg["test_type"]):
        return False

    # Paired_pragmas only valid for fortran code
    if d_arg["paired_pragmas"] and t.language != "fortran":
        return False

    # OpenMP doesn't support Complex Atomic
    if t.category == "complex" and d_arg["test_type"].startswith("atomic"):
        return False

    """
    >> The only constructs that may be nested inside a loop region are the loop construct, the parallel construct,
    the simd construct, and combined constructs for which the first construct is a parallel construct.

    That mean no atomic with loop
    """
    if d_arg["test_type"].startswith("atomic") and d_arg["loop_pragma"]:
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
        if d_arg["host_threaded"] or d_arg["multiple_devices"]:
            path = ["parallel for"] + path
        HP(path, d_arg).write_template_rendered(folder)


# ___        _
#  | _  _|_ |_)_ ._._ _   _|_ _._|_o _ ._
#  |(/_><|_ | (/_| | | ||_||_(_| |_|(_)| |
#
def gen_all_permutation(d_args):
    """
    Trust me on this one...
    Used to make the cartesian product of the list of options
    >>> list(gen_all_permutation({"b":["nvdia","intel"],"a":["x86","V100"]}))
    [{'b': 'nvdia', 'a': 'x86'}, {'b': 'nvdia', 'a': 'V100'}, {'b': 'intel', 'a': 'x86'}, {'b': 'intel', 'a': 'V100'}]
    >>> list(gen_all_permutation({"b":"intel","a":["x86","V100"]}))
    [{'b': 'intel', 'a': 'x86'}, {'b': 'intel', 'a': 'V100'}]
    """

    class hashabledict(dict):
        def __hash__(self):
            return hash(frozenset(self))

        def __missing__(self, key):
            return False

    to_iterable = lambda v: v if isinstance(v, (list, set)) else [v]
    l_values = map(to_iterable, d_args.values())
    for p in product(*l_values):
        yield hashabledict(zip(d_args.keys(), p))


#    _    ___    _
#   /  |   |    |_) _. ._ _ o ._   _
#   \_ |_ _|_   |  (_| | _> | | | (_|
#                                  _|

hp_d_possible_value = {
    "test_type": {"memcopy", "atomic_add", "reduction_add", "reduction_min", "reduction_max", "ordered"},
    "data_type": {"REAL", "DOUBLE PRECISION", "float", "double", "complex<float>", "complex<double>", "COMPLEX", "DOUBLE COMPLEX"},
    "loop_pragma": bool,
    "paired_pragmas": bool,
    "no_user_defined_reduction": bool,
    "no_implicit_mapping": bool,
    "host_threaded": bool,
    "multiple_devices": bool,
    "intermediate_result": bool,
    "collapse": int,
    "tripcount": int,
    "target_data": bool
}

hp_d_default_value = defaultdict(lambda: False)
hp_d_default_value.update({"data_type": {"REAL", "float"}, "test_type": {"memcopy", "atomic_add", "reduction_add"}, "collapse": [0], "tripcount": [32 * 32 * 32]})


mf_d_possible_value = {"standard": {"gnu", "cpp11", "cpp17", "cpp20", "F77", "gnu", "F08"}, "simdize": int, "complex": bool, "long": bool}

mf_d_default_value = defaultdict(lambda: False)
mf_d_default_value.update({"standard": {"cpp11", "F77"}, "complex": {True, False}})


def update_opt(p, d, d_possible):
    def error(k, i, footer):
        print(ovo_usage)
        print(f"Error: {i} is not a valid argument for --{k}")
        print("       " + footer)
        sys.exit(1)

    for k, v in vars(p).items():
        # Filter default arguments or spurious one
        if v is None or k not in d_possible:
            continue

        f = d_possible[k]
        # If people passed --intermediate_result they want that to be True
        if v == [] and f == bool:
            d[k] = True
            continue
        if isinstance(f, set):
            d[k] = set()

        for i in v:
            if isinstance(f, set):
                if not i in f:
                    error(k, i, f"Please use one in {f}")
                else:
                    d[k].add(i)
            elif f == int:
                try:
                    u = int(i)
                except:
                    error(k, i, "Please use a possitive scalar")
                else:
                    if u < 0:
                        error(k, i, "Please use a possitive scalar")
                    d[k] = u
            elif f == bool:
                if i.lower() not in ("true", "false", "0", "1"):
                    error(k, i, "Please use a boolean (True, False, 0, 1)")
                else:
                    d[k] = bool(i.lower())


if __name__ == "__main__":
    with open(os.path.join(dirname, "template", "ovo_usage.txt")) as f:
        ovo_usage = f.read()

    import argparse
    parser = argparse.ArgumentParser(usage=ovo_usage)

    action_parsers = parser.add_subparsers(dest="command")

    # ~
    # tiers
    # ~
    tiers_parser = action_parsers.add_parser("tiers")
    tiers_parser.add_argument("tiers", type=int, nargs="?")
    tiers_parser.add_argument("--tripcount", nargs="?", default=32 * 32 * 32)

    # ~
    # hierarchical_parallelism
    # ~
    hp_parser = action_parsers.add_parser("hierarchical_parallelism")
    for opt in hp_d_possible_value:
        hp_parser.add_argument(f"--{opt}", nargs="*")
    hp_parser.add_argument("--append", action="store_true")
    # ~
    # mathematical_function
    # ~
    mf_parser = action_parsers.add_parser("mathematical_function")
    for opt in mf_d_possible_value:
        mf_parser.add_argument(f"--{opt}", nargs="*")
    mf_parser.add_argument("--append", action="store_true")

    # ~
    # Parsing logic
    # ~
    p = parser.parse_args()
    # Now add the default, and check for validity
    if p.command == "hierarchical_parallelism":
        d = dict(hp_d_default_value)
        update_opt(p, d, hp_d_possible_value)
        l_hp = [d]
        l_mf = []
    elif p.command == "mathematical_function":
        d = dict(mf_d_default_value)
        update_opt(p, d, mf_d_possible_value)
        l_mf = [d]
        l_hp = []
    else:
        if not p.command or not p.tripcount:
            t = 32 * 32 * 32
        else:
            t = int(p.tripcount)

        if not p.command or p.tiers >= 1:
            l_hp = [{"data_type": {"REAL", "float", "complex<double>", "DOUBLE COMPLEX"}, "test_type": {"memcopy", "atomic_add", "reduction_add"}, "tripcount": {t}}]
            l_mf = [{"standard": {"cpp11", "F77"}, "complex": {True, False}, "simdize": 0}]
        if p.command == "tiers" and p.tiers >= 2:
            l_hp += [
                {"data_type": {"REAL", "float"}, "test_type": "ordered","tripcount": {t}},
                {"data_type": {"REAL", "float", "complex<double>", "DOUBLE COMPLEX"}, "test_type": {"reduction_min","reduction_max","atomic_min","atomic_max"}, "tripcount": {t}},
                {"loop_pragma": True, "data_type": {"REAL", "float"}, "test_type": "memcopy","tripcount": {t}},
                {"intermediate_result": True, "data_type": {"REAL", "float"}, "test_type": "atomic_add","tripcount": {t}},
                {"host_threaded": True, "target_data": True, "data_type": {"REAL", "float"}, "test_type": "atomic_add","tripcount": {t}},
                {"multiple_devices": True, "data_type": {"REAL", "float"}, "test_type": "reduction_add","tripcount": {t}},
                {"paired_pragmas": True, "data_type": {"REAL", "float"}, "test_type": "memcopy","tripcount": {t}},
                {"collapse": {2,}, "data_type": {"REAL", "float"}, "test_type": "memcopy","tripcount": {t}},
            ]
            l_mf += [{"standard": {"cpp11", "F77", "F08", "gnu"}, "complex": {True, False}, "simdize": [0, 32]}]
        if p.command == "tiers" and p.tiers >= 3:
            d1 = dict(hp_d_possible_value)
            for k, v in d1.items():
                if v == bool:
                    d1[k] = [True, False]
            d1["collapse"] = [1, 3, 5]
            d1["tripcount"] = [t]
            l_hp = [d1]

            d2 = dict(mf_d_possible_value)
            for k, v in d2.items():
                if v == bool:
                    d2[k] = [True, False]
            d2["simdize"] = [1, 32]
            l_mf = [d2]
    l_hp_unique = set(chain.from_iterable(gen_all_permutation(d) for d in l_hp))
    l_mf_unique = set(chain.from_iterable(gen_all_permutation(d) for d in l_mf))
    # ~
    # Generate tests for cartesian product of options
    # ~
    with open(os.path.join(dirname, "config", "omp_struct.json"), "r") as f:
        omp_construct = combinations_construct(json.load(f))

    for type_, l_args in [("hierarchical_parallelism", l_hp_unique), ("mathematical_function", l_mf_unique)]:

        if not ("append" in vars(p) and vars(p)["append"]):
            print(f"Removing ./tests_src/{{cpp,fortran}}/{type_}")
            shutil.rmtree(f"./test_src/cpp/{type_}", ignore_errors=True)
            shutil.rmtree(f"./test_src/fortran/{type_}", ignore_errors=True)

        for d_args in l_args:
            if type_ == "hierarchical_parallelism":
                gen_hp(d_args, omp_construct)
            else:
                gen_mf(d_args)
