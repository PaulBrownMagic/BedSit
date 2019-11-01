# BedSit

BedSit is a **Bed**rock upon which to build your **Sit**uation driven
application. It provides classes and categories that work with either
[SitCalc](https://github.com/PaulBrownMagic/SitCalc) or
[STRIPState](https://github.com/PaulBrownMagic/STRIPState) allowing you to get
on with making your application without having to worry about such details.

## Usage

We'll quickly outline how to use BedSit to develop an app.

### Loading

BedSit extends SitCalc or STRIPState, both of which provide the same
interface but differ in their situation representation. Thus, when
developing your BedSit app, you need to load your chosen one in your
`loader.lgt` file.

To do this, you need your chosen situation manager, in this example SitCalc, on your machine and your
`settings.lgt` file needs to locate it:

**`settings.lgt`**
```logtalk
:- multifile(logtalk_library_path/2).
:- dynamic(logtalk_library_path/2).

% redefine the "my_logtalk_libraries" library alias for the directory name and
% location where you will be cloning/downloading BedSit, SitCalc, and STRIPState
logtalk_library_path(my_logtalk_libraries, home('MyLogtalkLibs/')).

% assuming that the clones/downloads use the library names,
% no need to redefine the library aliases that follow
logtalk_library_path(sitcalc, my_logtalk_libraries('SitCalc/')).
logtalk_library_path(stripstate, my_logtalk_libraries('STRIPState/')).
logtalk_library_path(bedsit, my_logtalk_libraries('BedSit/')).
```

**`loader.lgt`**
```logtalk
:- initialization((
    logtalk_load([ sitcalc(loader)
                 , bedsit(loader)
                 , ... your app files ...
                 ])
    )).
```

### Managing Situations

BedSit provides a `situation_manager` class that you can instantiate to
manage the situation, be it with SitCalc or STRIPState. The instance of
a `situation_manager` is the gateway to the situation, you ask this what
fluents hold and ask this to do actions.

If your application only needs a single situation, you can instantiate
this in your loader and so refer to it in your application:

**`loader.lgt`**
```logtalk
:- initialization((
    logtalk_load([ sitcalc(loader)
                 , bedsit(loader)
                 ]),
    situation_manager::new(sm, s0),
    logtalk_load([
                 , ... your app files ...
                 ])
    )).
```

**some_app_file**
```logtalk
...
    todos::do(add_todo(Label)).
    todos::holds(completed(Todo)).
    sm::holds(todos::completed(Todo) and todos::recent(Todo)).
...
```

Only having a single `situation_manager` instance means we don't always have to
explicitly name it, as per the first two examples in **some_app_file**.
We can have more than one though, in which case we explicitly pass it:

**some_app_file**
```logtalk
...
    todos::do(add_todo(Label), sm).
    todos::holds(completed(Todo), sm).
    sm::holds(todos::completed(Todo) and todos::recent(Todo)).
...
```

There's one handy exception to this. If `todos` only acts upon one `situation_manager`, we
can declare this and thus skip passing the situation_manager explicitly
when doing actions:

**some_app_file**
```logtalk
:- object(todos,
    imports(actorc)).

    acts_upon(sm).

...
    todos::do(add_todo(Label)).
    todos::holds(completed(Todo), sm).
...
```

### Persisting Situations

BedSit provides a `persistency_manager` class, instances of which observe a
`situation_manager` instance and when an action is done, it persists the
new situation to file. On loading, it can then restore the situation
from the file.

For the observations to work you need to tell Logtalk about the events:

**`loader.lgt`**
```logtalk
:- initialization((
    logtalk_load([ sitcalc(loader)
                 , bedsit(loader)
                 , ... your app files ...
                 ]),
    define_events(after, _, do(_), _, persistent_manager),
    define_events(after, _, do(_, _), _, persistent_manager)
    )).
```

The simplest way to use a `persistency_manager` instance is to let it
also instantiate the `situation_manager` for you. If you don't provide a
starting situation and there is no file then your initial situation will
be `s0` in SitCalc or `[]` in STRIPState:

```logtalk
?- persistency_manager(sm, 'persisted/sm_store.pl').
true.

?- sm::sit(S).
S = s0.
```

Or you can provide a default situation that's used only if the file
doesn't exist yet, particularly useful for STRIPState.

```logtalk
?- persistency_manager(sm,
     'persisted/sm_store.pl',
     [current(level, 0), hp(player, 100)]).
true.

?- sm::sit(S).
S = [current(level, 0), hp(player, 100)].
```

**Note**: the persistent manager won't actually write the file until
some action is done, thus updating the base state.

### An Actor Category

Actors are those that act. When you've got shared state, you don't just
want anyone updating it without permission. The `actorc` category is how
you define who can do what.

To create an actor you import the `actorc` category and define the
actions it can do:

```logtalk
:- object(jump,
    extends(action)).

    poss(_Sit) :- true.

:- end_object.

:- object(bean,
    imports(actorc)).

    % Optional: define the situation_manager
    % instance bean acts_upon if more than one is defined:
    % acts_upon(sm).

    action(jump/0).

:- end_object.
```

Then if there's a single `situation_manager` instance in your app:

```logtalk.
?- bean::do(jump).
```
Or if you need to pass the `situation_manager` instance explicitly:

```logtalk
?- bean::do(jump, sm).
```

### A Fluent Category

A fluent is a relationship between things that either holds in a
situation or doesn't. Often the subject of that relationship is one
of your objects. The `fluentc` category gives an OO flavour to your
fluents.

To create an object where some of its predicates are fluents, you need
to import the `fluentc` category and declare which predicates are
fluents. You'll then be able to treat them like any other fluent or ask
the object itself if they hold.

For STRIPState:
```logtalk
:- object(teacup,
    imports(fluentc)).

    fluent(contents/2).

    :- public(contents/2).
    contents(C, Sit) :-
        self(Self),
        situation::holds(contents(Self, C), Sit).

    :- public(colour/1).
    colour(white).

:- end_object.
```
For SitCalc:
```logtalk
:- object(teacup,
    imports(fluentc)).

    fluent(contents/2).

    :- public(contents/2).
    contents(C, do(A, S)) :-
        A = fill(teacup, C)
      ; contents(C, S), A \= empty(teacup, C).

    :- public(colour/1).
    colour(white).

:- end_object.
```
Some example queries:

```
?- teacup::holds(contents(C)). % single situation_manager instance
?- teacup::holds(contents(C), sm). % passing situation_manager instance object
?- sm::holds(teacup::contents(Drink) and teacup::colour(Colour)).
?- sm::sit(Sit), situation:holds(teacup::contents(Drink) and not teacup::colour(black), Sit).
```

### A View Class

The `view_class` is the bedrock of the output part of your UI. The
view works by observing changes to situations in any situation manager
and passing that situation to the `render/1` predicate. As it's
observing events, you'll need to define this in the loader:

**`loader.lgt`**
```logtalk
:- initialization((
    logtalk_load([ sitcalc(loader)
                 , bedsit(loader)
                 , ... your app files ...
                 ]),
    define_events(after, _, do(_), _, view_class),
    define_events(after, _, do(_, _), _, view_class)
    )).
```

Now you can define your own view object:

```logtalk
:- object(app_view,
    instantiates(view_class)).

    :- uses(logtalk, [
            print_message/3
        ]).

    render(Sit) :-
        findall(F, situation::holds(F, Sit), Fluents),
        print_message(information, app_view, 'Fluents'::Fluents).

:- end_object.
```

It's recommended to make use of `print_message/3` and then hook into
this for the actual graphical representation. This'll make your app
easier to port to different GUIs and test.

When you have multiple `situation_manager` instances, you'll need to
tell which instance of the `view_class` observes which ones:


```logtalk
:- object(app_view,
    instantiates(view_class)).

    :- uses(logtalk, [
            print_message/3
        ]).

    view_for(sm1).
    view_for(sm4).

    render(Sit) :-
        findall(F, situation::holds(F, Sit), Fluents),
        print_message(information, app_view, 'Fluents'::Fluents).

:- end_object.
```


