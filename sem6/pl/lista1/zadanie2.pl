% -*- prolog -*-
% on(B1, B2)

on(a, b).
on(b, c).
on(c, d).
on(d, e).

above(B1, B2) :-
    on(B1, B2);
    on(X, B2), above(B1, X).
