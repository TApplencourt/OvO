#!/usr/bin/env python3
import jinja2, json, os, shutil, sys, math
from itertools import tee, zip_longest, product,chain
from functools import update_wrapper
from typing import List
from collections import namedtuple

#
#  __                                      _          _       
# /__ |  _  |_   _. |     | o ._  o  _.   /   _  ._ _|_ o  _  
# \_| | (_) |_) (_| |   \_| | | | | (_|   \_ (_) | | |  | (_| 
#                                _|                        _| 
#
dirname = os.path.dirname(__file__)
templateLoader = jinja2.FileSystemLoader(searchpath=os.path.join(dirname,"template"))
templateEnv = jinja2.Environment(loader=templateLoader)
def raise_helper(msg):
    raise Exception(msg)
templateEnv.globals['raise'] = raise_helper

#                
# | | _|_ o |  _ 
# |_|  |_ | | _> 
#                

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

def format_template(str_, language):
    """
    - Remove empty line.
    - right strip
    - Split Fortran line 
    """
    def split_fortran_line(line, max_width=100):
        prefix = '&\n!$OMP&' if line.startswith('!$OMP') else '&\n&'
        l_chunk =  range(len(line)//100)         

        l = list(line)
        for i in l_chunk:
            l.insert((i+1)*max_width+3*i,prefix)
        return ''.join(l)
  
    l_line = [line.rstrip() for line in str_.split('\n') if line.strip() ]
    l_result = l_line if language=='cpp' else map(split_fortran_line,l_line)
    return '\n'.join(l_result) + '\n'

#  _        _    ___
# / \ |\/| |_)    | ._ _   _
# \_/ |  | |      | | (/_ (/_
#

# Need to refractor this one... Too ugly or too smart
def combinations_construct(tree_config_path, path=['root']) -> List[List[str]]:
    '''
    >>> combinations_construct({'root':['target','target teams'],
    ...                         'target':['teams'],
    ...                         'target teams': [],
    ...                         'teams': [] })
    [['target'], ['target', 'teams'], ['target teams']]
    '''
    tails = [path[1:]] if len(path[1:]) else []

    for children in tree_config_path[path[-1]]:
        tails += combinations_construct(tree_config_path, path + [children])
    return tails

# ___                             
#  |     ._   _    | | _|_ o |  _ 
#  | |_| |_) (/_   |_|  |_ | | _> 
#        |                       

class TypeSystem():

    def __init__(self,T):
        self.T = T
    
    @cached_property
    def serialized(self):
        """
        >>> TypeSystem('REAL').serialized
        'real'
        >>> TypeSystem('DOUBLE PRECISION').serialized
        'double_precision'
        >>> TypeSystem('complex<long double>').serialized
        'complex_long_double'
        >>> TypeSystem('*double').serialized
        'double'
        """
        return '_'.join(self.T.lower().translate(str.maketrans("<>*", "   ")).split())

    @cached_property
    def without_pointer(self):
        '''
        >>> TypeSystem('*complex<float>').without_pointer
        'complex<float>'
        '''
        return self.T.replace('*','')

    @cached_property
    def category(self):
        """
        >>> TypeSystem('complex<long double>').category
        'complex'
        >>> TypeSystem('REAL').category
        'float'
        """
        if self.without_pointer in ('long int', 'int','long long int','unsigned','INTEGER'):
            return 'integer'
        elif  self.without_pointer in ('REAL','DOUBLE PRECISION', 'float','double','long double'):
            return 'float'
        elif self.without_pointer in ('COMPLEX', 'DOUBLE COMPLEX', 'complex<float>', 'complex<double>',  'complex<long double>'):
            return 'complex'
        elif self.without_pointer in ('bool',):
            return 'bool'
        raise NotImplementedError(f'Datatype ({self.T}) is not yet supported.')

    @cached_property
    def is_long(self):
        return 'long' in self.without_pointer

    @cached_property
    def internal(self):
        '''
        >>> TypeSystem('complex<float>').internal
        'float'
        >>> TypeSystem('DOUBLE COMPLEX').internal
        'DOUBLE'
        >>> TypeSystem('COMPLEX').internal
        'REAL'
        '''
        if self.category != 'complex':
            return self.without_pointer
        elif self.T == 'DOUBLE COMPLEX':
            return 'DOUBLE'
        elif self.T == 'COMPLEX':
            return 'REAL'
        elif self.category == 'complex': #Only the C++ type are left
            return self.without_pointer.split('<')[1][:-1]
        else:
            raise NotImplementedError("Datatype ({self.T}) is not yet supported")

    @cached_property
    def is_pointer(self):
        '''
        >>> TypeSystem('complex<float>').is_pointer
        False
        >>> TypeSystem('*complex<float>').is_pointer
        True
        '''
        return '*' in self.T

    @cached_property
    def language(self):
        '''
        >>> TypeSystem('*complex<float>').language
        'cpp'
        >>> TypeSystem('REAL').language
        'fortran'
        '''
        # Warning, just rely on the capitalization.
        # Not robust, but good enought
        if self.without_pointer.islower():
            return 'cpp'
        else:
            return 'fortran'

    def __str__(self):
        return self.T

# ___                               _                      
#  |  _   _ _|_   |_   _.  _  _ __ |_ _.  _ _|_  _  ._     
#  | (/_ _>  |_   |_) (_| _> (/_   | (_| (_  |_ (_) | \/   
#                                                     /    

class Path():

    def __init__(self, path_raw, d_arg):
        self.path_raw = path_raw

        # Explicit is better than implicit.
        # So this is ugly... But really usefull when testing
        # d_args keys containt [data_type, test_type, avoid_user_defined_reduction, paired_pragmas, loop_pragma, collapse]
        for k,v in d_arg.items():
            setattr(self, k, v)
    
    @cached_property
    def T(self):
        return TypeSystem(self.data_type)

    @cached_property
    def language(self):
        '''
        >>> Path(None, {'data_type':'float'} ).language
        'cpp'
        >>> Path(None, {'data_type':'REAL'} ).language
        'fortran'
        '''
        return self.T.language

    @cached_property
    def path(self):
        '''
        >>> Path( ['parallel','for'], {} ).path
        ['parallel', 'for']
        >>> Path( ['parallel','loop_for'], {} ).path
        ['parallel', 'loop']
        '''
        # To facilitate the recursion. Loop are encoded as "loop_distribute" and "loop_for".
        return [ ' '.join(pragma.split('_')[0] for pragma in p.split()) for p in self.path_raw]

    @cached_property
    def name(self):
        '''
        >>> Path( ['parallel','for'], {'data_type':'float'} ).name
        'parallel__for'
        >>> Path( ['parallel for','simd'], {'data_type':'REAL'} ).name
        'parallel_do__simd'
        '''
        l_node_serialized = ("_".join(node.split()) for node in self.path)
        
        n =  "__".join(l_node_serialized)
        if self.language == "cpp":
            return n
        elif self.language == "fortran":
            return n.replace('for','do')
        return NotImplementedError

    @cached_property
    def ext(self):
        '''
        >>> Path(None, {'data_type':'float'} ).ext
        'cpp'
        >>> Path(None, {'data_type':'DOUBLE PRECISION'} ).ext
        'F90'
        '''
        if self.language == "cpp":
            return "cpp"
        elif self.language == "fortran":
            return "F90"
        return NotImplementedError

    @cached_property
    def filename(self):
        '''
        >>> Path( ['parallel','for'], {'data_type':'float'} ).filename
        'parallel__for.cpp'
        >>> Path( ['parallel','loop_for'], {'data_type':'float'} ).filename
        'parallel__loop.cpp'
        >>> Path( ['parallel for','simd'], {'data_type':'REAL'} ).filename
        'parallel_do__simd.F90'
        '''
        return f"{self.name}.{self.ext}"

    @cached_property
    def flatten_path(self):
        '''
        >>> Path( ['parallel', 'for','simd'], {} ).flatten_path
        ['parallel', 'for', 'simd']
        >>> Path( ['parallel for','simd'], {} ).flatten_path
        ['parallel', 'for', 'simd']
        '''
        return list(chain.from_iterable(map(str.split,self.path)))

    def follow_by(self,a,b):
        '''
        >>> Path( ['parallel', 'for'], {} ).follow_by('parallel','for')
        True
        >>> Path( ['parallel for'], {} ).follow_by('parallel','for')
        True
        >>> Path( ['parallel', 'for'], {} ).follow_by('for','simd')
        False
        '''
        return any( (i == a) and (j == b) for i,j in pairwise(self.flatten_path))

    def has(self,construct):
        '''
        >>> Path( ['parallel', 'for'], {} ).has('for')
        True
        >>> Path( ['parallel for'], {} ).has('parallel')
        True
        >>> Path( ['parallel for'], {} ).has('simd')
        False
        '''
        return construct in self.flatten_path

    @cached_property
    def only_teams(self):
        '''
        >>> Path( ['teams', 'distribute'], {} ).only_teams
        False
        >>> Path( ['teams', 'loop'], {} ).only_teams
        False
        >>> Path( ['teams', 'parrallel','loop'], {} ).only_teams
        True
        '''
        return self.has("teams") and not ( self.follow_by("teams","distribute") or self.follow_by("teams","loop") )

    @cached_property
    def only_parallel(self):
        '''
        >>> Path( ['parallel', 'for'], {} ).only_parallel
        False
        >>> Path( ['parallel', 'loop'], {} ).only_parallel
        False
        >>> Path( ['teams','loop','parallel'], {} ).only_parallel
        True
        '''
        return self.has("parallel") and not  ( self.follow_by("parallel", "for") or self.follow_by("parallel","loop") )

    @cached_property
    def balenced(self):
        '''
        >>> Path( ['parallel', 'for'], {} ).balenced
        True
        >>> Path( ['teams', 'loop', 'parallel'], {} ).balenced
        False
        '''
        return not self.only_parallel and not self.only_teams
   
    def is_loop_pragma(self, pragma):
        '''
        >>> Path( {}, {}).is_loop_pragma('loop')
        True
        >>> Path( {}, {}).is_loop_pragma('parralel for')
        True
        >>> Path( {}, {}).is_loop_pragma('teams')
        False
        '''
        return any(p in pragma for p in ("distribute","for","simd","loop") )

    @cached_property
    def loop_pragma_number(self):
        '''
        >>> Path( ['teams', 'distribute', 'parallel', 'for'], {} ).loop_pragma_number
        2
        >>> Path( ['teams', 'distribute', 'parallel', 'loop'], {} ).loop_pragma_number
        2
        >>> Path( ['teams', 'parallel'], {} ).loop_pragma_number
        0
        '''
        return sum(map(self.is_loop_pragma, self.path)) 

    @cached_property
    def loop_construct_number(self):
        '''
        >>> Path( ['distribute'], {'collapse':1} ).loop_construct_number
        1
        >>> Path( ['distribute'], {'collapse':0} ).loop_construct_number
        1
        >>> Path( ['distribute'], {'collapse':2} ).loop_construct_number
        2
        >>> Path( ['teams', 'distribute', 'parallel', 'for'], {'collapse':2} ).loop_construct_number
        4
        >>> Path( ['teams', 'parallel'], {'collapse':2} ).loop_construct_number
        0
        '''
        if self.collapse:
            return self.loop_pragma_number*self.collapse
        else:
            return self.loop_pragma_number

    @cached_property
    def has_loop_construct(self):
        return self.loop_construct_number != 0
  
    @cached_property
    def loop_tripcount(self):
        '''
        >>> Path( ['distribute'], {'collapse':0} ).loop_tripcount
        262144
        >>> Path( ['distribute'], {'collapse':1} ).loop_tripcount
        262144
        >>> Path( ['distribute'], {'collapse':2} ).loop_tripcount
        512
        >>> Path( ['teams distribute paralel for simd'], {'collapse': 0} ).loop_tripcount
        262144
        >>> Path( ['teams', 'distribute', 'paralel', 'for', 'simd'], {'collapse':0} ).loop_tripcount
        64
        >>> Path( ['teams'], {'collapse':0} ).loop_tripcount
        ...
        '''
        if not self.loop_construct_number:
            return None

        return max(1, math.ceil(math.pow(64*64*64, 1./self.loop_construct_number)))

    @cached_property
    def loops(self):
        '''
        >>> Path( ['distribute'], {'collapse':1} ).loops
        [Idx(i='i0', N='N0', v=262144)]
        >>> Path( ['distribute'], {'collapse':2} ).loops
        [Idx(i='i0', N='N0', v=512), Idx(i='i1', N='N1', v=512)]
        >>> Path( ['teams'], {'collapse':None} ).loops
        []
        '''        
        Idx = namedtuple("Idx",'i N v')
        return [ Idx(f"i{i}",f"N{i}",self.loop_tripcount) for i in range(self.loop_construct_number) ]

        
    @cached_property
    def fat_path(self):
        '''
        >>> Path( ['distribute'], {'collapse':0, 'data_type':'REAL'} ).fat_path
        [{'pragma': 'DISTRIBUTE', 'loop': [Idx(i='i0', N='N0', v=262144)]}]
        >>> Path( ['target teams distribute', 'paralel for'], {'collapse':0, 'data_type':'REAL'} ).fat_path #doctest: +NORMALIZE_WHITESPACE
        [{'pragma': 'TARGET TEAMS DISTRIBUTE', 
          'loop': [Idx(i='i0', N='N0', v=512)], 'target': True, 'reduce': True}, 
         {'pragma': 'PARALEL DO', 
          'loop': [Idx(i='i0', N='N0', v=512)]}]
        '''
        # Yes, this is horible state machine...
        l, i_loop,n_reduce, target = [], 0, 0 , False
        for pragma in self.path:
            d = {}

            if self.language == 'cpp':
                d["pragma"] = pragma   
            elif self.language == 'fortran':
                d["pragma"] = pragma.replace('for','do').upper() 

            if self.is_loop_pragma(pragma):
                d["loop"] = [ self.loops[i_loop+i] for i in range(max(self.collapse,1)) ]
                i_loop+=self.collapse

            if "target" in pragma:
                d["target"] = True
                target = True

            if "teams" in pragma and self.only_teams:
                d["only_teams"] = True

            if "parallel" in pragma and self.only_parallel:
                d["only_parallel"] = True
            
            if any(p in pragma for p in ("teams","parallel","simd")):
                d["reduce"] = True

                if n_reduce == 1:
                    d["partial"] = True
                if n_reduce >= 1:
                    d["partial_reduce"] = True
                if not target:
                    d["reduce_host"] = True
                n_reduce += 1

            l.append(d)

        return l

    @cached_property
    def is_valid_common_test(self):
        '''
        >>> Path( ['for'], {'collapse':0,'loop_pragma':False} ).is_valid_common_test
        True
        >>> Path( ['for'], {'collapse':0,'loop_pragma':True} ).is_valid_common_test
        False
        >>> Path( ['loop'], {'collapse':0,'loop_pragma':False} ).is_valid_common_test
        False
        >>> Path( ['loop'], {'collapse':0,'loop_pragma':True} ).is_valid_common_test
        True
        >>> Path( ['loop'], {'collapse':1,'loop_pragma':True} ).is_valid_common_test
        True
        >>> Path( ['loop'], {'collapse':0, 'loop_pragma':True} ).is_valid_common_test
        True
        >>> Path( ['teams'], {'collapse':0, 'loop_pragma':False} ).is_valid_common_test
        True
        >>> Path( ['teams'], {'collapse':1, 'loop_pragma':False} ).is_valid_common_test
        False
        '''
        # If we don't ask for loop pragma we don't want to generate with tests who containt omp loop construct
        if self.loop_pragma ^ self.has('loop'):
            return False
        # If people whant collapse, we will print only the test with loop
        if self.collapse and not self.has_loop_construct:
            return False
        return True

    @cached_property
    def template_rendered(self):

        if not ( self.is_valid_common_test and self.is_valid_test):
            return None

        template = templateEnv.get_template(self.template_location)
        str_ = template.render(**{p:getattr(self,p)  for p in dir(self) if p != 'template_rendered' } )
        return format_template(str_,self.language)

    def write_template_rendered(self,folder):
        if self.template_rendered:
            with open(os.path.join(folder,self.filename),'w') as f:
                f.write(self.template_rendered)

#                                        _                                
# |_| o  _  ._ _. ._ _ |_  o  _  _. |   |_) _. ._ _. | |  _  | o  _ ._ _  
# | | | (/_ | (_| | (_ | | | (_ (_| |   |  (_| | (_| | | (/_ | | _> | | | 
#                                                                         

class Fold(Path):

    @cached_property
    def expected_value(self):
        '''
        >>> Fold( ['teams', 'distribute'], {'collapse':0} ).expected_value 
        'N0'
        >>> Fold( ['teams', 'distribute'], {'collapse':2} ).expected_value
        'N0*N1'
        >>> Fold( ['teams','parallel'], {'collapse':1} ).expected_value
        '1'
        '''

        if not self.loops:
            return "1"

        return f"{'*'.join(l.N for l in self.loops)}"

    @cached_property
    def is_valid_test(self):
        '''
        >>> Fold( ['teams', 'distribute'], {'collapse':0,'test_type': 'atomic'} ).is_valid_test
        True
        >>> Fold( ['teams', 'distribute', 'simd'], {'collapse':0,'test_type': 'atomic'} ).is_valid_test
        False
        >>> Fold( ['parralel for'], {'collapse':0,'test_type': 'reduction_atomic','data_type':'REAL'} ).is_valid_test
        False
        >>> Fold( ['teams','simd'], {'collapse':0,'test_type': 'reduction_atomic','data_type':'REAL'} ).is_valid_test
        True
        '''
        # Cannot use atomic inside simd
        if self.test_type in ('atomic','threaded_atomic') and self.has("simd"):
            return False

        # We want to do a two step fold (reduction in the inner loops and atomics in the outer)
        # - That mean we need at least 2 posible reduction <=> partial in fat_path
        if self.test_type == 'reduction_atomic' and not any("partial" in p for p in self.fat_path):
            return False

        return True
    
    @cached_property
    def template_location(self):
        return f"fold.{self.ext}.jinja2"

class Memcopy(Path):

    @cached_property
    def index(self):
        '''
        >>> Memcopy(['for'],{'data_type':'float','collapse':0}).index
        'i0'
        >>> Memcopy(['for'],{'data_type':'float','collapse':3}).index
        'i2+(i1+(i0*N1)*N2)'
        >>> Memcopy(['for'],{'data_type':'REAL','collapse':0}).index
        '(i0-1)+1'
        >>> Memcopy(['for'],{'data_type':'REAL','collapse':3}).index
        '(i2-1)+((i1-1)+((i0-1)*N1)*N2)+1'
        '''
        def fma_idx(n,offset = 0):
            idx = f'(i{n}-{offset})' if offset else f'i{n}'

            if n == 0:
                return idx
            return f'{idx}+({fma_idx(n-1,offset)}*N{n})'

        if self.language == 'cpp':
            return fma_idx(self.loop_construct_number-1)
        else:
            return f'{fma_idx(self.loop_construct_number-1,1)}+1'
    
    @cached_property
    def problem_size(self):
        '''
        >>> Memcopy( ['teams', 'distribute'], {'collapse':0} ).problem_size
        'N0'
        >>> Memcopy( ['teams', 'distribute'], {'collapse':2} ).problem_size
        'N0*N1'
        '''

        return '*'.join(l.N for l in self.loops) 

    @cached_property
    def is_valid_test(self):
        '''
        >>> Memcopy( ['teams', 'distribute'], {'collapse':0} ).is_valid_test
        True
        >>> Memcopy( ['teams', 'parallel'], {'collapse':0} ).is_valid_test
        False
        '''

        if not self.balenced or not self.has_loop_construct:
            return False
        return True

    @cached_property
    def template_location(self):
        return f"test_memcopy.{self.ext}.jinja2"

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

    @cached_property
    def ext(self):
        if self.language == "cpp":
            return "cpp"
        elif self.language == "fortran":
            return "F90"
        return NotImplementedError

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
         return f'{n}.{self.ext}'
 
    @cached_property
    def scalar_output(self):
        os = [ l for l in self.l if l.is_output and not l.T.is_pointer ]
        if os:
            assert (len(os) == 1)
            return [ l for l in self.l if l.is_output and not l.T.is_pointer ].pop()
        else:
            return None
    
    @cached_property
    def use_long(self):
        return any(t.T.is_long for t in self.l) 
                
    @cached_property
    def have_complex(self):
        return any(t.T.category == 'complex' for t in self.l)

    @cached_property
    def template_rendered(self):

        # We don't handle in pointer
        if any(t.T.is_pointer and t.is_input for t in self.l ):
            return None

        template = templateEnv.get_template(f"test_math.{self.ext}.jinja2")
        
        str_ = template.render(name=self.name, l_argv=self.l, scalar_output= self.scalar_output, have_complex=self.have_complex)
        return format_template(str_,self.language)

#  -                                                   
# /   _   _|  _     _   _  ._   _  ._ _. _|_ o  _  ._  
# \_ (_) (_| (/_   (_| (/_ | | (/_ | (_|  |_ | (_) | | 
#                   _|                                 
#

def gen_mf(d_arg):
    
    std = d_arg['standart']
    cmplx = d_arg['complex']
   
    if std.startswith('cpp') or std == 'gnu':
        language = 'cpp'
        if cmplx:
            f = 'cmath_complex_synopsis.json'
        else:
            f =  'cmath_synopsis.json'
    elif std.startswith('F'):
        language = 'fortran'
        f = "f77math_synopsis.json"
    
    with open(os.path.join(dirname,"config",f), 'r') as f:
        math_json = json.load(f)

    if d_arg['long'] and language == 'fortran':
        return False
 
    name_folder = [std] + [k for k,v in d_arg.items() if v == True]    
    folder = os.path.join("test_src",language,"mathematical_function",'-'.join(name_folder))
    os.makedirs(folder, exist_ok=True)

    with open(os.path.join(folder,"Makefile"),'w') as f:
        f.write(templateEnv.get_template(f"Makefile.jinja2").render(ext="cpp" if language == "cpp" else "F90"))

    std = f"{std}_complex" if cmplx else std
    if std not in math_json:
        return False

    for name, Y in math_json[std].items():
           lattribute = Y['attribute']
           lT = Y['type']
           largv = Y['name'] if 'name' in Y else []
           ldomain = Y['domain'] if 'domain' in Y else []

           for T, attr, argv, domain in zip_longest(lT,lattribute,largv, ldomain):
                    m = Math(name,T, attr, argv, domain,language)
                    if  ( (m.use_long and d_arg['long']) or (not m.use_long and not d_arg['long']) ) and m.template_rendered:
                        with open(os.path.join(folder,m.filename),'w') as f:
                            f.write(m.template_rendered)
       

def gen_hp(d_arg, omp_construct):
    
    t = TypeSystem(d_arg['data_type'])

    # Do we need to generate a folder?
    if d_arg['avoid_user_defined_reduction']:
        if t.language == "fortran":
            return False
        if t.category != 'complex':
            return False
        if d_arg['test_type'] not in ('reduction',):
            return False
    if d_arg['paired_pragmas'] and t.language != "fortran":
            return False
    
    if t.category == 'complex' and d_arg['test_type'] in ('reduction_atomic','atomic','threaded_atomic'):
        return False

    name_folder = [d_arg["test_type"], t.serialized ] + sorted([k for k,v in d_arg.items() if v is True])
    if d_arg['collapse'] != 0:
        name_folder += [ f"collapse_n{d_arg['collapse']}" ]

    folder =  os.path.join("test_src",t.language,"hierarchical_parallelism",'-'.join(name_folder))
    os.makedirs(folder, exist_ok=True)

    with open(os.path.join(folder,"Makefile"),'w') as f:
        f.write(templateEnv.get_template(f"Makefile.jinja2").render(ext="cpp" if t.language == "cpp" else "F90"))

    d_Construtor = {'reduction': Fold,
                    'atomic': Fold,
                    'reduction_atomic': Fold,
                    'memcopy': Memcopy,
                    'threaded_reduction': Fold,
                    'threaded_atomic': Fold}

    Constructor = d_Construtor[d_arg["test_type"]]
    for path in omp_construct:
        if d_arg["test_type"].startswith('threaded'):
            path = ['parallel for'] + path
        Constructor(path,d_arg).write_template_rendered(folder)
#
# ___                                  
#  |  ._  ._     _|_   |   _   _  o  _ 
# _|_ | | |_) |_| |_   |_ (_) (_| | (_ 
#         |                    _|      
#
def check_validy_arguments(possible_values, values, type_):
    wrong_value = set(values) - set(possible_values)
    if wrong_value:
        print (ovo_usage)
        print (f'{wrong_value} are not valid {type_}. Please choose in {possible_values}')
        sys.exit()

import argparse
class EmptyIsBoth(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        if len(values) == 0:
            values = [True,False]
        setattr(namespace, self.dest, values)

class EmptyIsAllTestType(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        possible_values = ['atomic','reduction','reduction_atomic', 'memcopy','threaded_atomic','threaded_reduction']
        if len(values) == 0:
            values = possible_values
        check_validy_arguments(possible_values, values, 'test type')
        setattr(namespace, self.dest, values)

class EmptyIsAllDataType(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        possible_values =  ['float','complex<float>', 'double', 'complex<double>', 'REAL', 'COMPLEX', 'DOUBLE PRECISION', 'DOUBLE COMPLEX']
        if len(values) == 0:
            values = possible_values
        check_validy_arguments(possible_values, values, 'data type')
        setattr(namespace, self.dest, values)

class EmptyIsAllStandart(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        if len(values) == 0:
            values = ['cpp11', 'cpp17','cpp20','F77']
        setattr(namespace, self.dest, values)

class EmptyIsTwo(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        if not values:
            values = [0, 1,2]
        setattr(namespace, self.dest, values)

import argparse
def ListOfBool(v):
    try:
        return eval(v)
    except:
        raise argparse.ArgumentTypeError('Boolean value expected.')

if __name__ == '__main__':
    with open(os.path.join(dirname,'template','ovo_usage.txt')) as f:
        ovo_usage=f.read()

    parser = argparse.ArgumentParser(usage=ovo_usage)
    action_parsers = parser.add_subparsers(dest='command')

    hp_parser = action_parsers.add_parser("hierarchical_parallelism")

    hp_parser.add_argument('--test_type', nargs='*', default=['atomic','reduction','memcopy'], action=EmptyIsAllTestType)
    hp_parser.add_argument('--data_type',nargs='*', default=['float','complex<double>', 'REAL', 'DOUBLE COMPLEX'], action=EmptyIsAllDataType)
    hp_parser.add_argument('--loop_pragma', nargs='*', default=[False], action=EmptyIsBoth, type=ListOfBool)
    hp_parser.add_argument('--paired_pragmas', nargs='*', default=[False], action=EmptyIsBoth, type=ListOfBool)
    hp_parser.add_argument('--avoid_user_defined_reduction', nargs='*', default=[False], action=EmptyIsBoth, type=ListOfBool)
    hp_parser.add_argument('--collapse', nargs='*', default=[0], action=EmptyIsTwo, type=ListOfBool)

    hp_parser.add_argument('--append', action='store_true' )
    
    mf_parser = action_parsers.add_parser("mathematical_function")
    mf_parser.add_argument('--standart', nargs='*', default=['cpp11','F77'], action=EmptyIsAllStandart)
    mf_parser.add_argument('--complex',  nargs='*', default=[True,False], action=EmptyIsBoth, type=ListOfBool)
    mf_parser.add_argument('--long',  nargs='*', default=[False], action=EmptyIsBoth, type=ListOfBool)
    mf_parser.add_argument('--append', action='store_true')

    l_args = [ parser.parse_args() ]
    if not l_args[0].command:
        l_args = [ parser.parse_args(['hierarchical_parallelism']), 
                parser.parse_args(['mathematical_function']) ]
    
    with open(os.path.join(dirname,"config","omp_struct.json"), 'r') as f:
        omp_construct = combinations_construct(json.load(f))
     
    if not any(args.append for args in l_args):
        print('Removing ./test_src...')
        shutil.rmtree('./test_src', ignore_errors=True)

    for args in l_args:
      d_args = dict(vars(args))
      del d_args['command']
      del d_args['append']

      k = d_args.keys()
      for p in product(*d_args.values()):
        d = {k:v for k,v in zip(k,p)}
        print(d)
        if args.command == 'hierarchical_parallelism':
            gen_hp(d,omp_construct)
        else:
            gen_mf(d)
