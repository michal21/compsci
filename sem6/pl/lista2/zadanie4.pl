% -*- prolog -*-

regula(X, *, Y, Y) :- number(X), X =:= 1.
regula(X, *, Y, X) :- number(Y), Y =:= 1.
regula(X, *, _, 0) :- number(X), X =:= 0.
regula(_, *, X, 0) :- number(X), X =:= 0.

regula(X, /, Y, R) :- X = R * Y; X = Y * R.
regula(X, /, Y, R) :- number(X), number(Y), (X =:= R * Y; X =:= Y * R).
regula(X, /, X, 1) :- X \= 0.

regula(X, +, Y, Y) :- number(X), X =:= 0.
regula(X, +, Y, X) :- number(Y), Y =:= 0.

regula(X, -, Y, Y) :- number(X), X =:= 0.
regula(X, -, Y, X) :- number(Y), Y =:= 0.
regula(X, -, X, 0).

regula(X, *, Y, X * Y).
regula(X, /, Y, X / Y).
regula(X, +, Y, X + Y).
regula(X, -, Y, X - Y).

uprosc_(E, R) :-
    E = A * B, uprosc_(A, SA), uprosc_(B, SB), regula(SA, *, SB, R);
    E = A / B, uprosc_(A, SA), uprosc_(B, SB), regula(SA, /, SB, R);
    E = A + B, uprosc_(A, SA), uprosc_(B, SB), regula(SA, +, SB, R);
    E = A - B, uprosc_(A, SA), uprosc_(B, SB), regula(SA, -, SB, R);
    R = E.

uprość(E, R) :- uprosc_(E, R), !.

