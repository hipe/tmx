# the find narrative :[#016]

## introduction

this is one of the oldest system utility wrappers in our universe, going
back 3.5 years before the birth of this document.

in its current incarnation it is (or will soon) represent a unification
of three separate nodes that were ground-up rewrites of this same kind
of thing. as we write this we are undertaking yet another rewrite (and
then another renovation).




## requirements for this latest edition


### Portability requirements (currently a wishlist item)

- At #history-B.1 we changed development platform from OS X to Ubuntu.
  This led to a change in the version of `find` from a (maybe) BSD version
  to a GNU version, which meant a change in available features and syntax
  and this broke everything.
  See the corresponding code comments created in this commit and infer
  the scope creep we could expand to.


### interface requirements

• make find commands be built with iambic args of course, like
    everything else is nowadays

• where it makes sense to and it is a good semantic fit, chose argument
    names that are the the same as (or are regular transformations of)
    names of options available in ack (or find (or grep)).

• keep easy easy - the find should be able to be as easy as using ruby's
    `Dir.glob` method, somehow ..


### implementation requirements

• immutability - in keeping with our pattern for normalizations, the
    agent will be immutable. "edits" to it will be implemented as
    (presumably duped) copies of whatever original you started with.
    (one day [#bs-018] will explain why we like immutability,
     and below will explain more specifically).

• separation of representation from execution - because today we like
    scanners but we expect that perhaps that might change, we should
    compartmentalize how we respresent the find command from how it
    is (within the system) executed.

• we used to and no longer represent or deliver the command as a string.
    we now represent and deliver it as an array of tokens. this frees us
    from the burden of escaping (e.g through `Shellwords.shellescape`),
    ** provided that the user passes the array of tokens as a list of
    args to e.g `Open3.popen3` **.
    this is a major point of concern for :+#security. this was tested
    only by finding a file whose filename had a space in it.





## "amazing hax" (now #[#sl-106]) :[#here.B]

so this is a fun weird experimental pattern: we don't want the command
object itself to have to worry about the logical mechanics of building
its command string, mainly because in this endeavor it's both convenient
an good design to use ad-hoc ivars just for this, as well as lots of
short single-purpose methods to this end, and..

.. we don't want those ivars nor those methods hanging around,
cluttering our ivarspace and methodspace, and muddling the design and
intent of our command object. our command object (let's just say) should
be interacted with as an immutable data structure that acts as a "portal"
to related services like these; but it itself is decidedly (by design) *not*
concerned with rendering the command string itself.

ordinarily, we see this as the kind of thing for a dedicated actor to
do. this kind of thing is pretty much how we refined the now ubiquitous
actor in this universe.

but in this case we do it somewhat differently .. (this is something we
tried before somewhere once like a year or so ago). it just so happens
that for this task, in our would-be actor we want just about every ivar
that we have on hand in the command object, and none that we don't, so it's
just too compelling not to try this silliness:

for all these reasons stated above we do it this way: we make a dup of the
command that is left as mutable i.e not frozen. with this dup we *prepend*
onto its singleton class a module with all the methods we want to use to
build the command string. it is as if we have changed the class of the
object, just to do this one ad-hoc task. (EDIT: just extend)

when this would-be actor is finished it produces its result. that result
in internalized into an ivar in the command object and it is frozen.
crazy fun.


## (document-meta)

- #history-B.1: target Ubuntu not OS X
