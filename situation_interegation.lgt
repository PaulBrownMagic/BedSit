:- category(situation_interegation).

    :- info([ version is 1.3
            , author is 'Paul Brown'
            , date is 2019/11/23
            , comment is 'A Situation Manager.'
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

:- end_category.
