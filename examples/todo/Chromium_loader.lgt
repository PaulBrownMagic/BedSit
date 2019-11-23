:- if((
    current_logtalk_flag(prolog_dialect, swi),
    current_prolog_flag(gui, true)
)).


    :- initialization((
        logtalk_load([web_hooks, chromium_app]),
        logtalk_load([ sitcalc(loader)
                     , random(loader)
                     , bedsit(loader)
                     , todo
                     ]),
        PersistenceFile = 'todo_storage.pl',
        persistence(PersistenceFile)::restore(Sit),
        situation::init(Sit),
        define_events(after, situation, do(_), _, todo_view),
        define_events(after, _, do(_), _, persistence(PersistenceFile)),
        logtalk_load(todo_web),
        server::serve,
        open_chromium_app
                 )).

:- else.

    :- initialization((
        write('(this example requires SWI-Prolog as the backend compiler)'), nl
    )).

:- endif.
