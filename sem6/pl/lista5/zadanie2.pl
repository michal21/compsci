% -*- prolog -*-

hetmany(N, P) :-
    numlist(1, N, L),
    permutation(L, P),
    dobra(P).

dobra(P) :-
    \+ zla(P).

zla(P) :-
    append(_, [Wi | L1], P),
    append(L2, [Wj | _], L1),
    length(L2, K),
    abs(Wi - Wj) =:= K + 1.

occurances_([], _, A, _, A).
occurances_([X | Xs], E, A, P, R) :-
    P1 is P + 1, (
                  X = E ->
                  occurances_(Xs, E, [P | A], P1, R);
                  occurances_(Xs, E, A,       P1, R)).

occurances(L, E, R) :-
    occurances_(L, E, [], 0, RR),
    reverse(RR, R).

line(0) :- write(+), nl.
line(N) :-
    N > 0,
    N1 is N - 1,
    write(+-----),
    line(N1).

field(N, C, F, L, W1, W2) :-
    C1 is C + 1, (
                  L = [C | L1] ->
                  write(W2), rowline(N, C1, F, L1);
                  write(W1), rowline(N, C1, F, L)).

rowline(N, N, _, _) :- write('|'), nl.
rowline(N, C, 0, L) :- C < N, field(N, C, 1, L, '|     ', '| ### ').
rowline(N, C, 1, L) :- C < N, field(N, C, 0, L, '|:::::', '|:###:').

row(N, N, _) :- line(N).
row(N, C, L) :-
    C < N,
    C1 is C + 1,
    H is N - C,
    F is H mod 2,
    occurances(L, H, O),
    line(N),
    rowline(N, 0, F, O),
    rowline(N, 0, F, O),
    row(N, C1, L).

board(L) :-
    length(L, N),
    row(N, 0, L),
    !.
