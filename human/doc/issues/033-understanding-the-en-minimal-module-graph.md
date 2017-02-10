# what the hell is that sneeze at the top of en minimal. :[#085]

just for fun, we will explain it in some detail.

## first, the operations in detail

in the diagram that follows, all of the nodes are modules (possibly classes),
and are assigned to global constants. the vertical arrows represent
inheritance. the horizontal arrows mean that the node on the right (which is a
class) is the parent class of the node on the left.

modules that belong to ruby have names that begin with '::'. if the module
name does not begin with '::' then it is a constant of our topic node.

                                ::Module
                                    ^
                                    |
                    EN --> EN::Minimal_Inflector__

that's it. EN is itself a module, *whose parent class* is a subclass of
the ruby ::Module called "minimal inflector", whose only instance is that EN
module itself. this might look strange because 99.999% of the time modules
are just instances of the ::Module class and not a custom module subclass.
(why we did this is explained in the next section.)

the parent class of EN is itself a constant *of* EN (which is a module).
since any parent class must of course exist before child instances are
created from it, we accomplish this chicken-and-egg pretzel simply by
creating the class "dynamically" via ::Class.new( ::Module ) and storing that
class object in a local variable, and then creating our module as an
instance of that class, and then assiging the value in that variable as a
constant in that module.

# why the hell did we do this?

to understand why we subject ourself to this convolution we must first
understand our self-imposed false requirements:

1) NLP-related facilities any particular natural language must live within
one object (probably module) assigned to a constant directly in the "NLP"
module, of which there exists only one universe-wide. this NLP module is a
"strict box module" meaning that the constantspace directly inside of it is
a controlled namespace reserved for the members of some stated collection,
in this case the set of natural languages (and by design we stipulate that
the constants assigned to herein will have names like "EN", "JP", etc; being
the all-caps two-letter ISO-XXXX abbreviation of that natural language for
which facilities are being provided).

we are writing lots of little functions for hacked english natural language
production, and per above all these must fit under "EN", which reasonably will
be a module. but:

2) we also want this "front object" (EN) to itself act as an
"expression agent" [#ze-040], which means that (per above) it will be a module
that itself must respond to particular messages related to articulation.

given the above requirements, namely that we need a module that itself has
some behavior, we could have

1) just created the module like normal people:

    module EN  # ..

and then define the required behavior to the object's singleton class:

    def EN.foo   # ..
    class << EN  # or this
      def bar    # ..

but we don't like this because a) we don't want to limit ourselves by
confining this behavior to the particular object - we may decide later that
we want these methods accessible as instance methods e.g in a class or module,
enabling them to be re-used elsewhere. b) writing lots of behavior to a
singleton class always feels like a smell (perhaps a generalization of (a)).

it is for this reason that we want to create a particular class to hold this
behavior. now with this class:

2) we could have just not assigned the class to any constants at all, but we
want it assigned to a constant for #pragmatic-aesthetics if nothing else:
it is always hell debugging an object whose ancestor chain inpects as:

    [#<Class:0x007fb0ab403090>, Module, Object, [..]]

3) we could have just created the class like normal people do, as e.g

    class Minimal_Inflector__ < ::Module # ..

but as described above, we are making support for EN, and this must live
under EN itself.

i hope this clears things up somewhat.
