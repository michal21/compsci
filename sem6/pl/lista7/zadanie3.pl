% -*- prolog -*-

log(ID, LM, MSG) :-
    mutex_lock(LM),
    tab(ID),
    write("["),
    write(ID),
    write("] "),
    write(MSG),
    write(.),
    nl,
    mutex_unlock(LM).

cycle(ID, LM, L, R) :-
    log(ID, LM, "mysli"),
    log(ID, LM, "chce prawy widelec"),
    mutex_lock(R),
    log(ID, LM, "podnosi prawy widelec"),
    log(ID, LM, "chce lewy widelec"),
    mutex_lock(L),
    log(ID, LM, "podnosi lewy widelec"),
    log(ID, LM, "je"),
    log(ID, LM, "odklada prawy widelec"),
    mutex_unlock(R),
    log(ID, LM, "odklada lewy widelec"),
    mutex_unlock(L),
    cycle(ID, LM, R, L).

filozofowie() :-
    mutex_create(LM),
    mutex_create(F1),
    mutex_create(F2),
    mutex_create(F3),
    mutex_create(F4),
    mutex_create(F5),
    thread_create(cycle(1, LM, F1, F2), _),
    thread_create(cycle(2, LM, F2, F3), _),
    thread_create(cycle(3, LM, F3, F4), _),
    thread_create(cycle(4, LM, F4, F5), _),
    thread_create(cycle(5, LM, F5, F1), _).

