SRC := $(wildcard *.f90)
EXE := $(SRC:%.f90=%.exe)

.PHONY: exe
exe: $(EXE)

pEXE := $(wildcard *.exe)
RUN := $(addprefix run_, $(basename $(pEXE)))


SRC_NO_LOOP := $(filter-out $(wildcard *loop*.f90), $(SRC))


SRC_NO_OMP_CALL := $(shell grep -L OMP_LIB *.f90)


EXE_NO_LOOP := $(SRC_NO_LOOP:%.f90=%.exe)

.PHONY: exe_no_loop
exe_no_loop: $(EXE_NO_LOOP)

EXE_NO_OMP_CALL := $(SRC_NO_OMP_CALL:%.f90=%.exe)

.PHONY: exe_no_omp_call
exe_no_omp_call: $(EXE_NO_OMP_CALL)


%.exe: %.f90
	-$(FC) $(FFLAGS) $< -o $@

.PHONY: run
run: $(RUN)
run_%: %.exe
	-./$<

.PHONY: clean
clean:
	rm -f -- $(pEXE)
