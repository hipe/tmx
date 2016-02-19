# the arity exegesis :[#090]


(EDIT: moved here from [fa] before it sunsetted. some parts are
likely stale but overall is hopefully still legit.)


## introduction to `arity` thru the case study of "parameter arity"

prerequisites:

  • the concept of parameter arity employs the notions of [#fi-025]
    formal-vs-actual parameters. in summary; the former refers to what is
    specified/declared/programmed for, and the latter refers to what is
    passed in actual requests/calls.

  • the terms "field", "parameter" and "property" are interchangeable here.


"parameter arity" means "for this given formal parameter, what is the
acceptable number of occurrences of actual parameters for it in actual
request?"

this concept is reinforced by the platform language's reflective
`Method#parameters` method and the sorts of categorizations it applies
to parameters: `opt`, `req`, `rest`. our treatment here acts as a more
general superset to these three (and is not concerned with `block`).

"parameter arity" itself is a "metaproperty", that is, it is a property
about properties.

until a large amount of dust settles there will be contention between
parameter arity and "argument arity" (introduced below) with regards to
the "polyadic arities", i.e having more than one thing.

although at its essence an arity is formally defined (by us) to be a
series of non-overlapping unbound postive ranges, in practice we often
model arities as a [#hu-003] "category of exponents", i.e something like
an "enum".

to start with, our most basic implementations that use parameter arity
recognizes something like the following classifications:

    a parameter arity of ..    means ..

    `zero_or_one`              the actual parameter may acceptably
                               occur zero or one times. i.e it is
                               an "optional field". the platform
                               equivalent category is `opt`.

    `one`                      the actual parameter must occur
                               exactly one time in the request. i.e
                               it is a "required field". the platform
                               equivalent category is `req`.

in a world where we put the "polyady" on the "parameter" and not
"argument" arity (explored later), we might find it useful to
classify the below:

    `zero_or_more`             a "polyadic arity", the "field" can take
                               multiple actual paramters, but none is
                               necessary. the platform equivalent
                               category of this is `rest`.

    `one_or_more`              also a "polyadic arity", the minimum
                               acceptable number of actual parameters
                               here is one, making this effectively a
                               required field that can accept multiple
                               actual parameters.


some concerns care about whether or not the arity includes zero: for
normalizations that determine whether there are any "missing required
fields", a required field is generally one whose formal property has a
parameter arity that does not include zero. (conversely an "optional
field" is one whose parameter arity includes but is not limited to zero).

other concerns may care about whether or not the arity includes numbers
possibly greater than one (i.e "polyadic"): in such cases, certain
interfaces in certain modalities may need to be designed to accomodate
such input.

for fun we can imagine other classifications and the other semantics
that could be associated with them (and the behaviors those semantics
suggest), but this is done purely as a dalliance:


    `zero`                     the parameter (by symbolic name, whatever)
                               must never occur in the request (i.e it is
                               on a "blacklist"). in practice and typically,
                               the set of all would-be formal parameters
                               outside the set of specified formal parameters
                               act as if they have this paramter arity,
                               because typically (but not always) we clasify
                               the request as invalid if it has any
                               "unrecognized properties." if we were
                               being cute we could say that there exists
                               for every such invalid actual argument a
                               formal property with a parameter arity of
                               zero. but we are not.



## the gory detals

to define `arity`, a word that itself is not in "most"
"dictionaries", we employ another "neologism" : "sensical".
("neologism" is a word that means "made up word", said by someone
who wants you to trust them with the words they made up.)

`arity` as it has come to be used here in the entity library means: "a range-ish
associated with a particular formal number describing the sensical range for
the actual numbers that will be associated with that formal number." we mean
formal/actual in the sense of formal-vs-actual parameters to a function,
(presented at [#fi-025]), although typically the number we are referring to
is not itself a parameter but a `count` derived (in some way) from other
parameters (either formal or actual), and the relationships therebetween!

hence given a particular arity associated with a particular formal number,
and given a particular actual number for that formal number, we can say
whether or not that number makes sense. examples could be cited at this point
but it is such a simple idea, you can probably come up with fun examples on
your own (but ok here's an e.g e.g to get you started: the legal drinking age
for any particular locality may be modeled as an arity).

## a constructed example: pseudo-HTTP

Let's construct a simple imagined world of "parameters" where every `formal`
parameter in a request frame is either "required" or "optional"; and given a
set of `actual` parameters associated with those formal ones, we can then
say discretely and absolutely whether any given formal parameter is either
"provided" or "not provided" based on whether or not one such corresponding
actual parameter was provided. (imagine an artificially simple HTTP GET or
POST request, with no "edge cases" like an empty (string) value or
unrecognized parameter names.)

even in such an ostensibly simple information space as this (there is no
concept of order, no multi-dimensional structures, and as stated, no
"empty" or "invalid" arguments, just name-value pairs), we find two distinct,
meaningful ways to apply the concept of arity to the structures that occur in
it, as we spell out here:

above we said that in this information space and given a request, we can
say that any particular formal parameter is either "required" or "optional"
and that any corresponding actual parameter is either "provided" or not.
by the definition of this (intentionally simplified) information space that
we are making now, the "request" is defined formally as an unorderd set of
actual parameters, where an actual parameter is a particular value (or
`argument`) associated with one of the formal parameters.

(to keep this didactic model simple, we are occluding certain phenomena like
actual parameters represented as key-value pairs where there cannot be found
a corresponding formal parameter to associate with the key (an "unrecognized
argument", or in other associative spaces an "unexpected argument"; or the
idea of an "empty" argument (e.g being the empty string, or nil). but it is
at least worth mentioning their existence now.)

## many emergent counts to chose from

(sidebar: "emergent counts"

we will use the term `emergent count` to talk about numbers that occur as
derivative aspects of the interface or data, that is, by counting the
occurences of such aspects; to stand in contrast with a number that exists
as direct data or through some other facet.

for example, take the string "foo": one `emergent count` that exists in all
strings is the string's length, in this case 3. another emergent count could
be "the number of characters that is a vowel", in this case 2. yet another
one would be "the number of unique vowels," in this case 1; and so on.

the point is that these counts aren't expressed directly in the data but may
be derived (deterministicly) from it.

-sidebar!)

given the information space as it has been thus far constructed above, there
are several `emergent counts` we have to chose from that we may or may not
want to apply arities to: there is the count of formal parameters in any
particular interface, and there is the count of actual paramters in any
given request, for example. also there is the whole separate issue of when
a given formal parameter models a counting number, we may want to apply
arities there. but these are not the counts we are looking for.

there exist in this system a couple of emergent counts that are so de-facto
intrinsic to it that they would almost certainly slip by without being noticed,
were it not for us dedicating an entire essay to them (which is to say we
care about them in a special way):

for one,

## there is for any given formal parameter the count of actual parameters that
  ## that may sensically be associated with it.

huh? well, imagine we have an interface within our constrained information
superset of CGI-esque in HTTP-esque we painted above, and our interface has
two required fields: first name and last name. if, by the nature of the
information space, a request could somehow model the idea of multiple values
being associated with one of the fields (e.g multiple first names), (which is
not, by the way, totally unheard of, either in the domain of first names nor
in the domain of interface models) then we now have to decide what is sensical
count to define here: what number of actual parameters does it make sense to
accept for each given formal parameter?

given the information space (or "interface superset"), the decision often
seems almost handed to us (indeed in many systems it is); but part of the
point of this essay is to encourage us to realize that it is in fact a design
choice: what is the sensical range of actual parameters that may be associated
with every given formal parameter in our information space? we call this the
`parameter arity`.

let's say that in our interface we decide that having zero first names
"doesn't make sense," nor does having multiple first names. likewise for
last names. we then say that the first and last name "fields" both have
a `parameter arity` of `one`. (a formal parameter with a parameter arity
of `one` belongs to a class of formal parameters that may be referred to
"in the wild" as a `required field`).

and let's say later we add a "middle name" field, but we decide that this
formal parameter is not "required". in this framework we would formally say
that the formal parameter ("field") has a `parameter arity` of `zero or one`.
(that it, it makes sense to have indicated zero middle names or one middle
name, but not more (and not less!)).

we have now looked at one of the `emergent counts` of this analytical model
(the number of actual parameters associated with any particular formal
parameter) and shown two (of several) arities that we may use to describe
sensible ranges for these counts (`zero or one` and `one`). we also hinted
that there are isomorphic terms we more commonly use to describe such
formal parameters with such arities, namely "optional field" and
"required field". and finally, we have given this sort of arity generally
a name: `parameter arity`.

but as promised above, there is another `emergent count` we care about, one
that is conceptually so close to `parameter arity` that (as you can see
in the previous version of this essay) we used to munge the two concepts
together without yet realizing that there may be some utility in separating
them:

## what is the sensical range of arguments that may be associated with
  ## a particular actual parameter?

huh? isn't that a different way of saying the same thing we just finished
describing? well, subtly no: on the one hand, for any given "interface"
(that is, set of formal parameters) and any given request for that interface
(that is, set of actual parameters), there exists for each formal parameter
the count of actual parameters that is associated with it.

this count occludes any concept of argument ("value"), it is merely a count
of the actual parameters per formal one; which is necessary to allow for,
if in your analytic model you make the decision to allow for it! (what we
mean by this is explained below.)

whereas over here on the other hand, if we want to be able to speak in terms
of formal parameter as having been "provided" in the form of an actual
parameter even though there is no meaning to be had from speaking of it as
having a particular argument ("value") associated with it, one way to
represent this will be to introduce this other subtly different vector,
one we will call `argument arity` (as opposed to to `paramter arity`).

it may be that this distinction is arbitrary, and that this system is
isomorphic with a simpler one we haven't come up with yet. if so, hopefully
this analysis will be a stepping stone towards that. but for now, we are
left with a matrix of common examples from nature:


                 an argument arity of zero      an argument arity of one


 a parameter     (NOTE - this cel should be skipped on first reading! really!)
 arity of zero   (regardless of the argument arity, in your analytical model
                 it may be useful to speak in terms of a blacklist of paramters
                 that "may not be specified", e.g parameters with restriced
                 access, e.g from access control lists. but such a thing is
                 a dynamic system that brings us well outside the scope of our
                 analysis here, so we won't speak of parameter arities of zero)
                 also, see [1] below.

 a parameter     in a web form or GUI, the      the "optional field", e.g
 arity of zero   simple checkbox, e.g:          the "middle name" field
 or one          [X] email me with updates.     from the example above.
                 there need not be an argument  it may be present or absent,
                 associated with such one such  but there must be one
                 actual parameter, its mere     argument associated with it.
                 presence may be its repre-     there cannot be multiple
                 sentation [2].                 such actual parameters.

 a parameter     the case that created this     if you had a guest-list app
 arity of zero   fork in the road, in a CLI     that had a "plus one" feature,
 or more         a -v (verbose) flag that       and you accepted any number
                 increases the verbosity the    of names to "plus one".
                 more you specify it. note it   attachments to an email is
                 takes no arguments. this       this. ditto the CC: field
                 isomorphs with a field that    to an email (see also [4]).
                 accepts counting ints, e.g     tags associated with a
                 maybe volume in a music        photo, e.g.
                 player [3]

 a parameter     does not occur in nature.      any simple required field.
 arity of one    for whatever reason, it        arguably this is the normative
                 is never meaningful to say,    case in this matrix: a simple
                 "you have to provide this      "slot" that must (or does)
                 parameter but you cannot       have some data in it. this will
                 associate an argument with     likely be the default assuption
                 it." [5]                       in our libraries along either
                                                or both of these two axes when-
                                                ever an arity is not specified
                                                explicitly.

 a parameter     does not occur in nature       if you changed the above
 arity of one    as a corollary to the above    interface to be able to
 or more         observation: there is never    accept one or more first names-
                 meaning to a required field    you could model middle names
                 that takes no arguments.       in this way. the unix `rm`
                                                command has such an arity, for
                                                the count of filenames it
                                                accepts. (more e.g at [4])

the leftmost column contains all of what we call the "useful five" :[#029]
arities, which we here present as the most useful of the `parameter arities`.
(even though in this model we will rarely use the `zero` term as
`parameter arity`). the topmost row contains the two most useful arities
for `argument arities` (although we discuss another one below).

[1] - parameter arities of zero - to take things in an abstract direction we
may want to say that for any given interface, all possible actual parameters
for which there cannot be found an associated formal parameter effectively
have a parameter arity of zero - that is it may (or may not) be that they
are not permitted; that the only sensical range for the count of their
occurrence is zero, which is a clinical way of saying "not allowed",
"nonsensical", "unrecognized", "unexpected", etc.

if the request substrate is a hash-like structure of name-value pairs, we
might say that the set of formal parameters with an argument arity of zero
is the infinite set of keys not in the the set of keys recognized by the
interface.

if the substrate is an array of arguments and we are associating the arguments
with their formal parameters via position (functions typically work this way),
then the formal parameters with an arity of zero may be the infinite set of
"index out of bounds"-type arguments that may be provided. just an example
analytical techinque - maybe not useful.

[2] - for this class of formal parameters, it may be that we are able to
express any member of it using the conceptual building blocks that precede
it (rather than needing to introduce a new class for it), (in fact, the actual
HTTP CGI specificaction represents such actual parameters in a different way
than is modelled here) but we present it here as pragmatically and
semantically useful as a class of its own. this proviso may apply generally
to any class of formal parameters presented here.

[3] - this provides a jumping-off point for the broad class of formal
parameters we call "scalars", which we mention here but will not explore
in depth in this document.

[4] - for whatever reason, many many command-line utilities have a parameter
arity of 'one or more' (if not 'zero or more'), often when dealing with
filenames, including `git-add` and `git-rm`, just to cite two more.

[5] - in an analogy to real life this would be like "you have to show
up but you cannot say anything", which sadly does occur in that space.


## meta-analysis: justification for the dichotomy, and the arities

it bears pointing out at this point that a lot of this is arbitrary
and/or a pragmatic arrangement of the problem to suit the kind of solutions
we are used to applying towards it. it may be that we can turn this model
on its head, and add more columns to the `argument arity` axis and less
to the other one. it may be that we can line them all up and flatten
them out somehow. or just turn it into a set of name-symbols, rather
than arity combinations.

in fact there *is* one more argument arity that we see occuring in nature
that we avoided accounting for in our analysis for simplicy: the argument
arity of `zero or one`. some command-line utilities have the concept of an
optional argument **to an option**, e.g the grep --color option takes an
optional WHEN argument. another e.g the `ack` utility has a --context
option that takes an optional number argument. (also the `git-commit`
--untracked-files option belongs to this class as well.)

these are arguments that do not need to be specified, but can be for added
meaning. if we wanted our library to support modeling this (which we certainly
one day might), then we would add this as a recognized arity for the argument
axis, and go down the table and consider what it means in combination with
the exponents of the `parameter arity` axis.

also, the "polyadic" class of arities (`zero or more`, `one or more`) we have
put into the `parameter` axis and not the `argument` axis, although with
effort we may be able to prove that there is some isomorphicism there
(that is, that they are equivalent)..

## what about many arguments (zero or more, one or more)?

(below we will use the term "field" as shorthand for `formal parameter`.)

in our table above, the "biggest" an argument arity (as opposed to parameter
arity) can get is `one`. but in real life we find ourselves wanting to model
fields that allow for a number of arguments greater than one. wat do?

as you may have guessed, and as the above examples demonstrate, if you want
to model a field that accepts many arguments, you can model its equivalent
using the corresponding arities on the `parameter` end and it is the same:

if you want to model a field that accepts zero or more arguments, you can
do so by modeling the field as having an `parameter arity` of `zero or more`
and an `argument arity` of `one`. if you want to model a field that accepts
one or more arguments, do the same but swap in the `one or more` arity.

not only are these classes equivalent, we posit further that there is
absolutely no meaningful difference between doing it this way and the
would-be other way of doing it. (for the zero-or-more, e.g we could say
`parameter arity` of `one` and `argument arity` of `zero or more`, -OR EVEN-
`parameter arity` of `zero or one` and `argument arity` of `one or more`.
(this property is tagged as [#hu-030] and explored further there.))

yes we *could* do the above if our model supported polyadic argument arities,
but as it stands it doesn't. and the reason we don't add it in is because
the distinction is meaningless. but alas we offer no proof of this and only
offer that it is a futile exercise in semantics and to ruminate on it further
would be splitting hairs. no, really. we should stop.

but then we are left with an asymmetry: why is it that the "parameters"
end gets to have the polyadics and not the "arguments" end? this feels
clunky, and if not a smell or sign of strain on the model, then at best
it seems inelegant.

the reason for the asymmetry is pragmatics: in nature, we find ourselves
with at least two `surface interface phenomena` that we find useful to
describe as having an argument arity of `zero`: (in fact they may be
the reason that we model the dichotomy at all):

one is the basic "flag/switch" (in CLI) or "checkbox" (in GUI): (image a
--dry-run flag, or a "[X] email me" checkbox). if the actual parameter were
to occur multiple times, it does not add any more meaning. it is meaningful
to expect it to be expressed zero or one time. it does not add meaning to
associate an argument with it, its mere presence is meaningful. this is to
say that this field has a `parameter arity` of `zero or one` and an
`argument arity` of `zero`. but note this use case only offers a
justification for there being an `argument arity` of `zero`. it does not yet
justify the asymmetry.

another class of fields that has an argument arity of `zero` may seem
to be a bit of an edge case as far as surface phenomena go, but it is
one we are glad to have when we have it: `parameter arity` `zero or more`
and `argument arity zero` - the "incrementing flag". in nature we only see it
in command line interfaces, but in these modalities it is an intuitive
way to represent a small positive integer (e.g the verbosity level): by
specifying more of a thing you get more of it.

in order to model a formal parameter like the one above we had to provide
for there being a `parameter arity` as distinct from an `argument arity`,
and for the former to allow for `zero or more` and the latter to allow
for `zero`. there is simply no other solution that adequately described
the phenomenon without feeling itself hacky.

## some more thoughts on isomorphicisms and equivalencies

as stated above, we model the `arity dichotomy` especially so we can represent
the edgy polyadic/niladic options like the incrementing -v (verbose) flag, an
option that can be specified multiple times but takes no arguments. in deep
representation, such an actual parameter will likely work out to being
represented as a non-negative integer, representing the count of the actual
parameter's occurences.

to go in the other direction, such a class of formal parameters may "isomorph"
cleanly with an already existing class. in this example, we could just model
the [-v[..]] parameter as a required field that accepts a string representing
an integer of zero or greater, or an optional field that accepts the integer
one or greater, and we could furthermore generate the surface representation
of it as it is (for the appropriate modality).

but to back up a step, there may be usability or aesthetic design
considerations that go in to chosing one abstract representation over another;
considerations that might give hints to the surface representation engine.
alghough these aesthetic vectors themselves could be somehow modeled
as heuristics (and yes we are thinking about this), we are holding off on this
effort as "too crazy for now," believe it or not.

we further argue that it is useful to model them this way if for no
other reason than that it is how we conceptualize them in our minds in the
first place, and it is useful to have our notation resemble this.

so notwithstanding any stochastics and arbitrariness here, we hope that we
have at least succeeded in distilling this problemspace down to a few key
concepts with some degree of primacy, namely that there exist formal
parameters and actual parameters, and that there exist emergent counts from
these, and that it is useful to associate one of a particular class of arities
to these counts.

### what about the infinity of arities not included here?

certainly there exist arities not among the "useful five" on the one axis or
the "useful two" (or three) along the other, and all the (5 * 3 - X) useful
combinations there-among (where X is the ones that are ridiculous or
impossible).

for example, we may want to specify a peevish structure-statement grammar
that could model kinky range requirements, like that the number of arguments
has to be an even number. in fact it's not that far fetched - corners of ruby
employ this interface:

  Hash[ 1, 2 ]    # => {1=>2}
  Hash[ 1, 2, 3]  # => ArgumentError: odd number of arguments for Hash

which, by virtue of the meaning derived from position of the arguments,
(keys of the odd-indexed elements, and their corresponding values for
each next element) "makes sense" of course, which is the whole point of this
wild, flailing tangent: to express sensicality of count.

as it stands for reasons we will touch on in this conclusion, this model
*does not* support the expression of arities not listed here. our aim is
to cover the 95% use case of interfaces in such a way that is as powerful
as is necessary and then as intuitive as possible.

## supporting concepts defined in detail (the *really* boring part)

so, what do we know?

### we know what an arity is

an arity is basically a range, right? let's take it a step further and
say that we're only dealing with "simple" ranges as opposed to "compound"
ranges. what do we mean by `simple range` and `compound range`?

  `simple range` - a simple range is a `tuple-ish` [#ba-010] of two elements:
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

going with a working definition that we hinted at above, let's say an arity
is a `simple range` as defined above. With any given such arity, we can take
any given `count` and definitively say whether that arity "includes" that
count. whew! that's why we defined those. ick.

## concluding thoughts on our approach

we hope we have demonstrated that sizeable expressive power comes from
this relatively simple model: using two metafields with (for now) four and
then two exponents, we can represent what amounts to the six most prevalent
classes of field (with respect to their parameter/argument arity); in a way
in a way that is flexible and abstract enough to be hopefully
future-proof-esque and modality agnostic while still being readable.

as for implementation, we opt to represent the arities as symbols spelling
out their respective arity, e.g `:one`, `:zero_or_more` etc. rather than
for example using integers or even (gasp) literal ranges. we had tried it
this way once with the literals and we actually found it less readable and
less immediately intuitive to grasp. furthermore, using the symbols rather
than the literals gives us a `poka-yoke` effect of a discrte (and small)
number of buckets that our working arities may fall in to, which both makes
implementation easier and encourages us to follow well-known conventions
and patterns in our design.

also, we have opted to use the term `arity` as a shorthand for one of these
two axes. which axis is the winner of this shorthand has been determined by
pragmatics and circumstance: we most often find ourselves expressing fields
as either "required" or "optional". and we less often (but still often) find
ourselves expressing that a field is "flag/checkbox"-like. hence, because we
use `paramter_arity` to express the required-ness of a field (optional fields
have zero in the parameter arity - fields with a parameter arity that does
not include zero are required) -AND- because we chose to let argument arity
default to the popular `one`, it is `parameter_arity` and not `argument_arity`
that gets to be shortened to `arity`!

arity. it's really that simple.
_
