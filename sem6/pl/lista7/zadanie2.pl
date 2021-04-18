% -*- prolog -*-

:- ["zadanie1"].

split_(I, [], [], _) :-
    freeze(I, (I = [])).

split_([I | Is], O1, O2, T) :-
    freeze(I, (
               T = 1 ->
               split_(Is, NO1, O2, 2),
               O1 = [I | NO1];
               split_(Is, O1, NO2, 1),
               O2 = [I | NO2])).

split(IN, OUT1, OUT2) :- split_(IN, OUT1, OUT2, 1).

merge_sort(I, O) :-
    freeze(I, (I = [E], O = [E])).

merge_sort(I, O) :-
    I = [Z, Y | _],
    freeze2(Z, Y, (
               split(I, U1, U2),
               merge_sort(U1, S1),
               merge_sort(U2, S2),
               merge(S1, S2, O))).
