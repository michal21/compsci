% -*- prolog -*-

scanner(S, T) :-
    get_char(S, C),
    dispatch(S, C, T).

dispatch(_, end_of_file, []) :- !.
dispatch(S, C, R) :- char_type(C, space), get_char(S, C1), dispatch(S, C1, R), !.
dispatch(S, C, R) :- char_type(C, lower), handle_key(S, C, [], R), !.
dispatch(S, C, R) :- char_type(C, upper), handle_id(S, C, [], R), !.
dispatch(S, C, R) :- char_type(C, digit), handle_int(S, C, 0, R), !.
dispatch(S, ;, R) :- onechar(S, ;, R).
dispatch(S, +, R) :- onechar(S, +, R).
dispatch(S, -, R) :- onechar(S, -, R).
dispatch(S, *, R) :- onechar(S, *, R).
dispatch(S, >, R) :- onechar(S, >, R).
dispatch(S, '(', R) :- onechar(S, '(', R).
dispatch(S, ')', R) :- onechar(S, ')', R).
dispatch(S, /, R) :- twochars(S, /, =, /=, R).
dispatch(S, <, R) :- twochars(S, <, =, <=, R).
dispatch(S, =, R) :- twochars(S, =, >, =>, R).
dispatch(S, :, R) :-
    get_char(S, =),
    get_char(S, C1),
    dispatch(S, C1, L),
    R = [ sep(:=) | L],
    !.

onechar(S, C, R) :- get_char(S, C1), dispatch(S, C1, L), R = [ sep(C) | L], !.

twochars(Str, F, S, FS, R) :-
    get_char(Str, C), (
    C = S -> get_char(Str, C1), dispatch(Str, C1, L), R = [ sep(FS) | L], !;
    dispatch(Str, C, L), R = [ sep(F) | L ], !).

handle_key(S, C, B, R) :-
     get_char(S, C1), (
         char_type(C1, lower),
         handle_key(S, C1, [ C | B ], R);
         reverse([ C | B ], TR),
         atom_codes(T, TR),
         kwrd(T),
         dispatch(S, C1, L),
         R = [ key(T) | L]), !.

handle_id(S, C, B, R) :-
    get_char(S, C1), (
        char_type(C1, upper),
        handle_id(S, C1, [ C | B ], R);
        reverse([ C | B ], TR),
        atom_codes(T, TR),
        dispatch(S, C1, L),
        R = [ id(T) | L ]), !.

handle_int(S, C, B, R) :-
    char_type(C, digit(CN)),
    N is  B * 10 + CN,
    get_char(S, C1), (
        char_type(C1, digit),
        handle_int(S, C1, N, R);
        dispatch(S, C1, L),
        R = [ int(N) | L ]), !.

kwrd(read).
kwrd(write).
kwrd(if).
kwrd(then).
kwrd(else).
kwrd(fi).
kwrd(while).
kwrd(do).
kwrd(od).
kwrd(and).
kwrd(or).
kwrd(mod).

