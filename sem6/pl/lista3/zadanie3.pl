% -*- prolog -*-

:- import(lists).

inv(L, [X, Y]) :-
    append(_, [X | R], L),
    member(Y, R),
    X > Y.

invcnt(L, X) :-
    findall(Y, inv(L, Y), I),
    length(I, X).

n_permutation(L, X, N) :-
    perm(L, X),
    invcnt(X, C),
    C mod 2 =:= N.

even_permutation(L, X) :- n_permutation(L, X, 0).
odd_permutation(L, X)  :- n_permutation(L, X, 1).

