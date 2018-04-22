# our inelegant `sys.path` hacking

## overview

this is perhaps a design consequence of our [sub projects][sub_projects]
architecture; perhaps not.

the main objective in this document is to describe the _three_ _kinds_
of places we hack `sys.path`, and why we do so in the manner we do so.

it goes into a lot of detail, and so probably stands as a useful
reference for the author only.




## <a name=b></a>what we know about `sys.path`

python resolves `import`s by going along each directory listed in `sys.path`
(in its order). (this is all subject to our understanding, which is subject
to evolve.)

python prepends the dirname of the entrypoint file to `sys.path`, which
has the effect of making the import system "just work" for most cases.

(when we say "entrypoint file" we mean usually the file that starts the
server when relevant. we also use it to mean a test file when a single
test file is being run.)

at writing we do not know ETC but we cannot afford to care.




## <a name='catch-22'></a>what that has to do with us (a synopsis)

our "macro-project" is different than most projects in several regards:

  - we chose _not_ to have entrypoint files live at the very top level
    of our project.

  - our only reference project we looked at (`youtube-dl`) had an issue
    we consider a soft bug in how it hacked `sys.path` for its test files,
    and so we had no good working models to base from (for lack of knowing
    one.)

but more generally, it would be reasonable to ask: why so complicated?

since the overarching goal of our `sys.path` hacking it to make it _one_
_normalized list of paths_ that's consisent throughout all our sub-projects,
it would make sense that you would want to DRY this hacking by certralizing
the code in one file that other files import.

but this presents a catch-22:

without hacking `sys.path`, we cannot from a given entrypoint file
"reach up" to another file (module). (try it.) another way of saying it
is that if you're entrypoint file is not at the top of your [sub-]project,
you're gonna have a bad time.

so what it all amounts to (we think) is that we need one `sys.path` hacking
copy-paste somewhere in every directory for the set of all directories that
contain all our entrypoint files (whew).




## understanding the structure of our project (an interrelated tree of sub-projects)

a typical sub-project consists of three top-level components (directories):

  - a documentation tree
  - a test tree
  - an asset tree

when we say "tree" we mean "directory" ("folder"). when we say "asset" we
mean code that is not test code; that is, the files that hold the code that
constitutes the raison d'être of the sub-project.

as provised by the [provisions][sub_projects] of sub-projects, each "asset
tree" must live at the top of the project directory.

furthermore it would be against conventions of both the python ecosystem
and our own to put the test trees *under* the asset trees. so the asset,
test, and documentation trees all live next to each other:

    our_project/
      sub_project_one/
      sub_project_one_test/
      sub-project-one-doc/


(we use dashes in the name of the doc directory because we can.)

also, the _various_ sub-project's _various_ such directories all live
alongside each other (we'll omit the doc directories now, because they
don't participate.)

as such, here is how the pertinent top-level directories end up relative
to each ther, and relative to the root of the project:

    our_project/
      sub_project_one/
      sub_project_one_test/
      sub_project_two/
      sub_project_two_test/


because (currently) we only ever test these fellows one sub-project at
a time, we'll just focus on one sub-project in our discussion here:

    our_project/
      sub_project/
      sub_project_test/


note that a sub-project's test tree and asset tree live side-by-side
at the top-level of our project directory.

we'll introduce one level of depth below (as directories) and (under
each of these directories, respectively) we'll add one example "asset file"
and one corresponding example "test file". this makes the point that every
test file "isomporphs" structurally with a corresponding asset file:

    our_project/
      sub_project/
        magnetics/
          magnetic_one.py
      sub_project_test/
        test_magnetics/
          test_magnetic_one.py


(throughout this section, there are other name conventions we are not
showing to keep the didactic examples more focused.)

ideally there is one test file for every assset file (for asset files of
a certain set of varieties):

    our_project/

      sub_project/
        models/
          model_foo.py            <----+
        magnetics/                     |----- foo, covered
          magnetic_bar.py         <-------+
                                       |  |
      sub_project_test/                |  |
        test_models/                   |  |--- bar, covered
          test_model_foo.py       <----+  |
        test_magnetics/                   |
          test_magnetic_bar.py    <-------+


we'll populate this example sub-project sub-tree with a few more example
files and annotate them with "types" and explore each type one by one in
the following sections:

    our_project/

      sub_project/
        some_entrypoint.py         # file type A
        models/
          model_one.py
        magnetics/
          magnetic_one.py

      sub_project_test/
        test_models/
          test_model_one.py
        test_magnetics/
          __init__.py              # file type B
          _init.py                 # file type C
          test_magnetic_one.py

        _init.py                   # file type D




## <a name='file-type-A'></a>"file type A": a normal, production, entrypoint file

there is ideally only one "asset entrypoint" per sub-project. it is the file
that ETC. for our purposed ETC are usually servers.

as offered [above](#b), python prepends the dirname of the entrypoint file
to `sys.path`.

here is an idea that is key to what we will do here and in all other places
like it:

  _we want to discourage relative imports_

mainly, we would like that the name you use to reach a module be the same
wherever you are referencing the module in the project.

more generally, we want you to be safe to assume that `sys.path` will be
the same whether you are running in production or in a test [suite].

as such, for places like this we *CLOBBER* the dirname of the entrypoint
file (which is a sub-project directory) *with* the *project* directory.

the reason we need to check for if this operation is already done is (only)
because when we are running our system under tests, these entrypoint files
will (sometimes) *not* be the entrypoint files (test files will be, as
explored below); and this "normalization" of `sys.path` will have been done
already by locations elsewhere as described in the following sections.




## <a name='file-type-B'></a>"file type B": this `__init__.py`

when running the whole test suite, it's necessary that files like this
exist so that python knows that this module (directory as) exists, and
has (probably) python files in it.

👉 however, when any given test file is run individually as a standalone
entrypoint, it cannot reliably import this file. 👈

(if we figure out a way that it _yes could_ do this it might be nice and
it might make this wole thing less inelegant, but at present we don't know
how. our issues might be assuaged when an existing issue near [here][here1]
is resolved in python (near warning generated) but it might not - you can't
reach "above" "the module" in such an import when an individual test file
is the entrypoint.)

as such, this file _must_ exist but _must_ contain nothing. ich muss sein.




## <a name='file-type-C'></a>"file type C": a "low" `_init.py` file

this "file type C" basically does what we wanted "file type B" to do but
couldn't for the reasons described there.

it is a single file meant to be imported by (typically) each of its
*sibling* test files, _sort of_. (in fact we will exploit a hack that
we describe [below](#x) that puts a finer point on this idea.)

as a corollary of the [this one python provision](#b), sadly this file
(more accurately, the pertinent logic) needs to be more-or-less copy-pasted
as-is to every such directory. (at writing there's two in this sub-project.)

  - were there a need for test-directory-specific resources (something
    that is almost guaranteed to happen), they would go here BUT this will
    present a challenge in light of [this same hack](#x). but this is a
    bridge we wil burn when we come to it.

at the end of this file (and when appropriate for requirements) we do the
hack where we replace the module in its entirety with an arbitrary object.
(but again this presents a bridge we may have ot one day burn.)




## <a name='file-type-D'></a>a "high" `_init.py` file

<a name='x'></a>
this file (in how it is expected to be loaded) reveals perhaps the most
glaring sore thumb that makes this feel like a workaround:

  - when we run the test suite for a sub-project, we do a thing like:

        python -m unittest discover my_sub_project_test

  - each participating directory under that path will need to
    "look like" a python directory as described [above](#file-type-B).

  - the _very first_ python file to be evaluated will be one of these
    `__init__.py` files. (but it would be folly to assume you know which
    file. like, it will depend.)

  - before the `sys.path` is hacked, the test runner will then load some
    arbitrary one of your test files.  *when that first test file imports*
    `_init` as they all should do, at the time of this import `sys.path`
    is not hacked yet. in fact it is hacked by the test runner. in fact
    the test runner has put the `my_sub_project_test` (equivlent) at the
    front of the `sys.path`

  - *SO*: when we `import _init` at the top of our test files (and we
    are running the whole test suite), whichever test file happens to
    run first will *not* load the `_init.py` that sits next to it but
    the one in `my_sub_project_test`!

  - *that* file then hacks the path so our _sub-project_ path is at the
    front of the list, but then _keeps_ the `my_sub_project_test` dir
    in the list so that subsequent imports of this module (from other
    files) will, um, also resolve to this higher file.


this gave us an idea..
(EDIT: now i have no idea what the idea was)




### <a name='why-this-in-the-second-position'></a>code note

now, the project dir is at the front like it always is, and we have
moved the test sub dir from head to the second position so when other
test files require this file, it's still in the `sys.path`.




[sub_projects]: ../README.md#sub-projects
[here1]: https://docs.python.org/3/tutorial/modules.html#intra-package-references




## (document-meta)

  - #born.
