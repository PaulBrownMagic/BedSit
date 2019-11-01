:- initialization((
    logtalk_load([ sitcalc(loader)
                 , bedsit(loader)
                 , meta(loader)
                 , random(loader)
                 ]),
    situation_manager::new(sm, s0),
    logtalk_load('SitCalc_tictactoe'),
    define_events(after, sm, do(_), _, view_class)
             )).
