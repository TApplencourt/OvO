#!/usr/bin/env python3

import re, unittest, os,sys
from typing import NamedTuple
from collections import defaultdict

dirname = os.path.dirname(__file__)

try:
    from tabulate import tabulate
except ImportError:
    sys.path.append(dirname)
    from tabulate_local import tabulate

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
        m = re.findall(r_compilation.launch, str_).pop()
        self.assertEqual(m, "target_teams_distribute__parallel")

    def test_launch01(self):
        str_ = "CC -h noacc -h omp lroundf_long_int_float.cpp -o lroundf_long_int_float.exe"
        m = re.findall(r_compilation.launch, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")

    def test_launch02(self):
        str_ = "fortran target_teams_distribute__parallel.F90 -o target_teams_distribute__parallel.exe"
        m = re.findall(r_compilation.launch, str_).pop()
        self.assertEqual(m, "target_teams_distribute__parallel")

    def test_launch02(self):
        str_ = "timeout 45s fortran target_teams_distribute__parallel.F90 -o target_teams_distribute__parallel.exe"
        m = re.findall(r_compilation.launch, str_).pop()
        self.assertEqual(m, "target_teams_distribute__parallel")


class TestCompilationError(unittest.TestCase):
    def test_error00(self):
        str_ = "make: [Makefile:7: lroundf_long_int_float.exe] Error 1 (ignored)"
        m, error = re.findall(r_compilation.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 1 (ignored)")

    def test_error01(self):
        str_ = "make: [lroundf_long_int_float.exe] Error 1 (ignored)"
        m, error = re.findall(r_compilation.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 1 (ignored)")

    def test_error02(self):
        str_ = "make: *** [lroundf_long_int_float.exe] Error 1 (ignored)"
        m, error = re.findall(r_compilation.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 1 (ignored)")

    def test_error03(self):
        str_ = "make:11 [lroundf_long_int_float.exe] Error 1 (ignored)"
        m, error = re.findall(r_compilation.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 1 (ignored)")

    def test_error04(self):
        str_ = "make:11 [lroundf_long_int_float.exe] Segfault"
        m, error = re.findall(r_compilation.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Segfault")

    def test_error03(self):
        str_ = "make:11 *** [lroundf_long_int_float.exe] Error 124 (ignored)"
        m, error = re.findall(r_compilation.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 124 (ignored)")


class TestRutimeLaunch(unittest.TestCase):
    def test_launch00(self):
        str_ = "./trunc_long_double_long_double.exe"
        m = re.findall(r_runtime.launch, str_).pop()
        self.assertEqual(m, "trunc_long_double_long_double")


class TestRuntimeError(unittest.TestCase):
    def test_error00(self):
        str_ = "make: [Makefile:7: run_lroundf_long_int_float] Error 1 (ignored)"
        m, error = re.findall(r_runtime.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 1 (ignored)")

    def test_error01(self):
        str_ = "make: [run_lroundf_long_int_float] Error 1 (ignored)"
        m, error = re.findall(r_runtime.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 1 (ignored)")

    def test_error02(self):
        str_ = "***make: [run_lroundf_long_int_float] Error 1 (ignored)"
        m, error = re.findall(r_runtime.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 1 (ignored)")

    def test_error03(self):
        str_ = "make:11 [run_lroundf_long_int_float] Error 1 (ignored)"
        m, error = re.findall(r_runtime.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 1 (ignored)")

    def test_error04(self):
        str_ = "make:11 [run_lroundf_long_int_float] Aborted"
        m, error = re.findall(r_runtime.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Aborted")


def parse_folder(folder):
    d = {}

    with open(os.path.join(folder, "compilation.log")) as f:
        for line in f:
            for m in re.findall(r_compilation.launch, line):
                d[os.path.join(folder, m)] = None

            for m, error in re.findall(r_compilation.error, line):
                d[os.path.join(folder, m)] = "compilation error"

    with open(os.path.join(folder, "runtime.log")) as f:
        for line in f:
            for m, error in re.findall(r_runtime.error, line):
                l = error.split()
                if l[0] != "Error":
                    error = "runtime error"
                elif l[1] in ("124", "137"):
                    error = "hanging"
                elif l[1] in ("112",):
                    error = "wrong value"
                else:
                    error = "runtime error"

                d[os.path.join(folder, m)] = error

    return d


#  _
# | \ o  _ ._  |  _.
# |_/ | _> |_) | (_| \/
#          |         /
#
def summary_csv(d,folder=None):
    
    total_test = len(d)
    from collections import Counter
    c = Counter(d.values())

    c["test"] = total_test
    c["success"] = c[None]
    c["pass rate"] = f"{c['success'] / c['test']:.0%}"

    if folder:
        *_,  c["language"], c["category"], c["name"] = folder.split('/')

    return c

def print_result(l_d, csv=False, overall=False):
    l_collum = ['language', 'category', 'name', 'pass rate(%)', 'test(#)', 'success(#)', 'compilation error(#)', 'runtime error(#)', 'wrong value(#)', 'hang(#)']
    if overall:
        l_collum = l_collum[3:]
    l_key = [key.split('(')[0] for key in l_collum ]

    data = [ l_collum ] + [[d[key] for key in l_key] for d in l_d] 
    if csv:
        import csv
        spamwriter = csv.writer(sys.stdout)
        for row in data:
            spamwriter.writerow(row)
    else:
        print(tabulate(data, headers="firstrow"))


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
            try:
                folders = (os.path.join("test_result", i) for i in os.listdir("test_result"))
                values = [max(folders)]
            except FileNotFoundError:
                sys.exit("The test_result folder doesn't seems to exit")
            except ValueError:
                sys.exit("The test_result seems to be empty")

        setattr(namespace, self.dest, values)


if __name__ == "__main__":
    with open(os.path.join(dirname, "template", "ovo_usage.txt")) as f:
        usage = f.read()
    parser = argparse.ArgumentParser(usage=usage)
    group = parser.add_mutually_exclusive_group()

    group.add_argument("--summary", action="store_true")
    group.add_argument("--failed", action="store_true")
    group.add_argument("--passed", action="store_true")
    parser.add_argument("--csv", action="store_true")
    
    parser.add_argument("result_folder", nargs="*", action=EmptyIsAllFolder)
    args = parser.parse_args()

    s_folder = set()
    for folder in args.result_folder:
        s_folder |= {os.path.dirname(path) for path in Path(folder).rglob("env.log")}


    d_agregaded, l_summary = {}, []

    for folder in sorted(s_folder):
        d = parse_folder(folder)
        d_agregaded.update(d)

        if args.summary:
            l_summary.append(summary_csv(d,folder))
        elif args.passed or args.failed:

            # Need to split between pass and failed
            d_failed, l_sucess = defaultdict(list), []
            for name, value in d.items():
                if value is None:
                    l_sucess.append(os.path.basename(name))
                else:
                    d_failed[value].append(os.path.basename(name))
       
            print(f">> {folder}")
            if args.failed:
                for k, v in sorted(d_failed.items()):
                    print(f">>> {k}")
                    print("\n".join(sorted(v)))
            elif args.passed:
                print("\n".join(sorted(l_sucess)))

    if not(args.passed or args.failed):
        if len(args.result_folder) <= 1:
            print(f">> Overall result using {args.result_folder[0]}")
            print_result([summary_csv(d_agregaded)],csv=args.csv,overall=True) 

        if args.summary:
            print ("\n >> Summary")
            print_result(l_summary,csv=args.csv)
        
    if any(i is not None for i in d_agregaded.values()):
        sys.exit(1)
