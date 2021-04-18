% -*- prolog -*-

:- use_module(library(clpfd)).

odcinek(X) :-
    X = [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P],
    X ins 0..1,
    sum(X, #=, 8),
    (0 #< A) #<==> XA, (A #< B) #<==> XB, (B #< C) #<==> XC, (C #< D) #<==> XD,
    (D #< E) #<==> XE, (E #< F) #<==> XF, (F #< G) #<==> XG, (G #< H) #<==> XH,
    (H #< I) #<==> XI, (I #< J) #<==> XJ, (J #< K) #<==> XK, (K #< L) #<==> XL,
    (L #< M) #<==> XM, (M #< N) #<==> XN, (N #< O) #<==> XO, (O #< P) #<==> XP,
    XA + XB + XC + XD + XE + XF + XG + XH + XI + XJ + XK + XL + XM + XN + XO + XP #= 1.
