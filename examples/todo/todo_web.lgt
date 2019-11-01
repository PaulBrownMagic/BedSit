:- object(server).

    :- use_module(thread_httpd, [http_server/2]).
    :- use_module(http_dispatch, [http_dispatch/1]).
    :- use_module(websocket, [ws_send/2]).

    :- meta_predicate(thread_httpd:http_server(1, *)).
    :- public(serve/0).
    serve :-
        http_server(http_dispatch, [port(8000)]).


    :- multifile(logtalk::message_hook/4).
    :- dynamic(logtalk::message_hook/4).
    logtalk::message_hook('ToDos'::ToDos, information, rad, _Tokens) :-
        meta::partition(is_current_todo, ToDos, ToDoIs, Completed),
        meta::map(todo_label, ToDoIs, TLs),
        meta::map(todo_label, Completed, CLs),
        broadcast(json(json{todo: TLs, completed: CLs})).

    is_current_todo(todo(_, todo)).
    todo_label(todo(L, _), L).
    broadcast(Msg) :-
        forall(instantiates_class(Inst, todos_socket),
                ( Inst::websocket(WS), ws_send(WS, Msg))
              ).

:- end_object.


:- object(home_page).
    :- use_module(html_write, [reply_html_page/2]).
    :- meta_predicate(html_write:reply_html_page(*, *)).

    :- public(get/0).
    get :-
        fast_random::member(RandomToDo, ['Mow the lawn', 'Do the dishes', 'Do the laundry', 'Water the plants']),
        reply_html_page(
            [ title('Todo')
            , link([href('/static/bootstrap.min.css'), rel(stylesheet)])
            , link([href('/static/todo.css'), rel(stylesheet)])
            ],
            [ div(class([container, 'mt-4']),
                [ div(class([jumbotron, 'bg-dark']), h1(class(['text-white', 'display-4']), 'ToDo'))
                , div(
                    [div(class('input-group'),
                        [ div(class('input-group-prepend'), div(class('input-group-text'), 'New Todo'))
                        , input([type(text), class('form-control'), id(newtodo), placeholder(RandomToDo)], [])
                        , div(class('input-group-append'), button([class([btn, 'btn-primary']), onclick('addTodo()')], 'Add'))
                        ])
                    ])
                , hr([])
                , div(class([progress, 'mb-2']), div([class(['progress-bar', 'progress-bar-striped', 'progress-bar-animated']), role(progressbar), 'aria-valuenow="5"', 'aria-valuemin="0"', 'aria-valuemax="100"', style('width: 5%')], []))
                , div(class([card, 'mb-2']),
                    [ div(class('card-header'), 'What''s todo?')
                    , div(class('card-body'),
                         ul([class('list-group list-group-flush'), id('todo')], []))
                    ])
                , div(class(card),
                    [ div(class('card-header'), 'What''s done?')
                    , div(class('card-body'),
                         ul([class('list-group list-group-flush'), id('completed')], []))
                    ])
                ])
            , ul([style='display:none', id(results)],
                [ li(class('list-group-item template todo d-none'),
                      [ span([])
                      , button([class(close), type(button), onclick('removeTodo(this)')], x)
                      , button([class(complete_btn), onclick('completeTodo(this)')], &('#10004'))
                      ])
                , li(class('list-group-item template completed d-none'),
                      [ span([])
                      , button([class(close), type(button), onclick('removeTodo(this)')], x)
                      ])
                ])
            , script([src('/static/jquery-3.4.1.min.js')],[])
            , script([src('/static/bootstrap.bundle.min.js')], [])
            , script([src('/static/todo.js')], [])
            ]).
:- end_object.


:- object(metasocket,
    instantiates(metasocket)).

    :- info([ version is 1.0
            , author is 'Paul Brown'
            , date is 2019/10/2
            , comment is 'An object describing a class with an instantiate method for creating instances and importing methods to traverse the subsumption heirarchy.'
            ]).

    :- public(instantiate/2).
    :- mode(instantiate(-object, +list), zero_or_one).
    :- info(instantiate/2,
        [ comment is 'Create a new instance of self'
        , argnames is ['Instance', 'Clauses']
        ]).
    instantiate(Instance, WS) :-
        self(Class),
        create_object(Instance, [instantiates(Class)], [], [websocket(WS)]).

:- end_object.


:- object(todos_socket,
    instantiates(metasocket)).
    :- use_module(websocket, [ws_receive/2]).

    :- public(websocket/1).

    :- public(receive/0).
    receive :-
        ::websocket(WS),
        ws_receive(WS, Message),
        ( Message.opcode == close, self(Self), abolish_object(Self)
        ; handle(Message)
        ).

    handle(Message) :-
        Data = Message.get(data),
        ( Data \= "refresh"
        -> read_term_from_atom(Data, Action, []), todos::do(Action)
        ; sm::sit(S), todo_view::render(S)
        ),
        receive.

:- end_object.
