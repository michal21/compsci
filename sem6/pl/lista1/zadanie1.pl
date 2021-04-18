% -*- prolog -*-
% ojciec(X, Y).          /* X jest ojcem Y       */
% matka(X, Y).           /* X jest matka Y       */
% mezczyzna(X).          /* X jest mezczyzna     */
% kobieta(X).            /* X jest kobieta       */
% rodzic(X, Y).          /* X jest rodzicem Y    */

ojciec(w, e).
ojciec(a, m).
ojciec(m, s).
ojciec(m, g).
matka(e, s).
matka(e, g).
matka(b, e).
matka(ma, m).
mezczyzna(w).
mezczyzna(m).
mezczyzna(g).
kobieta(e).
kobieta(g).
kobieta(ma).
kobieta(b).

rodzic(X, Y) :- matka(X, Y); ojciec(X, Y).
jest_matka(X) :- matka(X, _).
jest_ojcem(X) :- ojciec(X, _).
jest_synem(X) :- rodzic(_, X), mezczyzna(X).
siostra(X, Y) :- X \= Y, rodzic(R, X), rodzic(R, Y), kobieta(X).
dziadek(X, Y) :- rodzic(R, Y), rodzic(X, R), mezczyzna(X).
rodzenstwo(X, Y) :- X \= Y, rodzic(R, X), rodzic(R, Y).

