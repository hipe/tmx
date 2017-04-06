# the filesystem narrative :[#009]

## the given

our host platform (like many) integrates access to the filesystem as a
ubiquitous given: kernel methods abound for opening files. standard
library insturments like "pathname" (which models what is at essence an
immutable string) integrate access to the filesystem throughout.




## the experiment [#here.A]

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
datastore client :[#here.A], we diminish the cost of the two points above.
as well, we may reap other architectural benefits too, if we ever
try to swap out the filesystem for another datastore for some particular
"silo".




##  :[#here.B]

xx

(under #tombstone-A we explain the old way.)




## :[#here.C]

xx

(under #tombstone-A we explain the old way.)




## document-meta

  - #tombstone-A: we used to require that every normalization be constructed
    with a filesystem façade. no longer do we employ this idiom.
    as such two sections were removed with this change.
