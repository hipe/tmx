# structured declared nodes :[#022]

## table of contents

  - declarative (structural) grammar refection [#here.A]
  - (reserved for the blurb after the new intro [#here.s2])
  - overview of the toplevel features [#here.s3]
  - overview the association definition features [#here.G]
  - overview the less interesting toplevel features [#here.s8]
  - terminals (special associations) (in a test file) [#here.4]
  - terminal type assertion [#here.F]
  - groups [#here.I]
  - inheritence [#here.E]




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




## overview of the toplevel features [#here.s3]

  - the consts defined under that one module are only all the classes
    we have defined that isomorph with the set of all grammar symbols
    we support.

  - at the sub-"grammar symbol" level, the main feature is the association
    definition grammar, overviewed in the next section.

  - central feature: the recursive function (not defined here) takes
    an "injected context" that is the one to decide (in effect) what
    algorithm is in control.




## overview of the association definition features [#here.G]

  - "any"-ness. the "any" modifier applied to an association indicates that
    its corresponding node, value, or list structure in the corresponding
    actual structured node can be nil.

  - the plural arities:
    they are:
      - zero or more
      - one or more
      - zero or one

    please search the subject tag for all significant disussion of the
    arities in the asset code and tests.

  - node type groups. see [#here.I]

  - "terminals" as described in [#here.4]  (in a test file)




## overview of less interesting toplevel features [#here.s8]

  - lazy evaluation of associations. for a variety of reasons (efficiency
    of execution for small stories, regression friendliness for better
    coverage), nothing about the defined associations are evaluated until
    some point after when they are defined.

  - inheritence. please see [#here.E]

  - accomodation of strange casings. for grammar symbol names that won't
    translate directly into a valid const name, we have a declarative
    facility for this.




## terminal associations (in a test file) [#here.4]




## terminal type asssertions :[#here.F]

we assert the "type" of terminal values only as a safeguard to assert
that our understanding of the AST model accurately reflects the structure
of the actual AST tree.

it should be the case that this feature could be removed and have no
behavioral impact on the library (as with "assert" statements in C, say).

details: currently:

  - there is an implicit assertion that all terminal values will
    be non-nil (maybe).

  - the asserter is not resolved at definition time (nothing is)

  - the asserter is not resolved at definition resolution time
    (but the thing that will resolve the asserter is resolved.)

  - the asserter is resolved at document parse time.

to ease the pressure when testing, we currently resolve these
late. maybe this has a cost for a large corpus.




## groups [#here.I]

(likely permanent in spirit, but likely in flux in implementation EDIT after #open [#022.E2])

this facet of associations has to do with expressing what types of nodes
(as in `::Parser::AST::Node#type`) may occupy the corresponding "slot"
represented by the association.

this facility does not apply to terminal associations, because terminal
associations' corresponding data nodes are simple primitive values that
have no *node* type.

(sadly we must take care to distinguish whay we mean by "type". in this
section we typically mean "node type" and not "primitive type".)

we may, then, for the non-terminal "slots" express sets of allowable node
types for the given slot. these sets are expressed (through reference) as
simple lists (arrays) of symbols, each symbol being a type name of a type
allowed to occupy that slot.

  - sometimes you will want to express that only one type of node
    may occupy that slot. in these cases make a group with one member.

formally every given non-terminal association has a "group affiliation"
which is expressed as the last token of the association. this group
affiliation is the name of a group, which is defined (somewhere) and points
to the list of allowable types for a slot like that as explained above.

  - currently groups names must be limited to one token. so you can
    have a group named `bar`, but not `foo_bar`.

  - the group called `expression` is magic shorthand to mean "any type of
    node may occupy this slot". in practice this keyword probably short-
    circuits a lot of the machinery explained here, which is why you
    frequently see this group used in tests when groupiness is outside
    the scope of the test.

  - whether or not the syntax allows it (we're not sure), a group
    name of `terminal` really should be avoided. (assume it is disallowed.)
    to use such a group name would make a non-terminal association look
    like a terminal association to the eye if not the interpreter.

during things like traversal or structural recursion, the node's node type
will be checked against the group (a simple list of symbols of allowed
types, probably turned into a hash), and an exception will be raised on
unexpected types.

like terminal type assertions above [#here.F], this facility exists
purely to sanity-check the user's grammar against the corpus (document).
for normal use-cases this facility will have no noticeable behavior.
it's like `assert` statements in C.




## EXPERIMENTAL - limited support for grammar symbol inheritence [#here.E]

we allow that a grammar symbol class can inherit from another grammar
symbol class (and when we say inherit we mean in the plain old ruby
class sense) with these justifications/provisions/caveats:

  - this facility exists only so the same constituency (i.e same set, same
    order) of associations may be duplicated across several grammar symbol
    classes. it's a pragmatic refinement made for that set or sets of
    grammar symbols (in the practical grammar) that have the same
    constituency of associations.

  - to allow the child class to add to its list of associations presents
    these problems:

      - a definitional API would have to be designed and exposed that
        allows the designer to insert new associations at arbitrary
        locations in the existing list. there's no pretty way to do this.

      - such a "feature" would be counter to our founding design principle.
        the participating child classes would not be revealing their full
        constituency at a glance. "immediate, full, concise expressiveness"
        would be violated.

    as such we have prohibited this via this provision: in any class
    ancestor chain whose base class is our grammar symbol class; at most
    one class in that chain may invoke the `children` method.

    the designer who is thwarted by this limitation must for now simply
    rewrite the associations (or do the other kind of clever re-use if
    you must)




### implementation

since we have a weird requirement (don't add assocations) we can implement
this in a weird way that makes it easier: *every* such class (execept our
ultimate base class) will assume that somewhere in its ancestor chain is
a value retreivable by a particular const ("the const").

the base class will set "the const" to a falseish.

definitions "come in" thru the `children` method. we need some place to
store the definition. (we're not parsing it yet.) simply, "every time"
a definition comes in, we bork if the const evaluates to trueish
(reflecting it having already been set *anywhere* up the ancestor chain).
