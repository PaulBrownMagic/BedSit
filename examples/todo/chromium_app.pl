:- use_module(library(www_browser), [www_open_url/1]).
:- set_prolog_flag(browser, "chromium"-fg).

open_chromium_app :-
    www_open_url('--app=http://localhost:8000/').
