
TIMEOUT = $(shell command -v timeout 2> /dev/null)
ifdef TIMEOUT
	TIMEOUT = timeout -k 5s 10s
endif

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

SRC_NO_LONG = $(filter-out $(wildcard *long*.F90), $(SRC))
EXE_NO_LONG = $(SRC_NO_LONG:%.F90=%.exe)

.PHONY: exe_no_long
exe_no_long: $(EXE_NO_LONG)


.PHONY: exe_no_long_no_loop
exe_no_long_no_loop: $(filter $(EXE_NO_LONG), $(EXE_NO_LOOP)) 

%.exe: %.F90
	-$(FC) $(FFLAGS) $< -o $@

.PHONY: run
run: $(RUN)
run_%: %.exe
	-$(TIMEOUT) ./$<

.PHONY: clean
clean:
	rm -f -- $(pEXE) 
