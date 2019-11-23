:- initialization((
    logtalk_load([ sitcalc(loader)
                 , bedsit(loader)
                 , meta(loader)
                 , random(loader)
                 ]),
    bedsit::init(s0),
    logtalk_load('SitCalc_tictactoe'),
    define_events(after, bedsit, do(_), _, unicode_terminal),
    os::time_stamp(TS),
    Int is round(TS),
    fast_random::randomize(Int)
             )).
