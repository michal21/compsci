% -*- prolog -*-

program([]) --> [].
program([I | P]) --> instruction(I), [sep(;)], program(P).

instruction(assign(ID, EX)) --> [id(ID)], [sep(:=)], expression(EX).
instruction(read(ID)) --> [key(read)], [id(ID)].
instruction(write(EXPR)) --> [key(write)], expression(EXPR).
instruction(if(CND, PRG)) --> [key(if)], condition(CND), [key(then)], program(PRG), [key(fi)].
instruction(if(CND, PRG, ELS)) --> [key(if)], condition(CND), [key(then)], program(PRG),
    [key(else)], program(ELS), [key(fi)].
instruction(while(CND, PRG)) --> [key(while)], condition(CND), [key(do)], program(PRG), [key(od)].

expression(C + E) --> component(C), [sep(+)], expression(E).
expression(C - E) --> component(C), [sep(-)], expression(E).
expression(C) --> component(C).

component(E * C) --> element(E), [sep(*)], component(C).
component(E / C) --> element(E), [sep(/)], component(C).
component(E mod C) --> element(E), [key(mod)], component(C).
component(E) --> element(E).

element(id(E)) --> [id(E)].
element(int(E)) --> [int(E)].
element(E) --> [sep('(')], expression(E), [sep(')')].

condition(C1; C2) --> conjunction(C1), [key(or)], condition(C2).
condition(C) --> conjunction(C).

conjunction(S ',' C) --> simple(S), [key(and)], conjunction(C).
conjunction(S) --> simple(S).

simple(E1 =:= E2) --> expression(E1), [sep(=)], expression(E2).
simple(E1 =\= E2) --> expression(E1), [sep(/=)], expression(E2).
simple(E1 < E2) --> expression(E1), [sep(<)], expression(E2).
simple(E1 > E2) --> expression(E1), [sep(>)], expression(E2).
simple(E1 >= E2) --> expression(E1), [sep(>=)], expression(E2).
simple(E1 =< E2) --> expression(E1), [sep(<=)], expression(E2).
simple(C) --> [sep('(')], condition(C), [sep(')')].
