SRC = $(wildcard *.F90)
EXE = $(SRC:%.F90=%.exe)

.PHONY: exe
exe: $(EXE)

pEXE = $(wildcard *.exe)
RUN = $(addprefix run_, $(basename $(pEXE)))


SRC_NO_LOOP = $(filter-out $(wildcard *loop*.F90), $(SRC))
EXE_NO_LOOP = $(SRC_NO_LOOP:%.F90=%.exe)

.PHONY: exe_no_loop
exe_no_loop: $(EXE_NO_LOOP)


.PHONY: exe_no_long_double_no_loop
exe_no_long_double_no_loop: $(EXE_NO_LOOP)

%.exe: %.F90
	-$(FC) $(FFLAGS) $< -o $@

.PHONY: run
run: $(RUN)
run_%: %.exe
	-./$<

.PHONY: clean
clean:
	rm -f -- $(pEXE) 
