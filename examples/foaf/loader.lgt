:- initialization((
    logtalk_load([ stripstate(loader)
                 , bedsit(loader)
                 , foaf
                 , web_hooks
                 , foaf_web
                 ]),
        person::join(leroy, [given_name('Servais'), family_name('Le Roy')]),
        person::join(talma, [given_name('Mercedes'), family_name('Talma')]),
        person::join(bosco, [given_name('Leon'), family_name('Bosco')]),
        person::join(goldin, [given_name('Horace'), family_name('Goldin')]),
        person::join(henry, [given_name('Henry'), family_name('Worsley Hill')]),
        person::join(downs, [given_name('Thomas'), family_name('Nelson Downs')]),
        define_events(after, _, do(_), _, view_class),
        define_events(after, _, do(_), _, persistent_manager),
        server::serve
             )).
