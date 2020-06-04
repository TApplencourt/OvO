
TIMEOUT = $(shell command -v timeout 2> /dev/null)
ifdef TIMEOUT
	TIMEOUT = timeout -k 5s 10s
endif

SRC = $(wildcard *.F90)
.PHONY: exe
exe: $(SRC:%.F90=%.exe)

pEXE = $(wildcard *.exe)
.PHONY: run
run: $(addprefix run_, $(basename $(pEXE)))

%.exe: %.F90
	-$(FC) $(FFLAGS) $< -o $@

run_%: %.exe
	-$(TIMEOUT) ./$<

.PHONY: clean
clean:
	rm -f -- $(pEXE) 
