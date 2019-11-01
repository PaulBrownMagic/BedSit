
:- object(view_class,
    instantiates(meta_v)).

    :- info([ version is 1.0
            , author is 'Paul Brown'
            , date is 2019/11/2
            , comment is 'A parent class for views that are sent the situation to render'
            ]).

    :- public(render/1).
    :- mode(render(+term), zero_or_one).
    :- info(render/1,
        [ comment is 'Render the given Situation into the chosen view.'
        , argnames is ['Situation']
        ]).

    :- public(view_for/1).
    :- mode(view_for(+object), zero_or_one).
    :- mode(view_for(-object), zero_or_more).
    :- info(view_for/1,
        [ comment is 'This view will render the situation of the given SituationManager.'
        , argnames is ['SituationManager']
        ]).

:- end_object.
