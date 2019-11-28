# OmpVal

## How to run

```
run.sh a OpenMP test generator
Usage:
 ./run.sh -h | --help
 ./run.sh [ -g | --gen ] [ -r | --run] [ -d | --display ]

   -h --help          Show this screen.
   -g, --gen          Generate the tests
   -r, --run          Complile and run the tests
   -d, --display      Display the summary of the test

 Example:
CXX="icx" CXXFLAGS="-fiopenmp -fopenmp-targets=spir64=-fno-exceptions"  ./run.sh -g -r -d
 ```
    
# Requirement
 - python 3.
 - jinja2
