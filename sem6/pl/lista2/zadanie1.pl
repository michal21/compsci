% -*- prolog -*-

środkowy([X], X).
środkowy([_ | L], X) :- append(M, [_], L), środkowy(M, X), !.
