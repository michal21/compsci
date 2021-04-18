% -*- prolog -*-

left(D, D1, D2) :- append(_, R, D), R = [D1, D2 | _].
near(D, D1, D2) :- left(D, D1, D2); left(D, D2, D1).

rybki(Kto) :-
    D = [D1, _, D3, _, _],
    member([_, Kto, rybki, _, _], D),
    % kolor, kto, zwierze, pije, pali
    D1 = [_, norweg, _, _, _],
    member([czerwony, anglik, _, _, _], D),
    left(D, [zielony, _, _, _, _], [bialy, _, _, _, _]),
    member([_, dunczyk, _, herbata, _], D),
    near(D, [_, _, _, _, light], [_, _, koty, _, _]),
    member([zolty, _, _, _, cygara], D),
    member([_, niemiec, _, _, fajka], D),
    D3 = [_, _, _, mleko, _],
    near(D, [_, _, _, _, light], [_, _, _, woda, _]),
    member([_, _, ptaki, _, bezfiltra], D),
    member([_, szwed, psy, _, _], D),
    near(D, [_, norweg, _, _, _], [niebieski, _, _, _, _]),
    near(D, [_, _, konie, _, _], [zolty, _, _, _, _]),
    member([_, _, _, piwo, mentolowe], D),
    member([zielony, _, _, kawa, _], D).

