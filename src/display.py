#!/usr/bin/env python3

import re
from typing import NamedTuple

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

r_compilation = DRegex("\w+\.cpp -o (\w+)\.exe$", "make.*?(\w+)\.exe\]\s+(.*)")
r_runtime = DRegex("^\./(\w+)\.exe$", "make.*?run_(\w+)\]\s+(.*)")

import unittest
class TestCompilationLaunch(unittest.TestCase):
    
    def test_launch00(self):
        str_ = "gcc target_teams_distribute__parallel.cpp -o target_teams_distribute__parallel.exe"
        m  = re.findall(r_compilation.launch, str_).pop()
        self.assertEqual(m, "target_teams_distribute__parallel")

    def test_launch01(self):
        str_ = "CC -h noacc -h omp lroundf_long_int_float.cpp -o lroundf_long_int_float.exe"
        m  = re.findall(r_compilation.launch, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")

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
        str_ = "***make: [lroundf_long_int_float.exe] Error 1 (ignored)"
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
        str_ = "make:11 [run_lroundf_long_int_float] Segfault"
        m, error  = re.findall(r_runtime.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Segfault")

class Result(NamedTuple):
    test: set
    failure: dict

def parse_log(file_path, mode, avoid_long_double):

    r = Result( set(), {} )

    if not os.path.exists(p):
        return r

    if mode == "compilation":
        regex = r_compilation
    elif mode == "runtime":
        regex =  r_runtime

    with open(p) as f:
        for line in f:
            for m in re.findall(regex.launch, line):
                if not (avoid_long_double and 'long_double' in m):
                    r.test.add(m)
            for m,error in re.findall(regex.error,line):
                if not (avoid_long_double and 'long_double' in m):
                    r.failure[m] = error
    
    return r

#  _                    
# | \ o  _ ._  |  _.    
# |_/ | _> |_) | (_| \/ 
#          |         /  
#
def display(l_result,  mode=None):
    from operator import itemgetter

    compilation, runtime = l_result
    # Total number of test run.
    total_test = len(compilation.test | runtime.test ) 
    # Total failure 
    total_fail = len( set(compilation.failure) | set(runtime.failure) )
    total_success = total_test - total_fail
    
    if total_test != 0: 
        print (f'{total_success} / {total_test} ( {total_success/total_test :.0%} ) pass [ {len(set(compilation.failure)) } compilation failures / {len(set(runtime.failure))} runtime failures ]')
    else:
        print ("No tests where run in this directory")
        return

    if mode=='failure':
        for type_, d in  ("# Compile error", compilation.failure), ("# Runtime error", runtime.failure):
            if d:
                print (type_)
                # Sort by error message
                array = sorted(d.items(),key=itemgetter(1))
                # Display taking care of alignement  
                max_width = max(len(test) for test, _ in array)
                for test, error in array:
                    print(f"{test:{max_width}} {error} ")
            else:
                print (f"No {type_}")
    elif mode=='pass':
        print ("# Tests who passed")
        for k in sorted(runtime.test - set(runtime.failure)):
            print (k)

#                
# |\/|  _. o ._  
# |  | (_| | | | 
#                

if __name__ == "__main__":

    import sys
    import os.path
    # This function is called by a bach script, hence the quite non pythonic input convension.
    # It's easier to do the busness logic here than in bath

    # First argument is the folder who may containt the {compilation,runtime}.log
    folder = sys.argv[1]

    # The second and thirs arguments and sis the "mode" of display.
    # Should we print only the summary, the failed or the past tests.
    if sys.argv[2] == 'true':
        mode_display = "failure"
    elif sys.argv[3] == 'true':
        mode_display = "pass"
    else:
        mode_display = None

    # The last arguments skip the long_double example. Indeed, GPUs have limited support for them
    if sys.argv[4] == 'true':
        avoid_long_double = True
    else:
        avoid_long_double = False

    l_result = []
    print (f'>> {folder}')
    for mode in ("compilation","runtime"):
        p = os.path.join(folder,f"{mode}.log")
        l_result.append(parse_log(p,mode, avoid_long_double))

    display(l_result, mode_display)

