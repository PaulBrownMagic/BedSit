
:- initialization((
    logtalk_load([ os(loader)
                 , hierarchies(loader)
                 ]),
    logtalk_load([
        bedsit,
        persistence,
        actor,
        fluent_predicates,
        view_category
    ], [
        optimize(on)
    ])
)).
