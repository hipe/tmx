# structured business classes :[#022]

synopsis: generally this is a generic AST processor that wraps
*certain* grammar symbol instances into our "tupling" structures
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
(optionally) you can wrap a document AST node in such a "tupling"
so that you can just have the getters you might want as referenced
in the referenced remote documentation.

(by the way, we introduce "tupling" as a neo-logism to mean a struct-
like instance that relates an ordered, fixed-length list to certain
semantic names associated with offsets into that list.)

