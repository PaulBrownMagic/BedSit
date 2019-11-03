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
    logtalk::message_hook(Person::KnowAll, information, foaf, _Tokens) :-
        meta::partition(is_friend, KnowAll, Friends, Knows),
        meta::map(knows_dict, Friends, FDs),
        meta::map(knows_dict, Knows, KDs),
        broadcast(Person, json(json{friends: FDs, knows: KDs})).

    is_friend(friend(_)).
    knows_dict(RP, knows{name: Name, value: P}) :-
        arg(1, RP, P),
        P::given_name(GN),
        P::family_name(FN),
        format(atom(Name), "~w ~w", [GN, FN]).
    broadcast(Person, Msg) :-
        forall(instantiates_class(Inst, friends_socket),
                (Inst::browsing_as(Person), Inst::websocket(WS), ws_send(WS, Msg))
              ).

:- end_object.


:- object(home_page).
    :- use_module(html_write, [reply_html_page/2]).
    :- meta_predicate(html_write:reply_html_page(*, *)).

    :- public(get/0).
    get :-
        findall(option(value(P), Name), (instantiates_class(P, person), P::given_name(GN), P::family_name(FN), format(atom(Name), "~w ~w", [GN, FN])), Peeps),
        reply_html_page(
            [ title('FOAF')
            , link([href('/static/bootstrap.min.css'), rel(stylesheet)])
            , link([href('/static/foaf.css'), rel(stylesheet)])
            ],
            [ div(class([container, 'mt-4']),
            [ div(class([jumbotron]), [ h1(class(['display-3']), 'Friend Of A Friend'), p([class([lead, 'display-4']), id(lead)], ['Choose a person']) ])
                , div(class('form-inline'),
                [ div(class(['input-group', 'col-6']),
                        [ select([class('form-control'), id(browse_as)], Peeps)
                        , div(class('input-group-append'), button([class([btn, 'btn-primary']), onclick('browse_as()')], 'Browse As'))
                        ])
                    , div(class(['input-group', 'col-6']),
                        [ select([class('form-control'), id(add_friend)], Peeps)
                        , div(class('input-group-append'), button([class([btn, 'btn-primary']), onclick('add_friend()')], 'Add Friend'))
                        ])
                    ])
                , hr([])
                , div(class([card, 'mb-2']),
                    [ div(class('card-header'), 'Who''s my friend?')
                    , div(class('card-body'),
                         ul([class('list-group list-group-flush'), id('friends')], []))
                    ])
                , div(class(card),
                    [ div(class('card-header'), 'Who do I know?')
                    , div(class('card-body'),
                         ul([class('list-group list-group-flush'), id('knows')], []))
                    ])
                ])
            , ul([style='display:none', id(results)],
                [ li(class('list-group-item template knows d-none'),
                      [ span([])
                      , button([class(close), type(button), onclick('remove_friend(this)')], x)
                      ])
                ])
            , script([src('/static/jquery-3.4.1.min.js')],[])
            , script([src('/static/bootstrap.bundle.min.js')], [])
            , script([src('/static/foaf.js')], [])
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


:- object(friends_socket,
    instantiates(metasocket)).
    :- use_module(websocket, [ws_receive/2, ws_send/2]).

    :- public(browsing_as/1).
    :- dynamic(browsing_as/1).

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
        read_term_from_atom(Data, Action, []),
        handle_action(Action),
        receive.

    handle_action(browse_as(P)) :-
        ground(P), instantiates_class(P, person),
        retractall(browsing_as(_)),
        assertz(browsing_as(P)),
        initial_load(P).
    handle_action(add_friend(F)) :-
        ground(F), instantiates_class(F, person),
        ::browsing_as(P),
        P::do(add_friend(P, F)).
    handle_action(remove_friend(F)) :-
        ground(F), instantiates_class(F, person),
        ::browsing_as(P),
        P::do(unfriend(P, F)).

    initial_load(P) :-
        findall(_{name: Name, value: F}, (P::holds(has_friend(F)), F::given_name(GN), F::family_name(FN), format(atom(Name), "~w ~w", [GN, FN])), Friends),
        findall(_{name: Name, value: F}, (P::holds(knows(F)), \+ P::holds(has_friend(F)), F::given_name(GN), F::family_name(FN), format(atom(Name), "~w ~w", [GN, FN])), Knows),
        ::websocket(WS),
        ws_send(WS, json(json{friends: Friends, knows: Knows})).

:- end_object.
