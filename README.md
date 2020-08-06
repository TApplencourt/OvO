# OvO: OpenMP vs Offload

```
  ___
 (OvO)
<  .  >
--"-"---
```
[![Build Status](https://travis-ci.org/TApplencourt/OvO.svg?branch=master)](https://travis-ci.org/TApplencourt/OvO)

OvO containt a large set of tests OpenMP offloading of [C++](https://github.com/TApplencourt/OvO/tree/master/test_src/cpp) and [FORTRAN](https://github.com/TApplencourt/OvO/tree/master/test_src/fortran). More than 30k can be generated, and arround 1k are avalaible directly in this repo. 
OvO is focused on testing extensively [hierarchical parallelism](https://github.com/TApplencourt/OvO/tree/master/test_src/fortran/hierarchical_parallelism/) and [mathematical functions](https://github.com/TApplencourt/OvO/tree/master/test_src/cpp/mathematical_function/).
Presentation we did on OvO are avalaible in the [documentation](https://github.com/TApplencourt/OvO/tree/master/documentation/) folder.

For hierarchical parallelism, we generate *all* possible OpenMP loop-nests containing any combination of `target, teams, distribute, parallel for`, including combined pragma.

All tests are checked for compilation and correctness. Bellow is a simple C++ hierarchical parallelism kernel present in this repo:
```cpp
#pragma omp target map(tofrom: counter_N0)
#pragma omp teams distribute
for (int i0 = 0 ; i0 < N0 ; i0++ )
{
  #pragma omp parallel for
  for (int i1 = 0 ; i1 < N1 ; i1++ )
  {
     #pragma omp atomic update
     counter_N0 = counter_N0 +  1. ;
   }
}
assert (counter_N0 != N0*N1);
```

## Running 

To run OvO simply type `./ovo.sh run`. Log files will be saved in the newly created `test_result` folder. 
OvO will respect any usual environement provided by the user (e.g. `CXX` / `CXXFLAGS` / `FC` / `FFLAGS` / `OMP_TARGET_OFFLOAD`). 
OvO will also respect the special `OVO_TIMEOUT` enviroment who control the timeout used to kill too-long running tests (by default `15s`).

You can find commonly used flags for various compiler in [/documentation/README.md](https://github.com/TApplencourt/OvO/tree/master/documentation/README.md). PR are welcomed, for new version of compilers. 

Bellow is a simple run using GCC compiler:
```
$ OMP_TARGET_OFFLOAD=mandatory CXX="g++" CXXFLAGS="-fopenmp" FC="gfortran" FFLAGS="-fopenmp"./ovo.sh run
Running tests_src/cpp/mathematical_function/math_cpp11 | Saving log in results/2020-04-06_17-01_travis-job-24888c4a-3841-4347-8ccd-6f1e8d034e30/cpp/mathematical_function/math_cpp11
g++ -fopenmp isgreater_bool_float_float.cpp -o isgreater_bool_float_float.exe
[...]
```

## Result
A summary of the result can be obtained with `./ovo.sh report`. Example of output optained with `--summary`:

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

All information on the execution of the tests is available in the subfolder of `test_result` corresponding to our run (for example `./test_result/1957-04-01_19-02_CDC6600.lanl.gov/cpp/hierarchical_parallelism/memcopy-real`).
The environment used to tun the test is available in `env.log`. 
Two log files are also created one for the compilation (`compilation.log`), and one for the runtime (`runtime.log`).
  - Error code `112` corresponds to an incorrect result. 
  - Error `124` or `137` corresponds to a test that was hanging and was killed by `timeout`. 

## Requirement
  - python3
  - OpenMP compiler (obviously). We recommend an OpenMP 5.0 spec-complied compiler. Some test map and reduce a variable in the same combined construct
  - C++11 compiler
  - [jinja](https://jinja.palletsprojects.com/en/2.11.x/) (optional,  needed to generate more tests. See next section)
```
conda install --file requirements.txt
```
or
```
pip install requirements.txt
```

## List of tests available

More than 18,000 tests are available. For convenience, we bundle them in `tiers`. 
By default, the `Tiers 1` test are saved in the `OvO` directory.

```
|===========\
|Tiers 1     \
|-------------\
|Test          \
|  - Atomic     \
|  - Memcopy     \
|  - Reduction    \
|Datatype          \
|  - float, REAL    \
|  - complex<double> \
|  - DOUBLE COMPLEX   \
|======================\
|Tiers 2                \
|------------------------\
|  - Collapse + Memcopy   \
|  - Intermidate result +  \
|       Atomic              \ 
|  - Host threaded +         \
|       { Atomic, Memcopy,    \
|         Reduction }          \
|===============================\
|Tiers 3                         \
|---------------------------------\
| - loop pragma                    \
|DataType                           \
| - double, complex<float>           \
| - DOUBLE PRECISION, COMPLEX         \
| Cartesian production of all options  \
```

- Intermidate result: Use temporary variables to store loop-nest partial results.
- Collapse: Generate using with `collapse(2)` clause.
- Loop pragma: Use the OpenMP 5.0 `loop` construct
- Host threaded: Generate tests where the target region is enclosed in a host parallel for.


To generate new tests, please use `ovo.sh gen`. By default, it will generate `tiers 1` tests. But if you feel adventurous, you can type:
`ovo.sh tiers 3`.

