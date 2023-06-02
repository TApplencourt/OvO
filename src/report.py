#!/usr/bin/env python3

import re, unittest, os, sys, contextlib
from typing import NamedTuple
from collections import defaultdict, Counter
from operator import itemgetter

dirname = os.path.dirname(__file__)

try:
    from tabulate import tabulate
except ImportError:
    sys.path.append(dirname)
    try:
        from tabulate_local import tabulate
    #  New version of tabulate require `dataclass` who is python 3.6+
    except ModuleNotFoundError:
        from tabulate_local_pre36 import tabulate

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


r_compilation = DRegex("\.(?:cpp|F90) -o \S*?([^ /]+)\.exe$", "make.*?(\w+)\.exe\]\s+(.*)")
r_runtime = DRegex("^\S*?([^ /]+)\.exe$", "make.*?run_(\w+)\]\s+(.*)")


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

    def test_launch03(self):
        str_ = "timeout 45s fortran target_teams_distribute__parallel.F90 -o target_teams_distribute__parallel.exe"
        m = re.findall(r_compilation.launch, str_).pop()
        self.assertEqual(m, "target_teams_distribute__parallel")

    def test_launch04(self):
        str_ = "timeout 45s fortran /foo/bar/target_teams_distribute__parallel.F90 -o /foo/bar/target_teams_distribute__parallel.exe"
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

    def test_error05(self):
        str_ = "make:11 *** [lroundf_long_int_float.exe] Error 124 (ignored)"
        m, error = re.findall(r_compilation.error, str_).pop()
        self.assertEqual(m, "lroundf_long_int_float")
        self.assertEqual(error, "Error 124 (ignored)")


class TestRutimeLaunch(unittest.TestCase):
    def test_launch00(self):
        str_ = "./trunc_long_double_long_double.exe"
        m = re.findall(r_runtime.launch, str_).pop()
        self.assertEqual(m, "trunc_long_double_long_double")

    def test_launch01(self):
        str_ = "/foo/bar/trunc_long_double_long_double.exe"
        m = re.findall(r_runtime.launch, str_).pop()
        self.assertEqual(m, "trunc_long_double_long_double")

    def test_launch02(self):
        str_ = "gcc target_teams_distribute__parallel.cpp -o target_teams_distribute__parallel.exe"
        m = re.findall(r_runtime.launch, str_)
        self.assertEqual(m, [])

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

    with contextlib.suppress(FileNotFoundError):
        with open(os.path.join(folder, "compilation.log")) as f:
            for line in f:
                # By default the tests are sucessfull
                for m in re.findall(r_compilation.launch, line):
                    d[os.path.join(folder, m)] = "success"

                # Then we overwrite the tests status if needed
                for m, error in re.findall(r_compilation.error, line):
                    d[os.path.join(folder, m)] = "compilation error"

    with contextlib.suppress(FileNotFoundError):
        with open(os.path.join(folder, "runtime.log")) as f:
            for line in f:

                # Defensive programing, we should not need that in tradional case
                # All the tests should have been added during the compilation stage.
                # But maybe somebody somehow delete the "compilation.log" so...
                for m in re.findall(r_runtime.launch, line):
                    d[os.path.join(folder, m)] = "success"

                # Using error code to assisn test status
                for m, error in re.findall(r_runtime.error, line):
                    l = error.split()
                    if l[0].lower() != "error":
                        error = "runtime error"
                    elif l[1] in ("124", "137"):
                        error = "timeout"
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
def summary_csv(d, folder=None):
    """
    >>> summary_csv( {"a":"runtime error", "b":"success"} )
    Counter({'test': 2, 'runtime error': 1, 'success': 1, 'pass rate': 0.5})
    >>> summary_csv( {"a":"runtime error", "b":"success"}, folder='a/b/c/d')
    Counter({'runtime error': 1, 'success': 1, 'test': 2, 'pass rate': 0.5, 'test_result': 'a', 'language': 'b', 'category': 'c', 'name': 'd'})
    """
    if not d:
        return {}

    c = Counter(d.values())
    c["test"] = len(d)
    c["pass rate"] = c['success'] / c['test']

    if folder:
        *_, c["test_result"], c["language"], c["category"], c["name"] = folder.split(os.path.sep)
    return c


def print_result(l_d, tablefmt="simple", type_=None):
    """
    >>> print_result([Counter({'runtime error': 1, 'test': 1, 'pass rate': '0%'})],type_="no_folder")
      language    category    name  pass rate(%)      test(#)    success(#)    compilation error(#)    runtime error(#)    wrong value(#)    timeout(#)
    ----------  ----------  ------  --------------  ---------  ------------  ----------------------  ------------------  ----------------  ------------
             0           0       0  0%                      1             0                       0                   1                 0             0
    >>> print_result([Counter({'runtime error': 23, 'test': 46, 'pass rate': '50%'})], type_="overall")
    pass rate(%)      test(#)    success(#)    compilation error(#)    runtime error(#)    wrong value(#)    timeout(#)
    --------------  ---------  ------------  ----------------------  ------------------  ----------------  ------------
    50%                    46             0                       0                  23                 0             0
    """

    l_column = ["test_result", "language", "category", "name", "pass rate(%)", "test(#)", "success(#)", "compilation error(#)", "runtime error(#)", "wrong value(#)", "timeout(#)"]

    # The key are the column where we remove the unit
    l_key = [key.split("(")[0] for key in l_column]

    # - If the file don't exist or if the file is empty,
    #       the directy will be empty, so we filter empty dictionary
    # - We sort by folder, language and pass rate
    # - We cannot naively map(d.get) because this return an emtpy string and not 0
    rows = sorted([[d[k] for k in l_key] for d in filter(None, l_d)], key=itemgetter(0, 1, 2, 4))
    data = [l_column] + rows
    # For the overall summary, the language category and name are not needed
    if type_ == "overall":
        data = [row[4:] for row in data]
    elif type_ == "no_folder":
        data = [row[1:] for row in data]

    print(tabulate(data, headers="firstrow",tablefmt=tablefmt,floatfmt=".1%"))

#
# |\/|  _. o ._
# |  | (_| | | |
#
import sys
import argparse
from pathlib import Path
import os


class EmptyIsLastFolder(argparse.Action):
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
    parser.add_argument("--tablefmt", default="simple")
    
    parser.add_argument("result_folder", nargs="*", action=EmptyIsLastFolder)
    args = parser.parse_args()

    s_folder = set()
    for folder in args.result_folder:
        s_folder |= {os.path.dirname(path) for path in Path(folder).rglob("env.log")}

    # How many test_result are we using
    n_test_result = len(set(path.split(os.path.sep)[-4] for path in s_folder))

    d_test_aggregaded, l_summary = {}, []

    for folder in sorted(s_folder):
        d_test = parse_folder(folder)
        d_test_aggregaded.update(d_test)

        if args.summary:
            l_summary.append(summary_csv(d_test, folder))
        elif args.passed or args.failed:
            d_status_to_tests = defaultdict(list)
            for name, value in d_test.items():
                d_status_to_tests[value].append(os.path.basename(name))

            # Display failed or passed tests
            l_status = ["success"] if args.passed else [k for k in d_status_to_tests if k != "success"]
            # Don't display folder which no valid tests
            if any(d_status_to_tests[k] for k in l_status):
                print(f">> {folder}")
            for status in sorted(l_status):
                print(f">>> {status}")
                print("\n".join(sorted(d_status_to_tests[status])))

    if not (args.passed or args.failed):
        if len(args.result_folder) == 1:
            print(f">> Overall result for {args.result_folder[0]}")
        else:
            print(f">> Overall result")

        print_result([summary_csv(d_test_aggregaded)], tablefmt=args.tablefmt, type_="overall")

    if args.summary:
        print("\n >> Summary")
        print_result(l_summary, tablefmt=args.tablefmt, type_="no_folder" if n_test_result == 1 else None)

    if any(i != "success" for i in d_test_aggregaded.values()):
        sys.exit(1)
