:- object(persistence(_File_),
    implements(monitoring)).

    :- info([ version is 1:4:0
            , author is 'Paul Brown'
            , date is 2019-11-23
            , comment is 'An observer of some situation manager that persists updates to the situation.'
            ]).

    :- public(persist/1).
    :- mode(persist(+term), zero_or_one).
    :- info(persist/1,
        [ comment is 'Write the situation to file.'
        , argnames is ['Situation']
        ]).
    persist(Sit) :-
        nonvar(Sit),
        setup_call_cleanup(open(_File_, write, Stream),
            (write(Stream, 'situation('), writeq(Stream, Sit), write(Stream, ').\n')),
            close(Stream)).

    :- public(restore/1).
    :- mode(restore(-term), one).
    :- info(restore/1,
        [ comment is 'Either load the situation from the file or return the empty situation.'
        , argnames is ['Situation']
        ]).
    restore(Sit) :-
       os::file_exists(_File_),
       setup_call_cleanup(open(_File_, read, Stream),
                          read(Stream, situation(Sit)),
                          close(Stream)), !.
    restore(Sit) :-
       \+ os::file_exists(_File_),
       bedsit::empty(Sit).

   % On update, persist the situation to the file.
   after(SM, do(_), _Sender) :-
       SM::situation(Sit),
       persist(Sit).
   after(SM, do(_, SM), _Sender) :-
       SM::situation(Sit),
       persist(Sit).

:- end_object.
