# Presentation

- OvO_presentation_20-05-20.pdf : Introduction to OvO. Related to realease v0.1

# Compiler flags example

## AMD GPU -- clang++ / flang++ (AMD)

```bash
export OMP_TARGET_OFFLOAD=MANDATORY
export CXX='clang++'
export FC='flang++'
export COMMON_FLAGS='-fopenmp -fopenmp-targets=amdgcn-amd-amdhsa -Xopenmp-target=amdgcn-amd-amdhsa -march=gfx906'
export CXXFLAGS="$COMMON_FLAGS -fopenmp-version=50"
export FFLAGS=$COMMON_FLAGS
./ovo.sh run
```

## NVIDIA GPU -- clang++ (LLVM)

```bash
export OMP_TARGET_OFFLOAD=MANDATORY
export CXX='clang++'
export COMMON_FLAGS='-fopenmp -fopenmp-targets=nvptx64-nvidia-cuda -Xopenmp-target -march=sm_60'
export CXXFLAGS="$COMMON_FLAGS -fopenmp-version=50"
./ovo.sh run ./test_src/cpp/
```

## NVIDIA GPU -- xlC_r / xlf90_r (IBM)

```bash
export OMP_TARGET_OFFLOAD=MANDATORY
export CXX='xlC_r'
export CXX='xlf90_r'
export COMMON_FLAGS='-qsmp=omp -qoffload'
export CXXFLAGS="$COMMON_FLAGS -std=c++11"
export FFLAGS=$COMMON_FLAGS
./ovo.sh run
```

## NVIDIA GPU -- g++ / gfortran (GNU)

```bash
export OMP_TARGET_OFFLOAD=MANDATORY
export CXX='g++'
export FC='gfortran'
export COMMON_FLAGS='-fopenmp'
export CXXFLAGS=$COMMON_FLAGS
export FFLAGS=$COMMON_FLAGS
./ovo.sh run
```

## NVIDIA GPU -- Cray-classic / ftn (Cray)

```bash
export OMP_TARGET_OFFLOAD=MANDATORY
export CXX='CC'
export FC='ftn'
export COMMON_FLAGS='-h omp'
export CXXFLAGS=$COMMON_FLAGS
export FFLAGS=$COMMON_FLAGS
./ovo.sh run
```

## NVIDIA GPU -- Cray-llvm / ftn (Cray)

```bash
export OMP_TARGET_OFFLOAD=MANDATORY
export CXX='CC'
export FC='ftn'
export CXXFLAGS='-std=c++11 -fopenmp -fopenmp-targets=nvptx64 -Xopenmp-target -march=sm_70 -fopenmp-version=50'
export FFLAGS='-h omp'
./ovo.sh run
```

## NVIDIA GPU -- nvc++/nvfortran (Nvidia)

```bash
export OMP_TARGET_OFFLOAD=MANDATORY
export CXX='nvc++'
export FC='nvfortran'
export CXXFLAGS='-mp=gpu -gpu=cc70'
export FFLAGS='-mp=gpu -gpu=cc70'
./ovo.sh run
```

## Intel GPU -- icx / ifx (Intel)

```bash
export OMP_TARGET_OFFLOAD=MANDATORY
export CXX='icpx'
export FC='ifx'
export CXXFLAGS='-std=c++11 -fiopenmp -fopenmp-targets=spir64'
export FFLAGS='-fiopenmp -fopenmp-targets=spir64'
./ovo.sh run
```

# GCC

```bash
export OMP_TARGET_OFFLOAD=MANDATORY
export CXX='g++'
export FC='gfortran'
export CXXFLAGS='-std=c++11 -fopenmp'
export FFLAGS='-fopenmp
./ovo.sh run
```


