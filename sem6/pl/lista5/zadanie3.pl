% -*- prolog -*-

browse_([Cur | Next], Prev, Out) :-
    %write(------------), nl,
    %write('Prev: '), writeq(Prev), nl,
    %write('Cur: '), writeq(Cur), nl,
    %write('Next: '), writeq(Next), nl,
    %write('Out: '), writeq(Out), nl,
    writeq(Cur), nl,
    write('command: '),
    read(C), (
        C = n, browse_(Next, [Cur | Prev], Out);
        C = p, Prev = [P | Ps], browse_([P, Cur | Next], Ps, Out);
        C = i, Cur =.. [_ | In], browse_(In, [], [[Cur, Next, Prev] | Out]);
        C = o, (
                Out = [], !;
                Out = [[CC, N, P] | O], browse_([CC | N], P, O)));
    browse_([Cur | Next], Prev, Out).

browse(T) :- browse_([T], [], []).
