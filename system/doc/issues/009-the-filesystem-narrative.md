# the filesystem narrative :[#009]


## the given

our host platform (like many) integrates access to the filesystem as a
ubiquitous given: kernel methods abound for opening files. standard
library insturments like "pathname" (which models was it at essence an
immutable string) integrate access to the filesystem throughout.


## the experiment [#.A]

we reject all of the above (or so we say): writing our application and
library code as if there is a single, monolithic and ubiquitous
filesystem bolted to the runtime; this has a couple points of cost to
it:

  • this assumption makes certain kinds of testing almost prohibitivey
    difficult, like that of testing something against a path that has no
    `.git` entry in itself or any of its parent directories, all the way
    up to the root. (to do this naively requires that we make assumptions
    outside of our own filesystem sandbox, assumptions that weigh down
    the portability of our systems.)

  • threading the "bolted-to-it" assumption throughout our library and
    application code may prevent it from integrating smoothly into some
    new and weird environments we may (or may not) want to run in.

by modeling our access of the filesystem as though it is just another
datastore client :[#.A], we diminish the cost of the two points above.
as well, we may reap other architectural benefits too, if we ever
try to swap out the filesystem for another datastore for some particular
"silo".




## :[#.B]

let's assume that the plurality of use-cases for the "filesystem" by
our clients out in the wild is for reading from and/or writing to files.
(it is.) as such, we build access to these facilities from our
sidesystem top in a manner that is both concise and transparent:

    kn = [ss].filesystem( :Upstream_IO ).via_path "/some/path"

to the uninformed, what is happening here is not especially readable.
the method call results in a "knowness" which wraps an IO that is an
open, read-only filehandle on the (presumably existent) file referenced
by the argued path.

the fact that we have used the exact const name for the class that will
be used for this operation is towards our efforts at transparency:
searching universally for where this class is used is trivial.

this comes at a cost of poor implementation hiding; but for now we want
the clients to know that what they are actually doing is building and
executing a [#004] normalization operation. we house these operations
as locally canonical: their constituency is intrinsic to the identity of
their parent node. as such we are not afraid to make their names known.
it's almost a "convention over configuration" principle applied against
the principle of encapsulation.

but to the nub of this section: EEK




## :note-C

every normalization performance that is ever effected must typically be
bound to a filesystem façade. as such we produce them that way, from the
façade, and make this the only way to produce them.

for now there are these two different ways we produce normalizations.
the first way is for getting to a n11n from the "system" façade, the
second is for getting to one from the filesystem façade.
