TIMEOUT = $(shell command -v timeout 2> /dev/null)
ifdef TIMEOUT
	TIMEOUT = timeout -k 5s 10s
endif

SRC = $(wildcard *.cpp)
EXE = $(SRC:%.cpp=%.exe)

.PHONY: exe
exe: $(EXE)

pEXE = $(wildcard *.exe)
RUN = $(addprefix run_, $(basename $(pEXE)))

%.exe: %.cpp
	-$(CXX) $(CXXFLAGS) $< -o $@


.PHONY: run
run: $(RUN)
run_%: %.exe
	-$(TIMEOUT) ./$<

.PHONY: clean
clean:
	rm -f -- $(pEXE) 
