# the recursion algorithm :[#005]

## design factors (objectives/givens)

we'll try to make this exactly as complicated as it needs to be.

we are given one directory path that points to a resource that may or may
not exist and if it exists it may not be a directory. (this just in: we
want to accomodate it if it is an asset file as well as directory.)

we'll have a handle on a filesystem. we'll have access to the `find` service.

we'll maintain a "name conventions" structure that will be very similar
to that of [#ts-014] the file-coverage paraphernalia of the same name.
this encapsulates all the details of what name conventions the users are
employing in their project so that we keep hard-coded name convention
assumptions out of the subject code. whether this comes from for example
configuration files or environment variables or user interface elements
is outside of this scope.

(this "name conventions" participant is discussed further at #note-N below.)



## assumptions

  - we are going to assume that the test files (if any, for this
    request) all live in a single test directory (but they can be
    in a deep tree under this node).

  - we are going to assume that the test file tree has a structure that
    mirrors the asset file tree (to the extent that we will describe below).




## participants in the pipeline

### name conventions :#note-2

this is a repurposing of a same-named node in [ts]. it has diverged
from there (outside and in) so much that probably they are permananty
separate now (but maybe the subject could fold back into there one day).

the subject's purpose is to encapsulate those functions and elements
that relate to "filename patterns" and "stemming" in the following chain
of steps:

earlier in the pipeline, what we're calling "filename patterns" (e.g
`*_test.rb`) are given as arguments to dedicated subsystems that use
`find` and `grep` to find test and asset files variously.

then later in the pipeline, we (probably) re-represent one of these
lists as a tree (the "against" list), and with the other list (the
"given" list), for each path in that list we look for a corresponding
"counterpart" file in the "against" list using a techinque called
"stemming": we derive (and cache as appropriate) a "stem" string for
every element of every path being searched for or searched against.
the "stem" is the path element stripped of name-conventional decorating
so that only its semantic core remains; for example the asset directory
"foo-bizzle-", the asset file "foo-bizzle--.rb" and the test file
`08-foo-bizzle_test.rb` all have the same stem, "foo-bizzle".

how path elements are "stemmed" depends on what kind of element they
are across directory/file and asset/test (so there's four permutations
there). we distinguish these classifications in part because a
"morpheme" that might be part of a name convention for a path element
in one sub-tree (for example `_test` in a test file) might be a
legitimate part of the element's name in another (a file that houses
a node whose name is, say, `SystemCompatibilityTest`, i.e is not a
test file but an asset file).

some of this is configurble and some is hard-coded. we can expose
more API to convert the other to the one as needed.




## waypoints in the pipeline

(interesting note, we wrote and rewrote several *pages* (screens) of
algorithm text multiple times and erased it all as we re-shuffled the
order around towards what was actually a good narrative order v.s what
we at first thought seemed right. as always, the details don't become
evident until you reach them by building other details, and so on.)




### find the test directory

given: the argument path

we effect these assumptions about the test directory:

  - the test directory *is* the first directory found that "matches"
    the pattern for test directory, according to the "name conventions".
    (the implementation of this matching is entirely the domain of same.
    it may be that we will pass it only an "entry" and not a full path.)

  - the test directory may live exactly one level *under* the argument
    path. so argument path is `/foo/bar`, test dir can be `/foo/bar/tests`.

  - if it is not found in the above location, it *must* be found by
    walking upwards from the argument path to the root of the
    filesystem, such that each parent dir will be checked if one of
    its *immedate children* has the test directory. (this is as many
    filesystem hits as there are elements in the argument path, give
    or take.)

  - (what we just described above is exactly [#sy-176], but we may
    rewrite it for the usual reasons.)

  - it may be the case that the test directory is empty; (that is, we
    still have to be able to find it in these cases.) so we can't cheat
    and piggy-back on the `find` commmand for asset/test files, which
    we can't do anyway given what we said above, that the find directory
    can live outside the argument path's tree.

if the test directory is not found by the above means, we don't know
what to do and we are done. (but note it might one day become a given.
magnets!)




### find the counterpart directory

givens: the argument path, the test directory

this is probably the most fun part. this is *exactly* like what happens
in [#ts-012] "file coverage", but we are re-writing it here because that
guy's code is just a tiny bit too customized towards its own use case A),
and B) it makes some implementation choices that we probably wouldn't
make now so C) we can probably do better here and fold it back in there later.

now, we know where the test directory is and we know where one more
asset files are (and because we aren't sure whether we do or don't have
any test files, let's assume we don't). what we are going to attempt
next requires that we find the "counterpart directory" in the "whole" asset
tree that corresponds to the root pointed to by the test directory.
confused yet? yeah it's confusing. let's say we have a ruby gem called
"frobber". it is provided by a company called "skycorp", and they work
this name into the name of the gem, so the constant is

    Skycorp::Frobber

and the gem's "name" (like on github or wherever) is

    "skycorp-frobber"

and you require these resources by

    require 'skycorp/frobber'

but that's not important. what's important is the gem dir's structure.
at this current (fleeting) moment in time, here is the typical structure
we follow for our gems:

    some-directory-whatever
      ├ lib
      |  └ skycorp
      |     ├ frobber.rb
      |     └ frobber
      |        ├ magnetics-
      |        |  ├ fibble-via-dabble.rb
      |        |  └ dabble-via-dooper.rb
      |        ├ api.rb
      |        └ cli.rb
      └ test
         ├ 03-magnetics
         |  └ 07-dabble-via-dopper_spec.rb
         ├ 04-cli_spec.rb
         └ 05-cli_spec.rb

the main points are:

  - the name directory that holds the gem (during development)
    isn't important. (and it might sit arbitrary deeply in the
    filesystem.)

  - every (of our) gem(s) has at its root a `lib/` directory and a
    `test/` directory. (other nodes it may have here aren't important.)

  - the `lib/` directory will have as many nested single directories
    as is necessary according to the name of the main resource in the
    gem. so if it is a gem for `Foo::Bar::Bazzle`, there will be a
    lone directory `foo` under `lib`, and a lone directory `bar` under
    `foo`, and then the interesting assets in `bar` (almost always
    a `bazzle.rb` and a `bazzle/`).

  - the `test/` directory isn't an exact mirror image of `lib/`, it
    is a somewhat mirror image of `lib/skycorp/frobber`.

  - we utilize leading numbers in test nodes for reasons we won't
    explain here.

  - we utilize trailing dashes in asset node names for reasons that
    are likewise important but of no consequence here except that
    we utilize this pattern.


so back to our target instances: given any argument path that points
to a directory of the asset tree (so `lib` or `lib/skycorp` or
`lib/skycorp/frobber` or `lib/skycorp/frobber/magnetics-`), we've
got to figure out that `lib/skycorp/frobber` is the counterpart
directory to the test directory. for now, we will do this with
this sub-algorithm:

  - find the directory that is the common parent directory to
    both the test directory and the argument path. (given this whole
    document so far above, this must be the dirname of the test
    directory, right?) note we need not touch the filesystem for this.

  - produce the relative path from this common path to the argument
    directory. (you're not supposed to but you can do this with string
    math).

  - if that path "starts with" (in the way that we mean) `lib`, then
    OK, otherwise we don't know what to do and we are done.

  - find the "counterpart directory" this way:
    from the current directory (`lib` to start), get a listing of its
    entries (i.e do a directory listing). (we use `glob` instead of
    `Dir#entries` partly so we don't have to much with '.' and '..').
    (each of these is of course a separate filesystem hit.)

      - if there are zero entries then we don't know what to do
        and we are done.

      - if there is one entry, (see "when there is one entry" in code)

      - otherwise (and there are multiple entries), result is in the
        next bullet:

    we check the assumption that there is a directory `foo_bizzle` and a
    corresponding entrypoint file `foo_bizzle.rb` right next to it. if
    there is not then we don't know what to do and we are done. if there
    is then the `foo_bizzle` directory is our counterpart directory and we
    have found our target instance.



### build the counterpart test index

given:
  - the test directory
  - the name conventions

what we are leading up to is that we want to for each participating
asset file be able to say "here, this existing test file is the test
file" or say, "here, let's create a new test file and put it here."

but we're a few steps a way from that.

with the test directory and name conventions we can produce the stream
of paths of all test files under the test directory.

  - the name conventions has to be able to express the patterns for test
    files in a way that a [#sy-016] `find` command will understand. the test
    paths (at this pass) are simply the *zero* or more paths that are found
    by this means; so if you don't find any that's OK.

making trees from streams of paths is trivial thanks to work we've done
in [ba], but not so fast:

  - for the stream of tests (*and* stream of assets later), we will
    normalize these paths to their respective "edges of the world" -
    the test paths will be relativized to the test dir and the assets
    to the *counterpart* dir (not the argument dir).

we will make a tree of "nodes". this "node" is a custom, ad-hoc
(probably) class that is only useful to this application. but think of
the tree as a multidimentional hash. each node will have multiple
entries in it - the "entry" will correspond exactly to a filesystem
entry (file or directory). for now, we'll call this the "test index"
but it could just as soon be an asset index (for reverse
synchronization!). anyway, **each node has one "normal index" (symbol)**
that it exists under in its parent.

(we could do this a different way, where we put the "edge of the
world"-shortened paths into a tree as-is, without keyifiing their names
and then somehow going from there but this here feels easier to
comprehend.)

(currently since we're only modeling this for one-way (for sanity),
that's it. we're done.)




### produce the probably participating file stream

given
  - the argument path
  - the counterpart path (a parent dir of or the same dir as arg path)

this sub-algorithm has two steps: 1) asset file stream via a find command
and then 2) a participating file stream via asset file stream and some
plain old programming. for step (1),

with the counterpart path or the argument path, whichever is longer (deeper)

  - the asset paths *that we resolve* are those under this path
    according to patterns in the name conventions (similar to how we find
    the test paths in a previous section). however, because we require at
    least one asset path, if we don't find that here, we don't know
    what to do and we are done. (eek but that index tho.)

for each path in this stream of asset paths, we want to reduce it to a
stream of *possibly participating* files. since we can make this guess
with grep, we'll probably just go ahead and do that.




### unit of work stream

given:
  - probably participating file stream
  - the counterpart path
  - the counterpart test index
  - name conventions

so that we can operate in `--list` (or whatever) mode without having
to do the heavy lift, we're going to do all of this *first* without
opening the files. that is, to produce the unit of work stream does not
require peeking (beyond what happened with `grep`), but may produce units
of work that become no-ops when they are processed.

for each path in the probably participating file stream, normalize it
to its edge of the world (the counterpart path), and using the name
conventions, pass a stream of normal entries to the test index to see
if there is a corresponding test. **if not**, memo this fact and infer
a best-guess name using the last found directory and names that are
inferred along the terms you can probably guess!!!

with a unit of work stream, the rest of this should be almost trivial,
because the units of work should be desiged to resemble the arguments
that the core operation (function) takes.

WHEW!




## `find` and `grep` - why (and at what cost)?

the general implementation plan here is that we acquire a list of files
from `find` and then pass them to `grep` to reduce this list of files
to be only those files that *look like* they are "participating".

we say "look like" because at this stage in the pipeline we are only
making a guess based on file content - we can't be sure that the file
is "participating" unless we use a tall stack of ruby to parse it.

if `grep` is available on the system and we talk that particalar
installation of grep correctly, we can use it to pare down the files
that we look at for consideration as being "participating" files.
this requires a much smaller swath of code and is a more reasonable use
of system resources at this stage, rather than opening every single asset
file under the argument path and trying to parse it with a bunch of
ruby. (typically tens, hundreds or thousands of files; and only a small
percentage that are particating; but these numbers are of course fully
dependent on use-case.)

(what do to when `grep` is not available or compatible on the particular
system is a real issue, but it's a bridge we haven't yet crossed because
we find the problem uninteresting. we can regress to the ineffcient
way as necessary in the future.)

(what to do about `find` not being available or incompatible is a somewhat
more challenging problem. basically we should just consider compatible
forms of these two as being requirements..)

one cost to using grep in this manner is this: when we simply search for
any first occurrence of the magic byte sequence in each asset file, this
can certainly produce false positives because *any* asset file that contains
the magic byte sequence will look like a match. we can't be sure that a
given asset file is actually "participating" unless we parse it with the
tall stack of ruby. however since in practice the accuracy rate of this
guess is probably something like 98% or more, it's a purchase we're happy
to make.

but a corollary of this cost is that our "units of work" (or maybe just
our "probably participating files", depending on how we implement the
"UoW" streamer) might contain these false positives. consumers of such
streams must be aware of this, and hop over these cases as appropriate
so we can take advantage of this happy purchase.




## `find` and `grep` - why chunking?

in short, its because of input buffer limits in shells (or the system
or whatever). we are walking along a spectrum:

in one extreme we open up a new process for running the grep command
on *every* asset file produced by `find`, which throws out the window
all efficiency gains of using these two entirely.

on the other end of the spectrum, we cram all hundreds and hundreds
(or whatever) of files as resulted by `find` into the `grep` command.
*this* approach will fail at some limit, which is A) system dependant
and B) certainly reachable: it's not unreasonable to expect us to point
a recursive listing operation on a tree with thousands of asset files.
if each path to these files one hundred-ish bytes, then the string-form
of our super-long `grep` command is in the ballbark of 100 kilobytes.

the point is that expecting to hit all the files resulted by `find` with
one `grep` command is not a scalable assumption. as such we "chunk"
this pipeline by breaking the `find` stream of paths into chunks of
paths each of which we pass into grep in its own process.

A) although we accomplish this only crudely with a hard-coded limit
(see #note-1 below), the general idea is there, and a scale-path is
availble to perhaps make smart-chunking that perhaps calculates a
real byte-length for the grep command as it is being built; but yeah, eew.

B) more interestingly, chunking opens the door to an architecture that
would solve this problem with concurrency. we won't explore that idea
further here, other than to just say "go routines".


### :#note-1

currently the ultra-crude way we do "chunking" is to use a hard-coded
chunk size. (although we say this is crude, for realistic use-cases it's
likely to never hit the system command input buffer size limit and
to probably yield a reasonably small number of chunks for typical usage.)

the way we arrived at this particular number was to say "how many asset
files are there in the subject sidesystem (at writing)?"

    find . -name test -prune -o -name '*.rb' -print | wc -l  # => 51

and then add 15% to it (to allow a little room to grow):

    51 * ( 1.15 )  # => 58.65

and then divide by two (and round up):

    ( 58.65 / 2 ).ceil  # => 30

the idea here is that when we run the subject operation against the selfsame
sidesystem, we are likely to chunk exactly once. this is what we want,
so that we exercise the chunking code (real-use coverage?), but so that
we do not chunk so many times that performance is choppy. whew!
