SRC := $(wildcard *.f90)
EXE := $(SRC:%.f90=%.exe)

.PHONY: exe
exe: $(EXE)

pEXE := $(wildcard *.exe)
RUN := $(addprefix run_, $(basename $(pEXE)))


SRC_NO_LOOP := $(filter-out $(wildcard *loop*.f90), $(SRC))
EXE_NO_LOOP := $(SRC_NO_LOOP:%.f90=%.exe)

.PHONY: exe_no_loop
exe_no_loop: $(EXE_NO_LOOP)


%.exe: %.f90
	-$(FC) $(FFLAGS) $< -o $@

.PHONY: run
run: $(RUN)
run_%: %.exe
	-./$<

.PHONY: clean
clean:
	rm -f -- $(pEXE)
