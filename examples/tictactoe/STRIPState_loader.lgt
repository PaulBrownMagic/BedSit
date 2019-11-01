:- initialization((
    logtalk_load([ stripstate(loader)
                 , bedsit(loader)
                 , random(loader)
                 ]),
    situation_manager::new(sm, [ grid(board, [ [1, 2, 3]
                                             , [4, 5, 6]
                                             , [7, 8, 9]
                                             ])
                               , player_turn(game, human(x))
                               , current_player(game, human(x))
                               , current_player(game, computer(o, hard))
                               ]),
    logtalk_load('STRIPState_tictactoe'),
    define_events(after, sm, do(_), _, view_class)
             )).
