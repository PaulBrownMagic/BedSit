
:- initialization((
	logtalk_load([ os(loader)
                 , hierarchies(loader)
                 ]),
	logtalk_load([
		bedsit_metaclass,
		sit_man,
		meta_sm,
		situation_manager,
		meta_psm,
		persistent_manager,
		actor,
		fluent_predicates,
		meta_v,
		view_class
	], [
		optimize(on)
	])
)).
