
TIMEOUT = $(shell command -v timeout 2> /dev/null)
ifdef TIMEOUT
	TIMEOUT = timeout -k 5s 10s
endif

SRC = $(wildcard *.cpp)
.PHONY: exe
exe: $(SRC:%.cpp=%.exe)

pEXE = $(wildcard *.exe)
.PHONY: run
run: $(addprefix run_, $(basename $(pEXE)))

%.exe: %.cpp
	-$(CXX) $(CXXFLAGS) $< -o $@


run_%: %.exe
	-$(TIMEOUT) ./$<

.PHONY: clean
clean:
	rm -f -- $(pEXE) 
