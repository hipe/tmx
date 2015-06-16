# name conventions for constants :[#029]

(this is a ground-up re-write of a document "lost in the [#br-092] fire".)

## synopsis

we use these conventions not because they are pretty (they are not) but
because they pack a lot of self-documentation into a small space.

a const's style exhibits both is "scope" and the kind of object it
references. here is a summary of the N tiers of scope:

    Public_API  # this const assignment is part of your (semver) pub. API

    Library_Scope_  # may be used by this node (file) and any child nodes

    Cozy_Scope__  # (2) this const is used *only* by this file

    One_Off_Scope___  # (3) set in only 1 place, referenced in only 1 other

    Singleton_Scope____   # (4) this const (as string) only exists in 1 place

    Flagged_for_Elimination_____  # (5) referrant is not used. OK to remove


here is an overview of how the "shape" of the referenced object inflects
the name (we will use "cozy" scope becuase it is common):

    Module_eg_Class_in_Contemorary_Style__

    ModuleOrClassInLegacyStyle__

    This_casing_is_reserved_for_proc_likes_eg_actors__

    ANY_OBJECT_TREATED_AS_A_VALUE__




## justification (preview)

these conventions are both ugly and near perfect. there is a case to be
made for an intuitive semantic value in their ugliness: the uglier the
name is (the more trailing underscores it has), the less intended it is
for public consumption. i.e if you don't like the way a name looks it
probably doesn't like you either.

names like these are optimized for refactorability and comprehensivenes
though what they self-document. by seeing a const we immediately know
two things from which we can infer many others:

  1) through its shape we know rougly what it is and how we are
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

  • [#.E] a non-class module,
  • [#.F] a class,
  • [#.C] a proc or proc-like
  • or [#.B] any other value not in the above list.

we will present the conventions here in order from "smallest" to "biggest",
idiomatically:




#### the name convention for arbitrary values not in the list :.B

adopting the C-like convention, we use names in all caps whose
constituent words are separated by underscores:

    VALID_NAME_RX = /\A[A-Z][_A-Za-z0-9]*\z/

the above is an example of a const that holds a regex.

in practice, we will often see our const names containing one or more
[#.G] trailing underscores because of [#xxx] "rounded API's".

that is all.




#### the name conventions for proc-like consts :.C


for a proc when that proc is assigned to a const, or other proc-like
objects (that is, an object that is interfaced with like a proc, like
for e.g a [#cb-042] actor); we use a name where the first letter is
uppercase (as is mandated by the platform), and all subsequent letters
are lowercase separated by underscores (with an exception noted
below):

    Make_any_valid_name = -> x do
      if VALID_NAME_RX =~ "#{ x }"  # ..
    end

the exception is for acronyms. those must be in all uppercase:

    Resolve_event_from_HTTP_respose =  # ...


the justification for the utility of such a convention is as follows: if
we just made such names follow [#.B] the convention for arbitrary
values or [#.D] the convention for modules, then these names would carry
less information and the code would be less self-documenting.

the rationale behind the general convention is that this makes the
consts look more like platform-conventional method names (which are all
lowercase with underscores, with a few exceptions). the rational
behind using all caps for acronyms is because to make them all lowercase
is sometimes lossy, and always ugly.




#### the name convention for module names :.D




##### the const name conventions for a non-class module :.E




##### the const name conventions for a class :.F




## the way scope is reflected in const names



### scope is reflected in const names by trailing underscores :.G

perhaps the most visually prominent name convention of them all in this
universe, we employ this convention heavily: how many underscores trail
a const name indicates how private the value is:



#### a const with no trailing uderscores is..

.. part of the surrounding node's public API. (for a review of what we
mean by "node" see [#028.B].)

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




## peripherally related style convention: the OCD of literals in consts :[#.H]

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
