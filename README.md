# OvO: OpenMP vs Offload

```
  ___
 (OvO)
<  .  >
--"-"---
```
[![Build Status](https://travis-ci.org/TApplencourt/OvO.svg?branch=master)](https://travis-ci.org/TApplencourt/OvO)

OvO is a collection of OpenMP Offloading test functions for  C++ and Fortran.


OvO is a collection of OpenMP offloading tests for [C++](https://github.com/TApplencourt/OvO/tree/master/test_src/cpp) and [FORTRAN](https://github.com/TApplencourt/OvO/tree/master/test_src/fortran). 
OvO is focused on testing extensively [hierarchical parallelism](https://github.com/TApplencourt/OvO/tree/master/test_src/fortran/hierarchical_parallelism/) and [mathematical functions](https://github.com/TApplencourt/OvO/tree/master/test_src/cpp/mathematical_function/).

You can find the slides of some OvO presentations we did in the [documentation](https://github.com/TApplencourt/OvO/tree/master/documentation/) folder.
```
$ ./ovo.sh -h
OvO an OpenMP test generator.
Usage:
  ovo.sh gen
  ovo.sh gen tiers [1|2|3]
  ovo.sh gen hierarchical_parallelism [--test_type [atomic|reduction|memcopy]...]
                                      [--data_type [float|'complex<float>'|
                                                    double|'complex<double>'|
                                                    REAL|COMPLEX|
                                                    'DOUBLE PRECISION'|'DOUBLE COMPLEX']... ]
                                      [--loop_pragma [True|False] ]
                                      [--paired_pragmas [True|False] ]
                                      [--multi_devices [True|False] ]
                                      [--host_threaded [True|False] ]
                                      [--intermediate_result [True|False] ]
                                      [--no_user_defined_reduction [True|False] ]
                                      [--collapse [N]...]
                                      [--append]

  ovo.sh gen mathematical_function [--standart [cpp11|cpp17|cpp20|gnu|f77]... ]
                                   [--complex [True|False] ]
                                   [--long [True|False] ]
                                   [--simdize [N]...]
                                   [--append]

  ovo.sh run [<test_folder>...]
  ovo.sh report [ --summary | --failed | --passed ] [--tablefmt (github|tsv|jira)]  ] [<result_folder>...]
  ovo.sh clean
  ovo.sh (-h | --help)
```

Bug reports and PRs are more than welcome! The OpenMP specification can be tricky. And we use metaprogramming to generate the tests so, to pastiche Jamie Zawinski: 
>Some people, when confronted with a problem, think "I know, I'll use ~~regular expressions~~ metaprogramming." Now they have two problems.

## Requirement
  - python3
  - OpenMP compiler (obviously). We recommend an OpenMP 5.0 spec-compliant compiler. Some test map and reduce a variable in the same combined construct
  - C++11 compiler
  - [jinja](https://jinja.palletsprojects.com/en/2.11.x/) (optional, only needed if you want to generate tests that are not in the repo)
```
conda install --file requirements.txt
```
or
```
pip install requirements.txt
```
  - make >4.0  Make 4.0 introduced the ` --output-sync` option to serialize make output. If you use a version of make older than 4.0, we will compile the tests serially.
  
# Get me started

```
OMP_TARGET_OFFLOAD=mandatory CXX="g++" CXXFLAGS="-fopenmp" FC="gfortran" FFLAGS="-fopenmp"./ovo.sh run
[...]
./ovo.sh report
>> Overall result test_result/1957-04-01_19-02_CDC6600.lanl.gov
  pass rate(%)    test(#)    success(#)    compilation error(#)    runtime error(#)    wrong value(#)    hang(#)
--------------  ---------  ------------  ----------------------  ------------------  ----------------  ---------
          100%       7539          7539                       0                   0                 0          0
```

# <<Gentlemen you had my curiosity ... but now you have my attention>>

## Hierarchical parallelism tests

We generate 3 types of kernels: Kernels which perform a reduction using `atomic`, kernels which perform a reduction using the OpenMP `reduction` pragma, and memory copy kernels. For each type of kernel, we generate *all* possible OpenMP loop-nests containing any combination of `target, teams, distribute, parallel for`, including combined pragma.  Single precision and double precision complex datatype are used. More datatypes are available if needed.

The code below is an example of a code OvO can generate. It's a kernel using 'atomic' to perform a float reduction.  Note the absence of `for` in the parallel section.

```cpp
float counter_N0 {}
#pragma omp target map(tofrom: counter_N0)
#pragma omp teams distribute
for (int i0 = 0 ; i0 < N0 ; i0++ )
{
  #pragma omp parallel
  {
     #pragma omp atomic update
     counter_N0 = counter_N0 + 1./omp_get_num_theads();
   }
}
assert (counter_N0 != N0);
```
The real code can be found [here](https://github.com/TApplencourt/OvO/blob/master/test_src/cpp/hierarchical_parallelism/atomic-float/target__teams_distribute__parallel.cpp)

## Mathematical tests

We test if all functions of a specified standard are able to be offloaded.  The Offloaded result should match the CPU result with 4 ulp preference. 


## Running 

To run OvO simply type `./ovo.sh run`. Log files will be saved in the newly created `test_result` folder. 
OvO will respect any usual environment variables provided by the user (e.g. `CXX` / `CXXFLAGS` / `FC` / `FFLAGS` / `OMP_TARGET_OFFLOAD`). 
OvO will also respect the special `OVO_TIMEOUT` environment variable which controls the timeout used to kill too-long running tests (by default `15s`).

You can find commonly used flags for various compilers in [/documentation/README.md](https://github.com/TApplencourt/OvO/tree/master/documentation/README.md). PR are welcomed, for new versions of compilers. 

Below is a simple run using the GCC compiler:
```
$ OMP_TARGET_OFFLOAD=mandatory CXX="g++" CXXFLAGS="-fopenmp" FC="gfortran" FFLAGS="-fopenmp"./ovo.sh run
Running tests_src/cpp/mathematical_function/math_cpp11 | Saving log in results/2020-04-06_17-01_travis-job-24888c4a-3841-4347-8ccd-6f1e8d034e30/cpp/mathematical_function/math_cpp11
g++ -fopenmp isgreater_bool_float_float.cpp -o isgreater_bool_float_float.exe
[...]
```

## Result
A summary of the result can be obtained with `./ovo.sh report`. Example of output obtained with `--summary`:

```
./ovo.sh report --summary  --tablefmt github
>> Overall result for test_result/1957-04-01_19-02_CDC6600.lanl.gov
|   pass rate(%) |   test(#) |   success(#) |   compilation error(#) |   runtime error(#) |   wrong value(#) |   hang(#) |
|----------------|-----------|--------------|------------------------|--------------------|------------------|-----------|
|            57% |       828 |          471 |                    198 |                 41 |               98 |        20 |

 >> Summary
| language   | category                 | name                     |   pass rate(%) |   test(#) |   success(#) |   compilation error(#) |   runtime error(#) |   wrong value(#) |   hang(#) |
|------------|--------------------------|--------------------------|----------------|-----------|--------------|------------------------|--------------------|------------------|-----------|
| cpp        | hierarchical_parallelism | reduction-float          |            34% |        74 |           25 |                      2 |                  1 |               44 |         2 |
| cpp        | hierarchical_parallelism | reduction-complex_double |            47% |        74 |           35 |                      2 |                  1 |               28 |         8 |
| cpp        | hierarchical_parallelism | atomic-float             |            58% |        33 |           19 |                      0 |                  0 |                4 |        10 |
| cpp        | hierarchical_parallelism | memcopy-complex_double   |            93% |        45 |           42 |                      2 |                  1 |                0 |         0 |
| cpp        | hierarchical_parallelism | memcopy-float            |            93% |        45 |           42 |                      2 |                  1 |                0 |         0 |
| cpp        | mathematical_function    | cpp11                    |            92% |       177 |          163 |                      6 |                  4 |                4 |         0 |
| cpp        | mathematical_function    | cpp11-complex            |           100% |        34 |           34 |                      0 |                  0 |                0 |         0 |
| fortran    | hierarchical_parallelism | reduction-double_complex |             7% |        74 |            5 |                     49 |                 14 |                6 |         0 |
| fortran    | hierarchical_parallelism | reduction-real           |             8% |        74 |            6 |                     48 |                 14 |                6 |         0 |
| fortran    | hierarchical_parallelism | memcopy-real             |            22% |        45 |           10 |                     35 |                  0 |                0 |         0 |
| fortran    | hierarchical_parallelism | memcopy-double_complex   |            24% |        45 |           11 |                     34 |                  0 |                0 |         0 |
| fortran    | hierarchical_parallelism | atomic-real              |            39% |        33 |           13 |                     18 |                  0 |                2 |         0 |
| fortran    | mathematical_function    | F77-complex              |            71% |        14 |           10 |                      0 |                  0 |                4 |         0 |
| fortran    | mathematical_function    | F77                      |            92% |        61 |           56 |                      0 |                  5 |                0 |         0 |
```

You can also use `./ovo.sh report --failed` to get a list of tests that failed for more thoughtful investigation.

All information on the execution of the tests is available in the subfolder of `test_result` corresponding to our run (for example, `./test_result/1957-04-01_19-02_CDC6600.lanl.gov/cpp/hierarchical_parallelism/memcopy-real`).
The environment used to run the test is saved in `env.log`. 
Two log files are also created: one for the compilation (`compilation.log`), and one for the runtime (`runtime.log`).
  - Error code `112` corresponds to an incorrect result. 
  - Error `124` or `137` corresponds to a test which was hanging and killed by `timeout`. 


## List of tests available

More than 100,000 tests are available. For convenience, we bundle them in `tiers`. 

To generate new tests, please use `ovo.sh gen`. By default, it will generate `tiers 1` tests.  But if you feel adventurous, you can use: `ovo.sh tiers 3`. See more section for more information.

# Too much information about flags and arguments

## For running tests
```
Usage:
`ovo.sh run [test_folder]`:
    [test_folder]    List of tests folder. OvO will recurse on those folders to execute tests. 
                     By default all in test_src run, this lets you specify certain folders

Example:

    Run only the Fortran tests
        ./ovo.sh run ./test_src/fortran
```
## For reporting results
```
Usage:
`ovo.sh report`
Options you can pass:
    --summary        Print for each group of tests the pass rate
    --failed         Print all the test which failed
    --passed         Print all the test which passed
    --tablefmt       Can be used to change for formating of the table 
                     (useful for copy/pasting in Excel for example)
    
Example:

    Print for each tests group a summary of the pass rate:
        ./ovo.sh report --summary --failed
```
## For generating more tests

```
Usage:
`ovo.sh gen`
`ovo.sh gen tiers <1|2|3>`
    gen              Generate tests corresponding to tiers 1
    gen tiers        Generate tests corresponding to different tiers.
                     Tiers 1 list of tests (`ovo.sh gen` or `ovo.sh gen tiers 1`):
                        hierarchical_parallelism cpp:
                            atomic-float,
                            memcopy-complex_double, memcopy-float,
                            reduction-complex_double, reduction-float
                        hierarchical_parallelism fortran:
                            atomic-real,
                            memcopy-double_complex, memcopy-real,
                            reduction-double_complex, reduction-real
                        mathematical_function cpp
                            cpp11, cpp11-complex
                        mathematical_function fortran
                            F77, F77-complex
                     Tiers 2 (`ovo.sh gen tiers 2`):
                        hierarchical_parallelism cpp:
                            atomic-float, atomic-float-host_threaded, atomic-float-intermediate_result,
                            memcopy-complex_double, memcopy-float, memcopy-float-collapse_n2, memcopy-float-loop_pragma
                            reduction-complex_double, reduction-float, reduction-float-multiple_devices
                        hierarchical_parallelism fortran:
                            atomic-real, atomic-real-host_threaded, atomic-real-intermediate_result
                            memcopy-double_complex, memcopy-real, memcopy-real-collapse_n2, memcopy-real-loop_pragma
                            memcopy-real-paired_pragmas, reduction-double_complex
                            reduction-real, reduction-real-multiple_devices
                    Tiers 3 (`ovo.sh gen tiers 2`):
                        All possible combination
Options you can pass:
   For hierarchical_parallelism:
    --test_type      Choose the kind of tests you want to generate.
                       - atomic tests will use OpenMP `atomic` construct to perform a reduction.
                       - reduction tests will use OpenMP `reduction` construct to perform a reduction.
                       - memcopy tests perform a memory copy.
    --data_type      Trigger for which data type will be used in the tests. Uppercase type corresponds to Fortran datatype.
    --loop_pragma    Trigger to use OpenMP 5.0 "loop" construct
    --paired_pragmas Fortran Only. Will generate tests that use optional "$OMP END" constructs.
    --multi_devices  Tests will be offloaded to all the GPU available.
    --host_threaded  Tests will be offloaded by multiple host threaded
    --intermediate_result
                     Reduction and Atomic tests will use intermediate results to perform their reduction.
    --collapse
                     All the loops will be duplicate N time, and `omp collapse` will be used.
    --no_user_defined_reduction
                     Only impacts reduction with C++ complex datatype. Tests will not use `omp declare reduction` construct".

   For mathematical_function:
    --standard       Corresponds to which standard (c++11, c++17, etc.) used to generate math functions.
    --complex        Trigger for complex math functions
    --long           Trigger to use C++ long datatype if possible
    --simdize        Trigger to put math function inside a 'simd' region

Examples:

  Generate the `tiers 2` set of tests:
     ./ovo.sh gen tiers 2

  Generate hierarchical_parallelism reduction tests with REAL (fortran) and complex<float>(c++) datatype with and without multi-devices support:
    ./ovo.sh gen hierarchical_parallelism  --test_type reduction --data_type REAL "complex<float>" --multiple_devices True False
```
