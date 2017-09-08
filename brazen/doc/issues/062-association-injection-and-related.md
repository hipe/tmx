# association injection and related :[#062]

## table of contents :[#here.a]

  - table of contents [#here.a]
  - synopsis [#here.b]  (has [#here.3])




## synopsis :[#here.b]

  - you can inject arbitrary new associations into your action
    (after it constructs, realized before or as it is normalized).

  - you can remove arbitrary associations. (we call this "de-injection").

  - you can assign aribtrary parameters (really, just setting ivars).

  - you can ad action-level (not association-level) ad-hoc normalizers
    to your action in this same context.

  - this is meant to help you allow to "steer" the way your action is
    adapted for this or that particular modality; but can become a
    smell if overused. (see example in [bs] that links back to [#here.3]).




(EDIT: everything below this is legacy, half is OK..)

## fine-tuning modality expression decisions

ideally you can live with [br]'s inference choices for how your reactive
tree is expressed as a modality-specific UI. but sometimes out of a
usability concern and other times out of necessity you will need to
modify the choices that would have otherwise been made by this
inference; when expressing outwardly and interpreting inwardly the
behavior and data of your particular actions.
(EDIT: fine tune the above for [ze]-era)

first of all, it's worth understanding the reasons not to do this:


## reasons not to do this

there's just one, but it's a good one:

  • any modality-specific behavior you write will be behavior that does
    not translate across modalities.


## reasons to do this

understanding why we tend to avoid such customizations, here are some
examples of times that we just can't resist:

  • you want (really want) some fancy argument parsing syntax that differs
    from what would be generated.

  • you want to to catch particular events emitted by the corresponding
    upstream API action, and write modality-specific behavior for those
    events that is different than what happens by default for those
    events. (for the two-event filesystem write we often give this
    polish by writing the info output as one line in two parts.)

  • you want to render the end result in some way that is not covered
    by default (for example to render a tree or something..) [#021]


## ways to do this

At writing there are at least three ways that you can provide for a node
in your reactive tree a custom adapter class.

  • override the `adapter_class_for` method in your reactive tree node.
    the disadvantage to this technique is that it is in a #goofy-direction:
    now the reactive tree has to have knowledge of customizations going
    on at the modality level. (#todo why do we have it then?)

  • create an 'Actions' module in the appropriate branch adapter class
    (for example your top branch adapter class is usally called `CLI`).

    in this actions module assign appropriately named const with your
    custom adapter class. our implementation isn't going to bother using
    a full "const reduce" here so use the name `Foo_Bar` not `FooBar`
    for your class that answers to a slug "foo-bar".

    at writing *always* these custom classes are subclasses of
    `Action_Adapter` or `Branch_Adapter`. often the application makes
    its own shared base-class for actions from `Action_Adapter`, and
    uses this for most or all of its custom action adapters.

  • riffing off of above, if your toplevel CLI invocation class defines
    within itself its own `Action_Adapter` [typically sub-] class, this
    will be used as the action adapter class for all reactive leaf nodes
    that do use one of the other techniques here.
    (demonstrated in :codepoint-A.)
    autoloading is not yet available for this technique.

  • often seen for toplevel-non-top-branch nodes, and in the spirit of
    the last point, have a 'Modalities' module and under that a 'CLI'
    node.. (TODO)



## fine-tuning the formal properties

for any "action adapter" for which you want to modify the formal properties
of the (back) action somehow, use the below const name to indicate the list
of names of such formal properties.

    (demonstrated in :codepoint-B)

(we put "back" in parenthesis because all actions are "back actions" --
when dealing with the front we always call them "action adapters" to at
least *help* with the possible confusion.)

some important facets of this employed here:

  • the fact that we have set this const in our action adapter *base*
    class will be equivalent to having set this const to this value
    in all of its subclasses, because that's the way constants work
    in the platform (provided you access them in the inheritance-
    sensitive way we do).

  • every *generated* action adapter in our application will be built of
    this class for the reason explained in the previous section (namely,
    that the const that holds this class has this particular magic name).
    as such, this "list of names" (of formal properties to modify) applies
    to these generated action adapters as well.

  • it will have no effect for a name to appear in the list that does not
    correspond to a formal property for the action. this is by design, so
    that you can create one "master list" of names of properties you want
    to mutate in your base class, and have it not break on those actions
    that do not have this or that property.

  • setting the list-of-names const to false-ish is equivalent to the
    empty list. you may want to modify your base class to ignore a list
    set by a parent class.




## document-meta

  - #history-A.1: begin injection of [ze]-era talk of "injection".
_
