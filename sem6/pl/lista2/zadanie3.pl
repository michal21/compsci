% -*- prolog -*-

arc(a, b).
arc(b, a).
arc(b, c).
arc(c, d).

iosiagalny(X, Y, VIS) :-
    arc(X, Y), \+ member(Y, VIS);
    arc(X, R), \+ member(R, VIS), iosiagalny(R, Y, [X | VIS]).

osiągalny(X, Y) :-
    X = Y; iosiagalny(X, Y, [X]).
