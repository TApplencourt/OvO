# Presentation

- OvO_presentation_20-05-20.pdf : Introduction to OvO. Related to realease v0.1

# Compiler flags example

## AMD -- clang++ / flang++

```bash
export OMP_TARGET_OFFLOAD=MANDATORY
export CXX='clang++'
export FC='flang++'
export COMMON_FLAGS='-fopenmp -fopenmp-targets=amdgcn-amd-amdhsa -Xopenmp-target=amdgcn-amd-amdhsa -march=gfx906'
export CXXFLAGS="$COMMON_FLAGS -fopenmp-version=50"
export FFLAGS=$COMMON_FLAGS
./ovo.sh run
```

## NVIDIA -- clang++

```bash
export OMP_TARGET_OFFLOAD=MANDATORY
export CXX='clang++'
export COMMON_FLAGS='-fopenmp -fopenmp-targets=nvptx64-nvidia-cuda -Xopenmp-target -march=sm_60'
export CXXFLAGS="$COMMON_FLAGS -fopenmp-version=50"
./ovo.sh run ./test_src/cpp/
```

## xlC_r / xlf90_r

```bash
export OMP_TARGET_OFFLOAD=MANDATORY
export CXX='xlC_r'
export CXX='xlf90_r'
export COMMON_FLAGS='-qsmp=omp -qoffload'
export CXXFLAGS="$COMMON_FLAGS -std=c++11"
export FFLAGS=$COMMON_FLAGS
./ovo.sh run
```

## g++ / gfortran

```bash
export OMP_TARGET_OFFLOAD=MANDATORY
export CXX='g++'
export FC='gfortran'
export COMMON_FLAGS='-fopenmp'
export CXXFLAGS=$COMMON_FLAGS
export FFLAGS=$COMMON_FLAGS
./ovo.sh run
```

