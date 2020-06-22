# OvO: OpenMP vs Offload

```
  ___
 (OvO)
<  .  >
--"-"---
```
[![Build Status](https://travis-ci.org/TApplencourt/OvO.svg?branch=master)](https://travis-ci.org/TApplencourt/OvO)

OvO containt a large set of tests OpenMP offloading of [C++](https://github.com/TApplencourt/OvO/tree/master/test_src/cpp) and [FORTRAN](https://github.com/TApplencourt/OvO/tree/master/test_src/fortran). 
OvO is focused on testing extensively [hierarchical parallelism](https://github.com/TApplencourt/OvO/tree/master/test_src/fortran/hierarchical_parallelism/) and [mathematical functions](https://github.com/TApplencourt/OvO/tree/master/test_src/cpp/mathematical_function/).

For hierarchical parallelism, we generate *all* possible OpenMP loop-nests containing any combination of `target, teams, distribute, parallel for`, including combined pragma.

All tests are checked for compilation and correctness.

As an example of a simple C++ hierarchical parallelism kernel we check:
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

To run OvO simply type `./ovo.sh run`. The logs file will be saved in the newly created `test_result` folder. 
OvO will respect any usual environement provided by th user (e.g. `CXX` / `CXXFLAGS` / `FC` / `FFLAGS` / `OMP_TARGET_OFFLOAD`).
You can find commonly used flags for various compiler in [/documentation/README.md](https://github.com/TApplencourt/OvO/tree/master//documentation/README.md).

For example, runing with `gfortran`:
```
$ OMP_TARGET_OFFLOAD=mandatory CXX="g++" CXXFLAGS="-fopenmp" FC="gfortran" FFLAGS="-fopenmp"./ovo.sh run
Running tests_src/cpp/mathematical_function/math_cpp11 | Saving log in results/2020-04-06_17-01_travis-job-24888c4a-3841-4347-8ccd-6f1e8d034e30/cpp/mathematical_function/math_cpp11
clang++ -fopenmp isgreater_bool_float_float.cpp -o isgreater_bool_float_float.exe
[...]
```

## Result
A summary of the result can be obtained with `./ovo.sh report`. 

```
$ ./ovo.sh report
>> test_results/2020-04-06_17-01_travis-job-24888c4a-3841-4347-8ccd-6f1e8d034e30
811 / 910 ( 89% ) pass [failures: 8 compilation, 84 offload, 7 incorrect results]
```

You can also use `./ovo.sh report --failed` to get a list of tests that failed for more thoughtful investigation.

All information on the execution of the tests is available in the subfolder of `test_src` corresponding to our run.
The environment used to tun the test is available in `env.log`. 
Two log files are also created one for the compilation (`compilation.log`), and one for the runtime (`runtime.log`).
  - Error code 112 corresponds to an incorrect result. 
  - Error 124 or 137 corresponds to a test that was hanging and was killed by `timeout`. 

## Requirement
  - python3
  - OpenMP compiler (obviously). We recommand an OpenMP 5.0 spec-complied compiler. Some test map and reduce a variable in the same combined construct
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

More than tests 18000 are available. For convenience, we bundle them in `tiers`. 
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
|  - Colllapse + Memcopy  \
|  - Intermidate result +  \
|       atomic              \ 
|  - Host threaded           \
|       atomic,memcopy,       \
|       reduction              \
|===============================\
|Tiers 3                         \
|---------------------------------\
| - loop pragma                    \
|DataType                           \
| - double, complex<float>           \
| - DOUBLE PRECISION, COMPLEX         \
| Cartesian production of all options  \
```

To generate tests, please use `ovo.sh gen`.But default it will generate `tiers 1` tests. But if you feel adventurous, you can type:
`ovo.sh tiers 3`.

### Intermidate result

Use temporary variables to store loop-nest partial results.

### Collapse

Generate using with `collapse(2)` clause.

### Loop pragma

Use the OpenMP 5.0 `loop` construct

### host threaded

Generate tests where the target region is enclosed in a host parallel for.

