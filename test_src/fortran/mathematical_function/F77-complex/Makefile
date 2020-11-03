

TIMEOUT = $(shell command -v timeout 2> /dev/null)
OVO_TIMEOUT ?= 10s
ifdef TIMEOUT
	TIMEOUT = timeout -k 5s $(OVO_TIMEOUT)
endif

SRC = $(wildcard *.F90)
.PHONY: exe
exe: $(SRC:%.F90=%.exe)

pEXE = $(wildcard *.exe)
.PHONY: run
run: $(addprefix run_, $(basename $(pEXE)))

%.exe: %.F90
	-$(FC) $(FFLAGS) $(CURDIR)/$< -o $(CURDIR)/$@

run_%: %.exe
	-$(TIMEOUT) $(CURDIR)/$<

.PHONY: clean
clean:
	rm -f -- $(pEXE) 
