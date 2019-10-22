CXX=clang++
CXXFLAGS=-std=c++2a -g #-fsanitize=address #-DPRETTY_OUTPUT

.PHONY: all
all: fam kmp

fam: fam.o
kmp: kmp.o

%: %.o
	$(CXX) $(CXXFLAGS) $^ -o $@

%.o: %.c++
	$(CXX) $(CXXFLAGS) -c $< -o $@

.PHONY: clean
clean:
	$(RM) fam{,.o} kmp{,.o}

