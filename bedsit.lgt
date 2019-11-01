:- object(bs_metaclass,
    instantiates(bs_metaclass)).

    :- info([ version is 1.0
            , author is 'Paul Brown'
            , date is 2019/11/1
            , comment is 'A metaclass for bedsit classes'
            ]).

    :- protected(instantiate/2).
    :- mode(instantiate(?object, +list), one).
    :- info(instantiate/2,
        [ comment is 'Instantiate the class to create an Instance with the given Clauses'
        , argnames is ['Instance', 'Clauses']
        ]).
    instantiate(Instance, Clauses) :-
        self(Class),
        create_object(Instance, [instantiates(Class)], [], Clauses).

    :- public(only/1).
    :- mode(only(?object), zero_or_one).
    :- info(only/1,
        [ comment is 'True if Instance is the only instance of the class'
        , argnames is ['Instance']
        ]).
    only(Inst) :-
        self(Self),
        findall(Inst, instantiates_class(Inst, Self), [Inst]).

:- end_object.


:- category(sit_man).

    :- info([ version is 1.1
            , author is 'Paul Brown'
            , date is 2019/11/1
            , comment is 'A Situation Manager.'
            ]).

    :- private(sit_/1).
    :- dynamic(sit_/1).
    % Set in importer

    :- public(sit/1).
    :- mode(sit(?term), zero_or_one).
    :- info(sit/1,
        [ comment is 'The current situation.'
        , argnames is ['Situation']
        ]).
    sit(S) :-
        ::sit_(S).

   :- private(clobber_sit/1).
   :- mode(clobber_sit(+term), one).
   :- info(clobber_sit/1,
       [ comment is 'Assert the new Situation, retracting all prior ones'
       , argnames is ['Situation']
       ]).
   clobber_sit(S) :-
       ::retractall(sit_(_)),
       ::assertz(sit_(S)).

:- end_category.


:- object(meta_sm,
    specializes(bs_metaclass)).

    :- info([ version is 1.0
            , author is 'Paul Brown'
            , date is 2019/11/1
            , comment is 'Specialize the metaclass for situation managers.'
            ]).

    :- public(new/2).
    new(Instance, Sit) :-
        ^^instantiate(Instance, [sit_(Sit)]).

:- end_object.


:- object(situation_manager,
    imports(sit_man),
    instantiates(meta_sm)).

    :- info([ version is 1.3
            , author is 'Paul Brown'
            , date is 2019/11/1
            , comment is 'A situation manager: gatekeeper for a situation term.'
            ]).

    :- public(do/1).
    :- synchronized(do/1).
    :- mode(do(+object), zero_or_one).
    :- info(do/1,
        [ comment is 'Do the Action in the application, thread-safe.'
        , argnames is ['Action']
        ]).
    do(A) :-
        ::sit(S),
        do(A, S).

    :- public(do/2).
    :- mode(do(+object, +term), zero_or_one).
    :- info(do/2,
        [ comment is 'Do the Action in the application from the Situation, thread-safe.'
        , argnames is ['Action', 'Situation']
        ]).
    do(A, S) :-
        A::do(S, S1),
        ^^clobber_sit(S1).

    :- public(holds/1).
    :- mode(holds(+term), zero_or_one).
    :- mode(holds(-term), zero_or_more).
    :- info(holds/1,
        [ comment is 'Does the Fluent hold in the situation manager''s situation? Also accepts a query.'
        , argnames is ['Fluent']
        ]).
    holds(F) :-
        ::sit(S),
        situation::holds(F, S).

:- end_object.


:- object(meta_psm,
    implements(monitoring),
    specializes(bs_metaclass)).

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
        instantiates_class(SM, situation_manager), !.
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
       self(Self),
       forall((instantiates_class(Inst, Self), Inst::situation_manager(SM)), Inst::persist).
   after(SM, do(_, SM), _Sender) :-
       self(Self),
       forall((instantiates_class(Inst, Self), Inst::situation_manager(SM)), Inst::persist).

:- end_object.


:- object(persistent_manager,
    imports(sit_man),
    instantiates(meta_psm)).

    :- info([ version is 1.2
            , author is 'Paul Brown'
            , date is 2019/11/1
            , comment is 'An observer of some situation manager that persists updates to the situation.'
            ]).

    :- private([persisting_file_/1, situation_manager_/1]).

    :- public(situation_manager/1).
    :- mode(situation_manager(?object), zero_or_one).
    :- info(situation_manager/1,
        [ comment is 'The situation_manager instance whose situation this instance is persisting.'
        , argnames is ['SituationManager']
        ]).
    situation_manager(SM) :-
        ::situation_manager_(SM).

    :- public(persist/0).
    :- mode(persist, zero_or_one).
    :- info(persist/0,
        [ comment is 'Write the situation to file.'
        ]).
    persist :-
        ::persisting_file_(File),
        ::situation_manager(SM),
        SM::sit(Sit),
        setup_call_cleanup(open(File, write, Stream),
            (write(Stream, 'sit('), writeq(Stream, Sit), write(Stream, ').\n')),
            close(Stream)).

:- end_object.


:- category(actorc).

    :- info([ version is 1.1
            , author is 'Paul Brown'
            , date is 2019/10/31
            , comment is 'An category for actors: those who can do actions.'
            ]).

    :- set_logtalk_flag(events, allow).

    :- public(action/1).
    :- mode(action(?object), zero_or_more).
    :- info(action/1,
        [ comment is 'Denotes an action the actor has permission to do.'
        , argnames is ['Action']
        ]).

    :- private(acts_upon/1).
    :- mode(acts_upon(?object), zero_or_one).
    :- info(acts_upon/1,
        [ comment is 'Optional. Denotes a situation_manager whose situation this actor''s actions change. Only the first declaration will be used by default.'
        , argnames is ['SituationManager']
        ]).

    :- public(do/1).
    :- meta_predicate(do(2)).
    :- mode(do(+object), zero_or_one).
    :- info(do/1,
        [ comment is 'Do the Action via the default situation manager, either the one this actor acts_upon or the only instance of situation_manager.'
        , argnames is ['Action']
        ]).
    do(A) :-
        (::acts_upon(SM) ; situation_manager::only(SM)), !,
        do(A, SM).

    :- public(do/2).
    :- meta_predicate(do(2, *)).
    :- mode(do(+object, +object), zero_or_one).
    :- info(do/2,
        [ comment is 'Do the Action via the provided SituationManager.'
        , argnames is ['Action', 'SituationManager']
        ]).
    do(A, SM) :-
        nonvar(A), nonvar(SM),
        extends_object(A, action), instantiates_class(SM, situation_manager),
        functor(A, Func, Ar),
        ::action(Func/Ar),
        SM::do(A).

:- end_category.


:- category(fluentc).
    :- public(fluent/1).

    :- info([ version is 1.0
            , author is 'Paul Brown'
            , date is 2019/10/30
            , comment is 'An category for objects with fluent predicates.'
            ]).

    :- public(holds/1).
    :- meta_predicate(holds(1)).
    :- mode(holds(+term), zero_or_one).
    :- mode(holds(-term), zero_or_more).
    :- info(holds/1,
        [ comment is 'True iff. the Fluent holds in the default situation belonging to the only situation_manager defined.'
        , argnames is ['Fluent']
        ]).
    holds(Fluent) :-
        situation_manager::only(SM),
        holds(Fluent, SM).

    :- public(holds/2).
    :- meta_predicate(holds(1, *)).
    :- mode(holds(+term, +object), zero_or_one).
    :- mode(holds(-term, ?object), zero_or_more).
    :- info(holds/2,
        [ comment is 'True iff. the Fluent holds in the situation belonging to the provided SituationManager.'
        , argnames is ['Fluent', 'SituationManager']
        ]).
    holds(Fluent, SM) :-
        instantiates_class(SM, situation_manager),
        functor(Fluent, Func, Ar),
        NAr is Ar + 1,
        ::fluent(Func/NAr),
        SM::sit(S),
        call(::Fluent, S).

:- end_category.


:- category(view,
    implements(monitoring)).

    :- info([ version is 1.1
            , author is 'Paul Brown'
            , date is 2019/10/30
            , comment is 'A category for application views that render the situation for some UI.'
            ]).

    % Monitor for actions being done in the application and upate the view
    after(SM, do(_), _Sender) :-
        SM::current_predicate(sit/1),
        SM::sit(S),
        ::render(S).

    after(SM, do(_, SM), _Sender) :-
        SM::current_predicate(sit/1),
        SM::sit(S),
        ::render(S).

    :- public(render/1).
    :- mode(render(+term), zero_or_one).
    :- info(render/1,
        [ comment is 'Render the given Situation into the chosen view.'
        , argnames is ['Situation']
        ]).

:- end_category.
