CXX=g++
CXXFLAGS=-Wno-main
LEX=flex

PROGS=sws xcom ccom pc

.PHONY: all
all: $(PROGS)

.PHONY: clean
clean:
	@echo RM $(PROGS) $(PROGS:=.c)
	@$(RM) $(PROGS) $(PROGS:=.c)

%: %.cc
	@echo CXX $@
	@$(CXX) $(CXXFLAGS) -o $@ $^

%.cc: %.l
	@echo LEX $@
	@$(LEX) $(LFLAGS) -o $@ $^

