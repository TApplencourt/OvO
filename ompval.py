#!/usr/bin/env python3

import json, sys, os
from ompval.utils import omp_walk
from ompval.utils import gen_test, gen_makefile

import argparse

parser = argparse.ArgumentParser(description='OpenMP Validation (kinda).')
parser.add_argument("--tree_config_path", help='''path the openmp pragma tree config file. (default: config/intel_oneapi_beta0.txt''' )
parser.add_argument("--test_path", help='''path to the directory where the test will be generated. (default: tests''' )

args = parser.parse_args()




# Load configurations files.
dirname = os.path.dirname(__file__)

tree_config_path = os.path.join(dirname,'config/intel_oneapi_beta0.txt') if not args.tree_config_path else args.tree_config_path
typing_config_path = os.path.join(dirname,'config/typing.txt')

with open(tree_config_path, 'r') as f:
    omp_tree = json.load(f)

with open(typing_config_path, 'r') as f:
    omp_typing = json.load(f)



output_folder = "omp_tests"


paths = omp_walk(['root'],omp_tree)[1:] # Drop the 'root' path

l_name = []
for i, (_, *path) in enumerate(paths): # Drop the 'root' node

    print (i,path)

    # Generate test
    name = gen_test(path, omp_typing, [10,10,10], test="test_atomic.cpp.jinja2", folder=output_folder)
    l_name.append(name)

gen_makefile(l_name,folder=output_folder)

