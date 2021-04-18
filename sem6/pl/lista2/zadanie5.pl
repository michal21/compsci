% -*- prolog -*-

list([], [], [], []).

list(L, F, S, R) :-
    select(X, F, FX),
    list(L, S, FX, RR),
    R = [X | RR].

list([X | Xs], F, S, R) :-
    list(Xs, [X | S], F, RR),
    R = [X | RR].

lista(N, X) :-
    numlist(1, N, L),
    list(L, [], [], X).

