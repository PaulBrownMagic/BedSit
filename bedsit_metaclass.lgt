
:- object(bedsit_metaclass,
    instantiates(bedsit_metaclass),
    imports(class_hierarchy)).

    :- info([ version is 1.0
            , author is 'Paul Brown'
            , date is 2019/11/1
            , comment is 'A metaclass for bedsit classes'
            ]).

    :- protected(instantiate/2).
    :- mode(instantiate(?object, +list), one).
    :- info(instantiate/2,
        [ comment is 'Instantiate the class to create an Instance with the given Clauses'
        , argnames is ['Instance', 'Clauses']
        ]).
    instantiate(Instance, Clauses) :-
        self(Class),
        create_object(Instance, [instantiates(Class)], [], Clauses).

    :- public(only/1).
    :- mode(only(?object), zero_or_one).
    :- info(only/1,
        [ comment is 'True if Instance is the only instance of the class'
        , argnames is ['Instance']
        ]).
    only(Inst) :-
        ::descendants([Inst]).

:- end_object.
