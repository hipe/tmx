# all about coverage :[#002]

## table of contents

  - why two coverage plugins? :[#here.B]
  - how quickie approaches coverage :[#here.C]
  - isomorphic tree architectures explained :[#here.4]
  - lemmatics explained :[#here.E]
  - explicits :[#here.F]
  - slowie coverage is (was) a "no fun" zone :[#here.G]




## objective & scope (or, "why two coverage plugins?") :[#here.B]

this document holds documentation for two coverage plugins - one for
slowie and one for quickie. the slowie plugin came first and is currently
furloughed. the quickie plugin works great at writing.

this document started as documentation for the slowie coverage plugin,
and then we needed a place to put documentation for the quickie
counterpart, so we bombed it into this document rather than starting a
new document; with this justification:

slowie exists as a set of plugins useful to run our tests at a macro-level.
at present it in effect sits in front of `r.s` (but it would be nice to make
this only one of two options). quickie, on the other hand, exists explicitly
to serve as a 90% good-enough replacement of r.s, but is not yet suitable
for a macro-level acceptance test run.

to foster experimentation, discovery, and the development of new ideas,
these two test runners have a different plugin architecture. (quickie
(for example)'s main obsession is loading only those plugins whose
"primaries" invoke them via the command line. as for slowie, ???.)

this explains in part why they would want separate plugins for their
coverage implementation, but not the only reason:

quickie, for example, has coverage features that wouldn't be relevant to
slowie, becuase quickie's focus is at the sub-sidesystem level and so it
focuses on focusing coverage on the relevant sub-tree of the sidesystem.

anyway, it might be that we do away with the slowie coverage plugin
entirely or otherwise somehow merge these two test running architectures
into one, because despite our attempt at justifying it, it still doesn't
quite feel right.




## how quickie approaches coverage :[#here.C]

from an implementation perspective, the central game mechanic in generating
coverage reporting is filtering files. our current remote dependency
`SimpleCov` exposes a minimally simple API for this.

in our minds, at least, it works something like this: when the "locus" of
execution "jumps into" your first file, and subsequently whenever that
"locus" in effect jumps between files, a callback of yours is called to
determine whether you want to gather coverage information for that file:

(counter-intuitively to us) you result in `trueish` if you want to filter
that file OUT, and `falseish` if you want to filter the file IN. (i.e it's
a filter, not a pass-filter.)

the thing about filtering is, if you filter-out files you didn't mean to
filter-out, then you won't determine the coverage for the asset files
you care about. however, if you "filter-in" too many files, then you're
getting more information than you want and this counts against your
precentage of coverage.

to take a step back for a minute: coverage is measured (typically) in
terms of percent, and so it's entirely essential that you have an agreed-
upon set of files (usually implied not expressed), and sufficiently fine-
grained control to express and effect your set of files your are targeting
coverage for, otherwise the percents are meaningless.

(this is more relevant for focused coverage testing, rather than "acceptance
coverage testing"; the latter of which probably involves covering *every*
asset file in your project. but note that even in these "macro" cases you
may still want fine-grained control, if for example you wanted to detect
dead code in your test or test support files.)

the obsession of our coverage plugin, then, is on making it so that this
filtering happens intuitively so that you don't have to think about it,
generally. our "lemmatics" system (described below) is what implements
this "intuitive" filtering. because this might not be convenient for all
cases, we also have an experimental "explicit" API for specifying files
by name (also described below, later).




## isomorphic tree architectures explained :[#here.4]

before we can get to our main behavioral characteristic ("lemmatics"),
we have to get to know some architectural convention of our projects.

as an experimental provision that has carried us very far but may
not always carry us forever, we often follow something we call
"isomorphic tree architecture" between "asset" "nodes" and "test"
"nodes".

this simply means that all things being equal, the architecture
(as in tree-structure on the filesystem) of test files might as
well follow the structure of the "asset" files (by which we
typically mean code files that are not test files).

now, right away you might be saying "that's not how" (EDIT)

let's imagine an imaginary project (gem) called "tanfastico".
because it's a gem we'll have the `lib` directory at the top of the
project, but otherwise we have rolled our own weird architecture,
to illustrate that we are free to place files where we want.

we have the ever-popular "models" directory but we also have
some strange thing called "endpoints" which we just made up for
the sake of this explanation.

    tanfastico_dev  # (this name doens't matter)
      lib
        tanfastico.rb
        tanfastico/endpoints/frobulate.rb
        tanfastico/models/hairdryer.rb
        tanfastico/models/social-dissent/core.rb
        tanfastico/models/social-dissent/helper-.rb

now, here is what the test files might look like:

    tanfastico_dev  # (this name doens't matter)
      test
        endpoints/frobulate_speg.rb
        models/hairdryer_speg.rb
        models/social-dissent_spec.rb

there are many characteristics to note here:

  - the directory called `test` sits as sibling to the
    directory called `lib` (at the toplevel of the project).

  - we are using a made-up test suffix `_speg.rb` in this example
    just to emphasize that your test file suffixes may vary
    (or you weirdly don't have any pattern) based on whatever
    weird testing thing you do.

  - but in our real life testing framework, the default assumption
    for test filenames *is* `_spec.rb` (with an underscore).
    because we much prefer dashes generally but we don't want to
    deviate from the default when it comes to test file names,
    we awfully intermix dashes and underscores in test files for now.
    this ungly intermixing, however, is not relevant to the discussion.

  - note most importantly that the test files follow the structure
    of the asset files sort of. however:

  - whereas all the asset files are under a project-eponymous directory
    ("lib/tanfastico"), this is a sort of emergent requirement of the
    gem world, and it's one we do *not* carry into our test trees: there
    is no corresponding directory "tanfastico" under "test". since every
    test in the "tanfastico" project is for testing some part of
    "tanfastico", it adds noise with no meaning to have this added
    depth to our test tree. rather we in effect "hop over" this node
    in our test tree.

  - note there is *not* one test node for every asset node. we don't, for
    example, have a test file corresponding to the toplevel (eponymous)
    asset file "tanfastico.rb". and note there is not a dedicated test
    file for "hair-dryer/helper-.rb", whatever that is.



### there are a few small further considerations

  - in our ecosystem you will see asset files and directories that end
    in one or more undescores (like "foo-bar--.rb" or "magnetics-/").
    this is done for [#bs-029] reasons that are variously A) quite
    specific and B) not interesting to us here except to say that we do
    *NOT* (as a rule) carry these trailing underscores over into
    corresponding test file names.

  - in our ecosystem you will see test files and directories that begin
    with numbers (like "010-foo-bar_spec.rb" and "040-magnetics/").
    this is done for [#ts-001] reasons that are variously A) quite
    specific and B) not interesting to us here except to say that this
    is a convention that will affect test files but not their corresponding
    asset files.

 -  a corolloary of the above two points is (EDIT).



(see also: [#dt-005.3] which has an older explanation of the same set
of conventions.)



## lemmatics explained :[#here.E]

### lemmas generally

we introduce the existing concrete concept of "lemma" to signify
something of a more abstract idea. we then use examples of the
concrete idea to develop our abstract theme. then we explain what
this has to do with our coverage behavior. so:

the "lemma" form of a word is the form you would use as a heading
word in a dictionary: it's the essential, uninflected form of that
word so, "snake" for "snakes", and "understand" for "understood"
(maybe).

we can determine that the words "understanding" and "understood" are
related if we get the lemma for each word (formally, "lexeme") and
see that it is the same lemma ("understand").

our interest, then, is in having a function that can derive the lemma
for any item for the type of item of interest. we can apply such a function
towards a variety of algorithms involved in finding associated (or as we
sometimes say "isomorphic") items. (parenthetically, the algorithm
"metaphone" is the same concept.)


### lemmas for our purposes

we use what we call "lemmatics" to match up test files with asset
files. we distill the test path (the longest common base path)
into a "lemmatics" and use this to filter asset files.

our process of "lemmatizing" the element of a path is so that

for a test file named:

    "test/123-foo/34-bar-baz/56-wazooza_speg.rx"

its "lemmatics" looks like:

    [[:foo], [:bar, :baz], [:wazooza]]

now, when given a set of many test files, you would be reasonable
to think that we might want to build up a set of lemmatics; one
lemmatic for every test file; but you would be wrong.

when we have several test files, we first determine their "longest
common base path". (we won't explain that here except to say that
it is exactly what it sounds like.)

for a longest common base path of

    test/80-frobits/90-fiz-buzulator

and a gem path of

    /usr/me/.gem/my-great_gem-3.0.0/lib/my/great_gem

this implies there is a directory something like

    /usr/me/.gem/my-great_gem-3.0.0/lib/my/great_gem/fro-bits-/fiz-buzulator--

(we are adding the trailing dashes to make the example look realistic
but note that the test path does not imply these dashes.)

the "lemmatics" of our longest common base path is

    [[:fro, bits], [:fiz, buzulator]]

so finally, the crux of our lemmatics algorithm (in its parts) is this:
for each incoming asset file path that we haven't seen before

    /usr/me/.gem/my-great_gem-3.0.0/lib/my/great_gem/fro-bits-/chu-chi--.rb

we will walk along (stream-like) over ever *relevant* component
of the path so:

    fro-bits-          chu-chi--.rb
       ^

we generate the lemma-piece for the current part

    fro-bits-          chu-chi--.rb
    [:fro, :bits]
          ^

we then compare this lemma-piece against our target "lemmatics"

    [[:fro, bits], [:fiz, buzulator]]
           ^

it's a match so we procede to the next element of the doo-hah.

    fro-bits-          chu-chi--.rb
                       [:chu, :chi]
                             ^

we then compare this lemma-piece to the corresponding one in our target:

    [[:fro, bits], [:fiz, buzulator]]
                         ^

because these two lemma-pieces do not match, we categorize this particular
asset file path as a DO NOT COVER.

these are the other possible outcomes:

  - if we had gotten to the end of the target lemmatics before getting
    to the end of the incoming path, then it is as though the incoming
    asset file path is "inside" of the target lemmatics and it is
    categorize it as a DO COVER.

  - conversely, if we run out of asset file path components before we
    get to the end of our target lemmatics, then this is squarely the
    kind path that we want to filter out. DO NOT COVER.



## explicits :[#here.F]

(EDIT: this experimental thing "speaks for itself." we might explain it
here once it comes out of the oven.)




## slowie coverage is (was) a "no fun" zone :[#here.G]

coverage is not and cannot be a "clean plugin" - it needs its owns special
handling because of a distinct characteristic that only coverage has:

we cannot determine coverage for any file that is loaded by the ruby runtime
before the coverage agent is started. as long as we use the test runner to
determine (some kind of) coverage for the libraries on top of which the test
runner itself depends (which itself seems super fishy, except that the test
runner is like the quintessence of a perfect use-case for plugins, and the
plugin API hellof needs good test coverage);

as long as that is the case, we write our coverage-related mechanics with
no dependencies at all except ruby.

despite this, for aesthetics, comprehensiveness, and perhaps
future-proofing we still make the coverage mechaincs "look like" a true
plugin as much as we can, in terms of where its files live. the cost of
this is a couple lines of explicit file requiring.




## #at-this-exact-point

in order to report coverage on the widest possible amount of code
(including the code in this file) *yet* to implement this coverage
facility as a plugin; exactly two files have finished loading once we
get to this point here -> "." (and these two files were loaded
"manually"). a third file is in the process of being loaded: this
one. now that any coverage plugin is running, to get our sidesystem
([ts]) and sub-system (the tree runner) wired for autoloading in the
usual way, we have to do it in an unusual way: more manual loading:




## document-meta

  - #history-A.1: at this point we inject a bunch of years-newer content
    into this document with years-older content.
