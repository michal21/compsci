% -*- prolog -*-

jednokrotnie(X, L) :- select(X, L, M), \+ member(X, M).
dwukrotnie(X, L) :- select(X, L, M), jednokrotnie(X, M).
