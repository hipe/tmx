# the listeners manifesto :[#037]

## objective & scope

(EDIT: use [#001] the selective listener pattern instead.. )

with an ear planted firmly on [#033] the callback tree etc, we
endeavor to produce a listener solution within these design contraints:

  • for now we want it to be simple enough that we can write it
    "by hand" as needed per application that wants it, maybe
  • so rather than a library this is more an architecture convention




## background

in the distant past we used [#019] the then called "pub-sub emitter".
we don't like it anymore for [#035] a variety of reasons. then,
later, we simplified somewhat this space with our [#033] callback
trees.

now we want to take it a step further and come up with an easy-to-understand
callback solution that is powerful enough to keep things modular and
de-coupled yet simple enough to be written in about a screen of code
per-application.




## what we know that is good, what we know that is bad

• an event library creating the event objects itself is bad, period.

• what is good is lots of small classes with readable method names :[#038]
  as callbacks. this is preferrable to passing lots of procs as named
  arguments at the callpoint.




## listeners are objects

they are not just procs passed as arguments, or tuples of procs. they
are first-class objects. the fact that the listener is a single, atomic
object has this one advantage at least: it is far easier to pass it
around to other endpoints.  :+[#035]




## method naming conventions


### the need for conventions

the namespace of channel names that the client may employ is of course
wide-open. our listener will employ [#040] readable method names that
isomorph with the names of these particular channels, whatever they are.
also, the listener will need at least some mechanical ("plumbing") methods.

both of these categories of method need to be growable infinitely: that
is, a given enpoint may want to add an arbitrary number of new channels.
also we as developers may want to add an arbitrary number of new
mechanical ("plumbing") methods.

hence we must utilize some kind of method name prefixing and/or affixing
to the callback method names so that both of these namespaces can exist
and grow without overlapping each other.



### the conventions in particular :[#039]

in particular our convention has evolved to use `on_foo_..` and
`receive_foo_..` variously **for the same kind of method**. that is, both
of these conventions will be employed when we make callback methods.
there is nothing intrinsicly different for a callback method that starts
with `on_..`  as opposed to one that starts with `receive_..`; whether we
use one or the other is an aesthetic determination:

seeing `on_` looks better when you are reading a method definition:

    def on_password_authentication_failure_event ev
      # ..
    end

and people acquainted with the java-scripty event handlers of the 1990's
may find this familar (`onClick` and so on). that is, it may be better
for us to adapt existing conventions that are a good fit before we
re-invent our own.

however, the `on_` prefix may look awkward when you call the method:

    @listener.on_password_authentication_failure Failure_Event.new( .. )

because the "on" makes it read more like a conditional stipulation
("if this then that") rather than a declaration statement of fact
("this is happending now").


really, what we might like is something more like:

    @listener.password_authentication_failure Failure_Event.new( .. )

but that won't work for us either because method names cannot
simply be be channel names. so what we have chosen is the convention of:

    @listener.receive_password_authentication_failure ..



#### so which one do we use? `on_` or `receive_`?

we use `on_` when you are hand-writing the callback method yourself.  we
use `receive_` when the method name is getting generated.



#### a suffixing convention

in addition to the above mentioned prefixes, we will often utilize a
suffix that states at least the general shape of the argument(s)
(typically something like `_event` or `_string`). this is becaues in the
very old days we used to shoot strings everywhere, and then we got
smarter and starting sending around event objects. but we were left with
a bunch of methods with names like `info()` and `error()`, and at a
glace we had no idea whether those methods could take objects or not.




## random structural note

this node is an "ordered dictionary", which is really a special kind of
tree. however you will note that we didn't place this node under [#033]
the tree node. this is because we want to showcase (to the software and
to ourselves) the fact that this node is simple and has fewer moving
parts and no dependencies than/of the tree node.
