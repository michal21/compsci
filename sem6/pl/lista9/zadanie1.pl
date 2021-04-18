% -*- prolog -*-

:- use_module(library(clpfd)).

tasks([
    [2, 1, 3],
    [3, 2, 1],
    [4, 2, 2],
    [3, 3, 2],
    [3, 1, 1],
    [3, 4, 2],
    [5, 2, 1]]).

resources(5, 5).

mt1([], _, _, [], [], _).
mt1([[D, R, _] | L1], I, H, [task(S, D, E, R, I) | L2], [S | L3], MS) :-
    I1 is I + 1,
    S in 0..H,
    E #= S + D,
    MS #>= E,
    mt1(L1, I1, H, L2, L3, MS).

mt2([], _, _, [], [], _).
mt2([[D, _, R] | L1], I, H, [task(S, D, E, R, I) | L2], [S | L3], MS) :-
    I1 is I + 1,
    S in 0..H,
    E #= S + D,
    MS #>= E,
    mt2(L1, I1, H, L2, L3, MS).

schedule(H, S, MS) :-
    tasks(L),
    resources(R1, R2),
    MS in 0..H,
    mt1(L, 1, H, T1, S, MS),
    cumulative(T1, [limit(R1)]),
    mt2(L, 1, H, T2, S, MS),
    cumulative(T2, [limit(R2)]),
    once(labeling([min(MS), ff], [MS | S])).
