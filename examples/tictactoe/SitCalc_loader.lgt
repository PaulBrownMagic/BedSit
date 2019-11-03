:- initialization((
    logtalk_load([ sitcalc(loader)
                 , bedsit(loader)
                 , meta(loader)
                 , random(loader)
                 ]),
    situation_manager::new(sm, sitcalc, s0),
    logtalk_load('SitCalc_tictactoe'),
    define_events(after, sm, do(_), _, view_class),
    os::time_stamp(TS),
    Int is round(TS),
    fast_random::randomize(Int)
             )).
