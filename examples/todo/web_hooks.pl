:- use_module(library(http/thread_httpd), [http_server/2]).
:- use_module(library(http/http_dispatch), [http_handler/3, http_dispatch/1]).
:- use_module(library(http/websocket), [http_upgrade_to_websocket/3, ws_send/2, ws_receive/2]).
:- use_module(library(http/http_files), [http_reply_from_files/3]).
:- use_module(library(http/html_write), [reply_html_page/2]).

http:location(static, '/static', []).

:- http_handler(root(.), home, []).
:- http_handler(root(todos), http_upgrade_to_websocket(todos_socket, []), [spawn([])]).
:- http_handler(static(.), http_reply_from_files(static, []), [prefix]).

home(_R) :-
    home_page::get.

todos_socket(Websocket) :-
    todos_socket::instantiate(Instance, Websocket),
    Instance::receive.
