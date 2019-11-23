# BedSit

BedSit is a **Bed**rock upon which to build your **Sit**uation driven
application. It provides objects and categories that work with either
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

BedSit provides a `bedsit` prototype object that you can instantiate to
manage the situation, be it with SitCalc or STRIPState. This object is the
gateway to the situation term, you ask this what fluents hold and ask this to
do actions.

```logtalk
...
    todos::do(add_todo(Label)).
    todos::holds(completed(Todo)).
    bedsit::holds(todos::completed(Todo) and todos::recent(Todo)).
...
```

### Persisting Situations

BedSit provides a `persistence` prototype object, which observes the
`bedsit` prototype and when an action is done, it persists the
new situation to file. On loading, it can be used to restore the situation
from the file.

For the observations to work you need to tell Logtalk about the events:

**`loader.lgt`**
```logtalk
:- initialization((
    logtalk_load([ sitcalc(loader)
                 , bedsit(loader)
                 , ... your app files ...
                 ]),
    define_events(after, _, do(_), _, persistence),
    )).
```

The common way to use `persistence` is to restore the situation, then
use this to initiate `bedsit`. If there is no file yet then your initial situation will
default to the situation defined by your implementer of the
`situation_protocol`s definition of the empty situation:


**`loader.lgt`**
```logtalk
:- initialization((
    logtalk_load([ sitcalc(loader)
                 , bedsit(loader)
                 , ... your app files ...
                 ]),
    define_events(after, _, do(_), _, persistence('my_storage_file.pl')),
	persistence('my_storage_file.pl')::restore(Sit),
	bedsit::init(Sit)
    )).
```

**Note**: the persistent manager won't actually write the file until
some action is done, thus updating the base state.

### An Actor Category

Actors are those that act. When you've got shared state, you don't just
want anyone updating it without permission. The `actor` category is how
you define who can do what.

To create an actor you import the `actor` category and define the
actions it can do:

```logtalk
:- object(jump,
    extends(action)).

    poss(_Sit) :- true.

:- end_object.

:- object(bean,
    imports(actor)).

    % Optional: define the situation_manager
    % instance bean acts_upon if more than one is defined:
    % acts_upon(sm).

    action(jump/0).

:- end_object.
```

Then it can do actions in your app:

```logtalk.
?- bean::do(jump).
```

### A Fluent Category

A fluent is a relationship between things that either holds in a
situation or doesn't. Often the subject of that relationship is one
of your objects. The `fluent_predicates` category gives an OO flavour to your
fluents.

To create an object where some of its predicates are fluents, you need
to import the `fluent_predicates` category and declare which predicates are
fluents. You'll then be able to treat them like any other fluent or ask
the object itself if they hold.

For STRIPState:
```logtalk
:- object(teacup,
    imports(fluent_predicates)).

    fluent(contents/2).

    :- public(contents/2).
    contents(C, Sit) :-
        self(Self),
        bedsit::holds(contents(Self, C), Sit).

    :- public(colour/1).
    colour(white).

:- end_object.
```
For SitCalc:
```logtalk
:- object(teacup,
    imports(fluent_predicates)).

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
?- bedsit::holds(teacup::contents(Drink) and teacup::colour(Colour)).
?- bedsit::sit(Sit), bedsit:holds(teacup::contents(Drink) and not teacup::colour(black), Sit).
```

### A View Category

The `view_category` is the bedrock of the output part of your UI. The
view works by observing changes to situations in any situation manager
and passing that situation to the `render/1` predicate. As it's
observing events, you'll need to define this in the loader for whatever
object imports this category in your app:

**`loader.lgt`**
```logtalk
:- initialization((
    logtalk_load([ sitcalc(loader)
                 , bedsit(loader)
                 , ... your app files ...
                 ]),
    define_events(after, _, do(_), _, app_view),
    )).
```

Now you can define your own view object:

```logtalk
:- object(app_view,
    imports(view_category)).

    :- uses(logtalk, [
            print_message/3
        ]).

    render(Sit) :-
        findall(F, bedsit::holds(F, Sit), Fluents),
        print_message(information, app_view, 'Fluents'::Fluents).

:- end_object.
```

It's recommended to make use of `print_message/3` and then hook into
this for the actual graphical representation. This'll make your app
easier to port to different GUIs and test.
