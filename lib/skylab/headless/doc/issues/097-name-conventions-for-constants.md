# name conventions for constants :[#097]

(this is a ground-up re-write of a document "lost in the [#084] fire".)

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


### the way shape is reflected in a const name :[#102]

the name we choose will assume different "inflection" based on whether,
variously, it references [#166] a non-class module, [#167] a class,
[#101] a proc or proc-like, or [#114] any other value not in that list.
we will present the conventions here in order from "smallest" to "biggest",
idiomatically:




#### the name convention for arbitrary values not in the list :[#114]

adopting the C-like convention, we use names in all caps whose
constituent words are separated by underscores:

    VALID_NAME_RX = /\A[A-Z][_A-Za-z0-9]*\z/

the above is an example of a const that holds a regex.

in practice, we will often see our const names containing one or more
[#079] trailing underscores because of [[#165]] "rounded API's".

that is all.




#### the name conventions for proc-like consts :[#101]


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
we just made such names follow [#114] the convention for arbitrary
values or [#098] the convention for modules, then these names would carry
less information and the code would be less self-documenting.

the rationale behind the general convention is that this makes the
consts look more like platform-conventional method names (which are all
lowercase with underscores, with a few exceptions). the rational
behind using all caps for acronyms is because to make them all lowercase
is sometimes lossy, and always ugly.




#### the name convention for module names :[#098]




##### the const name conventions for a non-class module :[#166]




##### the const name conventions for a class :[#167]




## the way scope is reflected in const names



### scope is reflected in const names by trailing underscores :[#079]

perhaps the most visually prominent name convention of them all in this
universe, we employ this convention heavily: how many underscores trail
a const name indicates how private the value is:



#### a const with no trailing uderscores is..

.. part of the surrounding node's public API. (for a review of what we
mean by "node" see [#094].)

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




## references

[1]: http://semver.org
