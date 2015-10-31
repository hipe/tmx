# isomorphicisms exploited by the isomorphic methods client :[#103]

## introduction & caveat

this article (and the ideas in it) started as a stub in [fa]. when that
sunsetted the node moved to [hl]. then [hl] was sunsetted too and [br]
has taken on these still alive-and-kicking ideas like the magnanimous
foster parent that it is.

however, the "isomorphicisms" that we play with in these node are for
now a bit contrary to the part of the spirit of [br]:

[br] is about defining a reactive tree with our broadly applicable
generic structures and then generating front clients from that. the
topic node (and children) are about inferring such things from platform
structures (modules, methods, arguments). hypothetically we could bridge
the two by generating something like a reactive tree from platform
structures but that is not for today.




## the method parameter name isomoprhicism ( more at [#105] )

because of the remarkably fun `Method#parameters` reflection method that ruby
exposes, we experimentally exploit that method method both to determine
the labels to use for commands parameters, and for something else we describe
below.

note that this should only be leveraged to the extent that it is useful to.
although many a sane "engineer" would argue that this is smell-city to have
names in code act as the datstore for some UI labels, we do it because it is
fun, and because it is not at all limiting (yet). also, these engineers are
not invited to our party. just kidding, everyone is.



## the argument syntax isomorphicism ( more at [#105] )

implemented by [#106] the argument node, this is even crazier and more fun.
it is what it sounds like. every single category of parameter that ruby
supports (except 'block') have analogs in the world of the command line:

'opt' for optional argument, 'req' for required arguments, and 'rest' for
the (zero or more) glob term.

this should come as little surprise considering how structurally similar
these mechanisms are: both methods (and procs) and command-line commands
accept as input lists of actual arguments, and must use syntaxes of formal
arguments to stipulate what the valid sets of input are, and then how to
delineate those actual arguments into variables.

we take things a step further here because we induce all kinds of error
messages from the formal parameters list against the actual parameters list
(before we yet pass the other to the one). given the two, we can for example
state the set of all missing required parameters, or more concisely, just the
first missing one.



## the public method isomorphicism ( more at [#104] )

this one has caused us the most pain, yet still we deem it to be a strong
enough isomorphicism that we continue to re-work it over and over again.
(although it doesn't state it directly, the whole [#bs-040] matryoshka doll
subsystem was built around jumping through many hoops to make this work
while still keeping the namespace of the "shell" clear for business names,
in an effort to pretend to be futureproof.)

we haven't explained what this is yet..



## the module as business collection isomorphicism :[#A]

this is basically the same thing as the idea behind [#cb-030] "boxxy":
that a ruby module's full extent of constants defined within in (and
necessarily the other ones it may have inherited via its ancestor chain),
should in some way be treated as having some business value.

note this isomorphicism isn't always elegant or leakproof depending on what
you're doing. for one, this mechanic should not be exploited to derive any
meaningful order from: :[#ca-027]. the order that constants appear in when
returned by ruby reflection is non-deterministic (or should be treated as
so, if it is in load order and autoloading is being used, which it should
be generally.)

secondly, care must be taken with such modules that we don't :![#035]
add constants to it that we don't intend to. typically through its ancestor
such a "box module" may unintentionally pick up constants that are just
private helpers to the side-stream libraries, uness we are using method
modules that are sensitive to this.
