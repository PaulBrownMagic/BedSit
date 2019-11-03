:- object(metapersonclass,
    instantiates(metapersonclass)).

    :- public(join/2).
    join(Person, Information) :-
        self(Class),
        atom_concat(Person, '_situation', PS),
        atom_concat('storage/', PS, File),
        persistent_manager::new(PS, File, stripstate, []),
        create_object(Person, [instantiates(Class)], [], [acts_upon(PS)|Information]).
:- end_object.


:- object(person,
    imports([actor, fluent_predicates]),
    instantiates(metapersonclass)).

    fluent(has_friend/2).
    fluent(knows/2).
    action(add_friend/2).
    action(unfriend/2).

    :- public([given_name/1, family_name/1, has_friend/2, knows/2]).

    has_friend(F, S) :-
        ::knows(F, S),
        self(Self),
        F::holds(knows(Self)).

    knows(P, S) :-
        self(Self),
        ::acts_upon(SM),
        SM::holds(knows(Self, P), S).

:- end_object.


:- object(add_friend(_Person_, _Friend_),
    imports(action)).

    poss(S) :-
        \+ _Person_::knows(_Friend_, S), _Person_ \= _Friend_.

    retract_fluents([]).
    assert_fluents([knows(_Person_, _Friend_)]).

:- end_object.


:- object(unfriend(_Person_, _Friend_),
    imports(action)).

    poss(S) :-
        _Person_::knows(_Friend_, S).

    retract_fluents([knows(_Person_, _Friend_)]).
    assert_fluents([]).

:- end_object.


:- object(view,
    instantiates(view_class)).

    :- uses(logtalk, [ print_message/3 ]).

    render(Sit) :-
        meta::map(is_friend, Sit, Friends),
        Sit = [knows(Subject, _)|_],
        print_message(information, foaf, Subject::Friends).

    is_friend(knows(S, P), Out) :-
        ( S::holds(has_friend(P))
        -> Out = friend(P)
        ; Out = knows(P)
        ).

:- end_object.
