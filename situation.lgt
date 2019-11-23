:- object(situation,
    imports(situation_interegation)).

    :- info([ version is 1.3
            , author is 'Paul Brown'
            , date is 2019/11/23
            , comment is 'A situation interegator: gatekeeper for a situation term.'
            ]).

    :- public(do/1).
    :- synchronized(do/1).
    :- mode(do(+object), zero_or_one).
    :- info(do/1,
        [ comment is 'Do the Action in the application, thread-safe.'
        , argnames is ['Action']
        ]).
    do(A) :-
        ::situation(S),
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
        ::situation(S),
        holds(F, S).

    :- public(holds/2).
    :- mode(holds(+term, +term), zero_or_one).
    :- mode(holds(-term, +term), zero_or_more).
    :- info(holds/2,
        [ comment is 'Does the Fluent hold in the situation? Also accepts a query.'
        , argnames is ['Fluent', 'Situation']
        ]).
    holds(F, S) :-
        implements_protocol(Situation, situation_protocol),
        Situation::holds(F, S).

    :- public(empty/1).
    :- mode(empty(?term), one).
    :- info(empty/1,
        [ comment is 'Proxy to the situation manager''s situation empty/1'
        , argnames is ['Situation']
        ]).
    empty(S) :-
        implements_protocol(Situation, situation_protocol),
        Situation::empty(S).

:- end_object.
