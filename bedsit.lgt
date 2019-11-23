:- object(bedsit).

    :- info([ version is 1.4
            , author is 'Paul Brown'
            , date is 2019/11/23
            , comment is 'The core of bedsit: gatekeeper for a situation term.'
            ]).

    :- private(sit_/1).
    :- dynamic(sit_/1).
    % Set in importer

    :- public(situation/1).
    :- mode(situation(?term), zero_or_one).
    :- info(situation/1,
        [ comment is 'The current situation.'
        , argnames is ['Situation']
        ]).
    situation(S) :-
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

   :- public(init/1).
   :- mode(init(+term), zero_or_one).
   :- info(init/1,
       [ comment is 'Initialize with a starting situation'
       , argnames is ['Situation']
       ]).
   init(S) :-
       \+ sit_(_),
       ::assertz(sit_(S)).

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
        clobber_sit(S1).

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
