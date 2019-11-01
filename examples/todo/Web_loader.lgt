:- if((
	current_logtalk_flag(prolog_dialect, swi),
	current_prolog_flag(gui, true)
)).


    :- initialization((
		logtalk_load_context(directory, Directory),
		atom_concat(Directory, web_hooks, Path),
		consult(Path),
        logtalk_load([ sitcalc(loader)
                     , random(loader)
                     , bedsit(loader)
                     , todo
                     ]),
        persistent_manager::new(sm, 'todo_storage.pl'),
        define_events(after, _, do(_), _, view_class),
        define_events(after, _, do(_), _, persistent_manager),
        logtalk_load(todo_web),
        server::serve
                 )).

:- else.

	:- initialization((
		write('(this example requires SWI-Prolog as the backend compiler)'), nl
	)).

:- endif.
