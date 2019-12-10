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

class Atomic(Path):

    @property
    def expected_value(self):
        if self.only_target:
            return " == 1"
        elif self.balenced:
            return f"== {'*'.join(l.N for l in self.loops)}"
        else:
            return f" > 0"

class Memcopy(Path):

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


#  _                                                   
# /   _   _|  _     _   _  ._   _  ._ _. _|_ o  _  ._  
# \_ (_) (_| (/_   (_| (/_ | | (/_ | (_|  |_ | (_) | | 
#                   _|                                 
#
import os, jinja2

#~=~=~=~
#~ Utils
#~=~=~=~

def path2name(path):
    # Some node in the path have space in their name. We will replace them with
    # one underscore. Level will be replaced with two.
    l_node_serialized = ("_".join(node.split()) for node in path)
    return "__".join(l_node_serialized)

#~=~=~=~
#~ Template
#~=~=~=~

import os
import jinja2
# Setup jinja enviroement
dirname = os.path.dirname(__file__)
templateLoader = jinja2.FileSystemLoader(searchpath=os.path.join(dirname,"template"))
templateEnv = jinja2.Environment(loader=templateLoader)


if __name__ == '__main__':
    import json
    with open("/home/razoa/OmpVal/config/general.txt", 'r') as f:
        omp_tree = json.load(f)  

    #for test in ("atomic","reduction"):
    for test in ("memcopy",):
        folder = os.path.join("tests",test)
        template = templateEnv.get_template(f"test_{test}.cpp.jinja2")
    
        for path in combinations_construct(omp_tree):
            #p = Atomic(path)
            p = Memcopy(path)
            if test == "atomic" and p.has("simd"):
                continue
    
            if test == "memcopy" and not p.balenced:
                continue

            if test == "memcopy" and p.only_target:
                continue

            test_str = template.render(name=p.filename,
                                   fat_path=p.fat_path,
                                   loops=p.loops,
                                   index=p.index,
                                   size=p.size)
                                   #expected_value=p.expected_value)
    
            import os
            os.makedirs(folder, exist_ok=True)
            with open(os.path.join(folder,f'{p.filename}.cpp'),'w') as f:
              f.write(test_str) 
