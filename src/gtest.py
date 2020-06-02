#!/usr/bin/env python3
import jinja2, json, os
from itertools import tee, zip_longest
from functools import update_wrapper

dirname = os.path.dirname(__file__)
templateLoader = jinja2.FileSystemLoader(searchpath=os.path.join(dirname,"template"))
templateEnv = jinja2.Environment(loader=templateLoader)

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

def format_template(str_):
    return '\n'.join(line for line in str_.split('\n') if line.strip() ) + '\n'

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
        >>> sanitize_string('REAL')
        'real'
        >>> sanitize_string('DOUBLE PRECISION')
        'double_precision'
        >>> sanitize_string('complex<double>')
        'complex_double'
        >>> sanitize_string('*double')
        'double'
        """
        return '_'.join(self.T.lower().translate(str.maketrans("<>*", "   ")).split())

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

    @cached_property
    def language(self):
        if self.no_pt.islower():
            return 'cpp'
        else:
            return 'fortran'

#  _        _    ___          
# / \ |\/| |_)    | ._ _   _  
# \_/ |  | |      | | (/_ (/_ 
#                             

# Need to refractor this one... Too ugly or too smart
from typing import List
def combinations_construct(tree_config_path, path=['root']) -> List[List[str]]:
    
    tails = [path[1:]] if len(path[1:]) else [] 

    for children in tree_config_path[path[-1]]:
        tails += combinations_construct(tree_config_path, path + [children])
    return tails

# ___                               _                      
#  |  _   _ _|_   |_   _.  _  _ __ |_ _.  _ _|_  _  ._     
#  | (/_ _>  |_   |_) (_| _> (/_   | (_| (_  |_ (_) | \/   
#                                                     /    

class Path():

    def __init__(self, path, d_arg):
        # To facilitate the recursion. Loop are encoded as "loop_distribute" and "loop_for".
        self.path = [ ' '.join(pragma.split('_')[0] for pragma in p.split()) for p in path]

        self.T =  TypeSystem(d_arg['data_type'])
        self.test_type = d_arg['test_type']

        self.language = self.T.language
        self.avoid_user_defined_reduction = d_arg['avoid_user_defined_reduction']
        self.paired_pragmas = d_arg['paired_pragmas']
        self.loop_pragma = d_arg['loop_pragma']

    @cached_property
    def name(self):
        l_node_serialized = ("_".join(node.split()) for node in self.path)
        
        n =  "__".join(l_node_serialized)
        if self.language == "cpp":
            return n
        elif self.language == "fortran":
            return n.replace('for','do')

    @cached_property
    def ext(self):
        if self.language == "cpp":
            return "cpp"
        elif self.language == "fortran":
            return "F90"
        return NotImplementedError

    @cached_property
    def filename(self):
        return f"{self.name}.{self.ext}"

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
        i0 = ord('i')
        return [ Idx(chr(i0+i),f"N_{chr(i0+i)}",64) for i in range(self.n_loop) ]

        
    @cached_property
    def fat_path(self):

        l, i_loop = [], 0

        n_reduce  = 0
        target = False
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
        if not self.loops:
            return "1"

        return f"{'*'.join(l.N for l in self.loops)}"

    @cached_property
    def template_rendered(self):
        
        if self.test_type  == 'atomic' and self.has("simd"):
            return False

        if self.test_type == 'reduction_atomic' and not any("partial" in p for p in self.fat_path):
            return False
        
        if self.test_type  == 'reduction_atomic' and self.balenced and self.n_loop == 1:
            return False

        if not self.loop_pragma and self.has('loop'):
            return False
        if self.loop_pragma and not self.has('loop'):
            return False

        template = templateEnv.get_template(f"fold.{self.ext}.jinja2")

        str_ = template.render(name=self.name,
                               family=self.test_type,
                               fat_path=self.fat_path,
                               loops=self.loops,
                               balenced=self.balenced,
                               only_teams=self.only_teams,
                               only_parallel=self.only_parallel,
                               expected_value=self.expected_value,
                               T_category=self.T.category,
                               T_type=self.T.internal,
                               T=self.T.T,
                               avoid_user_defined_reduction=self.avoid_user_defined_reduction,
                               paired_pragmas=self.paired_pragmas)
                               
        return format_template(str_)

class Memcopy(Path):

    @cached_property
    def index(self):
        l=[]
        n = self.n_loop
        for j in reversed(range(n)):
            head, *tail = self.loops[j:]
            str_ = [ f"({head.i}-1)" if self.language =='fortran' else head.i  ] + [k.N for k in tail]
            l.append('*'.join(str_))
        if self.language == 'fortran':
            return '+'.join(l) + '+1'
        else:
            return '+'.join(l)
    @cached_property
    def size(self):
        return '*'.join(l.N for l in self.loops) 

    @cached_property
    def template_rendered(self):
        if not self.balenced or self.only_target:
            return False

        if not self.loop_pragma and self.has('loop'):
            return False
        if self.loop_pragma and not self.has('loop'):
            return False

        template = templateEnv.get_template(f"test_memcopy.{self.ext}.jinja2")

        str_ = template.render(name=self.name,
                               fat_path=self.fat_path,
                               loops=self.loops,
                               index=self.index,
                               size=self.size,
                               T_category=self.T.category,
                               T_type=self.T.internal,
                               T=self.T.T)

        return format_template(str_)

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
    def have_complex(self):
        return any(t.T.category == 'complex' for t in self.l)

    @cached_property
    def template_rendered(self):

        # We don't handle in pointer
        if any(t.T.is_pointer and t.is_input for t in self.l ):
            return None

        template = templateEnv.get_template(f"test_math.{self.ext}.jinja2")
        
        str_ = template.render(name=self.name, l_argv=self.l, scalar_output= self.scalar_output, have_complex=self.have_complex)
        return format_template(str_)

#  -                                                   
# /   _   _|  _     _   _  ._   _  ._ _. _|_ o  _  ._  
# \_ (_) (_| (/_   (_| (/_ | | (/_ | (_|  |_ | (_) | | 
#                   _|                                 
#

def gen_mf(d_arg):
    print (d_arg)
    
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

    name_folder = [std] + [k for k,v in d_arg.items() if v == True]    
    folder = os.path.join("test_src","mathematical_function",language,'-'.join(name_folder))
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
                    if m.template_rendered:
                        with open(os.path.join(folder,m.filename),'w') as f:
                            f.write(m.template_rendered)
       

def gen_hp(d_arg, omp_construct):
    
    print (d_arg) 
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

    name_folder = [d_arg["test_type"], t.serialized ] + [k for k,v in d_arg.items() if v == True]
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
import argparse
class EmptyIsBoth(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        if len(values) == 0:
            values = [True,False]
        setattr(namespace, self.dest, values)

import argparse
def ListOfBool(v):
    try:
        return eval(v)
    except:
        raise argparse.ArgumentTypeError('Boolean value expected.')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate tests.')
    action_parsers = parser.add_subparsers(dest='command')
    hp_parser = action_parsers.add_parser("hierarchical_parallelism")

    hp_parser.add_argument('--test_type', nargs='+', default=['atomic','reduction'])
    hp_parser.add_argument('--data_type',nargs='+', default=['float','complex<double>', 'REAL', 'DOUBLE COMPLEX'])
    hp_parser.add_argument('--loop_pragma', nargs='*', default=[False], action=EmptyIsBoth, type=ListOfBool)
    hp_parser.add_argument('--paired_pragmas', nargs='*', default=[False], action=EmptyIsBoth, type=ListOfBool)
    hp_parser.add_argument('--avoid_user_defined_reduction', nargs='*', default=[False], action=EmptyIsBoth, type=ListOfBool)

    mf_parser = action_parsers.add_parser("mathematical_function")
    mf_parser.add_argument('--standart', nargs='*', default=['cpp11','F77'])
    mf_parser.add_argument('--complex',  nargs='*', default=[True,False], action=EmptyIsBoth, type=ListOfBool)

    args = parser.parse_args()
    if not args.command:
        parser.parse_args(['--help'])
        sys.exit()

    with open(os.path.join(dirname,"config","omp_struct.json"), 'r') as f:
        omp_construct = combinations_construct(json.load(f))

    gen = gen_hp if args.command == 'hierarchical_parallelism' else gen_mf
    from itertools import product
    d_args = dict(sorted(vars(args).items()))
    del d_args['command']

    k = d_args.keys()
    for p in product(*d_args.values()):
        d = {k:v for k,v in zip(k,p)}
        if args.command == 'hierarchical_parallelism':
            gen_hp(d,omp_construct)
        else:
            gen_mf(d)
