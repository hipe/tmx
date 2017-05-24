# README for development :[#007]

## objective & scope

this document is meant to be *short* and to serve as both a crashcourse
in our "architecture" and a roadmap overview of same.




## content

  - the architecture is architected around (legacy) [br] which it is
    straining from somewhat.

  - rather than being a toolkit for applying map-reduce operations to
    entity collections, currently this seems larely concerned with
    filesystem marshaling and unmarshaling.

  - we should move the three kinds of "functions" to perhaps a dedicted
    toplevel branch node `FunctionClasses_`

  - we kind of want to rename `Items__` to `Subclasses`, even though
    the latter name is not accurate in the platform sense.




## smalls (in semi-narrative order)  :[#here.D]

### about mutating filetrees in tests :[#here.D.1]

when during the course of a test case we will need to mutate one or more
files on the filesystem, know the following:

  - it is local (and probably universal) custom (strict rule, event)
    that this file or files will all be in the sandbox tmpdir (probably
    using [#sy-020]). (as it works out, the path that the system provides
    to us appears to be consistent, not only within one platform runtime but
    even across runtimes (e.g it appears to be the same path from one test
    suite invocation to the next); but this detail must certainly not be
    relied upon!)

  - it is local custom (global custom not so much) that the participating
    fixture filesystem tree in its initial state will be set up via a
    single patchfile (being applied with the plain old unix `patch` utility,
    probably, but this is pursuant to [#sy-023.2] our "patch" facility).
    usually this filesystem tree is just one directory with one file.

whether this last provision above is more or less performant than using the
filesystem to do a recursive copy of a "prototype" filesystem tree is an
open question, however:

this approach has the advantage of representating the filesystem tree
as readable data (the lines of the patchfile) that can be manipulated
somewhat more forgivingly than the nodes of a filesystem tree. (for
example, if we change the API name of a special directory, with our
approach this manifests as a change to a single line in the patchfile,
rather than a rename effecting perhaps many files.)



### :[#here.D.2]

this point is all of A) a historical note about how we used to do things
B) a qualification for a particular item in a tombstone and C) a general
description of how we do things now.

when the association models a singleton (formerly "slotular")
component (as "upstream" and most others are), it used to be that
we would allow multiple sections to match and then we would combine
them together.

now we see this as an overly active stunt - a file that has multiple
sections for a singleton association is invalid; and it should not
be up to us to decide how to fix it. to merge all the assignments
into one section as we used to do is weird; akin to combining pages
from different books into one book.

local custom holds that when a workspace will be mutated during
the course of a test, we create it by patching it; and when not
we simply use a fixture directory in place (risky). as such, since
the fixture directory of this test went from being mutated to not
mutated, what used to be created by a patch has become a fixture
directory and we have put the old patch file under the tombstone that
is referenced on the same line as the referent code line. whew!



### :[#here.D.3]

near the referent code line we create a seemingly useless file
("shamonay.file"). here we explain exactly why we create it in this way
so that perhaps we can improve this test and any tests like it.

because of what validation does and doesn't occur during our object
unmarshaling for upstreams, it must be the case that this file A)
exists and B) looks like it has text in it.

firstly, as mentioned in [#here.D.1] above we "must" make this fixture
tree using a patch file (because a part of it will be mutated).

now, since this file is never opened (except for the aforementioned
validation) we would rather use one of our universal fixture files
for this purpose, rather than go thru the trouble (read: overhead)
of creating this file thru the act of patching it. but here's the rub:

file paths like this (survey "assets") must be specified either with
an absolute path or a relative path. we certainly cannot put absolute
paths in our patch file. (because, to state it explicitly, we cannot
assume that our installation (i.e development) directory is any one
particular path.) however, neither can we reach any of our other fixture
files in our sidesystem thru a relative path: this tree is built (patched)
into the sandboxed tmpdir; and we cannot assume that *that* is any one
particular path either.

as such, the easiest workaround for these constraints is just to
create the requisite files in the patch, which is the only portable
way we can actually refer to any existent assets from such a survey.

(we have also considered writing the lines of the config file
programmatically and using a template but YUCK!)

whew!
