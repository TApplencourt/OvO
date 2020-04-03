#!/usr/bin/env python3


# Line compilation 
# $(CXX) $(CXXFLAGS) $< -o $@

# Regex parsing command line: 
# \w+\.cpp -o (\w+)\.exe$

# Regex parsing make error message

#make: [f.exe] Error 1 (ignored)
#***make:  [f.exe] Error 1 (ignored)
#make:11 [f.exe] Error 1 (ignored)

# Regex parsing error compilation:
# make.*?(\w+)\.exe(.*)(Error.*)"

# Regex parsing error run
# make.*?run_(\w+)(.*)(Error.*)

#make: [run_f] Error 1 (ignored)
#***make:  [run_f] Error 1 (ignored)
#make:11 [run_f] Error 1 (ignored)

import re
from typing import NamedTuple
class Employee(NamedTuple):
    test: set
    failure: dict

def parse_log(io_stream, mode, avoid_long_double):
    if mode == "compilation":
        regex_test = "\w+\.cpp -o (\w+)\.exe$"
        regex_error = "make.*?(\w+)\.exe.*(Error.*)"
    elif mode == "runtime":
        regex_test = "^\./(\w+)\.exe$"
        regex_error = "make.*?run_(\w+)(.*)(Error.*)"

    s_test = set()
    d_failure = dict()

    for line in io_stream:
        for m in re.findall(regex_test, line):
            if not (avoid_long_double and 'long_double' in m):
                s_test.add(m)
        for m,error in re.findall(regex_error,line):
            if not (avoid_long_double and 'long_double' in m):
                d_failure[m] = error

    return Employee(s_test, d_failure)

def display( complile, runtime,  mode=None):
    # Total number of test run.
    total_test = len(complile.test | runtime.test ) 
    # Total failure 
    total_fail = len( set(complile.failure) | set(runtime.failure) )
    total_sucess = total_test - total_fail
    
    if total_test != 0: 
        print (f'{total_sucess} / {total_test} ( {total_sucess/total_test :.0%} ) pass [ {len(set(complile.failure)) } complile failures / {len(set(runtime.failure))} runtime failures ]')
    else:
        print ("No tests where run in this directory")
        return

    if mode=='failure':
        for type_, d in  ("Compile error", complile.failure), ("Runtime error", runtime.failure):
            if d:
                print (type_)
                for k,v in d.items():
                    print (k,v)
            else:
                print (f"No {type_}")
    if mode=='pass':
        print ("-- Tests who passed:")
        for k in runtime.test - set(runtime.failure):
            print (k)


import sys
import os.path
folder = sys.argv[1]

if sys.argv[2] == 'true':
    mode_display = "failure"
elif sys.argv[3] == 'true':
    mode_display = "pass"
else:
    mode_display = None

if sys.argv[4] == 'true':
    avoid_long_double = True
else:
    avoid_long_double = False

print (sys.argv)

l = []
print (f'>> {folder}')
for mode in ("compilation","runtime"):
    p = os.path.join(folder,f"{mode}.log")
    if os.path.exists(p):
        with open(p) as f:
            l.append(parse_log(f,mode, avoid_long_double))
    else:
        l.append(Employee(set(),{}))
display(l[0],l[1], mode_display)

