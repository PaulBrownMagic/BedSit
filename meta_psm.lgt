
:- object(meta_psm,
    implements(monitoring),
    specializes(bedsit_metaclass)).

    :- info([ version is 1.0
            , author is 'Paul Brown'
            , date is 2019/11/1
            , comment is 'An specialization of the metaclass for persistent_managers.'
            ]).

    :- public(new/4).
    :- mode(new(?object, +atom, +object, +term), zero_or_one).
    :- info(new/4,
        [ comment is 'Create an instance of persistent_manager observing the SituationManager, which is also created with the Situation.'
        , argnames is ['SituationManager', 'File', 'BackEnd', 'DefaultSituation']
        ]).
    new(SM, File, Backend, Sit) :-
        atom(File), ground(Sit),
        check_make(SM, File, Backend, Sit),
        ^^instantiate(_, [persisting_file_(File), situation_manager_(SM)]).

    % Check if situation_manager exists or instantiate
    check_make(SM, _, _, _) :-
        % Already exists.
        nonvar(SM),
        situation_manager::instance(SM), !.
    check_make(SM, File, Backend, Sit) :-
        (nonvar(SM), \+ current_object(SM) ; var(SM)),
        restore(File, SM, Backend, Sit).

    % On instantiation read in situation from file and use to instantiate situation manager
    restore(File, SM, Backend, _) :-
       os::file_exists(File),
       setup_call_cleanup(open(File, read, Stream), read(Stream, sit(Term)), close(Stream)),
       situation_manager::new(SM, Backend, Term), !.
    restore(File, SM, Backend, Sit) :-
       \+ os::file_exists(File),
       situation_manager::new(SM, Backend, Sit).

   % On situation_manager update, broadcast to appropriate instances to persist
   after(SM, do(_), _Sender) :-
       persist_send(SM).
   after(SM, do(_, SM), _Sender) :-
       persist_send(SM).

   persist_send(SM) :-
       forall((::descendant(Inst), Inst::situation_manager(SM)), Inst::persist).

:- end_object.
