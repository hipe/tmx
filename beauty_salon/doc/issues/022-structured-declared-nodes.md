# structured declared nodes :[#022]

## table of contents

  - declarative (structural) grammar refection [#here.A]
  - (reserved for the blurb after the new intro [#here.s2])
  - the list of features [#here.s3]
  - "components" (special associations) (in a test file) [#here.4]
  - #open track places where inheritence yadda [#here.E]




## declarative (structural) grammar reflection :[#here.A]

NOTE (EDIT) once #open [#022.E2] is closed, the wording here should be
worded to reflect the fact that this complements (or maybe will replace!
gulp) the work at that one main file.

inspired exactly by the excellently documented `::AST::Processor`,
this is our own (second of two) take on it with the following:

  - [ all of the reasons cited at [#021.C] ]

  - for better or worse, module-centric instead of method-centric
    constituency modeling (so, one module per node type (instead of
    one method per node) for those node types you're interested
    in modeling).

  - this avails us to a more declarative- and less imperative-style,
    more well suited to hierarchical meta-data.

  - compound processors - processors that rely on processors (imagined)




synopsis: generally this is a generic AST processor that wraps
*certain* grammar symbol instances
(EDIT: after #open [#022.E2] this should read "all" grammar symbol instances)
into our "structured node" structures
that makes accessing certain properties easier through derived getters.

read the blurb at `::AST::Node`, which is essential to understand
the justification of our API here. the gist of it is, making
*subclasses* of `::AST::Node` tailored to the specific grammatical
symbols (for example, a ClassNode subclass) is not appropriate.

they then recommend using `::AST::Processor` in its stead.

the problem with `::AST`'s processor approach is that it hard-codes
non-semantic offsets into the code.

the work here tries to bridge that gap, centralizing all knowlege
of component offsets in one place, reducing the strain on would-be
AST processors to have to know this.

this intends to have the effect of making processor code more readable,
as well as centralizing the offset knowledge in one place to make the
code more resilient in a DRY sense.

we also expose a composition-not-inheritance approach, whereby
(optionally) you can wrap a document AST node as such a structured node
so that you can just have the getters you might want as referenced
in the referenced remote documentation.




## this list of features

  - the consts defined under that one module are only all the classes
    we have defined that isomorph with the set of all grammar symbols
    we support. (A)

  - feature: that one thing with the strangely spelled grammar symbols
    that don't isomorph directly. (B)

  - feature: the "any" modifier. (C)

  - feature: the "arities": one (only ever implied never stated),
    zero or more, one or more. (note these don't conflict with the
    "any" modifier. "any" is always an indication that it could be
    nil: it can be nil IFF the "any" modifier is used. in "any zero
    or more", this means it's nil, the zero length array, or a non-
    zero length array. (D)

  - feature: "probablistic groups" (needs a better name). these need
    to be defined before the constituencies are defined; these specify
    sets of allowable (or maybe just expected) grammar symbols that
    are allowed at this constituent slot. (E)

  - central feature: the recursive function (not defined here) takes
    an "injected context" that is the one to decide (in effect) what
    algorithm is in control. (F)

  - feature: arbitrarily ordered arity evaluation (experiment).
    superficially this system is like the formal argument arities of
    the host language; but it frees itself from limitations there. (etc) (G)

  - feature: lazy evaluation of constituency groups. for regression-
    friendliness and perhaps speed of file load-time, EXPERIMENTALLY
    we won't evaluate a constituency definition until the first time
    it is used. (H)

  - feature: inheritence. in order to re-use same-constituencies across
    different grammar symbols, we allow that a child class can descend
    from a base class that uses this system. HOWEVER a child class cannot
    then define things.. (either use `define_constituents` or
    `redefine_constituents`, or simly assert no re-defintion.) (I)

  - feature: "components", as described in [#here.4]  (in a test file)




## terminal associations (in a test file) [#here.4]




# #open track places where inheritence yadda [#here.E]

for now, this tag tracks places where we thing the declared structured
grammar reppresentation could be aided by inheritence, but no such facility
is yet covered, supported or implemented. this gathering, then, should serve
as an aide to gathering requirements to that end, and then refactor all
referrents, and erase this clause or re-write it to describe the expressive
feature.
