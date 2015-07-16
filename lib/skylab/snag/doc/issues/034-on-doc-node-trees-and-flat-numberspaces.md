# on doc node trees and flat numberspaces :[#034]

(this "essay" evolved from a commit message (ha), explaining a commit where
we were flattening a deep doc-node tree, in a certain way. the commit in
question will also be the first commit in the history of the file that
this essay first resided in, that is, "this file".)



# why this change


## the (new) document hierarchy "system" was already showing strain

the document hierarchy as we had been doing it was fun, and was an attempt at
doing something resembling "scaling", but the system that it had become **as
it pertains to the referencing system** was whack, because we knew we were
going to restructure the hierarchy - restructuring the document hierarchy
should not require changes to code that references those doc-nodes.

for example, we actually had a doc-point reference that looked like this:
"[#ss-api-api-ss-003]". if you know what the initials stand for (and they
are each local to that node they are in) then you might be able to induce
that it reads: "face / API / API API / facets / issue 003". "what's wrong
with that?" you might ask. well for one thing:


### the qualified names are too damn verbose

those issues references are getting verbose (which is not necessarily bad,
because it is semantic (but we see that scaling along one access introduces
scaling issues along another axis - it's like how ipv6 addresses are longer
than ipv4 ones or whatever. there is some practical upper limit to the
reasonable length of any name for a given purpose in in a given system)).

and for twosies,


### qualified names are not scalable along another axis

another issue with that (long) name: there is a chance that we will one day
merge the `entity` node and the `API action` nodes of the doc (and system)
somehow. do we really want to go through and change all the references in the
code? all the time, it is changesets that we are writing - we want an optimal
signal-to-noise ratio there; and commits with lots of officious changes like
this are noise. also time consuming, if for no other reason than that it
compels us write commit messages like this one.

(already this above issue will be a thing / has been a thing whenever we have
to deal with merging or diverging subproducts (because by (almost necessary)
design each subproduct has its own numberspace) but meh: we don't want to do
it more than we "have" to.)

**AND** from an information theory (or whatever) standpoint, this is an
interesting cut-off point between the broader thing (nested namespaces are
necessary for scaling) and the more immediate thing (nested names are annoying
/ inflexible).

(some fun alternate names for this section:
   ### if names were actually identity, they would have to be longer
   ### the map is not the territory
etc.)


# but some nesting lives on..

experimentally we will still keep a structured "physical" hierarchy (albeit a
less deep one) for ease of editing and reading the docs "raw" as we do now.

that is, where we used to have a file like:

  "doc/issues/005-foo/issues/002-bar/issues/002-baz.md"

we now will (experimentally) try:

  "doc/issues/005-foo/006-bar/007-baz.md"

three things to note here:

1) we have dropped the intermediate and recursive 'issues' folders because
we are flattening the numberspace (following the structure set out
by the planned "file format" of subproduct `snag`)

2) note that now that the numbers draw from the same numberspace, they always
get bigger with time, and no longer reset to '1' when we drop down a level.
actually scratch that explanation: it is i.e that the filesystem hierarchy
is a semantic, taxonomic, semi-cosmetic thing. `snag` will be able to induce
the structure from the #parent tag, and then will look for the files in the
appropriate places.

3) now that we are back to a flat numberspace, we can again refer simply
to e.g [#ss-123] and not need to say [#sp-foo-bar-baz], which is neither good
nor bad in itself. (also the space therebetween on this spectrum of good
and bad sort of became the unintended focus of this whole dalliance.)

## some corolaries and auxiliary lessons ..

one broad realization is that your logical tree structure (as opposed to
physical one) should *not* come purely in an isomorphic manner from the
filesystem and numbered files etc. given how labor-intensive (reasonably) it
is to restructure trees to this degree while keeping the object history of
their each leaf node versioned, it will be easier and is better design to
have our tree structure emerge from index files etc.

to state this from a different angle: certainly it is bad design to have your
rendered tree be determined by the order in which your filesystem presents
files in. le duh.

(and yes, this whole point is at odds with "some nesting lives on" above,
but that might be opt-in and not relevant, depending on how flexibly we end
up writing `snag`.)

the only forseen disadvantage to this "new way" is that because under any
given subproduct the numberspace has now been flattened, we will "run out"
of numbers more quickly. we'll wait and see what that feels like when it
actually approaches.

on the plus side almost every recourse we have for that is at this point
almost uncomfortably over-documented.

~
