# name conventions for constants :[#029]

(this is a ground-up re-write of a document "lost in the [#!br-092] fire".)

## synopsis

we use these conventions not because they are pretty (they are not) but
because they pack a lot of self-documentation into a small space.

a const's style exhibits both its "scope" and the kind of object it references.

(when we say "node", we typically mean "module (e.g class)".)
a node's scope is expressed by the number of trailing underscores
in its const name:

    PublicAPI  # :[#here.0]: this node is part of your public API (see semver.org),
               # and so cannot change without a major version change of your gem.

    LibraryScope_  # :[#here.1] a const named like this is visible (only)
                   # to scope-wise child nodes that can "see" it. (more later)

    CozyScope__  # :[#here.2]: this node is used *only* by a single other node
                 # (and only from one file). (note the node itself can be
                 # defined in a dedicated file separate from the file that
                 # uses it.) probably the most common convention.

    OneOffScope___  # :[#here.3] exactly as [#here.2] and also it is only
                    # ever referenced from one code location. used frequently.

    SingletonScope____   # :[#here.4] as a const name in this const scope you
                         # will only find this string in one place. typically
                         # used in a kind of ugly older way to implement singletons.

apart from the underscores that trail a const name, there is also convention
around how interceding underscores are used in const names. here is a
cursory overview of this, with in-depth explanations to follow in this
document. (in the below example we use "cozy scope" because it is common):

    ThisIsThePlatformConventionAndOurCurrentConvention__

    Some_Legacy_Classes_Are_Named_Like_This__   # called "camelcase with underscores". deprecated.
                                                # but further explanation justifies some use-cases

    This_casing_is_reserved_for_proc_likes_eg_actors__  # as a rule

    ANY_OBJECT_TREATED_AS_A_VALUE__  # even when we use a module to implement a singleton




## when do we use the weird-looking `Camel_Case_With_Underscores`?  :[#here.2]

  - we will use underscores if any piece of the const name is an acronym,

        API_Key  # better
        APIKey   # worse

    probably we only use the underscores to separate the piece that is
    an acronym; it's not whole-hog:

        Invalid_HTTP_RequestResponse   # better
        Invalid_HTTP_Request_Response  # worse

    (EDIT 2023): We now prefer either all underscores or no underscores
    (in one name). Use underscores if the acronym touches a non-acronym
    capital letter, otherwise don't? Not sure, experimental.

    We may now leave this up to the author: underscores or none.

  - we use this convention for names of some modules whose files are
    loaded with simplified autoloading (e.g test support nodes) because
    it's trivial to implement inflectors for this kind of name translation,
    and we don't like our test code having extraneous dependencies.

       :some_test_suppport_node  => `Some_Test_Support_Node`

    this has a side-benefit of allowing us to search for a public-API
    "asset code" node without getting hits for its test support node
    (for those names with multiple pieces).

  - we use underscores mixed in with conventional looking class name
    elements as special higher-level syntactic separators, like
    for [#ta-005] "magnetics":

        SomeThing_via_OneIngredient_and_OtherIngredient

    (this is a quite bespoke convention.)

  - at one point we adopted this as the default for typical classes
    and modules (reasons don't matter); so there is still a lot of
    mid-legacy code with this convetion, with the old justification:

    conceptually we though of `_` as being halfway to `::`.
    if you have a name like `API_Key` are you sure you don't want
    it to be `API::Key` instead? using the underscore as an imaginary
    ersatz for a `::` is a visual reminder that we should be planning
    for our name graphs to grow.




## justification (preview)

these conventions are both ugly and near perfect. there is a case to be
made for an intuitive semantic value in their ugliness: the uglier the
name is (the more trailing underscores it has), the less intended it is
for public consumption. i.e if you don't like the way a name looks it
probably doesn't like you either.

names like these are optimized for refactorability and comprehensivenes
through what they self-document. by seeing a const we immediately know
two things from which we can infer many others:

  1) through its "shape" we know roughly what it is and how we are
     expected to interact with it.

  2) to be able to know its scope at a glance has two important
     ramifications for what we can know about a const assignment right
     away:

     A) we know immediately how far we have to look for documentiation
        (at best) or (at least) a home for the const. const assignments at
        tier 0 should always be documented, and consts at tier 1 should
        usually be. (so we also know something about our chances for
        finding documentation - you can know right away whether a const
        at tier 2 and below is documented because you are already "in"
        the node that owns it.)

     B) if we want to change the const (or are at least considering it),
        we get an immediate estimate of how broad an impact that change
        might have on the broader system: a const assignment at tier
        5 is tautologically OK to removed. removing or changing a const
        at tier 0, on the other hand, is a violation of "semver.org".

        (consts at tier 2 and below are usually trivial to change.
        at tier 1 is somewhere in between.)





## introduction

remember that a constant in ruby can refer to any arbitrary value.
remember too that ruby itself dictates that the const name must be
something like:

    [A-Z][_A-Za-z0-9]*

(we will now typically say "const" instead of "constant" universally,
because ruby itself uses this abbreviation in its method names.)


we take this pattern which itself is a language requirement and further
refine it to several sub-patterns, such that the const name we chose for
any particular thing being named will be "inflected" by at least two
dimensions:

    1) the name will reflect the "shape" of the thing being named.
    2) the name will reflect the "scope" of the thing being named.


### the way shape is reflected in a const name :.A

the name we choose will assume different "inflection" based on whether,
variously, it references

  • [#here.5] a non-class module,
  • [#here.F] a class,
  • [#here.3] a proc or proc-like
  • or [#here.B] any other value not in the above list.

we will present the conventions here in order from "smallest" to "biggest",
idiomatically:




#### the name convention for arbitrary values not in the list :.B

adopting the C-like convention, we use names in all caps whose
constituent words are separated by underscores:

    VALID_NAME_RX = /\A[A-Z][_A-Za-z0-9]*\z/

the above is an example of a const that holds a regex.

in practice, we will often see our const names containing one or more
[#here.7] trailing underscores because of [#xxx] "rounded API's".

that is all.




#### the name conventions for proc-like consts :[#here.3]


for a proc when that proc is assigned to a const, or other proc-like
objects (that is, an object that is interfaced with like a proc, like
for e.g a [#fi-016] actor); we use a name where the first letter is
uppercase (as is mandated by the platform), and all subsequent letters
are lowercase separated by underscores (with an exception noted
below):

    Make_any_valid_name = -> x do
      if VALID_NAME_RX =~ "#{ x }"  # ..
    end

the exception is for acronyms. those must be in all uppercase:

    Resolve_event_from_HTTP_respose =  # ...


the justification for the utility of such a convention is as follows: if
we just made such names follow [#here.B] the convention for arbitrary
values or [#here.D] the convention for modules, then these names would carry
less information and the code would be less self-documenting.

the rationale behind the general convention is that this makes the
consts look more like platform-conventional method names (which are all
lowercase with underscores, with a few exceptions). the rational
behind using all caps for acronyms is because to make them all lowercase
is sometimes lossy, and always ugly.




#### the name convention for module names :.D




##### the const name conventions for a non-class module :[#here.5]




##### the const name conventions for a class :.F




## the way scope is reflected in const names



### scope is reflected in const names by trailing underscores :[#here.7]

perhaps the most visually prominent name convention of them all in this
universe, we employ this convention heavily: how many underscores trail
a const name indicates how private the value is:



#### a const with no trailing uderscores is..

.. part of the surrounding node's public API. (for a review of what we
mean by "node" see [#028.6].)

this means that the characters that make up this const's name and the
semantics of what this const references must not change during this
"version" [1][1] of the surrounding node.

as such, during development of a new-ish library we will often find that
we largely avoid naming constants using this classification because of
how quickly things are changing.

also we avoid deep names with many such consts for the same reason
[#xxx].



#### a const with *one* trailing underscore is..

.."visible" to the surrounding node and any nodes below it.

in practice we often see this kind of name employed for a const that
points to a value relied upon by more than one node in the subsystem,
yet that value is not or should not be made pubic outside of the
subsystem.



#### a const with *two* trailing underscores is..

.."visible" only to the surrounding node and/or file that the const is
defined in. this is both the ugliest variant and perhaps most commonly
used.

the reason we see this convention employed so often is that it reflects
and encourages "good" design: [#xxx]



#### a const with *three* trailing underscores..

..has the same characteristis as the criteria for "two" above, but also
that constant is only accessed from one code location.



### why use these scope-related name conventions for consts?

we certainly don't use them because they are pretty. we use them because
it optimizes our code for refactorability: how large the scope is for a
given const directly expressses the cost of changing it. on the one
end, a const with three trailing underscores can be presumed to have a
relatively low cost of change because the instances of it being coupled
to is relatively low (it is only used in one place). on the other end, a
const with zero trailing underscores can be presumed to have a much
greater scope and consequently probably has a much higher cost of
change.

this added dimension to const names can help inform decisions quickly
about how important a node is when we are considering changing its
interface or removing it altogether.




## peripherally related style convention: the OCD of literals in consts :[#here.H]

(this moved here from the sunsetting [m-h])

this counter-cultural habbit sprung out of the OCD compulsion not to allocate
memory for objects that we knew would need never be more than their primitive,
monadic forms. consider: at the time of this writing, the frozen empty array
constant is used in about 40 places. granted, allocating memory for 40 arrays
as opposed to one would have a negligible impact on resources when e.g we run
all of our tests, but our reasoning behind this has evolved:

1) for the same reason we use constants in place of literal values generally,
using constants for these values can give the code a louder voice. consider
the case of throwing the empty proc around. if we are frequently passing this
value to the same function from different places, it may be an indication that
this callack argument should perhaps be made optional, or eliminated all
together.

more than just making the code self-documenting, a pattern like this can
transform the code into a sentient being that expresses original thoughts back
up to us.

2) in the case of a potentially mutable value like an array or string, the
fact that these values are frozen acts as a small assertion that the
participating code is not mutating these values (if that is indeed what we
expect). again this makes to code more expressive (but this time at runtime),
perhaps telling us things we didn't know about our logic.





## references

[1]: http://semver.org
