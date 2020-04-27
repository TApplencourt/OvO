#!/usr/bin/env python3

from itertools import tee
import json, os

from functools import update_wrapper
class cached_property(object):
    def __init__(self, func):
        update_wrapper(self,func)
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

def sanitize_string(str_):
    """
    >>> sanitize_string('REAL')
    'real'
    >>> sanitize_string('DOUBLE PRECISION')
    'double_precision'
    >>> sanitize_string('complex<double>')
    'complex_double'
    >>> sanitize_string('*double')
    'double'
    """
    return '_'.join(str_.lower().translate(str.maketrans("<>*", "   ")).split())

class TypeSystem():

    def __init__(self,T):
        self.T = T
    
    @cached_property
    def serialized(self):
        return sanitize_string(self.T)     

    @cached_property
    def category(self):
        if self.no_pt in ('long int', 'int','long long int','unsigned','INTEGER'):
            return 'integer'
        elif  self.no_pt in ('REAL','DOUBLE PRECISION', 'float','double','long double'):
            return 'float'
        elif self.no_pt in ('COMPLEX', 'DOUBLE COMPLEX', 'complex<float>', 'complex<double>',  'complex<long double>'):
            return 'complex'
        elif self.no_pt in ('bool',):
            return 'bool'
        raise NotImplementedError(f'Datatype ({self.T}) is not yet supported')

    @cached_property
    def internal(self):
        '''
        For complex give the internal type, for other give back thenself"
        >>> TypeSystem('complex<float>').internal
        'float'
        >>> TypeSystem('DOUBLE COMPLEX').internal
        'DOUBLE'
        >>> TypeSystem('COMPLEX').internal
        'REAL'
        '''
        if self.category != 'complex':
            return self.no_pt
        elif self.T == 'DOUBLE COMPLEX':
            return 'DOUBLE'
        elif self.T == 'COMPLEX':
            return 'REAL'
        elif self.category == 'complex': #Only the C++ type are left
            return self.no_pt.split('<')[1][:-1]
        else:
            raise NotImplementedError("Datatype ({self.T}) is not yet supported")

    @cached_property
    def is_pointer(self):
        return '*' in self.T

    @cached_property
    def no_pt(self):
        return self.T.replace('*','')

    def __str__(self):
        return self.T

#  _        _    ___          
# / \ |\/| |_)    | ._ _   _  
# \_/ |  | |      | | (/_ (/_ 
#                             

from typing import List
def combinations_construct(tree_config_path, path=['root']) -> List[List[str]]:
    
    paths = [path[1:]] if len(path[1:]) else [] 

    for children in omp_tree[path[-1]]:
        paths += combinations_construct(tree_config_path, path + [children])
    return paths



class Path():

    def __init__(self, path,T, language='cpp'):
        # To facilitate the recursion. Loop are encoded as "loop_distribute" and "loop_for".
        self.path = [ ' '.join(pragma.split('_')[0] for pragma in p.split()) for p in path]
        self.T = TypeSystem(T)
        self.language = language

    @cached_property
    def name(self):
        l_node_serialized = ("_".join(node.split()) for node in self.path)
        
        n =  "__".join(l_node_serialized)
        if self.language == "cpp":
            return n
        elif self.language == "fortran":
            return n.replace('for','do')

    @cached_property
    def filename(self):
        # Some node in the path have space in their name. We will replace them with
        # one underscore. Level will be replaced with two.
        # The path will always containt 'for'. If we are in fortran, for sanity, we shoud replace then with 'do'.
        
        if self.language == "cpp":
            return f"{self.name}.cpp"
        else:
            return f"{self.name}.F90"

    @cached_property
    def flatten_path(self):
        # [ "teams distribute", "parallel" ] -> [ "teams distribute parallel" ]
        from itertools import chain
        return list(chain.from_iterable(map(str.split,self.path)))

    def follow_by(self,a,b):
        return any( (i == a) and (j == b) for i,j in pairwise(self.flatten_path))

    def has(self,constructs):
        return constructs in self.flatten_path

    @cached_property
    def only_teams(self):
        return self.has("teams") and not ( self.follow_by("teams","distribute") or self.follow_by("teams","loop") )

    @cached_property
    def only_parallel(self):
        return self.has("parallel") and not  ( self.follow_by("parallel", "for") or self.follow_by("parallel","loop") )

    @cached_property
    def only_target(self):
        return len(self.flatten_path) == 1

    @cached_property
    def balenced(self):
        return not self.only_parallel and not self.only_teams
   
    @cached_property
    def loop_contruct(self):
        return ("distribute","for","simd","loop")

    def has_loop(self, pragma):
        return any(p in pragma for p in self.loop_contruct)

    @cached_property
    def n_loop(self):
        return sum(map(self.has_loop, self.path))
    
    @cached_property
    def loops(self):

        from collections import namedtuple
        Idx = namedtuple("Idx",'i N v')
        if self.n_loop == 0:
            return []
        elif self.n_loop == 1:
           return [Idx('i','L',64*64*64)]
        elif self.n_loop == 2:
           return [Idx('i','L',64*64), Idx('j','M',64)]
        elif self.n_loop == 3:
           return [Idx('i','L',64), Idx('j','M',64), Idx('k','N',64)]

    @cached_property
    def fat_path(self):

        l, i_loop = [], 0

        for pragma in self.path:
            d = {}

            if self.language == 'cpp':
                d["pragma"] = pragma   
            elif self.language == 'fortran':
                d["pragma"] = pragma.replace('for','do').upper() 

            if self.has_loop(pragma):
                d["loop"] = self.loops[i_loop]
                i_loop+=1

            if "target" in pragma:
                d["target"] = True

            if "teams" in pragma and self.only_teams:
                d["only_teams"] = True

            if "parallel" in pragma and self.only_parallel:
                d["only_parallel"] = True
            
            if any(p in pragma for p in ("teams","parallel","simd")):
                d["reduce"] = True

            if self.has("parallel") and "parallel" in pragma:
                d["partial"] = True
            elif not self.has("parallel") and "simd" in pragma:
                d["partial"] = True

            l.append(d)

        return l

import os
import jinja2
dirname = os.path.dirname(__file__)
templateLoader = jinja2.FileSystemLoader(searchpath=os.path.join(dirname,"template"))
templateEnv = jinja2.Environment(loader=templateLoader)


def format_template(str_):
    return '\n'.join(line for line in str_.split('\n') if line.strip() ) + '\n'

class OmpReduce(Path):

    @cached_property
    def expected_value(self):
        if not self.loops:
            return "1"

        return f"{'*'.join(l.N for l in self.loops)}"

class Atomic(OmpReduce):

    @cached_property
    def template_rendered(self):

        if self.language == "cpp":
            template = templateEnv.get_template(f"test_atomic.cpp.jinja2")
        elif self.language == "fortran":
            template = templateEnv.get_template(f"test_atomic.f90.jinja2")

        if self.has("simd"):
            return 

        str_ = template.render(name=self.name,
                                      fat_path=self.fat_path,
                                      loops=self.loops,
                                      balenced=self.balenced,
                                      only_teams=self.only_teams,
                                      only_parallel=self.only_parallel,
                                      expected_value=self.expected_value,
                                      T_category=self.T.category,
                                      T_type=self.T.internal,
                                      T=self.T.T)

        return format_template(str_)

class Reduction(OmpReduce):

    @cached_property
    def template_rendered(self):

        if self.language == "cpp":
            template = templateEnv.get_template(f"test_reduction.cpp.jinja2")
        elif self.language == "fortran":
            template = templateEnv.get_template(f"test_reduction.f90.jinja2")

        str_ =  template.render(name=self.name,
                                        fat_path=self.fat_path,
                                        loops=self.loops,
                                        balenced=self.balenced,
                                        only_teams=self.only_teams,
                                        only_parallel=self.only_parallel,
                                        expected_value=self.expected_value,
                                        T_category=self.T.category,
                                        T_type=self.T.internal,
                                        T=self.T.T)

        return format_template(str_)

class ReductionAtomic(OmpReduce):

    @cached_property
    def template_rendered(self):

        if self.language == "cpp":
            template = templateEnv.get_template(f"test_reduction_atomic.cpp.jinja2")
        elif self.language == "fortran":
            template = templateEnv.get_template(f"test_reduction_atomic.f90.jinja2")

        # Need at least 2 layers of construct
        if any([sum(self.has(p) for p in ("teams","parallel","simd") ) < 2,
                len(self.path) < 2,
                self.path[0] == 'target' and (len(self.path) > 2 and "partial" in self.fat_path[1]) ] ):
            return
 
        str_ = template.render(name=self.name,
                                      fat_path=self.fat_path,
                                      loops=self.loops,
                                      balenced=self.balenced,
                                      only_teams=self.only_teams,
                                      only_parallel=self.only_parallel,
                                      expected_value=self.expected_value,
                                      T_category=self.T.category,
                                      T_type=self.T.internal,
                                      T=self.T.T)

        return format_template(str_)
    
class Memcopy(Path):

    @cached_property
    def index(self):
        if self.language == "cpp":
            if self.n_loop == 1:
                return "i"
            elif self.n_loop == 2:
                return "j + i*M"
            elif self.n_loop == 3:
                return "k + j*N + i*N*M"
        elif  self.language == "fortran":
            if self.n_loop == 1:
                return "i"
            elif self.n_loop == 2:
                return "j + (i-1)*M"
            elif self.n_loop == 3:
                return "k + (j-1)*N + (i-1)*N*M"

    @cached_property
    def size(self):
        return '*'.join(l.N for l in self.loops) 

    @cached_property
    def template_rendered(self):
        if not self.balenced or self.only_target:
            return

        if self.language == "cpp":
            template = templateEnv.get_template(f"test_memcopy.cpp.jinja2")
        elif self.language == "fortran":
            template = templateEnv.get_template(f"test_memcopy.f90.jinja2")

        str_ = template.render(name=self.name,
                               fat_path=self.fat_path,
                               loops=self.loops,
                               index=self.index,
                               size=self.size,
                               T_category=self.T.category,
                               T_type=self.T.internal,
                               T=self.T.T)

        return format_template(str_)

#from cmath import complex
class ccomplex(object):
   
    def __init__(self, a, b):
        self.real = a
        self.img = b

    def __str__(self):
        return f"{self.real}, {self.img}"

class Argv:
            def __init__(self,t,attr, argv):
                self.T = TypeSystem(t)
                self.attr = attr
                self.name = argv
                self.val = None

            @cached_property
            def is_argv(self):
                return self.attr == 'in' or (self.attr == 'out' and self.T.is_pointer)

            def argv_name(self,suffix):
                if self.attr == 'in':
                    return self.name
                elif self.attr == 'out' and self.T.is_pointer:
                    return f'&{self.name}_{suffix}'            
                else:
                    raise NotImplemented(f'{self.name} is not yet implemented as parameters of function')

            @cached_property
            def name_host(self):
                return f'{self.name}_host'

            @cached_property
            def name_device(self):
                return f'{self.name}_device'

            @cached_property
            def argv_host(self):
                return self.argv_name('host')

            @cached_property
            def argv_device(self):
                return self.argv_name('device')

            @cached_property
            def is_output(self):
                return self.attr == 'out'

            @cached_property
            def is_input(self):
                return self.attr == 'in'
  
class Math():

    T_to_values = {'bool': [True],
         'float': [0.42, 4.42],
         'REAL': [0.42, 4.42],
         'long int': [ 1 ], 
         'unsigned': [ 1 ], 
         'double': [ 0.42, 4.42],
         'DOUBLE PRECISION': [ 0.42, 4.42],
         'int': [ 1, 0, 2 ] ,
         'INTEGER': [1, 0, 2 ],
         'long long int': [ 1] , 
         'long double': [ 0.42, 4.42], 
         'complex<float>' : [ ccomplex(0.42, 0.) ,  ccomplex(4.42, 0.) ],
         'COMPLEX':  [ ccomplex(0.42, 0.) ,  ccomplex(4.42, 0.) ],
         'complex<double>' : [ ccomplex(0.42, 0.) , ccomplex(4.42, 0.) ],
         'DOUBLE COMPLEX':  [ ccomplex(0.42, 0.) , ccomplex(4.42, 0.) ],
         'complex<long double>' : [ ccomplex(0.42, 0.) , ccomplex(4.42, 0.) ],
         'const char*' : [None]
         }


    def __init__(self, name, T, attr, argv, domain, language="cpp"):
        self.name = name
        if not argv:
            argv = [f'{j}{i}'  for i,j in enumerate(attr) ]
        self.language = language
        self.l = self.create_l(T,attr, argv, domain)

    def create_l(self, T, attr, argv, domain):
        l =  [ Argv(t,a,b) for t,a,b in zip(T,attr, argv)]

        l_input = [t for t in l if t.is_input ]
        # Got all the possible value of the input
        l_input_name = [ t.name for t in l_input ]
        l_input_values = [ Math.T_to_values[t.T.T] for t in l_input ] 

        from itertools import product
        for l_input_value in product(*l_input_values):
            if not domain:
                break

            d = {name:value for name,value in zip(l_input_name, l_input_value) }
            from math import isinf, isnan
            d['isinf'] = isinf
            d['isnan'] = isnan

            if eval(domain,d): 
                break

        for t,v in zip(l_input, l_input_value):
            t.val = v
        return l

    @cached_property
    def filename(self):
         n = '_'.join([self.name] + [ t.T.serialized for t in self.l])
         if self.language == "cpp":
            return f'{n}.cpp'
         elif self.language == "fortran":
            return f'{n}.F90'
 
    @cached_property
    def scalar_output(self):
        os = [ l for l in self.l if l.is_output and not l.T.is_pointer ]
        if os:
            assert (len(os) == 1)
            return [ l for l in self.l if l.is_output and not l.T.is_pointer ].pop()
        else:
            return None

    @cached_property
    def have_complex(self):
        return any(t.T.category == 'complex' for t in self.l)

    @cached_property
    def template_rendered(self):

        # We don't handle in pointer
        if any(t.T.is_pointer and t.is_input for t in self.l ):
            return None

        if self.language == "cpp":
            template = templateEnv.get_template(f"test_math.cpp.jinja2")
        elif self.language == "fortran":
            template = templateEnv.get_template(f"test_math.f90.jinja2")
        str_ = template.render(name=self.name, l_argv=self.l, scalar_output= self.scalar_output, have_complex=self.have_complex)
        return format_template(str_)

#  -                                                   
# /   _   _|  _     _   _  ._   _  ._ _. _|_ o  _  ._  
# \_ (_) (_| (/_   (_| (/_ | | (/_ | (_|  |_ | (_) | | 
#                   _|                                 
#
def gen_math(makefile, l_json, language):
    from itertools import zip_longest

    for p in l_json:
      with open(os.path.join(dirname,"config",p), 'r') as f:
          math_json = json.load(f)

      for category, X in math_json.items():
        folder = os.path.join("test_src",language,f"{category}")
        os.makedirs(folder, exist_ok=True)

        with open(os.path.join(folder,'Makefile'),'w') as f:
            f.write(makefile)

        for name, Y in X.items():

           lattribute = Y['attribute']
           lT = Y['type']
           largv = Y['name'] if 'name' in Y else []
           ldomain = Y['domain'] if 'domain' in Y else []
            
           for T, attr, argv, domain in zip_longest(lT,lattribute,largv, ldomain):
                    m = Math(name,T, attr, argv, domain,language)
                    if m.template_rendered:
                        with open(os.path.join(folder,m.filename),'w') as f:
                            f.write(m.template_rendered)

def gen_hp(makefile, omp_tree, tests, language):


    for test,Constructor, l_T in tests: 
        for T in l_T:
            folder = os.path.join("test_src",language,"hierarchical_parallelism",test,sanitize_string(T))

            os.makedirs(folder, exist_ok=True)

            with open(os.path.join(folder,'Makefile'),'w') as f:
                f.write(makefile)

            for path in combinations_construct(omp_tree):
                p = Constructor(path,T,language)
                if p.template_rendered:
                    with open(os.path.join(folder,p.filename),'w') as f:
                        f.write(p.template_rendered)

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description='Generate tests.')
    args = parser.parse_args()

    makefile_cpp = templateEnv.get_template(f"Makefile.cpp.jinja2").render()

    makefile_fortran = templateEnv.get_template(f"Makefile.f90.jinja2").render()

    gen_math(makefile_cpp, ("cmath_synopsis.json" ,"cmath_complex_synopsis.json"), "cpp")
    gen_math(makefile_fortran, ("f90math_synopsis.json",), "fortran" )

    with open(os.path.join(dirname,"config","omp_struct.json"), 'r') as f:
        omp_tree = json.load(f)

    gen_hp(makefile_cpp, omp_tree,( ("memcopy", Memcopy,     ['float', 'complex<float>', 'double','complex<double>']) ,
                                    ("atomic" , Atomic,      ['float', 'double']) ,
                                    ("reduction", Reduction, ["float",'complex<float>','double','complex<double>']), 
                                    ("reduction_atomic", ReductionAtomic, ['float','double'] )),
                                    "cpp" ) 
    gen_hp(makefile_fortran, omp_tree, (  ("memcopy", Memcopy,     ['REAL', 'COMPLEX', 'DOUBLE PRECISION', 'DOUBLE COMPLEX']) ,
                                          ("atomic" , Atomic,      ['REAL','DOUBLE PRECISION']) ,
                                          ("reduction", Reduction, ['REAL', 'COMPLEX', 'DOUBLE PRECISION', 'DOUBLE COMPLEX']), 
                                          ("reduction_atomic", ReductionAtomic, ['REAL','DOUBLE PRECISION'] )),
                                          "fortran" )

