# the CLI box DSL narrative :[#040]

## :#storypoint-05

welcome to the CLI box DSL. familiarity will be assumed with any concepts
presented in any [#137] CLI box narrative.

if you use this, it will not be future-proof oweing to the concerns of
[#fa-037], but you should use it anyway.


### understanding the behavioral domain of the DSL box

fitting into our [#010] "client tree" model, a component called "box" is
concerned with managing children nodes in terms of operations like rendering
the collection to screen, dispatching requests by resolving a particular one,
and handling the case that a child cannot be resolved from the request (in
terms of actuaing UI behavior).

as for the "DSL" part such a box, the general mechanic of it is twofold: one,
we will expose an API of private "class methods" that are used to define
properties of each particular child node at this level.

two (and most essentially), the central thesis statement of this experiment
is: [#147] "can a clean isomorphicism be drawn between the public methods of
a particular class and its collection of supported "commands"?". this remains
the space of active inquiry and we embark on our seventh or so rewrite of an
implementation of this idea.

to get pseudo-formal for a second, the grammar ends up looking something like:

    class Foo
      Headless::CLI::Box[ self, :DSL ]  # EXAMPLE - not yet implemetned #todo:during-merge

      NODE_DEFINITION *

      NODE_DEFINITON : NODE_MODIFIER *  COMMAND

      COMMAND: ( a public method definition )
    end

the above is to say, a DSL-enhanced box class contains zero or more node
definitions. a node defintion is be zero or more node modifiers followed
by one command. a command is (simply) a public method definition.

so note that by this defintion, the empty class by itself is still a valid
box node, as is one with only one public method definition..



## :#storypoint-25

this is less ugly than it used to be, but the general rubric still holds: we
want to avoid the smell of cross-cutting concerns, but in this case we can't
think of an easy way out:

we may be vivifying the box module. we will use const reduce or the
equivalent elsewhere, and typically we want the "boxxy" behavior (that
reads the filesystem and infers the names of constants that are not even
loaded yet) so we specify that here as the asssumed default.



## :#storypoint-55 (method)

the essence of this module is in this 'method_added' hook. providing that the
DSL is "on") we resolve the constant that we will use to store the action
class under. we "touch" the action class.

when we say we :#touch the action cass we mean that we use any existing action
class that is currently being built, and if one is not being built then we
start one.

we then effectively close the action by nillifying the ivar. we do this now
because (somewhat arbitrarily) the method definition is the thing that
terminates the action definition.



## :#storypoint-105 (method)

the DSL distinct from an ordinary box will be the controller that executes
the request. under normal circumstances the "bound downtree action" is not
used for any execution; it just a vessel for the properties.

we've already parsed the opts once, but since we are a box we would have
skipped the actual parsation of them unless they were at the front. so we
try to parse them again, but this time use the o.p from the downtree.

this brings us to the central hack of this node which is allued to at
#storypoint-155 below. this is where we mutate ourselves to "engage" with
the downtree action.

if the act of parsing added something to the [#143] queue, we take no further
action. we return from this call and bubble back out to the main invocation
loop, which will have that one more item to process. otherwise.. (jump to
method)


## :#storypoint-155 (method), :#the-mutable-engagement-mechanic

an ancestor module near us may hold that it is always a branch by its
definition of `is_leaf` that always results in false. another one still may
hold that it is always a leaf by defining this method to be the immedate
value of `true`.

we, however, do something ridiculous: we make this method a simple attr
reader. this do this because we as a bound action node will acting either as
a branch or as a leaf. what's even more, what "mode" we are will is mutable.

keep this in mind throughout the rest of the narrative.



## :#storypoint-175 (method)

if we are here it means that we have engaged to a downtree action and that
we have run its option parser around the argv, and furthermore that doing so
did not add any additional items to the queue. we do that simply by adding
the appropriate method to the queue, and bubbling up a no-op dispatch object.
keep in mind we set our argv back to the argv intended for the child above.
we will bubble all the way out to the main invocation / queue loop, and it
will evaluate one more iteration, doing the appropriate arg syntax validation.




presumably we are supposed to
run that action. we do that by resulting in an approrpriate dispatch that
will bubble back up to the main invocation / queue loop. note that ultimately
it is we who implement the child action, because that's at the heart of the
design of the DSL: although a downtree action class is created to model the
various properties, the implementation of the action lies in a method defined
in our body.




## :#storypoint-195

egads if the o.p for the child is being executed that means we have already
engaged to it, so showing our own help screen will be showing its help screen.
to tell ourselves we are doing this trick we pass our version of an empty
reference.



## :#storypoint-200

if you are engaged then the call is presumably coming in from a bound child
from a generated class (or the like) who passed the second argument as above
in #storypoint-195. if you are not engaged then the call is coming presumably
from an 'infix'- style operation ("foo -h bar" not "foo bar -h"). no matter
what we do not let the outstream handle this. the child never has autonomy
and so cannot render his own help screen (for one, he doesn't know what his
"default action" method is so he can't render is syntax).



## :#storypoint-405

although clearly some of the below methods add no additional behavior to
the parent methods they call up to, they are written there to make a point.
all of the fragileness and coupling that you see here is the cost of
#the-mutable-engagement-mechanic, and a case for reworking this (again) so
that even the generated bound actions can produce their own help-screen
related components with ordinary autonomy, rather than this nonsense.

the whole thing that started this was the desire to be able to use custom
methods (and the controller context, to be sure) from inside the o.p option
blocks. this could be the goal for the next reworking.



## :#storypoint-505

the sub-sections in this section pertain to all the "extra" things that
we do when we define an action, besides giving it a name and an argument
signature. namely we may use the option parser and 'desc' facilities.

we will address writing those properties for the branch host node too,
now that you cannot use these methods for anything other than children.



## :#storypoint-515

in this case, given the way the DSL works we don't have to worry about making
this an inheritable attribute. and we may or may not context switch when we
actually use the proc so this is why we don't use the proc to re-define a
method with otherwise we would.
