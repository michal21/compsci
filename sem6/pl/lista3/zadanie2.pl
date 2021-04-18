% -*- prolog -*-

max_sum_([], Best, _, Best).
max_sum_([X | Xs], Best, Sum, RBest) :-
    NSum is max(0, Sum + X),
    NBest is max(Best, NSum),
    max_sum_(Xs, NBest, NSum, RBest).

max_sum(L, S) :- max_sum_(L, 0, 0, S).
