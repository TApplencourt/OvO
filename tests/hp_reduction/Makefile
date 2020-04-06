SOURCES := $(wildcard *.cpp)
SOURCES_NO_LONG_DOUBLE= $(filter-out $(wildcard *long_double*.cpp), $(SOURCES))

EXE := $(SOURCES:%.cpp=%.exe)
EXE_NO_LONG_DOUBLE := $(SOURCES_NO_LONG_DOUBLE:%.cpp=%.exe)

pEXE := $(wildcard *.exe)
RUN := $(addprefix run_, $(basename $(pEXE)))

.PHONY: exe
exe: $(EXE)

.PHONY: exe_nlg
exe_nlg: $(EXE_NO_LONG_DOUBLE)

%.exe: %.cpp
	-$(CXX) $(CXXFLAGS) $< -o $@

.PHONY: run
run: $(RUN)
run_%: %.exe
	-./$<

.PHONY: clean
clean:
	rm -f -- $(pEXE)