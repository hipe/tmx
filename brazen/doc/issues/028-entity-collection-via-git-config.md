# entity collection via git config :[#028]

## in context

the subject library is a bit of a solution in search of a problem; but
it's one we feel strongly about maintaining.

it's worth explaining how it arrived at its current form:

at one point we used the facilities behind the subject library to store
and retrieve an entity that consisted of a single, "primitive" value. we
have since decided that's it's overkill to use an entity model when our
requirements are limited to the storage and retrieval of primitive values
(strings, specifically filesystem paths).

however, the vacuum left behind was a conspicuous one: as we would come
to see it, the "problem" of using a config-file based store *as* as
entity store is one that is both interesting and easily solveable.

despite the fact that we apparently no longer had an immediate need for
such a "sophisticated" layer on top of of our plain old config file
API (recently overhauled to be perfect), if we nevertheless persisted
it would have this value:

  - working with parsing config files is easy and fun

  - a full CRUD-like facility on top of the store layer bolsters
    the general robustity of the adapter

  - having an exemplary CRUD solution can act as a guide
    (an "acceptance gamut") for other CRUD adaptations

  - having the above be based on a store that we control and that
    is easy to add features to and modify increases its value.

as such, this amounts to an intentional #feature-island.




## table of contents

  - [#here.B]: about our "external" vs. "internal" names
  - [#here.3]: meditations on file locking





## a universal normal name convention :[#here.B]

the git config syntax specifies that variable names cannot contain
underscores (but dashes are OK). however everyplace else we usually
follow the opposite for "normal names" ("normal names" have underscores,
the things with dashes we call "slugs"). (but yes, we like the look of
"slugs" better so we are glad git adopted this as the standard).

hence we are left with conversion work to do: going into and coming out
of the collection we need to convert dashes to underscores in field
names. furthermore we haven't yet said anything about all the other kinds
of characters, like numbers, mixed case names and others.

as it stands this is work left for the client to do; the collection
merely borks with a message when invalid names are passed. and this is
halfway to the way it should be: if the collection makes decisions about
how to convert invalid names to valid ones, information may be lost,
which is tautologically the wrong way for a collection to behave:

    `foo-bar_baz`   ->   `foo-bar-baz`    ->   `foo_bar_baz`

   contrived name        collection name        incorrect guess


a better way might be to agree in one place universally on a set of
rules dicating "univerally normal names": it would be a super distilled,
lowest-common-denominator standard, something like:

    /\A[a-z][a-z0-9]*(?:_[a-z0-9]+)*\z/

that is: alphanumeric, all lowercase, underscores only used as
separators (so no leading or trailing underscores and no underscores
occuring in multiples adjacently).

(we *might* allow case-sensitive capitalization to sneak in, which we
might then shoehorn into this term of `variegated_symbol` that
we've been using.)

if both the business layer and the collection know that this is the
standard, *and* the character classes variously that the standard speaks
of either *are* or *are not* allowed in the collection and in the cases
where they are *not* there are other characters available to substitute;
characters not included in the standard (whew), THEN it might be that
the collection can do the name conversions, rather than the business
layer having to worry about it, which would be optimal.




## a meditation on file-locking (introduction to the problem) :[#here.3]

the idea of programming for concurrency is a bit outside of the auspices
of our current platform, but that is not to say it is a problem we want
to (or should) sidestep completely.

more specifically, if it were the case that we had an architecture where
many instances of a "microservice" of ours were running concurrently while
sharing one filesystem (a setup that is not unimaginable), we would want
to be able to say that we tried, at least, to address the underlying problem
there.

more interestingly, this is a tiny glimmer of a shadow of the broader
problem that challenges larger datastore solutions, relational and
"no-SQL" alike: that of concurrency, replication, eventual consistency, etc.

rather than come from the outside in (taking in the heavy galaxy of work
that has been done there and then trying to apply it to our toy stack
here); we will come from the inside out; and start with our few easy pieces
and come up with a solution for them in a vacuum, and then later compare
notes with what the grownups do in said galaxy.




## explanation by way of example of the problem.

the classic example is something like this:

  1. instance A reads the whole "config file" from the filesystem, and turns
     it into a "document"; i.e a data structure floating in memory.

  1. instance A makes a change to the document (but has not yet written
     this change back to the filesystem).

  1. instance B reads the same file from the filesystem, again parsing it
     and producing the exact same (but different instance of) the structure
     that instance A had in step 1.

  1. instance A writes its changed document back to the filesystem.

  1. instance B writes *its* changed document back to the filesystem,
     clobbering the work that instance A did.




## simple, "shotgun" approach to a solution for the problem

always lock the file (whether reading or read/writing). this solution
presents scaling problems but it ensures consistency. if you really wanted
to scale you would probably want to explore the more robust options.
