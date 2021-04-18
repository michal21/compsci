% -*- prolog -*-

% +-1-+-2-+-3-+
% 4   5   6   7
% +-8-+-9-+-0-+
% 1   2   3   4
% +-5-+-6-+-7-+
% 8   9   0   1
% +-2-+-3-+-4-+

sqr(_, 0, []).

sqr(1, 1, [ 1,  4,  5,  8]).
sqr(1, 1, [ 2,  5,  6,  9]).
sqr(1, 1, [ 3,  6,  7, 10]).
sqr(1, 1, [ 8, 11, 12, 15]).
sqr(1, 1, [ 9, 12, 13, 16]).
sqr(1, 1, [10, 13, 14, 17]).
sqr(1, 1, [15, 18, 19, 22]).
sqr(1, 1, [16, 19, 20, 23]).
sqr(1, 1, [17, 20, 21, 24]).

sqr(2, 1, [ 1,  2,  4,  6, 11, 13, 15, 16]).
sqr(2, 1, [ 2,  3,  5,  7, 12, 14, 16, 17]).
sqr(2, 1, [ 8,  9, 11, 13, 18, 20, 22, 23]).
sqr(2, 1, [ 9, 10, 12, 14, 19, 21, 23, 24]).

sqr(3, 1, [1, 2, 3, 4, 7, 11, 14, 18, 21, 22, 23, 24]).

sqr(S, N, R) :-
    N1 is N - 1,
    N1 > 0,
    sqr(S, 1, X),
    sqr(S, N1, Y),
    min_list(X, SX),
    min_list(Y, SY),
    SX < SY,
    union(X, Y, R),
    R \= Y.

sqrcnt_([], _, A, A).
sqrcnt_([X | Xs], L, A, R) :-
    intersection(X, L, X) -> (A1 is A + 1, sqrcnt_(Xs, L, A1, R));
    sqrcnt_(Xs, L, A, R).

sqrcnt(X, L, R) :- sqrcnt_(X, L, 0, R).

writeif(W, L, X) :-
    member(X, L) ->
    write(W), !;
    atom_length(W, N), tab(N).

drawhoriz(L, N1, N2, N3) :-
    write(+), writeif(---, L, N1),
    write(+), writeif(---, L, N2),
    write(+), writeif(---, L, N3),
    write(+), nl.

drawvert(L, N1, N2, N3, N4) :-
    writeif("|", L, N1), tab(3),
    writeif("|", L, N2), tab(3),
    writeif("|", L, N3), tab(3),
    writeif("|", L, N4), nl.

drawsqr(L) :-
    write("Rozwiazanie:"), nl,
    drawhoriz(L,  1,  2,  3    ),
    drawvert( L,  4,  5,  6,  7),
    drawhoriz(L,  8,  9, 10    ),
    drawvert( L, 11, 12, 13, 14),
    drawhoriz(L, 15, 16, 17    ),
    drawvert( L, 18, 19, 20, 21),
    drawhoriz(L, 22, 23, 24    ).

solve(T, B, M, S) :-
    sqr(3, B, S3),
    sqr(2, M, S2),
    sqr(1, S, S1),
    union(S1, S2, U),
    union(U, S3, R),
    sqrcnt([[ 1,  4,  5,  8], [ 2,  5,  6,  9], [ 3,  6,  7, 10],
            [ 8, 11, 12, 15], [ 9, 12, 13, 16], [10, 13, 14, 17],
            [15, 18, 19, 22], [16, 19, 20, 23], [17, 20, 21, 24]], R, S),
    sqrcnt([[ 1,  2,  4,  6, 11, 13, 15, 16], [ 2,  3,  5,  7, 12, 14, 16, 17],
            [ 8,  9, 11, 13, 18, 20, 22, 23], [ 9, 10, 12, 14, 19, 21, 23, 24]], R, M),
    sqrcnt([[1, 2, 3, 4, 7, 11, 14, 18, 21, 22, 23, 24]], R, B),
    length(R, N),
    T is 24 - N,
    drawsqr(R).

zapalki_(N, (T), B, M, S) :-
    T = duze(TN),    solve(N, TN, M, S);
    T = srednie(TN), solve(N, B, TN, S);
    T = male(TN),    solve(N, B, M, TN).

zapalki_(N, (T, Ts), B, M, S) :-
    T = duze(TN),    zapalki_(N, (Ts), TN, M, S);
    T = srednie(TN), zapalki_(N, (Ts), B, TN, S);
    T = male(TN),    zapalki_(N, (Ts), B, M, TN).

zapalki(N, T) :- zapalki_(N, T, 0, 0, 0).
