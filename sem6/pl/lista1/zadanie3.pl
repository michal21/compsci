% -*- prolog -*-
left_of(butterfly, fish).
left_of(hourglass, butterfly).
left_of(pencil, hourglass).

above(camera, butterfly).
above(bicycle, pencil).

right_of(O1, O2) :- left_of(O2, O1).
below(O1, O2) :- above(O2, O1).

rleft_of(O1, O2) :-
    left_of(O1, O2);
    left_of(X, O2), rleft_of(O1, X).

rabove(O1, O2) :-
    above(O1, O2);
    above(X, O2), rabove(O1, X).

samelevel(O1, O2) :-
    O1 = O2;
    rleft_of(O1, O2);
    rleft_of(O2, O1);
    above(O1, X), above(O2, Y), samelevel(X, Y).

higher(O1, O2) :- samelevel(X, O2), rabove(O1, X).

