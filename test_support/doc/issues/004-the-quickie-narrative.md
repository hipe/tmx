# the quickie narrative :[#004]

## brief introductory note on style

this node has a relatively long history in this universe throughout
which it has undergone many periodic although rarely comprehensive
modernifications. as such it stands as a mosaic of the many different
phases we have gone through. there are some ancient muddy patches from
our foray into functionalism which remain there today both because
they have no known issues and because they are amusing to read.

(EDIT: at this writing it has been modernized nearly comprehensively.)

we strictly follow [#bs-029.7] the name conventions for const visibility
because it has compelling merit in its self-documentation; but the
effect to the the uninitiated may be jarring with all the trailing
underscores in the const names.




## introduction to Quickie

Quickie is an attempt at a minimal drop-in ersatz for the simplest/
most frequently used 80% of RSpec, but one that is supposed to take
scant milliseconds to load and (depending on your tests) run one file.
It tries to hold itself to the "swallow rule" - that the time it takes
to load and start running one file (or changeset) of tests should not
take longer than the time it takes you to swallow.

As well we wanted a test runner that 1) would be able to run the tests
on one spec file with an implementation that lives in one file that
hovers around 1000 lines of code; and 2) we hated what rspec did to our
exception stacks.

Quickie is not a replacement for RSpec (depening on how you use RSpec);
it is just a means to an end of writing RSpec-compatible tests that
can run much faster during development provided that you want to run
only 1 file and are doing something "simple" (for various definitions
of that) in that file.



### RSpec-like features it *does* include include:

  + arbitrarily deeply nested contexts (can define class methods, i.m's).
  + memoized `attr_accessor`s with `let` (that nest appropriately)
  + core predicate matchers for `eql`, `match`, `raise_error`,
    (by design the predicates are added only to the test context, not
     to Kernel, so the places you can make your assertions are limited.)
  + the wildcard predicate matcher `be_<foo>` (`be_include`, `be_kind_of`)
  + tag filters (only run certain examples tagged a certain way)
  + pending examples (and unlike r.s pending contexts too)
  + limited support for before( :each | :all ) (currently no overriding)


### These are the most salient (to the author) features of RSpec that
quickie offers limited or NO support for:

  + `should_not` (meh)
  + run multiple files "at once" - (but now experimental recursive runner exists
  + `before` and `after` blocks - limited support per above
  + `specify` (but experiments in the universe exist at [#017])
  + custom matchers - except for the `be_<foo>` wildcard per above
  + ..and pretty much everything else not in the first list!


### Strange behaviors (features not bugs!):

  + Quickie has the exception matcher (`should raise_error`(..)) that tries
    to work just like r.s, but beyond this: **Quickie does not use
    exceptions internally to indicate a test failure.**
    2 corollaries follow from this:

    1) when there are multiple tests (`x.should eql(y)`)
    in one example (`it "..." { }`), the first failing test will *not*
    automatically halt further processing of the example (in contrast to
    r.s).

    2) Quickie makes no effort to rescue any exceptions, so any that are
    unhandled during test execution bubble all the way out and probably
    halt the execution of subsequent tests. it is the way of simplicity.

  + As hinted at above, Quickie finds it just as easy to mark an
    entire context as pending (because it has no block) as it does
    for an example, so this is something it does that ::RSpec does not do.
    Arguably this can be a nice enhancement to flow, when you know you
    are going to make a node a context rather than an example, but you
    want to just jot it down and pend it.
    (::Rspec lets such nodes exist, it just does not report them, hence
    cross-compatibility is not broken, it's just that one way is better.)




# code comments

for fun and profit, we often define the code in "pre-order traversal"
which is supposed to mean that where possible things in the file
are presented in the order they are called during a typical execution,
so that if you had a stack trace of each first time a function was
called, that is ideally the order they will appear in this file.

the idea is to make it more of a narrative coherent "story" when read
from top to bottom: ideally its structure has your eyes jumping around
the shortest disatances necessary to find a method definition you haven't
seen yet from the first occurrence of its call that you encounter when
following the narrative. this is all built around the presupposition
that your idea of fun (like mine) is to read entire files of code from
start to finish.





## about how we implement "enable kernel describe" :[#here.A]

at the moment, our version of rspec achieves what we call "kernel describe"
by enhancing the singleton class of the toplevel runtime object `main` with
a line like this: `extend RSpec::Core::DSL`. it is not chance that this line
occurs outside of any method, at the toplevel context of the entrypoint file
of the library: apparently there is no other way to reach the `main` object
than by being there. and again apparently, they were avoiding monkeypatching
e.g ::Object or ::Kernel. (note they *do* monkeypatch `::Module` with this
same `describe` method so (presumably) it is available as a singleton method
on ordinary modules and classes, for whatever reason..)

anyway all this is to say that we have no "direct" way of reaching `main` to
see if this enhancement has occurred (without doing something terrible like
setting it to a const, or no, wait, `TOPLEVEL_BINDING.target`), but that's
all obnoxious to test and brittle. in its stead, we:





## the CLI client as it pertains to rendering :#storypoint-465

this is kind of derky mostly because we jump through hoops to accomplish two
behaviors: 1) render the name of the example in the right color, yet do that
before you render the constituent test(s) inside it that made it fail 2) don't
render surrounding context description names for nodes in the tree that you
skipped..
