
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
