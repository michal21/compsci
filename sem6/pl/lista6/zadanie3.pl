% -*- prolog -*-

sym1(e, _) --> [].
sym1(s(Sem), S) --> [S], sym1(Sem, S).
sym2(e, _) --> [].
sym2(s(e), S) --> [S].
sym2(s(s(Sem)), S) --> sym2(s(Sem), S), sym2(Sem, S).

% to są te gramatyki:
s1 --> sym1(Sem, a), sym1(Sem, b).
s2 --> sym1(Sem, a), sym1(Sem, b), sym1(Sem, c).
s3 --> sym1(Sem, a), sym2(Sem, b).

p([]) --> [].
p([X | Xs]) --> [X], p(Xs).
% phrase(p(L1), L2, L3) <-> append(L1, L3, L2)
