% -*- prolog -*-

sqsum([X],      A, S, R) :- Y is X - A, R is S + Y * Y.
sqsum([X | Xs], A, S, R) :- Y is X - A, sqsum(Xs, A, S + Y * Y, R).

wariancja([], 0).
wariancja(L, D) :-
    length(L, C),
    C > 0,
    sumlist(L, S),
    A is S / C,
    sqsum(L, A, 0, R),
    D is R / C.
