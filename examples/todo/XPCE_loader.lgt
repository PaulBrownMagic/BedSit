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
        writeln('Init1'),
        persistence(PersistenceFile)::restore(Sit),
        writeln('Init2'),
        situation::init(Sit),
        writeln('Init3'),
        define_events(after, situation, do(_), _, todo_view),
        define_events(after, _, do(_), _, persistence(PersistenceFile)),
        writeln('Init4444'),
        logtalk_load(todo_xpce),
        writeln('Init5'),
        app::init
                 )).

:- else.

    :- initialization((
        write('(this example requires SWI-Prolog as the backend compiler)'), nl
    )).

:- endif.
