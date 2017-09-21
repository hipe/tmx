# our take on an AST processor :[#021]

## table of contents

  - introduction [#here.[a]]

  - what is this "document processors?" :[#here.B]

  - why not use `::AST::Processor`? :[#here.C]

  - what are these hashes for? :[#here.D]  [ EDIT ]

  - grammar symbols and method in detail :[#here.J]

  - awareness of stack frame :[#here.E]

  - small developer's notes :[#here.F]

  - foolhardy :[#here.G]

  - temporary debugging method :[#here.H]

  - declarative (structural) grammar reflection :[#here.I]




## introduction :[#here.[a]]

the earliest form of the earliest member asset node under this rubric
was born from necessity: we wrote our (originally named) "hooks via [etc]"
magnetic because we needed the behavior.

shorty *after* its birth, we discoverd that ours was a pattern exhibited
squarely by the remote `::AST::Processor`, whose succint documentation
serves as good background reading for this document.

generally, the efforts under this rubric have one primary objective:

  - to get to know the remote API's AST structures as they pertain
    to our own work.

we do this by writing assertive code that does not fail silently,
and running it with our entire "ecosystem" as a corpus. not only
does this serve our primary objective above but it also gives us
insight into the peculiarities of our corpus's "pragmatics" (as in
socio-linguistics) of the host language.

our secondary objective will one day be our primary objective:

  - act as a sort "generic processor" that exposes "hooks interface"
    API to support our several reports (all of them).




## what is this "document processor"? :[#here.B]

this is the moneyshot - this is the guy that traverses every node
of the document AST and runs all the hooks.

a "hook" is a proc associated with a symbol from the grammar: each
time a node is encountered corresponding to that symbol, the proc
is called, being passed the node. (the result of this call is ignored.)

there need not be one hook for every symbol. even if a symbol does not
have an associated hook, our traversal will nonetheless descend into
those nodes that are nonterminal (i.e "deep", "branchy", recursive).

currently there cannot be multiple hooks associated with one symbol.
(an exception will be thrown.) you could, however, hack such an
arrangement in your definition (because you can write arbitrary
code in your hook).

a "document processor" is simply a collection of these hooks (just
a tuple). (what it is is under flux EDIT)

you can have several plans in one definition, so for example you could
follow one set of behaviors for files that look like tests (based on
their filename), and another set of behaviors for files that look like
asset files. (really, this feature is just a cheap by-product of the
fact that for performance reasons we evaluate definitions before we
traverse files.)

we follow our own simple #[#sli-023] "prototype" pattern. or we don't. EDIT




## why not use `::AST::Processor`? :[#here.C]

the `'parser'` gem provides a well-documented facility for accomplishing
more-or-less what our subject facility attempts. so why re-invent the wheel?

  - we're making an educated guess that we will end up wanting the power to
    change implementation and add arbitrary features, beyond what may be
    practical or possible with the remote library. (some examples follow.)

  - subclassing the remote class is awful - couples us to their API

  - our "hooks interface" might allow the higher level client code
    (the reports) to be more concise and readable. (unconfirmed.)

  - we want fine-grained enough control that we can inject arbitrary behavor
    for the case of grammar-symbol not found (i.e something in the remote
    library for which he have no local methods written for yet).

  - if none of the above serve as compelling reasons after some point,
    then refactoring our work to fit into the remote API should be
    straightforward (however labor-intensive).

  - in any case, when we reach something resembling "stable", it will
    be fun to step through the implementation of the remote and decide
    if it's compelling to flip to it.




## what are these hashes for? :[#here.D]

first, here were the original objectives of this (at one time
only) hash (but what's after this is more important):

  - it was for getting to know how the previous parsing library
    parsed things, and likewise can be used to see how the
    current library parses things.

  - to traverse an AST recursively, we want to be able to do
    this "forwardly" rather than passively reflecting on each
    AST; i.e we want a sense for the discrete set of symbols
    that are nonterminal rather than terminal

  - for the nascent but soon-to-be-burgeoning "selector" API
    we may want fine-grained control over what behavior we
    avail to each symbol, for example to make complicated
    representations appear simpler to the DSL.

  - it's fun to get a sense for the statistics (the grammar symbol
    distribution) of our own corpus vs the set of all known grammar
    symbols.

Here is the new deal, some requirements:

  - we want these hashes to appear as they are, as simple as
    possible, with one grammar symbol name being related to
    one method name and that's it. :(A)

  - we want these hashes to be *no* more lenient than the grammar,
    i.e we want each grammar symbol to be supported only where it
    is possible to occur so e.g you can't have a `when` symbol occur
    at the root of your document; it has to be in a `case` expression.

  - as described [#here.B], allow that 0 or 1 arbitrary user hook proc
    is associated with each grammar symbol; BUT NOW: don't check for
    the existence of this hook proc every time the grammar symbol is
    encountered. "optimize" this decision by memoizing it away (per plan).

  - every traversal method takes the children of the subject node
    "splayed out" - the (human) author of the method should make choices
    for how to "splat" the method's argument signature to accord
    semantically with what is probably the grammar rule for that nonterminal
    (a didactic example: `def __method_call( method_name_symbol, * args )`)

    furthermore, (and towards (A) keeping things looking simple in the
    hashes), we put some nasty but useful magic in there: IFF the
    argument signature of the traversal method's *last* formal argument
    is named `self_node`, this will get placed in it the while node itself.
    (everything else stated above still holds, about the "splaying out".)
    :[#here.D.2]

  - the two above points together (whether and how a grammar symbol
    is hooked-in to, and whether the traveral method take an additional
    special argument to be the whole node), this combination of factors
    permutes out to six permutations ((no hooks | universal hook | name-based
    hook) x (no extra argument|extra argument)) for which we have six
    possible methods, one of which is the right one to call for any given
    tuple of grammar-symbol-plus-traversal-method-name tuple. whew!
    we memoize which method is the right method per tuple, which happens
    at the node tagged with the subject.






## grammar symbols and method in detail :[#here.J]

consider the relationship between grammar symbol names and method
names. are they one-to-one? one-to-many? many-to-many?



### many methods to one grammar symbol?

as it is there are sometimes many method names for one grammar symbol
name. this happens when the same grammar symbol appears in different
lookup hashes and there's a different "right hand side" value (i.e method
name) for these different entries. this, in turn, happens because you want
to assert or recognize context-specific variations of the grammar symbol.

  - whether or not this arrangement is optimal is outside of our
    domain here. (see #provision1.2)

as such, know that a given grammar symbol does not have a one-to-one
relationship with a given method name; but rather it is one-to-many.



### many grammar symbols to one method?

there are a few corollaries of such a hypothetical arrangement:

  - coverage. in normal "imperative" style code, you have function
    definitions and function calls, and you can see coverage reporting
    for each of these sides. (that is, you can see if you have functions
    you defined that you never called, and also you can see if you have
    function calls that are never executed.) in our "declarative" style
    with lookup hashes, you only get one side of this coverage but not
    the other. (coverage doesn't tell you if you have hash elements that
    are never accessed.)

  - method-name-as-key. there is certainly grammar-symbol-specific data
    that you we to cache (namely, whether there is a grammar-symbol-specific
    user-supplied hook). under the subject provision, it would then be non-
    workable to use the method name as a key into this cache because the
    method name does not uniquely identify one grammar symbol.

our solution at the moment addresses both of these concerns (but note that
all of this is subject to change):

  - for reading and writing to the cache we use a "compound key", a tuple
    of grammar symbol name and method name. even if we want things to be
    one method name per grammar symbol, there are not enough safeguards
    built into the language to stop us from really screwing ourselves if
    we accidentally associate different grammar symbols with one method
    name, and we use only the method name as a key.

  - when we do the work, check a *second* index that is method-name only
    to assert that we are not using the same method across different
    grammar symbols. if we want to change things so that we *can* adopt this
    DRY provision we can, but we have to do so only after taking all of the
    above concerns into account.




## awareness of stack frame :[#here.E]

both as a contact exercise and to reduce moving parts, awareness of
a frame stack is "baked in" to the mechanics here, regardless of
whether the user has supplied a hook for listening for "branchy"
nodes.

  - when the hook *is* supplied, the user gets a wrapped node
    that knows the depth (integer) of this node on the stack.

  - but when the hook is *not* supplied, we don't create wrapped
    node objects that would otherwise go unused.

  - artificially we add a once-per-file root stack frame for
    the file itself. this frame always has a depth of zero.

  - then, each "branchy" node at the root level of the document
    will have a frame depth of 1, and so on.

        file: foo-bar.rx     # depth: 0
          class: FooBar      # depth: 1
            def: frobulate   # depth: 2
        file: other-file.rx  # depth: 0





## small developer's notes :[#here.F]

  - the first pass at this whole thing leveraged 'ruby\_parser' instead
    of 'parser', the former of which conceives of its nodes as "sexps"
    whereas the latter calls them "nodes" or (more formally) "AST's".

  - sidebar: it's a bit of an arbitrary semantic distinction because the
    two concepts appear to be isomorphic; and indeed the latter library
    exposes something like a `to_sexp` method on its node class. we prefer
    the latter's treatment of it because the former's subclassing of
    `::Array` for sexps starts to feel like a smell in practice. (for one
    thing, life is easier if every node has a `type` (`::Symbol`) so
    there is no good reason to ever support empty arrays (sexps). for two,
    it's typically convenient to have children modeled as its own array,
    rather than the [1..-1] slice. for three, the latter's FP leanings and
    immutabily feel better.)

  - but anyway, our code followd suit with using whatever name the remote
    library used (oops/meh) so old code uses the old name (`sexp` or `s`)
    and newer code uses the new name (`node` or `n`).

  - oh by the way we typically don't encourage single-letter variable names
    (except for [#bs-040] these), but for the host project we deal with
    nodes (formally AST's) so much that to use this one domain-specific
    abbreviation makes code much less noisy horizontally.




## "foolhardy" :[#here.G]

the TL;DR: ruby being the dynamic language that it is makes it just
plain old impossible for us to parse some things to the degree of
meaning we might want, depending on what your expectations are.

in spite of, because of, or unrelated to this: as a developmental
crutch that we really should refactor out later, we have written
some parts of our generic processor to be more explicit syntactically
than the language actually is; that is, incorrect. (below we describe
this as "granular optimism".)

this implementational quirk applies (or did at one time) at least to:
  - `defs`
  - `splat`
  - "expression of module" for example:
    - the right side of `<`
    - the left side of `::`

in places marked with this tag (viz the above places at least), the
grammatical nonterminal has as one of its components an "argument"
that can in fact be any expression (presumably).



### example of this principle using `<` (as in subclass)

for example in the case of subclassing with `<`, you could write any
expression to the right side of the operator, for example a case
expression that weirdly determines the superclass to use:

    MyThingBaseWindows = ::Class.new
    MyThingBaseLinux = ::Class.new

    os = :Linux

    class MyThing < case os
      when :Linux   ; MyThingBaseLinux
      when :Windows ; MyThingBaseWindows
      end
    end

so a couple things to say right off the bat:

  - we are not recommending you use the above as a "pattern". our only
    purpose is to demonstrate that the syntax of the language supports
    shennanigans like this.

  - the main point this tries to demonstrate (but does not prove) is how
    you can use *any* expression for the right side of the `<` operator.
    (we have intentionally chosen a chunky expression to emphasize this
    point.)


now, in the above example, if you run it (by, say, putting it in a file
and running it with `ruby -w file.rb`) it compiles and runs and does nothing.

however, if you were to change the value of the `os` variable to something
other than the two supported values, what would happen? if you try this,
a `::TypeError` is thrown (at runtime) complaining that the superclass
must be a class.

however *however*, if you run that same erroneous file with `ruby -wc file.rb`,
what happens? you get `Syntax OK`.

the fact that this "erroneous" file compiles OK but does not run OK
demonstrates that these expressions are evaluated at runtime and not at
compile time; so how subclassing is resolved is not a syntax thing but a
runtime thing.



### but what does it mean?

a more realistic example is using a case expression as the left
side of a `::` operator, something we do in one place in the corpus,
and is turned into a testpoint.

the real-world consequences of this dynamic spell out for us in a way
that we anticipated: for example you cannot reliably find all classes
in a corpus that subclass some particular class the basename of whose
fully qualified name is equal to some string:

like, "find me all of the places where a class is opened up where that
class subclasses a class called `*::FooBar`". you can't do this
comprehensively.

you might find some but the dynamic nature of the language prevents you
from doing this reliably with syntactic analysis alone.

however as it is implemented presently, we are not so lenient.
rather, we have gone thru and made a case expression with a case for
every single grammatical symbol that *does* occur in our corpus;
rather that doing what is correct and acceping *any* expression (so
`_node`).

this is for at least two reasons:

  - we didn't really realize that all these things were this way
    at the outset. (we didn't exactly think they were *not* this way,
    either. we just hadn't really thought about it.)

  - there is a tiny chance that our "granular optimism" here will
    yield profit later - if for example we want to implement selectors
    to be "pragmatic" rather than "pure" so that for example we *could*
    find all those classes that subclass a module as expressed by a
    certain const string, like "Xx::Yy". (in fact our selectors should
    be flexible enough to support such a query by "pure" means, but
    that's later.)




## temporary debugging method :[#here.H]

this method will probably go away when things settle down (#todo will it?).
the overall objective is that we get detailed information about a
grammatical symbol that is missing coverage in terms that relate this "hole"
back to our code, so that we can amend our tests to cover these cases.
in detail, here's the intended usage of the subject method:

  1) run that one test with coverage turned on:
         tmx-test-support-quickie -cover <the spec for the indented report>

  2) using the coverage report generated by the above, derive (in your
     head iteratively, or in writing) a set of the grammar symbol methods
     that did not get covered by our test suite. in each of those methods,
     make a single call to the subject method at the beginning of that method.

  3) run the indented report against the target corpus using "corpus
     mode" of the CLI (documented under its `--help`). doing so should
     call all the hook methods that we care to cover for our purposes.
     when the subject method is called, it prints out two lines of
     information explaining this hole, and exits (at which point the state
     of the macro batch operation (i.e how far it got) is written to disk
     by the "corpus mode" plugin).

  4) use the 2 lines of information written by the above to make the
     appropriate test (i.e add fixture code) so that the missing hook
     method is now implemented and/or covered.

  5) repeat (3) and (4) until you eliminate all such calls to the subject
     method, at which point your coverage of all our grammar symbol
     methods should be up to 100%.

note this could be automated somewhat, but it would require work.




## (document-meta)

  - #history-A.1 - original content broke out of asset file.
