% Todos
:- object(todos,
    imports([fluentc, actorc])).

   action(add_todo/1).
   action(remove_todo/1).
   action(mark_complete/1).
   fluent(current_todo/2).

   :- public(current_todo/2).
   current_todo(todo(Label, Status), do(A, S)) :-
       ( A = add_todo(Label), Status = todo
       ; A = mark_complete(Label), Status = complete
       ; current_todo(todo(Label, Status), S), A \= remove_todo(Label), A \= mark_complete(Label)
       ).

:- end_object.

% Actions
:- object(add_todo(_Label_),
    extends(action)).

   poss(S) :-
       \+ todos::current_todo(todo(_Label_, _), S).

:- end_object.


:- object(remove_todo(_Label_),
    extends(action)).

   poss(S) :-
       todos::current_todo(todo(_Label_, _), S).

:- end_object.


:- object(mark_complete(_Label_),
    extends(action)).

   poss(S) :-
       todos::current_todo(todo(_Label_, todo), S).

:- end_object.


% View
:- object(todo_view,
    instantiates(view_class)).

    :- uses(logtalk, [
            print_message/3
        ]).

    render(Sit) :-
        findall(ToDo, situation::holds(todos::current_todo(ToDo), Sit), ToDos),
        print_message(information, rad, 'ToDos'::ToDos).

        /*
         *findall(Action, situation::poss(Action, Sit), Actions),
         *print_message(information, rad, 'PossActions'::Actions).
         */

:- end_object.

