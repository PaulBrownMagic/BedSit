:- category(actor).

    :- info([ version is 1.2
            , author is 'Paul Brown'
            , date is 2019/11/3
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
        situation_manager::instance(SM),
        functor(A, Func, Ar),
        ::action(Func/Ar),
        SM::do(A).

:- end_category.
