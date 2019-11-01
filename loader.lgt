
:- initialization((
	logtalk_load(os(loader)),
	logtalk_load([
		bedsit_metaclass,
		sit_man,
		meta_sm,
		situation_manager,
		meta_psm,
		persistent_manager,
		actorc,
		fluentc,
		meta_v,
		view_class
	], [
		optimize(on)
	])
)).
