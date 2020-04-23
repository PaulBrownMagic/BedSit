:- if((
    current_logtalk_flag(prolog_dialect, swi),
    current_prolog_flag(gui, true)
)).


    :- initialization((
        consult('xpce_hooks.pl'),
        logtalk_load([ sitcalc(loader)
                     , random(loader)
                     , bedsit(loader)
                     , todo
                     ]),
        PersistenceFile = 'todo_storage.pl',
        persistence(PersistenceFile)::restore(Sit),
        bedsit::init(Sit),
        logtalk_load(todo_xpce),
        define_events(after, bedsit, do(_), _, todo_view),
        define_events(after, _, do(_), _, persistence(PersistenceFile)),
        app::init
                 )).

:- else.

    :- initialization((
        write('(this example requires SWI-Prolog as the backend compiler)'), nl
    )).

:- endif.
