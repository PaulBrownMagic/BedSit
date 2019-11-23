:- category(view_category,
    implements(monitoring)).

    :- info([ version is 1.1
            , author is 'Paul Brown'
            , date is 2019/11/23
            , comment is 'A parent class for views that are sent the situation to render'
            ]).

    :- public(render/1).
    :- mode(render(+term), zero_or_one).
    :- info(render/1,
        [ comment is 'Render the given Situation into the chosen view.'
        , argnames is ['Situation']
        ]).

    % Monitor for actions being done in the application and upate the view
    after(SM, do(_), _Sender) :-
        SM::situation(Sit),
        ::render(Sit).
    after(SM, do(_, SM), _Sender) :-
        SM::situation(Sit),
        ::render(Sit).

:- end_category.
