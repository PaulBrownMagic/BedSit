% GUI
:- object(xpce).
   :- include('xpce_includes.lgt').

   :- public(init/0).

   :- public(id/1).
   id(@ID) :-
       self(Self),
       functor(Self, ID, _).

   :- public(object/0).
   object :-
       ::id(ID),
       xobject(ID).

   :- public(object/1).
   object(O) :-
       xobject(O).

   :- public(size/2).
   size(W, H) :-
       ::get(size, size(W, H)).

   :- public(new/1).
   new(O) :-
       ::id(ID),
       xnew(ID, O).

   :- public(get/2).
   get(P, O) :-
       ::id(ID),
       xget(ID, P, O).

   :- public(selected_key/1).
   selected_key(O) :-
       ::get(selection, S),
       xget(S, key, O).

   :- public(send/1).
   send(M) :-
       ::id(ID),
       xsend(ID, M).

   :- public(send/2).
   send(P, O) :-
       ::id(ID),
       xsend(ID, P, O).

   :- public(send/3).
   send(P, O, M) :-
       ::id(ID),
       xsend(ID, P, O, M).

   :- public(free/0).
   free :-
       ::id(ID),
       xfree(ID).

:- end_object.


:- object(window,
    extends(xpce)).

   init :-
       ^^new(frame('ToDo')),
       ^^send(open).

   :- public(append/1).
   append(O) :-
       O::id(ID),
       ^^send(append, ID).

   :- public(append/3).
   append(O, Dir, Ref) :-
       O::id(OID),
       ^^send(append, OID),
       Ref::id(Rid),
       Where =.. [Dir, Rid],
       ^^send(OID, Where).

:- end_object.


:- object(todo_dialog,
    extends(xpce)).
    btn(button(new_todo, logtalk(new_todo_dialog, init))).
    btn(button(mark_complete, logtalk(app, mark_complete))).
    btn(button(remove_todo, logtalk(app, remove_todo))).

    init :-
        ^^new(dialog),
        ^^send(append(text('ToDos'))),
        forall(btn(B), ^^send(append(B))),
        self(Self),
        window::append(Self),
        ^^send(layout_dialog).

:- end_object.


:- object(todo_browser,
    extends(xpce)).

   init :-
       ^^new(browser),
       self(Self),
       window::append(Self),
       ^^send(below(@todo_dialog)).

   :- public(update/1).
   update(Labels) :-
      ^^send(members(Labels)).

:- end_object.


:- object(completed_dialog,
    extends(xpce)).
    btn(button(remove_completed, logtalk(app, remove_completed))).

    init :-
        ^^new(dialog),
        ^^send(append(text('Completed'))),
        forall(btn(B), ^^send(append(B))),
        self(Self),
        window::append(Self),
        ^^send(layout_dialog),
        ^^send(below(@todo_browser)).


:- end_object.


:- object(completed_browser,
    extends(xpce)).

   init :-
       ^^new(browser),
       self(Self),
       window::append(Self),
       ^^send(below(@completed_dialog)).

   :- public(update/1).
   update(Labels) :-
       ^^send(members(Labels)).

:- end_object.


:- object(app_dialog,
    extends(xpce)).
    btn(button(exit, logtalk(app, close))).

    init :-
        ^^new(dialog),
        forall(btn(B), ^^send(append(B))),
        self(Self),
        window::append(Self),
        ^^send(below(@completed_browser)).

:- end_object.


:- object(todo_name,
    extends(xpce)).
   init :-
       ^^new(text_item(new_todo_name)).
:- end_object.


:- object(new_todo_dialog,
    extends(xpce)).
    btn(button(save, logtalk(new_todo_dialog, save))).
    btn(button(cancel, logtalk(new_todo_dialog, close))).

    init :-
        ^^new(dialog('New Project')),
        todo_name::init,
        ::append(todo_name),
        forall(btn(B), ^^send(append(B))),
        ^^send(open).

    :- public(close/0).
    close :-
        todo_name::free,
        ::free.

    :- public(save/0).
    save :-
        todo_name::get(selection, ToDoName),
        todos::do(add_todo(ToDoName)),
        ::close.

   :- public(append/1).
   append(O) :-
       O::id(ID),
       ^^send(append, ID).

:- end_object.


% App
:- object(app).

    :- public(init/0).
    init :-
        window::init,
        todo_dialog::init,
        todo_browser::init,
        completed_dialog::init,
        completed_browser::init,
        app_dialog::init,
        bedsit::situation(Sit),
        todo_view::render(Sit),
        !.

    :- public(close/0).
    close :-
        window::free.

    :- public(mark_complete/0).
    mark_complete :-
        todo_browser::selected_key(TD),
        todos::do(mark_complete(TD)).

    :- public(remove_todo/0).
    remove_todo :-
        todo_browser::selected_key(TD),
        todos::do(remove_todo(TD)).

    :- public(remove_completed/0).
    remove_completed :-
        completed_browser::selected_key(TD),
        todos::do(remove_todo(TD)).

    :- multifile(logtalk::message_hook/4).
    :- dynamic(logtalk::message_hook/4).
    logtalk::message_hook('ToDos'::ToDos, information, rad, _Tokens) :-
        meta::partition(is_current_todo, ToDos, ToDoIs, Completed),
        meta::map(todo_label, ToDoIs, TLs),
        meta::map(todo_label, Completed, CLs),
        todo_browser::update(TLs),
        completed_browser::update(CLs).

    is_current_todo(todo(_, todo)).
    todo_label(todo(L, _), L).

:- end_object.
