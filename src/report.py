#!/usr/bin/env python3

import re, unittest, os
from typing import NamedTuple
from collections import defaultdict

dirname = os.path.dirname(__file__)

#  _                    
# |_) _. ._ _ o ._   _  
# |  (_| | _> | | | (_| 
#                    _|

# Store the regex who will be used to parse Make output.
# In a suspicion of bugs regarding the "error" regex,
# verify that  `grep make | wc -l $file.log` match the number of failure displayed.
class DRegex(NamedTuple):
    launch: str
    error: str

r_compilation = DRegex("\w+\.(?:cpp|F90) -o (\w+)\.exe$", "make.*?(\w+)\.exe\]\s+(.*)")
r_runtime = DRegex("\./(\w+)\.exe$", "make.*?run_(\w+)\]\s+(.*)")

class TestCompilationLaunch(unittest.TestCase):
    
    def test_launch00(self):
        str_ = "gcc target_teams_distribute__parallel.cpp -o target_teams_distribute__parallel.exe"
        m  = re.findall(r_compilation.launch, str_).pop()
        self.assertEqual(m, "target_teams_distribute__parallel")

    def test_launch01(self):
        str_ = "CC -h noacc -h omp lroundf_long_int_float.cpp -o lroundf_long_int_float.exe"
        m  = re.findall(r_compilation.launch, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")

    def test_launch02(self):
        str_ = "fortran target_teams_distribute__parallel.F90 -o target_teams_distribute__parallel.exe"
        m  = re.findall(r_compilation.launch, str_).pop()
        self.assertEqual(m, "target_teams_distribute__parallel")

    def test_launch02(self):
        str_ = "timeout 45s fortran target_teams_distribute__parallel.F90 -o target_teams_distribute__parallel.exe"
        m  = re.findall(r_compilation.launch, str_).pop()
        self.assertEqual(m, "target_teams_distribute__parallel")


class TestCompilationError(unittest.TestCase):

    def test_error00(self):
        str_ = "make: [Makefile:7: lroundf_long_int_float.exe] Error 1 (ignored)"
        m, error  = re.findall(r_compilation.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 1 (ignored)")

    def test_error01(self):
        str_ = "make: [lroundf_long_int_float.exe] Error 1 (ignored)"
        m, error  = re.findall(r_compilation.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 1 (ignored)")

    def test_error02(self):
        str_ = "make: *** [lroundf_long_int_float.exe] Error 1 (ignored)"
        m, error  = re.findall(r_compilation.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 1 (ignored)")

    def test_error03(self):
        str_ = "make:11 [lroundf_long_int_float.exe] Error 1 (ignored)"
        m, error  = re.findall(r_compilation.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 1 (ignored)")

    def test_error04(self):
        str_ = "make:11 [lroundf_long_int_float.exe] Segfault"
        m, error  = re.findall(r_compilation.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Segfault")


class TestRutimeLaunch(unittest.TestCase):
    def test_launch00(self):
        str_ = "./trunc_long_double_long_double.exe"
        m  = re.findall(r_runtime.launch, str_).pop()
        self.assertEqual(m, "trunc_long_double_long_double")

class TestRuntimeError(unittest.TestCase):

    def test_error00(self):
        str_ = "make: [Makefile:7: run_lroundf_long_int_float] Error 1 (ignored)"
        m, error  = re.findall(r_runtime.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 1 (ignored)")

    def test_error01(self):
        str_ = "make: [run_lroundf_long_int_float] Error 1 (ignored)"
        m, error  = re.findall(r_runtime.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 1 (ignored)")

    def test_error02(self):
        str_ = "***make: [run_lroundf_long_int_float] Error 1 (ignored)"
        m, error  = re.findall(r_runtime.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 1 (ignored)")

    def test_error03(self):
        str_ = "make:11 [run_lroundf_long_int_float] Error 1 (ignored)"
        m, error  = re.findall(r_runtime.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 1 (ignored)")

    def test_error04(self):
        str_ = "make:11 [run_lroundf_long_int_float] Aborted"
        m, error  = re.findall(r_runtime.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Aborted")

def parse_folder(folder):
    d = {}
    
    with open(os.path.join(folder,"compilation.log")) as f:
        for line in f:
            for m in  re.findall(r_compilation.launch, line):
                d[os.path.join(folder,m)] = None

            for m,error in re.findall(r_compilation.error, line):
                d[os.path.join(folder,m)] = 'compilation'
    
    with open(os.path.join(folder,"runtime.log")) as f:
        for line in f:
            for m,error in re.findall(r_runtime.error, line):
                 l = error.split()
                 if l != 'Error':
                        error = 'runtime'
                 elif l[1] in ('124','137'):
                        error =  'hanging'
                 elif l[1] in ('112',):
                        error = 'wrong value'
                 else:
                        error = 'runtime'
           
                 d[os.path.join(folder,m)] = error

    return d


#  _
# | \ o  _ ._  |  _.
# |_/ | _> |_) | (_| \/
#          |         /
#

def summary_d_result(d):
    total_test = len(d)
    from collections import Counter
    d = Counter(d.values())

    c = d['compilation']
    r = d['runtime']
    h = d['hanging']
    v = d['wrong value']
    total_success = d[None]
    
    print (f'{total_success} / {total_test} ( {total_success/total_test :.0%} ) pass [failures: {c} compilation, {r} offload, {v} incorrect value, {h} hanging]')

#                
# |\/|  _. o ._  
# |  | (_| | | | 
#                
import sys
import argparse
from pathlib import Path
import os

class EmptyIsAllFolder(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        if len(values) == 0:
            folders = [os.path.join('test_result',i) for i in os.listdir('test_result') ]
            values = [ max(folders) ]

        setattr(namespace, self.dest, values)

if __name__ == "__main__":
    with open(os.path.join(dirname,'template','ovo_usage.txt')) as f:
            usage=f.read()
    parser = argparse.ArgumentParser(usage=usage)
    group = parser.add_mutually_exclusive_group()

    group.add_argument('--coarse' , action='store_true')
    group.add_argument('--failed'  , action='store_true')
    group.add_argument('--passed'  , action='store_true')
   
    parser.add_argument('result_folder', nargs='*',action=EmptyIsAllFolder)
    args = parser.parse_args()

    s_folder = set()
    for folder in args.result_folder:
        s_folder |= {os.path.dirname(path) for path in Path(folder).rglob('env.log')}
    
    d_agregaded = {}
    for folder in sorted(s_folder):
        d = parse_folder(folder)
        d_agregaded.update(d)
    
        dd = defaultdict(list)
        for name, value in d.items():
            dd[value].append(os.path.basename(name))

        if args.coarse:
            print (f'>> {folder}')
            summary_d_result(d)
        elif args.failed and set(dd.keys()) - {None}:
            print (f'>> {folder}')
            for k,v in sorted(dd.items()):
                print (f'>>> {k}')
                print ('\n'.join(sorted(v)))
        elif args.passed and dd[None]:
            print (f'>> {folder}')
            for name, value in d[None].values():
                print (n)
    
    if len(args.result_folder) == 1:
        print (f">> Summary of {args.result_folder[0]}")
    else:
        print (">> Summary")
    summary_d_result(d_agregaded)
