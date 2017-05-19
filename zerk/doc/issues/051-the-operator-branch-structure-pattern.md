# the operator branch structure pattern :[#051]

## introduction

because of the ubiquity of hashes and their near-univeral familiarity
across different platforms (programming languages), it's useful to
introduce "operator branches" in terms of how they can be seen as
something of a "view" on a hash.

but it's equally essential to understand that hashes actually don't
have anything to do with operator branches, except that a) one particular
operator branch implementation happens to exist that wraps a hash and
b) hashes are useful as a didactic tool here because of their partial
isomorphism with the subject.

there is nowadays a tendency to conceive of everything that seems like
a "collection" (as in the broad category of data structures as described
in wikipedia) as an "operator branch" (this name to be justified below).
the relevant point here is that at its essense an operator branch is a
collection of some sort of "items".

whereas in a hash an item is *added* (or call it "inserted", or call it
"set" (these three ideas are similar but not the same)) using a key (or
say it's "associated" with a key); in an operator branch the terminology
we use is "reference" (as opposed to "key").

  - the item *reference* is (usually) not the *item*




## synopsis of possible exposures  :[#here.2]

one key "thing" about operator branches is that it's not a strict
"interface" per se, but more of a set of method names with well-defined
semantics, acting as a sort of "guideline" for how collections should
be interfaced; for lack of any compelling reason not to. participating
clients are free to cherry-pick whichever methods from this set it makes
sense to; and so

  - it *cannot* be assumed that anything calling itself an operator branch
    responds to any *particular* one of these methods.

  - it *can* be assumed that anything calling itself an operator branch
    implements at least one (and probably a few) of these methods.

here's some of these:

  - `to_loadable_reference_stream`

  - `to_dereferenced_item_stream`

  - `dereference`

  - `lookup_softly`

here's some more specialized possibilites:

  - `has_reference`

experimental suggested names for mutation

[none yet]



## why is it called "operator branch"?

(EDIT)




## beginnings

for driving an argument scan, a popular choice of ours lately is
to use a plain old hash as a logical "branch" structure, with each
of the hash's entry pairs acting as the possible "branch items":

the head of the scanner (or a normal symbol derived from it) is
tossed as a key against the hash. if an entry is found in the hash,
the value of the entry is used (somehow) to drive the next step of
the parse.

(often the values in the hash are method names, but this entirely
the choice of the caller (more at [#here.1] below). compare a more conventional implementation
of such a "control-flow structure" by switch statements (platform:
case expressions) or if-else chains, which could be used similarly.)

to date this pattern has served our needs well and has discovered
broad usage, becoming a near founding principle of the [#052]
argument scanner stack.

a small sliver of strain, however, appeared when we wanted to apply
this useful pattern to cases where the "representational structure"
was "normal", but something other than a hash.

(specifically, we mean filesystem directories and/or autoloaderized
modules. at writing these use-cases are undergoing (EDIT: have undergone) full overhaul to
be corraled into this new moving-target API. implementors are tracked
with [#subject]. even more volatile information than this should be
the manifest entry ("issues.md" file) for this document.)

as such, we now conceptualize the above described hash as a concrete
example of an abstract "structure-pattern" endemic to parsing with
argument scanners. we have tentatively dubbed this structure-pattern
"operator branch".




## first swing at a definition will be via the subject

the objective of the subject, then, is twofold: 1) let a directory
act sort of like one such hash for the purposes of argument-scan-
driven parsing; and (2) approach a formalization of such an
interface so that one day we can have hashes, directories (and
whatever else) be façaded behind adapters so that the argument
scanner stack can be refactored so that it parses not against
hashes but against operator branches.

(we will probably want the ability to aggregate a series of these
nodes into a compound such structure too.)




## `lookup_softly` and `dereference` :[#here.1]

the primary point of this node is to state it explicitly that these two
methods (in their many adaptation manifestations) must result in the same
kind of structure, a "trueish item value". the shape of this object is
totally "mixed" and unknowable to the subject, except to know that it
must be trueish. (agreeing to this formally allows us to implement the
many adaptations of `lookup_softly` without needing to wrap its positive
result.)

the above properties of this result type are more or less restated in [#060.B].

it's worth considering how this contrasts to the familiar methods of
platform `::Hash`: `fetch` and `[]` (the latter sometimes called `aref`
from within code that cannot name methods like this).

  - `lookup_softly` is comparable to `[]`, but we prefer the former
    because it states explicitly (to the extent that it does) what will
    happen when the key is not found.

  - whereas with `fetch` you can achieve the effect of either our
    one method or our other method, we prefer our system because A)
    it makes it more clear in the code the exact semantics of it
    and B) our method name is a custom, dedicated name to a concept
    that we "own".

in fact, as a case study (and also for very pragmatic reasons) see
 #history-A.




## `has_reference`

comparable to platform `Hash#key?`.

the idea is it results in yes/no based solely on whether this reference
(a symbol, probably) is stored in the operator branch (associated with
some loadable trueish business value).

the only reason to expose such a method and not just use `lookup_softly`
is so that the subject instance can save on any necessary work that would
be involved in dereferencing the reference.

the full set of values that results in `true` for this method should be
be equivalent to the set of values produced by `to_loadable_reference_stream`.




## document meta

  - #pending-rename: we sorta want to rename this "operator branch theory" (maybe)

  - #history-A: in this selfsame commit we refactor a problematic method
    name (and indeed whole interface) to make use of the standard interface
    of [#here.1].
