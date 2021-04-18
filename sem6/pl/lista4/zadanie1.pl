% -*- prolog -*-

expr([X], X).
expr([X | Xs], E) :-
    expr(Xs, Y), (
        E = X + Y;
        E = X - Y;
        E = X * Y;
        (E = X / Y, Y =\= 0)).

expr(L, E) :-
	append(Xs, [X], L),
    expr(Xs, Y), (
        E = Y + X;
        E = Y - X;
        E = Y * X;
        (E = Y / X, X =\= 0)).

wyrażenie(L, R, E) :-
    expr(L, E),
    E =:= R.

