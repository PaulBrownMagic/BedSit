
:- initialization((
	logtalk_load([ os(loader)
                 , hierarchies(loader)
                 ]),
	logtalk_load([
		situation_interegation,
		situation,
        persistence,
		actor,
		fluent_predicates,
		view_category
	], [
		optimize(on)
	])
)).
