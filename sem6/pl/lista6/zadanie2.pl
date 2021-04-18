% -*- prolog -*-

:- ["../lista5/zadanie1"].
:- ["zadanie1"].

podstaw([], ID, N, [ID = N]).
podstaw([ID = _ | AS], ID, N, [ID = N | AS]) :- !.
podstaw([ID1 = W1 | AS1], ID, N, [ID1 = W1 | AS2]) :- podstaw(AS1, ID, N, AS2).

pobierz([ID = N | _], ID, N) :- !.
pobierz([_ | AS], ID, N) :- pobierz(AS, ID, N).

wartosc(int(N), _, N).
wartosc(id(ID), AS, N) :- pobierz(AS, ID, N).
wartosc(W1 + W2, AS, N) :- wartosc(W1, AS, N1), wartosc(W2, AS, N2), N is N1 + N2.
wartosc(W1 - W2, AS, N) :- wartosc(W1, AS, N1), wartosc(W2, AS, N2), N is N1 - N2.
wartosc(W1 * W2, AS, N) :- wartosc(W1, AS, N1), wartosc(W2, AS, N2), N is N1 * N2.
wartosc(W1 / W2, AS, N) :- wartosc(W1, AS, N1), wartosc(W2, AS, N2), N2 =\= 0, N is N1 div N2.
wartosc(W1 mod W2, AS, N) :- wartosc(W1, AS, N1), wartosc(W2, AS, N2), N2 =\= 0,N is N1 mod N2.

prawda(W1 =:= W2, AS) :- wartosc(W1, AS, N1), wartosc(W2, AS, N2), N1 =:= N2.
prawda(W1 =\= W2, AS) :- wartosc(W1, AS, N1), wartosc(W2, AS, N2), N1 =\= N2.
prawda(W1 < W2, AS) :- wartosc(W1, AS, N1), wartosc(W2, AS, N2), N1 < N2.
prawda(W1 > W2, AS) :- wartosc(W1, AS, N1), wartosc(W2, AS, N2), N1 > N2.
prawda(W1 >= W2, AS) :- wartosc(W1, AS, N1), wartosc(W2, AS, N2), N1 >= N2.
prawda(W1 =< W2, AS) :- wartosc(W1, AS, N1), wartosc(W2, AS, N2), N1 =< N2.
prawda((W1, W2), AS) :- prawda(W1, AS),prawda(W2, AS).
prawda((W1; W2), AS) :-( prawda(W1, AS), !; prawda(W2, AS)).

interpreter([], _).
interpreter([read(ID) | PGM], AS) :- !, read(N), integer(N), podstaw(AS, ID, N, AS1), interpreter(PGM, AS1).
interpreter([write(W) | PGM], AS) :- !, wartosc(W, AS, WART), write(WART), nl, interpreter(PGM, AS).
interpreter([assign(ID, W) | PGM], AS) :- !, wartosc(W, AS, WAR), podstaw(AS, ID, WAR, AS1), interpreter(PGM, AS1).
interpreter([if(C, P) | PGM], ASO) :- !, interpreter([if(C, P, []) | PGM], ASO).
interpreter([if(C, P1, P2) | PGM], AS) :-
    !, (prawda(C, AS) -> append(P1, PGM, DALEJ); append(P2, PGM, DALEJ)), interpreter(DALEJ, AS).
interpreter([while(C, P) | PGM], AS) :- !, append(P, [while(C, P)], DALEJ), interpreter([if(C, DALEJ) | PGM], AS).

interpreter(PROGRAM) :- interpreter(PROGRAM, []).

wykonaj(F) :-
    open(F, read, S),
    scanner(S, T),
    close(S),
    phrase(program(P), T),
    interpreter(P).
