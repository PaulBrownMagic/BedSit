:- category(fluent_predicates).

    :- info([ version is 1:4:0
            , author is 'Paul Brown'
            , date is 2019-11-23
            , comment is 'An category for objects with fluent predicates.'
            ]).

    :- public(fluent/1).

    :- public(holds/1).
    :- meta_predicate(holds(1)).
    :- mode(holds(+term), zero_or_one).
    :- mode(holds(-term), zero_or_more).
    :- info(holds/1,
        [ comment is 'True iff. the Fluent holds in the situation.'
        , argnames is ['Fluent']
        ]).
    holds(Fluent) :-
        ::fluent(Func/PAr),
        Ar is PAr - 1,
        functor(Fluent, Func, Ar),
        bedsit::situation(S),
        call(::Fluent, S).

:- end_category.
