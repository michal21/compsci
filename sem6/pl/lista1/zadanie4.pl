% -*- prolog -*-
% le(X, Y)

le(1, 1).
le(1, 2).
le(1, 3).
le(1, 4).
le(1, 5).
le(1, 6).

le(2, 1).
le(2, 2).
le(2, 3).
le(2, 4).
le(2, 5).
le(2, 6).

le(3, 1).
le(3, 2).
le(3, 3).
le(3, 4).
le(3, 5).
le(3, 6).
le(3, 7).

le(4, 1).
le(4, 2).
le(4, 3).
le(4, 4).
le(4, 7).

le(5, 1).
le(5, 2).
le(5, 3).
le(5, 5).
le(5, 6).
le(5, 7).

le(6, 1).
le(6, 2).
le(6, 3).
le(6, 5).
le(6, 6).
le(6, 7).

le(7, 3).
le(7, 4).
le(7, 5).
le(7, 6).
le(7, 7).

maksymalny(X) :- le(_, X),
    \+ (le(X, Y), X \= Y),
    !.
minimalny(X) :- le(X, _),
    \+ (le(Y, X), X \= Y),
    !.

najwiekszy(X) :- \+ (
    le(_, Z), \+ le(Z, X)).
najmniejszy(X) :- \+ (
    le(Y, _), \+ le(X, Y)).

