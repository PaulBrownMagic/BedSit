
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
