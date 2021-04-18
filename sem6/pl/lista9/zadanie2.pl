% -*- prolog -*-

:- use_module(library(clpfd)).
%:- use_module(library(pce)).

inv([], [], _, []).
inv([X, Y | PS], [N | NS], H, [X, Y1 | RS]) :-
    Y1 is H - Y - N,
    inv(PS, NS, H, RS).

msq([], _, _, [], []).
msq([N | NS], MX, MY, [X, Y | R], [rect(X, N, Y, N) | RSET]) :-
    X #>= 0,
    Y #>= 0,
    X #=< MX - N,
    Y #=< MY - N,
    msq(NS, MX, MY, R, RSET).

kwadraty(NS, MX, MY, RR) :-
    msq(NS, MX, MY, R, RSET),
    disjoint2(RSET),
    once(label(R)),
    inv(R, NS, MY, RR).
%    show(RR, NS, MX, MY, 20).

%drawsqr([], [], _, _, _).
%drawsqr([X, Y | PS], [N | NS], W, H, S) :-
%    X1 is X * S,
%    Y1 is (H - Y - N) * S,
%    N1 is N * S,
%    send(@p, display, new(B, box(N1, N1)), point(X1, Y1)),
%    send(B, fill_pattern, colour(light_blue)),
%    drawsqr(PS, NS, W, H, S).

%show(PS, NS, W, H, S) :-
%    W1 is W * S,
%    H1 is H * S,
%    new(@p, window('Window')),
%    send(@p, display, new(B, box(W1, H1))),
%    send(B, fill_pattern, colour(dark_blue)),
%    send(@p, width, W1),
%    send(@p, height, H1),
%    send(@p, resize),
%    drawsqr(PS, NS, W, H, S),
%    send(@p, open).
