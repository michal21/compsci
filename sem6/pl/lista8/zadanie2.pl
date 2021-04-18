% -*- prolog -*-

:- use_module(library(clpfd)).

plecak(V, S, C, R) :-
    length(V, L),
    length(S, L),
    length(R, L),
    R ins 0..sup,
    scalar_product(S, R, #=<, C),
    scalar_product(V, R, #=, P),
    once(labeling([max(P)], R)).
