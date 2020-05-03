MAKEFLAGS+=-r

CXX:=clang++
CXXFLAGS:=-w
LD:=$(CXX)
LDFLAGS:=$(CXXFLAGS)
LDLIBS:=-lreadline
YACC:=bison
YFLAGS:=-d
LEX:=flex
LFLAGS:=


PRG:=calc
INT:=$(addprefix $(PRG),.o .yy.cc .yy.hh .yy.o .ll.cc .ll.o)


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


.PHONY: all clean clear
.PRECIOUS: $(INT)

all: $(PRG)

$(PRG): $(addprefix $(PRG),.o .yy.o .ll.o)

clean:
	$(call mkrule,RM,,$(INT))

clear: clean
	$(call mkrule,RM,,$(PRG))


%: %.o
	$(call mkrule,LD,$(LDFLAGS) $(LDLIBS) -o,$@,$^)

%.o: %.cc
	$(call mkrule,CXX,$(CXXFLAGS) -c -o,$@,$<)

%.yy.cc: %.yy
	$(call mkrule,YACC,$(YFLAGS) -o,$@,$<)

%.ll.cc: %.ll
	$(call mkrule,LEX,$(LFLAGS) -o,$@,$<)

%.yy:;
%.ll:;

