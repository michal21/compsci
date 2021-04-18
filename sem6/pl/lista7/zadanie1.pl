% -*- prolog -*-

freeze2(A, B, C) :- freeze(A, freeze(B, C)).

merge(X, Y, R) :- freeze(Y, (Y = [], freeze(X, (R = X)))).
merge(X, Y, R) :- freeze(X, (X = [], freeze(Y, (R = Y)))).

merge([X | Xs], [Y | Ys], R) :-
    freeze2(X, Y, (
                   X < Y ->
                   R = [X | L], merge(Xs, [Y | Ys], L);
                   R = [Y | L], merge([X | Xs], Ys, L))).
