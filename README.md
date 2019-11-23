# OmpVal

## How to run
 
 - [Optional] Create a new config file for your system (take inspiration from `config/general.txt`)
 - Generate the tests (do `-h` for more info)
    - `./ompval.py` 
 - `cd omp_tests/*`
 - Modify the makefile with correct flags
 - Run tests [and check for error (not super robust)]
    - `make |& grep -B1 'make'`

# Requirement
 - python 3.
 - jinja2
