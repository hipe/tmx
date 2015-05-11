# :[043]


## introduction

formalizing something we've been trending towards recently, here is an
experiment akin to what [br] does with resolving precondition
identifiers but with the filesystem mixed into it too: given a "flat" name
(a series of tokens), resolve its corresponding node in a tree, figuring
out (or possibly failing on ambiguity or other uninterpetability) where
the name of each one node ends and the other one begins.

so, given a tree:

    [local root]
      |
      |- foo
      |   \- bar
      |
      \- foo-bar
          |
          \- biff
               \- blammo

figure out what we mean by:

    `foo_bar_biff_blammo`




## objective

the overarching premise here is that tests are made more valuable when
you can read them quickly, and that the below above reads more easily
than each next below below.

    use :user_authentication_test_support

vs

    use :"User_Authenticaction::Test_Support"

vs

    require_relative 'user/authentication/test-support'

    User::Authentication::TestSupport[ self ]


this whole facility was constructed in service of this assumption.




## caveats

note that this is done *solely* to make the literal identifiers more
readable to the human, a process that incurs what is seen as negligible
overhead for its benefit (and yes novelty).

this has some conceptual near-overlap with the logic that is in [cb]
autoloading, however we simplify things here for the narrowed scope that
this facility has (intended only for test support "bundles" and only in
new projects or rewrites):

    • an entirely differet set of assumptions is made here than is made
      by [cb]'s autoloading with regards to how we decide what paths to
      attempt to load, and what nodes (e.g modules (e.g classes)) are
      assumed to exist when that file is loaded. see #assumptions-made..




## discussion

of course this idea could be (and has been) extended to "asset code"
(i.e non-test-code) more broadly, but bear in mind general autoloading
as it is is near stable, and this:

when we speak of "grammar" below, we are not speaking from a pure
programming language stadpoint, but from the standpoint of our layer of
isomorphic conventions and assumptions that we have constructed on top
of it.

so expanding on what is obliquely stated in the intro, what this facility
offers on top of (and below) the existing (near stable) autoloading stems
naturally from the fact that our "grammar" for identifers has less
separator tokens (only one, `_`) than the "grammar" for constants (which
has patterns for separators at different syntactic levels variously in
the form of `::` and e.g `Foo_Bar` or (legacy/platform) `FooBar` (the
corresponding patterns for those).

to try to interpret the same tree node unambiguosly from an identifier
with this less expressive grammar involves more indirection, more
inference, and less strong isomorphicism between the identifier and its
referrant:

whereas `Foo_Bar::Baz` unambiguously implies `foo-bar/baz`, a
`foo_bar_baz` here can imply `foo-bar/baz` or `foo/bar-baz`.

to disambiguate the added amibguity that comes from this simplification
is the focus of our implementation here.




## #why we don't use [cb] autoloading here

[cb] autoloading implements a magic that skirts the limits of
acceptability: given an identifer like `Foo::Bar_Baz::Io`, it will
figure out that it needs to load:

   foo/bar-baz/io.file

and along the way, it will load assets under `foo` and `bar-baz` as
necesary; whether those files were called `foo.file` or `foo/core.file`,
`bar-baz.file` or `bar-baz/core.file` and so on.

what's more, it implements `stowaways`, discussion of which is out of
scope here.

what's more, the autoloading will correct it for you if what you really
meant was, for e.g

    Foo::BarBaz::IO

instead of:

    Foo::Bar_Baz::Io

this is all way more interpretive machinery than we need here, and
furthermore it doesn't implement the resolution our new "lossier"
grammar for indentifers.




## :#assumptions-made that are different from [cb] autoloading

    • your file-to-be-loaded ("your file") may assume that the
     "local top file" (i.e in the "project") ("top file") has been loaded.

    • with each itermediate directory between the top file and your
      file (that is, all the directories your file is in between the
      top "node" and it), your file assume that:

       * each such directory corresponds to a *non-class* module, and

       * the casing of the const name for the corresponding module
         must be able to be correctly inferred from the identifier
         name. so we use "variegated symbols" instead of method case,
         so `foo_IO_test_support` (not `foo_io_test_support`) to refer
         to for e.g `Foo::IO::Test_Support`.

       * any corresponding file for this node maybe has been loaded and
         maybe hasn't; with certainty it is uncertain.

    • if your file needs files (or if you prefer, "nodes") to have been
      loaded beyond the top file and whatever it loads, it must load
      these itself, and assume they may have been (but are certainly
      not with certainty) loaded already.

      your file *should* probably only load its immediate parent
      as necessary, and that parent should load its parent and so on,
      forming a straight line from your file to the top.

    • it follows from above that if your node (in your file) does have
      or ever will have children in the future, it must express itself
      as a *non-class* module. (just use private classes as necessary.)





## :#note-05

having more to parse from here implies with certainty that what we just
parsed is a branch node. using the received token with its particular
casing (i.e as a "variegated symbol"), convert it to a conventional
constant while preserving the particular upperscpace casing:


    `IO_foo_bar_biff_bazz`        # from a name like this
                                  # a token like this becomes..
    `IO_foo_bar` => `IO_Foo_Bar`  # ..a const like this


at the current module, if the module does not exist, create this module
while autoloaderizing it. repeat if necessary.

when there is not more to parse, the current node is an "x". load the
file while praying.
_
