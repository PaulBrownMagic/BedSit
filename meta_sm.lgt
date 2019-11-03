:- object(meta_sm,
    specializes(bedsit_metaclass)).

    :- info([ version is 1.0
            , author is 'Paul Brown'
            , date is 2019/11/1
            , comment is 'Specialize the metaclass for situation managers.'
            ]).

    :- public(new/3).
    new(Instance, Backend, Sit) :-
        ^^instantiate(Instance, [sit_(Sit), backend(Backend)]).

:- end_object.
