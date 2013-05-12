# all about 'arity' as it pertains to metafields

to define `arity`, a word that itself is not in "most"
"dictionaries", we employ another "neologism" : "sensical".
("neologism" is a word that means "made up word", said by someone
who wants you to trust them with the words they made up.)

`arity`, then, (in its usage here in the entity library) means:
"the sensical range of the number of actual arguments for a
field." That is, "what number of arguments makes sense for
this field?".  They key word here is "argument". Let's explore
this in full right now:

(in the below, don't worry about rigid definitions for "field",
"option", "argument", "parameter" - their usage may be hazy in our
treatment here (in fact we are postponing defining them rigdly).
Our purpose here is not to understand those terms, it is to refine
the utility of `arity` as a metaproperty.)

Let's construct a simple imagined world of "parameters" where every `formal`
[#mh-025] parameter in a request frame is either "required" or "optional", and
each `actual` [#mh-025] parameter in a given actual request is either
"provided" or "not provided" (imagine an artificially simple HTTP GET or POST
request, with no "edge cases" like an empty (string) value or unrecognized
parameter names)

In this world, when we talk of the `arity` of each such formal
parameter, it will perhaps come as a surpise that both of these
kinds of parameters (required and optional) are considered to have an
arity of 1 insomuch as: a formal required parameter "takes"
exactly one argument, and likewise a formal optional parameter also
"takes" exactly 1 argument -- the optional parameter doesn't
need to be present in the actual request, but if it *is*
present, it must (by virtue of the constraints of our made-up
protocol) as an actual parameter have exactly one argument associated with it.

if the formal parameter is of type `required`, and an actual argument is
provided, it 'takes' exactly that one argument.  if an optional parameter is
provided, it also takes exactly one argument. ergo, maybe "parameter"
is a short way of saying "field with an arity of 1."

(yes, through real life HTTP GET and POST there are ways to "pass"
arbitrarily structured data in requests .. but let's stick with
sublime simplicity of our imagined world for now for the sake
of making some points..)

To counter-intuit things a bit further, when we speak of an "option":
from one angle, the arity of the option field *itself*, we could say,
is 0..1 (the range, an integer between 0 and 1 inclusive, i.e either
0 or 1.), because "option" meaning "optional", means that there can
be zero or one of it, right? Well, wrong. Again arity refers
to the sensical range for a "number" of "arguments" that a
"field" may "have".

we mean arity _of the arguments_ that a field takes, not
simply the presence or absense of the actual field in a request.

If you are as confused after reading this as the author was after both reading
it *and* writing it, then we should both revisit it from a different angle:

## what do we know?

### we know what an arity is

an arity is basically a range, right? let's take it a step further and
say that we're only dealing with "simple" ranges as opposed to "compound"
ranges. what do we mean by `range`?

  `simple range` - a simple range is a tuple of two elements:
    the first element in the tuple is a non-negative integer.
    the second element in the tuple must be either:
      and integer equal to or greater than the first element in the tuple
        - or -
      nil to mean positive infinity.

#### some things about ranges (sidebar!)

something to take into account when it comes to parlance about ranges: the set
of these such tuples ('simple ranges') that have the same integer for the
first and second element, they are each isomophic with that integer itself.
that is, the range '1..1' is equivalent to '1', and 2..2' is equivalent to '2'
and so on.

so then it follows (no proofs provided here) that the set of all non-negative
integers is a subset of the set of all simple ranges as defined here, i.e
every non-negative integer is a simple range. but whatevs.

(end sidebar!)

  `compound range` - is a collection of one or more ranges. they can be used
    to represent a non-contiguous subset of a simple range of integers, for
    example certain lines in a file. we don't use them there but we do
    elsewhere so we added this for completenes.

    (a compound range is a range so it can be made of other compound
    ranges but stahp.)

### we know what a count is

but really quick let's define it:

  `count` - a number from the set of non-negative integers {0, 1, 2, 3, ...}

### we know what an arity is for

Going with a working definition that we hinted at above, let's say an arity
is a `simple range` as defined above. With any given such arity, we can take
any given `count` and definitively say whether that arity "includes" that
count.

## so why did we get confused?

So we know what an `arity` is and we know what a `count` is and we know that
any arity either includes or excludes any count. The reason we got confused
above is because of the question "what count are we talking about?".

in a given request, there is the question of whether a given parameter was
either provided or not provided. It is tempting to say that there is a count
there: 1 for provided and 0 for not provided. and in this way we can express
whether the parameter is required or optional by selecting one of the two
ranges for each formal parameter: [0..1] or [1]. so note in this usage where
the count is coming from, the count is counting the paramter itself (by its
name).

*but there is another count there*: for some corners of this world we want to
talk about the `count` of *arguments* to given parameter (or more betterly,
to a given field). if we wanted to specify an annoying structure-statement
grammar we could deal with kinky range requirements, like that the number of
arguments has to be an even number. Not that far fetched - here's an example
of this from ruby:

  Hash[ 1, 2 ]    # => {1=>2}
  Hash[ 1, 2, 3]  # => ArgumentError: odd number of arguments for Hash

which, by virtue of the meaning derived from position of the arguments,
"makes sense" of course, which is the whole point of this wild, flailing
tangent: to express sensicality of count.

## so let's go deeper

So, above we saw that there were at least two axes on which we can count:

one: whether a parameter is or is not provided can become a count of zero or 1
(and formally we can express the idea of "required" vs. "optional" with the
arities '1' and [0..1], respectively).

two: the count of the number of arguments, we can use arities formally there
to express the acceptable number of arguments.

Whenever we use the plain old term `arity` the question then always becomes,
"for which count?". hence, so we don't get confused after this (yeah right),
we will hereafter stop using the plain term `arity` all together, and rather
we will speak of the `argument arity`. (we aren't even going to name the
type `one` arity above, or even suggest names. how's *that* for avoiding
confusion!)

## So what can we do with this new idea of `argument arity`?

An "option" (for this definition of "option" (or maybe we should just say
"field")) accepts one of an infinite composition of argument arities. But for
now and maybe always we will only need to deal with these five argument
arities below, which we will hereafter call the "sacred five" :[#fa-029].

## The Sacred Five Argument Arities:

* 0      (the integer literal) the field takes no arguments -
         the actual parameter's mere presence or absence alone
         manifests the totality of its meaning. may be conceptualized
         as a "flag" in some modalities ("flag" being a kind
         of "option"). it manifests as a checkbox in others.
         examples might include a `--verbose` option in a CLI,
         or an "[X] email me with updates" checkbox in a web
         form.

* 0..1   (the range "zero to one, inclusive". when referring
         to integers, which we are, this of course means "zero
         or one".) the field *can* but does not *have* to
         take one argument. this is actually weird and we will
         explore its wierdness elsewhere.

* [0..]  (the range zero to positive infinity, or "zero or more"
         or "any") the field can take zero, one, or many arguments.
         In a messaging application (e.g email or iMessage whatever)
         if you have the equivalent of a CC: field, this is the
         argument arity of that. that is, you don't have to indicate
         anything in the CC: field, or you can indicate one value,
         or more than one.

* 1      (the integer literal) the field takes one argument.
         if not otherwise indicated, this is usually the
         argument arity we mean when we say "parameter" or
         "argument" or "required field".

* [1..]  (one to positive inifinity. "one or more")
         the field can take one or more arguments.
         the unix `mv` command (for moving files), its first
         "field" is like this. you can indicate one or more
         fields to move [to a directory].

         in general many unix utilities that operate on one file
         can, when sensical, operate on many files, and have this
         argument aritiy. (e.g `grep`)

         many git commands have fields that have this argument arity.

         to use an example from a thing i know little about, the Dropbox
         application, when you are putting one or more files up there,
         this is the argument error for that two (that is, putting zero
         files up is not a sensical count for that field).

There is of course an inifinte number of other argument arities, and with
these you could express all kinds of kinky requirements for your counts, like
that it has to be a prime number, or greater than one or whatever but we are
going to assume there won't be a good rason to employ argument arities like
that ever ; until we run into a counter example (*maybe* the argument arity
of [2..] would be useful for some actions that perform aggregations, but meh).

## conclusion.

All of the above was to merely to develop what argument arity really means, to
assert why we aren't simply calling it `arity`, and to develop the sacred five
and to arrive at this:

insomuch as the sacred five are useful general purpose argument arities that
cover the 99% use cases of field fields (that is, fields in the field),
we are going to hard-code them as symbols in the code, for some poka-yoke.

so, 200 lines of natural language to get to 2 lines of pseudocode:

    meta_fields [ :argument_arity, :property ] ..
      # { :zero | :zero_or_one | :zero_or_more | :one | :one_or_more }

~
