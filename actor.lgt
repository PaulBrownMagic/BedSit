:- category(actor).

    :- info([ version is 1.4
            , author is 'Paul Brown'
            , date is 2019/11/23
            , comment is 'An category for actors: those who can do actions.'
            ]).

    :- set_logtalk_flag(events, allow).

    :- public(action/1).
    :- mode(action(?object), zero_or_more).
    :- info(action/1,
        [ comment is 'Denotes an action the actor has permission to do.'
        , argnames is ['Action']
        ]).

    :- public(do/1).
    :- meta_predicate(do(2)).
    :- mode(do(+object), zero_or_one).
    :- info(do/1,
        [ comment is 'Do the Action via bedsit.'
        , argnames is ['Action']
        ]).
    do(A) :-
        nonvar(A),
        functor(A, Func, Ar),
        ::action(Func/Ar),
        bedsit::do(A).

:- end_category.
