#!/usr/bin/env python3

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

    def has(self,constructs):
        return constructs in self.flatten_path

    @property
    def only_teams(self):
        return self.has("teams") and not self.has("distribute")

    @property
    def only_parallel(self):
        return self.has("parallel") and not self.has("for")

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
    
            if any(p in pragma for p  in ("distribute","for","simd")):
                d["loop"] = Path.idx_loop[n_loop]
                n_loop+=1

            if "target" in pragma:
                d["target"] = True

            if "teams" in pragma and self.only_teams:
                d["only_teams"] = True

            if "parallel" in pragma and self.only_parallel:
                d["only_parallel"] = True

            if any(p in pragma for p in ("teams","parallel","simd")):
                d["reduce"] = True

            l.append(d)

        return l

import os
import jinja2
dirname = os.path.dirname(__file__)
templateLoader = jinja2.FileSystemLoader(searchpath=os.path.join(dirname,"..","config","template"))
templateEnv = jinja2.Environment(loader=templateLoader)

class AtomicReduction(Path):

    @property
    def expected_value(self):
        if self.only_target:
            return " == 1"
        elif self.balenced:
            return f"== {'*'.join(l.N for l in self.loops)}"
        else:
            return f" > 0"

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


class Math():

    template = templateEnv.get_template(f"test_math.cpp.jinja2")

    def __init__(self, name, t_arguments):
        self.name = name
        self.type_output, self.n = t_arguments

    @property
    def l_type(self):
        l = [' '.join(i.split()[:-1]) for i in self.n]
        q = []
        for i in l:
            q.extend(i.split())
        return q

    @property
    def template_rendered(self):
        
        l_name = [i.split()[-1] for i in self.n]
        l_type = [' '.join(i.split()[:-1]) for i in self.n]
        

        args = [f'{i}' for i in l_name ]
        args_t = [f'{i}_t' for i in l_name ]
        
        if any('*' in t for t in l_type):
            return None

        return Math.template.render(name=self.name,
                                    args=args,
                                    args_t=args_t,
                                    l_type = l_type,
                                    type_outout = self.type_output,
                                    zip=zip)

def gen_math():
    #path_ = "/soft/compilers/gcc/8.2.0/linux-rhel7-x86_64/include/c++/8.2.0/cmath"
    path_ = "/home/tapplencourt/project/p19.21/OmpVal/config/cmath.synopsis.txt"
    import re
    regex = "^\s+(.*)\s+(\w+)\((.*)\)"

    with open(path_) as f:
        test_str = f.read()

    from collections import defaultdict

    d = defaultdict(list)
    matches = re.finditer(regex, test_str, re.MULTILINE)
    for match in matches:
        d[ match.group(2).strip() ] .append( (match.group(1), match.group(3).split(',') )) 
 
    return d

#  -                                                   
# /   _   _|  _     _   _  ._   _  ._ _. _|_ o  _  ._  
# \_ (_) (_| (/_   (_| (/_ | | (/_ | (_|  |_ | (_) | | 
#                   _|                                 
#

if __name__ == '__main__':
    import json, os
    with open(os.path.join(dirname,"..","config","omp_struct.json"), 'r') as f:
        omp_tree = json.load(f)  
    makefile = templateEnv.get_template(f"Makefile.jinja2").render()
    
    d ={"memcopy":Memcopy,
        "atomic":Atomic,
        "reduction":Reduction}

    test='math' 
    folder = os.path.join("tests",test)
    os.makedirs(folder, exist_ok=True)
    d_ = gen_math()
    for k,lv in d_.items():
        # For now take the first.
        for v in lv:
            m = Math(k,v)
            if m.template_rendered:
                uuid = ['_'.join(m.type_output.split())] + m.l_type
                name = f"{k}_{'_'.join(uuid)}.cpp"
                with open(os.path.join(folder,name),'w') as f:
                    f.write(m.template_rendered)

    for test, Constructor in d.items():
        folder = os.path.join("tests",test)
        os.makedirs(folder, exist_ok=True)

        with open(os.path.join(folder,'Makefile'),'w') as f:
            f.write(makefile)
 
        for path in combinations_construct(omp_tree):
            p = Constructor(path)
            
            if p.template_rendered: 
                with open(os.path.join(folder,f'{p.filename}.cpp'),'w') as f:
                      f.write(p.template_rendered) 
