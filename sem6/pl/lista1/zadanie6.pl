% -*- prolog -*-

is_prime(2).
is_prime(3).

is_prime(X) :-
    X > 3,
	X mod 2 =\= 0,
    is_prime_(X, 3).

is_prime_(X, Y) :-
    Y * Y > X, !;
	X mod Y =\= 0,
	is_prime_(X, Y + 2).

prime(LO, HI, N) :- between(LO, HI, N), is_prime(N).

