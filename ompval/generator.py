#!/usr/bin/env python3

import json, sys, os
from utils import omp_walk
from utils import gen_test, gen_makefile

import argparse

parser = argparse.ArgumentParser(description='OpenMP Validation (kinda).')
parser.add_argument("--tree_config_path", help='''path the openmp pragma tree config file. (default: config/intel_oneapi_beta0.txt''' )
parser.add_argument("--test_path", help='''path to the directory where the test will be generated. (default: tests''' )

args = parser.parse_args()




# Load configurations files.
dirname = os.path.dirname(__file__)

tree_config_path = os.path.join(dirname,'../config/intel_oneapi_beta0.txt') if not args.tree_config_path else args.tree_config_path
typing_config_path = os.path.join(dirname,'../config/typing.txt')

with open(tree_config_path, 'r') as f:
    omp_tree = json.load(f)

with open(typing_config_path, 'r') as f:
    omp_typing = json.load(f)



output_folder = os.path.join(dirname, "../omp_tests")


paths = omp_walk(['root'],omp_tree)[1:] # Drop the 'root' path

i = 0
for test in ["memcopy","atomic","reduction"]:

  test_folder=os.path.join(output_folder,test)
  test_template=f"test_{test}.cpp.jinja2"
  l_name = []
  for _, *path in paths: # Drop the 'root' node
  
      # Generate test
      name = gen_test(path, omp_typing, [10,10,10], test=test_template, folder=test_folder)
      if name:
        print (i, test, path)
        i+=1

  gen_makefile(folder=test_folder)

