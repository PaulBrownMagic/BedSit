
:- object(meta_psm,
    implements(monitoring),
    specializes(bedsit_metaclass)).

    :- info([ version is 1.0
            , author is 'Paul Brown'
            , date is 2019/11/1
            , comment is 'An specialization of the metaclass for persistent_managers.'
            ]).

    :- public(new/2).
    :- mode(new(?object, +atom), zero_or_one).
    :- info(new/2,
        [ comment is 'Create an instance of persistent_manager observing the SituationManager, which is also created if it does not yet exist.'
        , argnames is ['SituationManager', 'File']
        ]).
    new(SM, File) :-
        atom(File),
        situation::empty(Sit),
        check_make(SM, File, Sit),
        ^^instantiate(_, [persisting_file_(File), situation_manager_(SM)]).
    :- public(new/3).
    :- mode(new(?object, +atom, +term), zero_or_one).
    :- info(new/3,
        [ comment is 'Create an instance of persistent_manager observing the SituationManager, which is also created with the Situation.'
        , argnames is ['SituationManager', 'File', 'Situation']
        ]).
    new(SM, File, Sit) :-
        atom(File), ground(Sit),
        check_make(SM, File, Sit),
        ^^instantiate(_, [persisting_file_(File), situation_manager_(SM)]).

    % Check if situation_manager exists or instantiate
    check_make(SM, _, _) :-
        % Already exists.
        nonvar(SM),
        situation_manager::instance(SM), !.
    check_make(SM, File, Sit) :-
        (nonvar(SM), \+ current_object(SM) ; var(SM)),
        restore(File, SM, Sit).

    % On instantiation read in situation from file and use to instantiate situation manager
    restore(File, SM, _) :-
       os::file_exists(File),
       setup_call_cleanup(open(File, read, Stream), read(Stream, sit(Term)), close(Stream)),
       situation_manager::new(SM, Term), !.
    restore(File, SM, Sit) :-
       \+ os::file_exists(File),
       situation_manager::new(SM, Sit).

   % On situation_manager update, broadcast to appropriate instances to persist
   after(SM, do(_), _Sender) :-
       persist_send(SM).
   after(SM, do(_, SM), _Sender) :-
       persist_send(SM).

   persist_send(SM) :-
       forall((::descendant(Inst), Inst::situation_manager(SM)), Inst::persist).

:- end_object.
