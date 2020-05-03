MAKEFLAGS+=-r

CXX:=clang++
CXXFLAGS:=-std=c++17 -w
LD:=$(CXX)
LDFLAGS:=$(CXXFLAGS)
YACC:=bison
YFLAGS:=--defines=tokens.hh
LEX:=flex
LFLAGS:=
MKMF:=gcc
MKMFFLAGS:=-MM
ZIP:=zip
ZFLAGS:=

PRG:=kompilator
PPCS:=$(wildcard *.yy) $(wildcard *.ll)
SRCS:=$(wildcard *.cc) $(PPCS:=.cc)
OBJS:=$(SRCS:.cc=.o)
INTR:=$(PPCS:=.cc) tokens.hh rules.mk

# mkrule, PROG, FLAGS, OUTPUT, INPUT
ifndef VERBOSE
 define mkrule
	@echo "$(1)	$(3)"
	@$($(1)) $(2) $(3) $(4)
 endef
else
 define mkrule
	$($(1)) $(2) $(3) $(4)
 endef
endif

.PHONY: all clean clear zip
.PRECIOUS: $(INTR)

all: $(PRG)

clean:
	$(call mkrule,RM,,$(OBJS) $(INTR))

clear: clean
	$(call mkrule,RM,,$(PRG))

zip: clear
	$(call mkrule,ZIP,$(ZFLAGS),244923.zip,*)

ifeq (,$(findstring $(MAKECMDGOALS),clean clear zip))
 include rules.mk
endif

$(PRG): $(OBJS)
	$(call mkrule,LD,$(LDFLAGS) $(LDLIBS) -o,$@,$^)

%.mk: $(SRCS)
	$(call mkrule,MKMF,$(MKMFFLAGS) >,$@,$^)

%.o: %.cc
	$(call mkrule,CXX,$(CXXFLAGS) -c -o,$@,$<)

%.yy.cc: %.yy
	$(call mkrule,YACC,$(YFLAGS) -o,$@,$<)
	@printf ',s/$$undefined/token/g\nw\n' | ed $@ >/dev/null
	@printf ',s/$$end/end of file/g\nw\n' | ed $@ >/dev/null

%.ll.cc: %.ll
	$(call mkrule,LEX,$(LFLAGS) -o,$@,$<)

%.yy:;
%.ll:;

