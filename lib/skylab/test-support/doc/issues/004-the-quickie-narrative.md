# the quickie narrative :[#004]


Quickie is an attempt at a minimal drop-in ersatz for the simplest/
most frequently used 80% of RSpec, but one that is supposed to take
scant milliseconds to load and (depending on your tests) run one file.
It tries to hold itself to the "swallow rule" - that the time it takes
to load and start running one file (or changeset) of tests should not
take longer than the time it takes you to swallow.

It is not a replacement for RSpec (depening on how you use RSpec),
it is just a means to an end of writing RSpec-compatible tests that
can run much faster during development provided that you want to run
only 1 file and are doing something "simple" (for various definitions
of that) in that file.


### RSpec-like features it *does* include include:

  + arbitrarily deeply nested contexts (can define class methods, i.m's).
  + memoized attr_accessors with `let` (that nest appropriately)
  + core predicate matchers for `eql`, `match`, `raise_error`,
    (by design the predicates are added only to the test context, not
     to Kernel, so the places you can make your assertions are limited.)
  + the wildcard predicate matcher `be_<foo>` (`be_include`, `be_kind_of`)
  + tag filters (only run certain examples tagged a certain way)
  + pending examples (and contexts! unlike r.s)
  + limited, experimental support for non-nested before( :each )


### These are the most salient (to the author) features of RSpec that
quickie offers limited or NO support for:

  + `should_not` (meh)
  + run multiple files "at once" - experimental recursive runner exists
  + `before` and `after` blocks - limited support per above
  + `specify` (but experiments in the universe exist at [#017])
  + custom matchers - except for the `be_<foo>` wildcard per above
  + ..and pretty much everything else not in the first list!


### Strange behaviors (features not bugs!):

  + Quickie has the exception matcher (should raise_error(..)) that tries
    to work just like r.s, but beyond this: **Quickie does not use
    exceptions internally to indicate a test failure.**  2 corollaries
    follow from this:
    1) when there are multiple tests (`x.should eql(y)`)
    in one example (`it "..." { }`), the first failing test will not
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



~ just for fun, below is sometimes defined in a pre-order-ish traversal ~

(which is supposed to mean that where possible things in the file
are presented in the order they are called during a typical execution,
so that if you had a stack trace of each first time a function was
called, that is ideally the order they will appear in this file.
In theory this should make it more of a narrative story to read top
to bottom (and hopefully have your eyes jumping shorter distances)
if it's your idea of fun to read the whole thing .. we'll see..)



## :#storypoint-285

one client is creted per test run. it manages
UI, parsing the request to run the tests, creating a test runtime,
and initiating the test run on the object graph.



## :#storypoint-465 (method)

this is kind of derky mostly because we jump through hoops to accomplish two
behaviors: 1) render the name of the example in the right color, yet do that
before you render the constituent test(s) inside it that made it fail 2) don't
render surrounding context description names for nodes in the tree that you
skipped.. (and it's the weirdest way to do a collection of "view templates"
that i've ever seen/done.)
