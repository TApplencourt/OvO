SRC := $(wildcard *.cpp)
EXE := $(SRC:%.cpp=%.exe)

.PHONY: exe
exe: $(EXE)

pEXE := $(wildcard *.exe)
RUN := $(addprefix run_, $(basename $(pEXE)))


SRC_NO_LONG_DOUBLE := $(filter-out $(wildcard *long_double*.cpp), $(SRC))
EXE_NO_LONG_DOUBLE := $(SRC_NO_LONG_DOUBLE:%.cpp=%.exe)

.PHONY: exe_no_long_double
exe_no_long_double: $(EXE_NO_LONG_DOUBLE)

SRC_NO_LOOP := $(filter-out $(wildcard *loop*.cpp), $(SRC))
EXE_NO_LOOP := $(SRC_NO_LOOP:%.cpp=%.exe)

.PHONY: exe_no_loop
exe_no_loop: $(EXE_NO_LOOP)


.PHONY: exe_no_long_double_no_loop
exe_no_long_double_no_loop: $(EXE_NO_LONG_DOUBLE) $(EXE_NO_LOOP)

%.exe: %.cpp
	-$(CXX) $(CXXFLAGS) $< -o $@

.PHONY: run
run: $(RUN)
run_%: %.exe
	-./$<

.PHONY: clean
clean:
	rm -f -- $(pEXE)
