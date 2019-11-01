
:- object(meta_v,
    implements(monitoring),
    specializes(bedsit_metaclass)).

    :- info([ version is 1.0
            , author is 'Paul Brown'
            , date is 2019/11/2
            , comment is 'An specialization of the metaclass for view_class.'
            ]).

    % Monitor for actions being done in the application and upate the view
    after(SM, do(_), _Sender) :-
        instances_render(SM).
    after(SM, do(_, SM), _Sender) :-
        instances_render(SM).


    instances_render(SM) :-
        situation_manager::only(SM),
        SM::sit(S),
        forall(::descendant(Inst), Inst::render(S)).
    instances_render(SM) :-
        SM::sit(Sit),
        forall((::descendant(Inst), Inst::view_for(SM)), Inst::render(Sit)).

:- end_object.
