:- object(board,
    imports(fluentc)).
     fluent(grid/2).
     fluent(available_move/2).

     :- public(grid/2).
     grid(G, S) :-
         self(Self),
         situation::holds(grid(Self, G), S).

     :- public(available_move/2).
     available_move(N, S) :-
         grid(G, S),
         list::flatten(G, Flat),
         list::member(N, Flat),
         integer(N).

    :- public(update/4).
    update(N, C, [R1, R2, R3], [N1, R2, R3]) :-
        % In row 1
        list::select(N, R1, C, N1), !.
    update(N, C, [R1, R2, R3], [R1, N2, R3]) :-
        % In row 2
        list::select(N, R2, C, N2), !.
    update(N, C, [R1, R2, R3], [R1, R2, N3]) :-
        % In row 3
        list::select(N, R3, C, N3), !.

:- end_object.


:- object(game,
    imports(fluentc)).
   fluent(is_draw/1).
   fluent(over/1).
   fluent(current_player/2).
   fluent(player_turn/2).

   :- public(is_draw/1).
   is_draw(Sit) :-
       \+ board::available_move(_, Sit).

   :- public(over/1).
   over(Sit) :-
       ::is_draw(Sit)
       ; ::current_player(P, Sit), P::has_won(Sit).

   :- public(current_player/2).
   current_player(P, Sit) :-
       self(Self),
       situation::holds(current_player(Self, P), Sit).

   :- public(player_turn/2).
   player_turn(P, S) :-
       self(Self),
       situation::holds(player_turn(Self, P), S).

:- end_object.


:- object(move(_C_, _N_), extends(action)).

    poss(S) :-
        % game::player_turn(P, S),
        % P::char(_C_),
        board::available_move(_N_, S).

    retract_fluents([ grid(board, _)
                     , player_turn(game, _)
                     ]).
    assert_fluents([ grid(board, B)
                    , player_turn(game, P)
                    ]) :-
        board::holds(grid(G)),
        board::update(_N_, _C_, G, B),
        game::holds(player_turn(C)),
        game::holds(current_player(P)),
        C \= P.

:- end_object.


:- object(player(_C_),
    imports([actorc, fluentc])).
    action(move/2).
    fluent(has_won/1).

    :- public(char/1).
    char(_C_).

    :- public(choose_move/1).

    :- public(has_won/1).
    has_won(Sit) :-
        board::grid(G, Sit),
        has_won(_C_, G).

    has_won(C, [ [C, C, C]
               , [_, _, _]
               , [_, _, _]
               ]).
    has_won(C, [ [_, _, _]
               , [C, C, C]
               , [_, _, _]
               ]).
    has_won(C, [ [_, _, _]
               , [_, _, _]
               , [C, C, C]
               ]).
    has_won(C, [ [C, _, _]
               , [C, _, _]
               , [C, _, _]
               ]).
    has_won(C, [ [_, C, _]
               , [_, C, _]
               , [_, C, _]
               ]).
    has_won(C, [ [_, _, C]
               , [_, _, C]
               , [_, _, C]
               ]).
    has_won(C, [ [_, _, C]
               , [_, C, _]
               , [C, _, _]
               ]).
    has_won(C, [ [C, _, _]
               , [_, C, _]
               , [_, _, C]
               ]).

:- end_object.


:- object(human(_C_),
    extends(player(_C_))).

    choose_move(N) :-
        write('Where should '), write(_C_), write(' go?\n'),
        read(N), integer(N),
        board::holds(available_move(N))
    ; % Move is invalid, notify and recurse
        write('Can''t make that move\n'),
        choose_move(N).

:- end_object.


:- object(computer(_C_, _Difficulty_),
    extends(player(_C_))).

    choose_move(N) :-
        choose_move(_Difficulty_, N), !.

    :- public(choose_move/3).
    :- mode(choose_move(+atom, +list, -integer), zero_or_more).
    :- info(choose_move/3,
        [ comment is 'Choose a move using the strategy appropriate for the Difficulty'
        , argnames is ['Difficulty', 'Board', 'Move']
        ]).
    choose_move(easy, N) :-
        choose_random_member(N, [1, 2, 3, 4, 5, 6, 7, 8, 9]),
        board::holds(available_move(N)), !,
        write('Computer chooses '), write(N), nl.
    choose_move(hard, N) :-
        sm::sit(Sit),
        ai_choose_move(N, Sit),
        write('Computer chooses '), write(N), nl.

    :- private(ai_choose_move/2).
    :- mode(ai_choose_move(+list, -integer), zero_or_one).
    :- info(ai_choose_move/2,
        [ comment is 'Use a strategy to choose a move'
        , argnames is ['Board', 'GridNumber']
        ]).
    ai_choose_move(N, Sit) :-
        % Computer can win
        board::available_move(N, Sit),
        move(_C_, N)::do(Sit, NewSit),
        ^^has_won(NewSit), !.
    ai_choose_move(N, Sit) :-
        % Player can win
        board::available_move(N, Sit),
        move(x, N)::do(Sit, NewSit),
        human(x)::has_won(NewSit), !.
    ai_choose_move(N, Sit) :-
        % Pick a corner
        choose_random_member(N, [1, 3, 7, 9]),
        board::available_move(N, Sit), !.
    ai_choose_move(5, Sit) :-
        % Pick the center
        board::available_move(5, Sit), !.
    ai_choose_move(N, Sit) :-
        % Pick a middle
        choose_random_member(N, [2, 4, 6, 8]),
        board::available_move(N, Sit), !.

    :- private(choose_random_member/2).
    :- mode(choose_random_member(-any, +list), zero_or_more).
    :- info(choose_random_member/2,
        [ comment is 'Yield elements from list in random order'
        , argnames is ['Elem', 'List']
        ]).
    choose_random_member(N, L) :-
        fast_random::permutation(L, NL),
        list::member(N, NL).


:- end_object.


:- object(unicode_terminal, instantiates(view_class)).

    render(Sit) :-
        board::grid(Board, Sit),
        print_board(Board),
        ( player(C)::has_won(Sit), congratulate(C)
        ; game::is_draw(Sit), write('It''s a draw\n')
        ; true
        ).

    :- public(print_board/1).
    print_board([R1, R2, R3]) :-
        write('┌─┬─┬─┐\n'),
        print_row(R1),
        write('├─┼─┼─┤\n'),
        print_row(R2),
        write('├─┼─┼─┤\n'),
        print_row(R3),
        write('└─┴─┴─┘\n').

    % Helper to print board, prints row.
    print_row(Row) :-
        meta::map(print_tile, Row), write('│\n').

    % Helper to print row, prints one tile
    print_tile(Tile) :-
        integer(Tile), write('│'), write(Tile)
    ;   Tile == o, write('│○')
    ;   Tile == x, write('│×').

    congratulate(Player) :-
        write('Player '), write(Player), write(' wins!\n').

:- end_object.


:- object(tictactoe).

    :- public(play/0).
    play :-
        sm::sit(S),
        unicode_terminal::render(S),
        turn.

    :- public(turn/0).
    turn :-
        ( sm::holds(game::player_turn(P) and not game::over),
          P::choose_move(N),
          P::char(C),
          P::do(move(C, N)), !,
          turn
        ;
          game::holds(over)
        ).

:- end_object.
