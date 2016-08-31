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



## assumptions

  - we are going to assume that the test files (if any, for this
    request) all live in a single test directory.

  - we are going to assume that the test file tree has a structure that
    mirrors the asset file tree (to the extent that we will describe below).




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
