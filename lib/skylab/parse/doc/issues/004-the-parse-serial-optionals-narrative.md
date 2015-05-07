# the parse series narrative :[#029]

## (legacy documentation, kept for posterity and amusement)

parse out (a fixed) N values from M args

imagine a formal parameter syntax that is made up of one or more
contiguous optional arguments, and we want to determine which actual
arguments to tag as which formal arguments not in e.g the usual ruby
left-to-right way (if we are talking about a method signature); but
rather via functions, one function per formal argument.

specifically, consider the example "grammar" of `[age] [sex] [location]`.
a primitive attempt at this as a ruby method signature is:

    def asl age=nil, sex=nil, location=nil

however we would like it to work for calls like

    asl "male", "Berlin"

which would not work as illustrated. we can, however, create one
function for each of the formal parameters that can be used to indicate
whether any given actual parameter is a match for the particular
formal parameter. we would then be able to accept eight possible
permutations of these fields in this order, each one being either
provided or not provided; in contrast to the four permutations of
pseudo-signatures possible in the ruby example. this facility may
offer your application more power without sacrificing clarity or
conciseness.

the result is always an array of same length as `p_a`, with each element
either nil or the positionally corresponding actual argument. if an
argument cannot be processed with this simple state machine an argument
error is raised by default.

(as such, `args` of length zero always succeeds. `args` of length longer
than length of `p_a` will always execute the "exhaustion action")

NOTE that despite the flexibility that is afforded by such a signature,
the position of the actual arguments still is not freeform - they must
occur in the same order with respect to each other as they occur in the
formal arguments. such a grammar would be possible but is beyond this
scope (and is addressed by the sibling nodes of this node).

in contrast to the similar-acting "parse from ordered set", this only
matches input that occurs in the same order as the grammar; i.e there
is one cursor that tracks the current head of the input, and one cursor
that tracks the current head of the grammar. neither cursor ever moves
backwards.

changing it from a matching parser to a scanning parser:

way back in ancient times the original inspiration for something like
this was writing crazy method signatures, like e.g imagine an abstract
representation of a "file" that is constructured with either, both, or
none of an ::IO representing the file as a resource on the system, and
a ::String representing the file's desired content. it is
straightforward enough to accept a glob of arguments to the constructor
and programmatically determine which arguments are which, but man alive
is it ever ugly looking. the desire of this, then was to allow method
signatures to exhibit this flexibility and to yet be readable and
concise in both their calls and implementation

(this creation myth also suggests why we don't do "pool"-style (non-
orderd) parsing - we wanted it to be relatively fast, and also possibly
to leverage precedence to avoid grammar ambiguities.)

as such, "scanning" (parsing, even (detailed discussion at [#037])) had
no real meaning in that context - we were just trying to expand an
ordered subset of items to fit within the defined superset, positionally.
the actual "identity" of the items stayed the same.

any who dad doo, the point of all this is that although it doesn't
out of the box treat your functions as scanners, you may find yourself
wishing that it did, and that you could easily take care of semantic
representation in addition to parsing (again see [#037]).

note that while we keep the method signatures simple (monadic in/out),
one way to do scanning in addition to matching is to
indicate `token_scanners` instead of `token_matchers`:
