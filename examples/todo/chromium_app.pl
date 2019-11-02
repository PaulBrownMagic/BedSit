:- use_module(library(www_browser), [www_open_url/1]).

open_chromium_app :-
    try_alt("chromium",
        try_alt("chromium-browser",
            try_alt("google-chrome",
                no_such_browsers
            ))).

try_alt(A, B) :-
    try_browser(A),
    catch( open_url,
           error(process_error(_LaunchProg, exit(1)), _),
           call(B)
         ).

try_browser(B) :-
    set_prolog_flag(browser, B-fg).

open_url :-
    www_open_url('--app=http://localhost:8000/').

no_such_browsers :-
    existence_error('one of the browsers', 'chromium/chromium-browser/google-chrome').

