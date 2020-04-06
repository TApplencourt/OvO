#!/usr/bin/env python3

from itertools import tee
def pairwise(iterable):
    "s -> (s0,s1), (s1,s2), (s2, s3), ..."
    a, b = tee(iterable)
    next(b, None)
    return zip(a, b)

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

    from collections import namedtuple
    Idx = namedtuple("Idx",'i N v')
    idx_loop =  [Idx('i','L',5), 
                 Idx('j','M',6), 
                 Idx('k','N',7)]

    def __init__(self, path):
        self.path = path

    @property
    def filename(self):
        # Some node in the path have space in their name. We will replace them with
        # one underscore. Level will be replaced with two.
        l_node_serialized = ("_".join(node.split()) for node in self.path)
        return "__".join(l_node_serialized)
    
    @property
    def flatten_path(self):
        from itertools import chain
        return list(chain.from_iterable(map(str.split,self.path)))

    def follow_by(self,a,b):
        for i,j in pairwise(self.flatten_path):
            if (i == a) and (j == b):
                return True
        return False

    def has(self,constructs):
        return constructs in self.flatten_path

    @property
    def only_teams(self):
        return self.has("teams") and not ( self.follow_by("teams","distribute") or self.follow_by("teams","loop") )

    @property
    def only_parallel(self):
        return self.has("parallel") and not  ( self.follow_by("parallel", "for") or self.follow_by("parallel","loop") )

    @property
    def only_target(self):
        return len(self.flatten_path) == 1

    @property
    def balenced(self):
        return not self.only_parallel and not self.only_teams
    
    @property
    def n_loop(self):
        return sum("loop" in fat_pragma for fat_pragma in self.fat_path)

    @property
    def loops(self):
        return Path.idx_loop[:self.n_loop]

    @property
    def fat_path(self):
        l, n_loop = [], 0

        for pragma in self.path:
            d = {"pragma":pragma}
    
            if any(p in pragma for p  in ("distribute","for","simd","loop")):
                d["loop"] = Path.idx_loop[n_loop]
                n_loop+=1

            if "target" in pragma:
                d["target"] = True

            if "teams" in pragma and self.only_teams:
                d["only_teams"] = True

            if "parallel" in pragma and self.only_parallel:
                d["only_parallel"] = True

            if any(p in pragma for p in ("teams","parallel","simd","loop")):
                d["reduce"] = True

            l.append(d)

        return l

import os
import jinja2
dirname = os.path.dirname(__file__)
templateLoader = jinja2.FileSystemLoader(searchpath=os.path.join(dirname,"template"))
templateEnv = jinja2.Environment(loader=templateLoader)

class AtomicReduction(Path):

    @property
    def expected_value(self):
        if self.only_target:
            return ("==", "1")
        elif self.balenced:
            return ("==", f"{'*'.join(l.N for l in self.loops)}")
        else:
            return (">", "0")

class Atomic(AtomicReduction):

    template = templateEnv.get_template(f"test_atomic.cpp.jinja2")

    @property
    def template_rendered(self):
        if self.has("simd"):
            return 

        return Atomic.template.render(name=self.filename,
                                      fat_path=self.fat_path,
                                      loops=self.loops,
                                      expected_value=self.expected_value)

class Reduction(AtomicReduction):

    template = templateEnv.get_template(f"test_reduction.cpp.jinja2")

    @property
    def template_rendered(self):

        return Reduction.template.render(name=self.filename,
                                        fat_path=self.fat_path,
                                        loops=self.loops,
                                        expected_value=self.expected_value)
class Memcopy(Path):

    template = templateEnv.get_template(f"test_memcopy.cpp.jinja2")

    @property
    def index(self):
        if self.n_loop == 1:
            return "i"
        elif self.n_loop == 2:
            return "j + i*M"
        elif self.n_loop == 3:
            return "k + j*N + i*N*M"

    @property
    def size(self):
        return '*'.join(l.N for l in self.loops) 

    @property
    def template_rendered(self):
        if not self.balenced or p.only_target:
            return

        return Memcopy.template.render(name=self.filename,
                                      fat_path=self.fat_path,
                                      loops=self.loops,
                                      index=self.index,
                                      size=self.size)


#from cmath import complex
class ccomplex(object):
   
    def __init__(self, a, b):
        self.real = a
        self.img = b

    def __str__(self):
        return f"{self.real}, {self.img}"

class Math():

    template = templateEnv.get_template(f"test_math.cpp.jinja2")

    c = {'bool': [True],
         'float': [0.42, 4.42],
         'long int': [ 1 ], 
         'unsigned': [ 1 ], 
         'double': [ 0.42, 4.42] , 
         'int': [ 1, 0, 2 ] , 
         'long long int': [ 1] , 
         'long double': [ 0.42, 4.42], 
         'complex<float>' : [ ccomplex(0.42, 0.) ,  ccomplex(4.42, 0.) ],      
         'complex<double>' : [ ccomplex(0.42, 0.) , ccomplex(4.42, 0.) ],
         'complex<long double>' : [ ccomplex(0.42, 0.) , ccomplex(4.42, 0.) ],
         }

    def __init__(self, name, d_argument, domain):
        self.name = name
        self.input_name = d_argument['input_name']
        self.input_types = d_argument['input_types']
        self.output_type = d_argument['output_type']
        
        if "domain" in domain:
            self.domain = domain['domain']
            self.domain_complex = None
        else:
            self.domain = None 
            self.domain_complex = domain['domain_complex']

    @property
    def output_type_T(self):
        if self.output_type_category != "complex":
            return None

        return self.output_type.split('<')[1][:-1];
    
    @property
    def output_type_category(self):
        if self.output_type in ('long int', 'int','long long int','unsigned'):
            return 'integer'
        elif  self.output_type in ('float','double','long double'):
            return 'float'
        elif self.output_type in ('complex<float>', 'complex<double>',  'complex<long double>'):
            return 'complex'
        else: 
            return self.output_type

    @property
    def uuid(self):
         a =str.maketrans("<>", "  ")

         i = map(str.split, ( s.translate(a) for s in [self.name, self.output_type] + self.input_types ) )
         from itertools import chain 
         return '_'.join(chain.from_iterable(i))


    @property
    def template_rendered(self):

        # We don't handle pointer
        if any('*' in t for t in self.input_types + [self.output_type] ):
            return None

        l_input_values = ( Math.c[type_] for type_ in self.input_types )

        
        from itertools import product
        for input_values  in product(*l_input_values):

            d = {name:value for name,value in zip(self.input_name, input_values) }
            from math import isinf, isnan
            d['isinf'] = isinf
            d['isnan'] = isnan

            if self.output_type_category == 'complex':
                if self.domain_complex == 'None' or self.domain_complex == '' or eval(self.domain_complex,d): break
            else:
                if self.domain  == 'None' or self.domain == '' or eval(self.domain,d): break

        return Math.template.render(name=self.name,
                                    input_types = self.input_types,
                                    input_names = self.input_name,
                                    output_type = self.output_type,
                                    input_values = input_values,
                                    output_type_category = self.output_type_category,
                                    output_type_T = self.output_type_T,
                                    zip=zip)

#  -                                                   
# /   _   _|  _     _   _  ._   _  ._ _. _|_ o  _  ._  
# \_ (_) (_| (/_   (_| (/_ | | (/_ | (_|  |_ | (_) | | 
#                   _|                                 
#

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description='Generate tests.')
    parser.add_argument('ompv5', metavar='literal_bool', type=str,
                   help='Generate OpenMP v5 construct (ie loop)')
    args = parser.parse_args()

    import json, os
    makefile = templateEnv.get_template(f"Makefile.jinja2").render()

    for hfolder, p in ( ("math","cmath_synopsis.json"), ("complex", "cmath_complex_synopsis.json") ):   
      with open(os.path.join(dirname,"config",p), 'r') as f:
          math_json = json.load(f)

      for version, d_ in math_json.items():
        folder = os.path.join("tests",f"{hfolder}_{version}")
        os.makedirs(folder, exist_ok=True)

        with open(os.path.join(folder,'Makefile'),'w') as f:
            f.write(makefile)

        for name, ( l_set_argument, domain) in d_.items():

            for l_arguments in l_set_argument:
                m = Math(name, l_arguments, domain)
                if m.template_rendered:
                    with open(os.path.join(folder,f'{m.uuid}.cpp'),'w') as f:
                        f.write(m.template_rendered)



    ompv5 = False if args.ompv5 == 'false' else True

    with open(os.path.join(dirname,"config","omp_struct.json"), 'r') as f:
        omp_tree = json.load(f)

    d ={"memcopy":Memcopy,
        "atomic":Atomic,
        "reduction":Reduction}

    for test, Constructor in d.items():

        folder_45 = os.path.join("tests","hp_omp45",f"{test}")
        os.makedirs(folder_45, exist_ok=True)
   
        folder_50 = os.path.join("tests","hp_omp50",f"{test}")
        os.makedirs(folder_50, exist_ok=True)

        with open(os.path.join(folder_45,'Makefile'),'w') as f:
            f.write(makefile)

        with open(os.path.join(folder_50,'Makefile'),'w') as f:
                        f.write(makefile)

        for path in combinations_construct(omp_tree):
            # Take only construct of `construct_uuid` for loop
            p = Constructor([ ' '.join(pragma.split('_')[0] for pragma in path.split()) for path in path])
            if p.template_rendered:
                if not p.has("loop"):
                    with open(os.path.join(folder_45,f'{p.filename}.cpp'),'w') as f:
                              f.write(p.template_rendered) 
                with open(os.path.join(folder_50,f'{p.filename}.cpp'),'w') as f:
                    f.write(p.template_rendered)

