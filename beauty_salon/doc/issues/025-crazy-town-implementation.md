# crazy town implementation :[#025]

## table of contents

  - framing our whole architecture as being predicated on this one operation
  - our requirements for reading nodes (so we can search for them)
  - one final consideration for these top-level requirements
  - synthesis: our requirements so far
  - the old way: introducing method-based traversal
  - does referential transparency have anything to do with this?
  - no, really: what does referential transparency have to do with this?
  - managing our own stack by hand is easy
  - towards our grammar representation model
  - appendix A: the branchy node report
  - appendix B: this one algo




## framing our whole architecture as being predicated on this one operation :[#here.o]

if we have one "essential operation" it's the "replace" report.

we can understand a large swath of our architecture by working backwards
from this ultimate objective, re-framing it in terms of its (proposed)
requirements, then exploring the corollary design decisions that stem from
those requirements.

in turn, we can re-frame *those* designs into requirements and so on
recursively, and then (finally) "flush the stack" by seeing how the lowest-
level decisions feed back into serving our essential operation. (i.e top-
down and then bottom-up.)

this effort will graze against the scope of [#021] our take on document
processing and [#022] our structured, declared node API. rather than
framing this document as subservient to those (or the reverse), it is
perhaps best to see these documents as complimentary to one another.

so as for the "replace" report, we wanted to "yield" matching parts of
the document out to (for example) a rewriting function. when that function
receives each node, we're going to want it to be wrapped in a "structured"
wrapper so that the clients will have something more readable and intuitive
than just needing to work with the children array directly.

that is:

  - requirement: the ability to offer a replacement expression for a node
    in a way that is intuitive, concise, and readable.

  - requirement: for the simplest rewrites, allow our interface to be
    friendly for non-code UI's (like CLI or GUI). :[#here.n]

for contrast let's imagine that we are somehow using an `::AST::Processor`
to rewrite the document. off the bat we can think of several issues:

  - needing to write a conventional `::AST::Processor` (even just one method)
    won't translate well into our requirement to be amenable to UI's.

  - more generally, our issue with an `::AST::Processor` is that the
    isomorphicism between ruby's formal argument mechanism (on the one hand)
    and (on the other) "grammar symbol associations" feels like a smell.
    the expressiveness of ruby method signatures doesn't fit exactly with
    the expressiveness of these grammar symbol relationships.
    (this echoes some of our CON's listed at [#021.C].)
    :[#here.A] (and see reference to this below)

  - a corollary of the above is that there isn't a strong rigidity/assertion
    dynamic happening, if for example the document processor is out of sync
    (in terms of version number) with the reflection of the target language.
    [#here.m] will develop this idea further.

but to take a step back: in order to replace something we have to find it
first. this brings us to:




## our requirements for reading nodes (so we can search for them) :[#here.b]

the requirement we will develop here brings us nicely in line with the theme
we introduced above. in order to replace nodes (our essential operation,
recall), we have to have some way to find them (or if you prefer, "select"
them).

the `::AST::Processor` way to select nodes by a certain node type would
be to write a document processor with a method named after that type.
here again, because of a requirement cited [#here.n] above, this won't
work well for us.

more interesting (and again echoing the above) is at the intra-node level:
the `::AST::Processor` way of accessing the child nodes of a node is thru
the actual arguments to your handler methods. this won't work for us for
a few reasons:

  - such an arrangement doesn't expose itself well to programmatic access
    in service of our client UI's.

  - furthermore with such an arrangement there is no intrinsic grammar
    reflection, like we will want for [#here.l]

rather, we want to work with semantic names (like typical `attr_reader`s)
instead of having knowledge of particular child offsets built into the
client code.




## one final consideration for these top-level requirements

one crucial piece that we barely even implied much less stated was this:

if we are going to find in a document every node that matches some certain
criteria, then it follows axiomatically that we will have to "look at" every
node.

(in fact this is not true, depending on the grammar. if you have a priori
knowlege of the grammar and you know that the current kind of node you have
cannot contain the kind node you are looking for (recursively), then you
can eliminate the recursion into this node. but (partly because of [#here.k])
this is a potential optimization that we avoid with delight and gusto.)

presumably, `::AST::Processor` does this sort of traversal/recursion
internally (and #open [#047] it would be interesting to find out how),
but since we are developing a full substitute for that facility, we will
need (simply):

  - the ability to traverse the AST document.

(sidebar: saying "AST document" is a bit of an imaginary abstraction of
convenience. nowhere in the grammar of the target language is there a
toplevel grammar symbol representing the "document". the parser just parses
a finite list (not stream) of bytes and turns it into an AST node. if the
only expression in "the document" (the code file) is just a single line
containing a single integer, then the (terminal) AST node representing this
value will be the "AST document". so when we use this term, really it's
just an aide to help visualize the practical implications of whatever
it is we're describing. :[#here.i])

so far, in these first few sections of this document we have developed
several requirements. it would behoove us to synthesize them all now:




## synthesis: our requirements so far :[#here.c]

  - in order to find (select) nodes, we will need to (or just chose to)
    traverse the document comprehensively.

  - we want the AST node exposed (wrapped) in a way that allows us to
    access its children with semantic names instead of hard-coded
    offsets (or parameter arguments).




## the old way: introducing method based traversal :[#here.j]

we come by this architecture honestly. originally (before [#022.history-A.1])
we hewed close to the same kind of method-based approach that something
like `::AST::Processor` exposes. (presumably this is not also the same
technique that it uses for document traversal, but #open [#047] maybe it
does.)

in this approach, the grammar was represented by a bunch of methods, one
method per grammar symbol. for document traversal, we would call the method
corresponding to the grammar symbol of whatever the root node of the
document was (like [#here.i]), and it would call the methods corresponding
to each of its children node. each of these nodes, in turn, would undergoj
this same recursion, and so on recursively. in this manner the document
AST was traversed.

to explore one issue (of several) that crops up with this approach, we'll ask:




## does referential transparency have anything to do with this? :[#here.k]

..maybe not. but nonetheless we'll use it as an analogy. we borrow this
concept from computer science to discuss a phenomenon that we see frequently
in the target language: from wikipedia:

> An expression is said to be referentially transparent if it can be
> replaced with its corresponding value without changing the program's
> behavior[^1].

[^1]: as cited at wikipedia's `Referential_transparency`

now that we've heard of that, let's give some thought to this: consider how
fundamentally recursive ruby is as a language. it allows *any* expression
to go in many of its syntactic "slots" to an extent you may not have
realized because of how frequently we write code that "feels" more static.

for example, consider the straightforward code snippet:

    Foo::Bar.new :baz

(yes, this looks like it creates an object that we do nothing with.)

it would in fact be possible to achieve the same runtime action as above
through something like the highly dynamic (and horribly contrived):

    ( my_require 'foo.rb' )::( class_basename ).send construction_method, * args

(imagine that three of those things are variables with appropriate
values, or maybe they are method calls. you can't tell by looking at
just the snippet.)

again: it's horribly contrived, but see how the same effect can be achieved
by writing code in (variously) a static way or a more dynamic way:

            Foo            ::       Bar           .new                   :baz
              ^                      ^              ^                      ^
              |                      |              |                      |
              v                      v              v                      v
    ( my_require 'foo.rb' )::( class_basename ).send construction_method, * args

the point here is, every "slot" of this "expression" has been turned into
a variable or method call. so (for example) the parts that resolve into
a const value, they themselves could be other expressions, that themselves
are arbitrarily deep and so on.

we aren't showing the AST nodes here but it would be trivial to view them
with the `ruby-parse` executable that comes with the vendor library.
to use this tool to visualize the resultant AST's would show you that the
latter code snippet produces an AST that is deeper and heavier than the
former.

now, "so what?" you might say. "recurive grammatical constructs exist in
probably every language," you might say. well there are several facets of
this characteristic that are pertinent to us generally.

  - we can't resolve all const access expressions thru static analysis :[#here.D]

(this is not even to say "we can't resolve the const value [..]". we mean
that we can't reliably resolve the const *name* itself thru static analysis.)

but the reason we bring this up is because it helps us visualize a small issue..




## no, really: what does referential transparency have to do with this? :[#here.e]

perhaps the most straightforward approach to the problem of traversing
such a recursive structure is with a recursive solution. this is the
solution we outlined in the above [#here.j], and the one that was used up
until [#022.history-A.1].

the answer to the question of "what does referential transparency have
to do with this?" is "nothing, really". we just offered the example in
the [#here.k] previous section just to get us thinking about the many points
where the call stack can go arbitrarily deeply into arbitrary expressions.

one side-effect of this arrangement is that the deeper the document is,
the deeper our own call-stack goes. for a typical document this can add
maybe a hundred or so frames to the call stack.

deep call stacks generally can be a sign of poor use of resources.

although it would probably never have a palpable effect on our performance,
it just "felt wrong" that computational complexity (when measured by the
depth of our call stack) increased in a direct relationship with the
increasing "weight" of our document.

and regardless, deep call stacks are an eyesore when trying to debug
an error, and as well highly recursive call stacks can make it cumbersome
to set breakpoints when tracking a particular error. but fortunately:




## managing our own stack by hand is easy :[#here.F]

so far stack depth has been portrayed as a bad thing. but there is a time
when we want to touch it and feel it. this (or something like it) is for
a report that we will present [#here.G] below.

the good news is, it's fun and easy to manage our own stack with the
these easy steps. here, then, is a barely-pseudocode overview, demonstrating
how easy it is to manage our own stack without incurring the cost we
discussed [#here.e] above, and as well gives us a direct way to know what
the stack depth is.

  - (to review) before "structure über alles", every grammar symbol was
    visited by a call to a counterpart method, recursively. [#022.history-A.1]

  - now, each truly branch node (that is, most of them) gets its own frame
    on a hand-made stack.

  - for any such node we can produce a scanner. this scanner only scans
    over the (relatively small) handful of children that the node has (only
    one level deep). let this scanner in effect comprise the first frame on
    the stack (or be part of it). (jump down to (2).)

  - if the stack is empty, you are done. :(1)

  - if the scanner at the top of the stack has finished,
    pop that frame off the stack and jump up to (1). :(2)

  - now (with the non-empty stack and the non-empty topmost scanner),
    if the current node is terminal, yield it or whatever and advance
    the scanner and jump back up to (2).

  - now that the current node is non-terminal, create a scanner from this
    node as we did before. push it to the stack. advance the scanner.
    jump back up to (2).

this approach visits the same nodes in the same order as we would traverse
them with a recursive method-based approach. node that in this approach,
the logic that drives the traversal stays within the same method scope
(call frame) the entire time, instead of being spread across typically
hundreds of grammar-symbol methods.

this is how we can make a hand-written stack-based traversal that does
*not* rely on methods calling each other recursively. again the supposed
benefits here are A) the appearance of computational complexity is reduced
and B) it's easy to know our depth in our own stack.




## towards our grammar-representation model :[#here.m]

as synthesized [#here.c] above, we have established these requirements:
A) we need to be able to traverse the document and B) we want to be able to
access the children of nodes using semantic names for them instead of offsets.

in [#here.e] above, we offered some reasons why we don't like the
recursive, method-based approach for document traversal.

but as touched on [#here.A], there is another problem with using
methods recursively for traversal, which we develop on top of these
points:

  - we have [#021.A] an over-arching objective to verify the correctness
    of our own grammatical model against that of the vendor library.
    (this has value not just for today, but especially in the future
    when syntax of the target language changes.)

  - to state it explicitly, we don't let the current node and its children
    drive the traversal. the current node (in its structured) is treated
    as an uknown, unsanitized, mixed value. rather, it is our formal grammar
    that drives the traversal, *against* the current node. we will for a
    long time rely on this to assert outwardly that our expectation of the
    grammar matches reality, rather than letting failed assumptions go
    unnoticed, as might happen with other models.

  - as developed at [#here.b], we want the children (either formal
    or actual as relevant) to be accessible with semantic names rather
    than offsets.

now all other things being equal, if we were to traverse the document with
our recursive methods alone, we would get *some* but not *adequate*
verification that our grammar is correct. the method-based approach only
verifies that the count of actual children matches an arity. it does none
of the several other kinds of assertions we offer in [#022.G].

all of that brings us to this, a sort of summary of [#022]:

  - the main game mechanic of this library is this: the grammar is modeled
    in classes, with one class for each grammar symbol. we expose these 70-
    something wrapper classes to wrap the 70- or 80-something grammar
    symbols the remote vendor library parses. (our model is #open [#045] not yet complete)

let's consider the problem of traversal. image that we are searching
("selecting") for (say) all nodes of a certain type. or imagine more broadly
that we have to integrate with our "hooks" facility which underlies our
essential operation/report ("replace").

given just the bullet above, a crude approach to traversal would be to
promote (wierdly) every single nonterminal node to become one of our wrapped
(structured) nodes (recursively) and (recursively, too) walk along each
(now wrapped) child of the structured node.

this would work, but it would be wildly inefficient, would fall over when
run against large and/or many documents, and would be shameful to publish.
that's what led to this provision:

  - the structural information about each grammar symbol is available
    statically under each class :[#here.l]

this means that you need not have an structured node *object* just to get
reflection information about the formal structure of the grammar symbol.

for example, if we wanted to reflect on the grammatical children of the
`case` expression, we could use

    Case.association_index.associations

(provided we dereferenced that class using the "feature branch" idiom).

this is the approach we use in traversal, is to access this grammar
information statically rather than instantiating an object for every node.
this save us the cost of creating structured nodes that we don't absolutely
need (which in our naive approach against our corpus would be in the
millions).

all of this together is how we traverse "efficiently" (for our definition)
an entire document while still verifying correctness of our grammar model.




## appendix A: the branchy node report :[#here.G]

this "branchy node" report became something of a waystation along the
way to our [#here.o] goal that grew into an objective in itself that is
now seen as interesting as a report in its own right.

it has a backstory that is probably not important but nonetheless
has a few steps:

  - before we realized "structure über alles", we nonetheless needed
    some specialized classes to wrap particular AST nodes in order to
    expose them out to replacing functions, fulfilling [#here.b] as
    a proof-of-concept.

  - so with a limited subset of the grammar, we made special classes
    for a few grammatical symbols of interest (like `module`, `class`,
    `send`).

  - in order to (in effect) map certain children offsets to certain
    meaningful names, we devised the original (unreadable, now sunsetted)
    component system.

the "branchy report", then, was conceived as a way to help prototype these
early classes while verifying at a glance that the above machinery was
working against a representative sample of our input documents.

this report was the pioneer case of needing what we now call a "logical
stack", that is (roughly) a stack that follows along with the amount of
indentation developers typically employ for any given line of code in its
context. this allows the report to output its "summary glimpse" of the
document with indentation that "looks right" for what is being presented
but is effectively the result of a normalizing function rather than a
function of whatever arbitrary indentation was actually used in the
document.

    (document)                  (report output)
    +------                     +--------
    |# one file                 |file: one.rb
    |module Foo                 |  module: Foo
    |  class Bar                |    class: Bar
    |                           |

    +------                     +--------
    |# another file             |file: another.rb
    |    module Baz             |  module: Baz
    |    class Qux              |    class: Qux
    |                           |

(fig 1. indentation is normalized in the report.)

note also that we add a once-per-file root stack frame for
 the file itself. this frame always has a depth of zero.

    file: foo-bar.rx     # depth: 0
      class: FooBar      # depth: 1
        def: frobulate   # depth: 2
    file: other-file.rx  # depth: 0

so:

  - in each document, the artificially inserted frame representing
    the file itself reports a stack depth of `0`

  - each subsequent nested branchy node has a depth of `1`, then `2`
    and so on.

but more broadly as it pertains to the whole system, it's worth knowing
that A) this report has its own conception of a stack, B) the [#here.F]
central traversal function has *its* own conception of a stack, and C)
these two stack exist semi-independently of one another (the one *is*
a clean susbset of the other).




## appendix B: this one algo :[#here.H]

    somehow parse the code selector

    somehow parse the replacement function

    for each file
      attempt to parse the file
      if error, explain and skip to next file
      (or maybe actually fail out entirely - be atomic - user should cull the file list)

      somehow get a stream of features by applying the code selector to the sexp

      for each feature (occurrence of a match),
        somehow pass this (with sufficient context) to the replacement function
        put the result into a queue of line-level changes

      at the end, add our list of line-changes to some kind of structure
        associating it with a reference to the file (just a path)

    (now you have a structure that is a list of file-changes)
      (this is past the point of failure.)

    output the diff from that.




## document-meta

  - #history-A.1: spike synthesis of justification for hand-made stack
