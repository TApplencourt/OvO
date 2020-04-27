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

r_compilation = DRegex("\w+\.(?:cpp|F90) -o (\w+)\.exe$", "make.*?(\w+)\.exe\]\s+(.*)")
r_runtime = DRegex("\./(\w+)\.exe$", "make.*?run_(\w+)\]\s+(.*)")

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

    def test_launch02(self):
        str_ = "fortran target_teams_distribute__parallel.f90 -o target_teams_distribute__parallel.exe"
        m  = re.findall(r_compilation.launch, str_).pop()
        self.assertEqual(m, "target_teams_distribute__parallel")

    def test_launch02(self):
        str_ = "timeout 45s fortran target_teams_distribute__parallel.f90 -o target_teams_distribute__parallel.exe"
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
        str_ = "make:11 [run_lroundf_long_int_float] Error 70 (ignored)"
        m, error  = re.findall(r_runtime.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Segfault")

class Result(NamedTuple):
    path: str
    test: set
    failure: dict
    
def parse_log(file_path, mode, avoid_long_double, avoid_loop):

    r = Result(file_path, set(), {} )

    if not os.path.exists(p):
        return r

    if mode == "compilation":
        regex = r_compilation
    elif mode == "runtime":
        regex =  r_runtime

    with open(p) as f:
        for line in f:
            for m in re.findall(regex.launch, line):
                if not (avoid_long_double and 'long_double' in m) and not (avoid_loop and 'loop' in m):
                    r.test.add(m)
            for m,error in re.findall(regex.error,line):
                if not (avoid_long_double and 'long_double' in m) and not (avoid_loop and 'loop' in m):
                    r.failure[m] = error

    return r

#  _                    
# | \ o  _ ._  |  _.    
# |_/ | _> |_) | (_| \/ 
#          |         /  
#
def display(name, l_result,  mode=None):
    from operator import itemgetter
    compilation, runtime = l_result

    # Total number of test run.
    total_test = len(compilation.test | runtime.test ) 
    # Total failure 
    total_fail = len( set(compilation.failure) | set(runtime.failure) )
    total_success = total_test - total_fail
    if total_test == 0: 
        return

    l_to_print=[]

    if mode=='failed':
        for type_, d in  ("Compile error", compilation.failure), ("Runtime error", runtime.failure):
            if d:
                l_to_print.append(f"# {type_}")
                # Sort by error message
                array = sorted(d.items(),key=itemgetter(1))
                # Display taking care of alignement  
                max_width = max(len(test) for test, _ in array)
                for test, error in array:
                    l_to_print.append(f"{test:{max_width}} {error}")
                l_to_print.append('')

    elif mode=='passed':
        l_to_print.append("# Tests who passed")
        for k in sorted(runtime.test - set(runtime.failure)):
            l_to_print.append(k)
        l_to_print.append('')
    
    if mode=='detailed' or l_to_print:
        if name:
            print (f'>> {name}')
        s_runtime_compilation = set()
        s_runtime_incorrect_result = set()
        for n,e in runtime.failure.items():
            try:
                _, i, *_ = e.split()
                if i == '112':
                    s_runtime_incorrect_result.add(n)
                else:
                    raise ValueError
            except ValueError:
                 s_runtime_compilation.add(n)

        print (f'{total_success} / {total_test} ( {total_success/total_test :.0%} ) pass [failures: {len(set(compilation.failure)) } compilation, {len(s_runtime_compilation)} offload, {len(s_runtime_incorrect_result)} incorrect results]')
        print ('\n'.join(l_to_print) )

#                
# |\/|  _. o ._  
# |  | (_| | | | 
#                

if __name__ == "__main__":

    import sys
    import os.path
    # This function is called by a bach script, hence the quite non pythonic input convension.
    # It's easier to do the busness logic here than in bath

    # The second and thirs arguments and sis the "mode" of display.
    # Should we print only the summary, the failed or the past tests.
    name = sys.argv[1]

    if sys.argv[2] == 'true':
        mode_display = "detailed"
    elif sys.argv[3] == 'true':
        mode_display = "failed"
    elif sys.argv[4] == 'true':
        mode_display = "passed"
    else:
        mode_display = 'summary'

    # The last arguments skip the long_double example. Indeed, GPUs have limited support for them
    avoid_long_double = True if sys.argv[5] == 'true' else False
    avoid_loop = True if sys.argv[6] == 'true' else False

    paths =  sys.argv[7:]

    d_result = {}
    for folder in paths:
        l_result = []
        for mode in ("compilation","runtime"):
            p = os.path.join(folder,f"{mode}.log")
            l_result.append(parse_log(p,mode, avoid_long_double, avoid_loop))
            
        d_result[folder] = l_result[:]
        if mode_display != 'summary':
            display(folder, l_result, mode_display) 

    # We agreage all the result,
    # Test may have the same name in different folder
    # Because we print only a summary, we just need the list of the name of the test who ffailed,
    # not their error type 
    test_c = set(); failure_c = dict()
    test_r = set(); failure_r = dict()

    for folder, (c,r) in d_result.items():
        test_c |= set(f"{folder}_{p}" for p in c.test)
        failure_c.update( {f"{folder}/{k}":e for k,e in c.failure.items() } )
    
        test_r |= set(f"{folder}_{p}" for p in r.test)
        failure_r.update( {f"{folder}/{k}":e for k,e in  r.failure.items() } )

    if mode_display == 'summary':
        display(name,  [Result("", test_c, failure_c), Result("", test_r, failure_r)], 'detailed' )
        
