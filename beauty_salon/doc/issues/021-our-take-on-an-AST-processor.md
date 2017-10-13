# our take on an AST processor :[#021]

## table of contents

  - introduction [#here.[a]]

  - introduction to hooks :[#here.B]

  - why not use `::AST::Processor`? :[#here.C]

  - vaguely, our requirements for traversing :[#here.D]

  - awareness of stack frame :[#here.E]

  - small developer's notes :[#here.F]

  - foolhardy :[#here.G]

  - declarative (structural) grammar reflection :[#here.I]




## introduction :[#here.[a]]

the earliest form of the earliest member asset node under this rubric
was born from necessity: we wrote our (originally named) "hooks via [etc]"
magnetic because we needed the behavior.

shorty *after* its birth, we discovered that ours was a pattern exhibited
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




## introduction to hooks :[#here.B]

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

a "document processor" is simply a collection of these hooks, so called
because one or more documents can be feed into this (stateless) document
processor to effect its hooks against document.

you can have several plans in one definition, so for example you could
follow one set of behaviors for files that look like tests (based on
their filename), and another set of behaviors for files that look like
asset files. (really, this feature is just a cheap by-product of the
fact that for performance reasons we evaluate definitions before we
traverse files.)




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




## vaguely, our requirements for traversal :[#here.D]

  - originally this was for getting to know how the previous parsing library
    parsed things. then, this was for getting to know how the current parsing
    library parses things. always, this was used for implementing the "hooks"
    facility which underlies our essential function/report ("replace").
    as discusses at [#here.F] we will rely for a long time on using this to
    assert outwardly that our expectation of the grammar matches the reality.

  - to traverse an AST recursively, we want to be able to do
    this "forwardly" rather than passively reflecting on each
    AST; i.e we want a sense for the discrete set of symbols
    that are nonterminal rather than terminal

  - it's fun to get a sense for the statistics (the grammar symbol
    distribution) of our own corpus vs the set of all known grammar
    symbols.

  - as described [#here.B], allow that 0 or 1 arbitrary user hook proc
    is associated with each grammar symbol; BUT NOW: don't check for
    the existence of this hook proc every time the grammar symbol is
    encountered. "optimize" this decision by memoizing it away (per plan).




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
crutch we originally wrote portions of our grammar reflection with too
much "granular optimism", a concept whose development will comprise the
remainder of this section.

although we think we have (as of this writing) refactored out all
"granular optimism", this idea remains as a historical footnote because
(erroneous as they were) these associations we made between certain grammar
symbols have left their traces in the form of certain testpoint associations
that we have preserved for the sake of enriching the story nonetheless.

to begin to explain what we mean by "granular optimism" we start from
a counterpoint: consider the `case` grammar symbol. its second formal
association is (at writing) called `one_or_more_whens`. seeing that "whens"
at the end of the association name tells us that there is a [#022.I] "group"
called "when". either by looking at the group or by knowing the grammar, we
can see that this group has only one member: the grammar symbol `when`.

furthermore, with a priori knowledge of the grammar we can know that the
only place a `when` ever occurs is as the child of a `case`. so `case`
cannot exist without `when` and `when` never occurs outside of `case`.

this is a particularly extreme example of a strong association between
grammar symbols. (in fact we're not sure if the platform language has any
other grammar symbols with a relationship like this.)

we might (confusingly) call this association "one-to-one". it's potentially
confusing because we're not talking about the [#022.G] arity of the
association, which represents the valid "counts" for the number of child
AST's that the association "slot" can have. here we're talking about how
many other grammar symbols a given grammar symbol is "had" by.

for an association category that's not as strong but still significant,
consider the `args` grammar symbol. this symbol models the formal arguments
to a method or proc or block definition. again, with a priori knowledge of
the grammar it follows intuitively that the types of things (grammar
symbols) that can be children of an `args` will be of a limited set. i.e
when you define a method you can't just plop arbitrary expressions in the
`args` part:

    def foo_bar( var, 1+2 )  # syntax error - the second thing doesn't look like a formal arg
      # ..
    end

the grammar symbols that are valid under `args` have names like `arg`,
`optarg`, `kwoptarg`; several others.

this introduces (potentially) a new type of relationship that we'd call
a one-to-many "polymorphic" association. the "one-to-many" is to say that
(for example) a `kwoptarg` only ever occurs under an `args` node; but this
is not to say that every `args` node has a `kwoptarg`.

in more detail, an `args` node need not have any children, but if it does
have children we can (try to) assert the set of all possible grammar symbol
names for each child that we could possibly have in this (plural) association.

(NOTE that the above alone does not constitue a "proof" of this relationship
between these particular grammar symbols. our goal is merely to introduce
the categories of association as a concept, and try to provide examples that
we can imagine as possibly having this relationship.)

to round out a triptych of categories, a last category of association that
we might offer is the "anything" set: given that (it seems) any kind of
grammatical phenomenon in ruby can be used as an expression, and certain
grammatical association "slots" accept any expression (in fact many do);
then there are certain grammatical assocation "slots" that accept any kind
of grammatical phenomenon. what?

consider subclassing. when we subclass we typically put a `const` expression
in the right hand side of the `<` operator:

    class MyClass < Foo::Bar
    end

however, did you know you can validly put *any* expression in that "slot"
and it will still compile?

    class MyClass < ( require 'foo-bar.rb' )
    end

(put the above in a file and `ruby -wc tmp.rb` that file. `Syntax OK`)

now, we don't recommend that you ever write code in that manner. more
specifically, even if you could get the above to "work" we're strongly
suggesting *against* you ever doing so. but the point here is that the
language might not be as syntactically strict as you think in several
regards.

this anticipation of expecting a `const` expression in that "slot" (even
though no such grammatical requirement exists), this is what we called
"granular optimism". again as we said at the beginning, we have (we think)
refactored out all such granular optimisms from our grammar.

now that we have introduced the concept of association categories (and
suggested three of them), we can approach our objective: formally we
might define "granular optimism" as the application of an association
category (or just [#022.I] group affiliation) as a constraint; when the
constraint is in fact more restrictive than the grammar dictates.

for historical posterity (and to add context to certain testpoint
associations), here are cases where we fell victim to granular optimism:

  - `defs` ( e.g `def o.foo ; ..` ) - the "operand" here is just any expression

  - `splat` ( e.g the `*` and after in `def foo( * wee)` ) - the "operand"
      of a splat can be any expression. at runtime an array is attempted
      to be resolved from the result of this expression.

  - the right hand operand of `<` (for subclassing) as explored above.

  - the left side of `::` - can be any expression but at runtime must
    resolve into a module (e.g class) else exception.

(historical note: for the last two cases above, we used to call this
apparition of a grammatical concept "expression of module".)




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




## (document-meta)

  - #history-A.2 - remove *tons* of stuff from the old, method-based way
  - #history-A.1 - original content broke out of asset file.
