
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
        situation_manager::instance(SM),
        functor(Fluent, Func, Ar),
        NAr is Ar + 1,
        ::fluent(Func/NAr),
        SM::sit(S),
        call(::Fluent, S).

:- end_category.
