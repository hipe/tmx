# the parse narrative :[#001]

## introduction

at this node and below, parsing is conceived of as nothing more or less
than what a "parse function" does. the particular parse function may
employ whatever algorithm(s) it wishes to effect the parse, being bound
only by the limitations expressed below for what it means to be a parse
function.

"grammars" are simply aggregations of user-determined parse functions that
collectively constitute the input to whatever algorithm is being employed
for that grammar. actually, if we do our job right then grammars are
themselves indistinguishible from parse functions.

the question then becomes "what is a parse function?". given the primacy
of parse functions in this library, it is essential that we express a
specification for all parse functions that defines exactly what is assumed
and allowed of them in terms of input, output, and any side-effects.




## parse functions

### input scanners

so, a "parse function" takes as input an "input scanner". the input
scanner exposes the boolean state of whether or not it has unparsed
tokens remaining in its buffer, and if so it exposes that token. as well
it exposes a method to advance the current position by one. any and all
other functions exposed by the input scanner will be functions built
from these.

(for now we sidestep the question of what tokens are and how they got
there. the answers to these questions must in fact be determined by the
application itself. currently the input scanner is implemented simply as
a platform array of mixed (any) values. in the future we would like for
this to work for stream-style scanners as well that for e.g are reading
from a long file, data dump (e.g twitter feed) etc.)

(also we are side-stepping the question of lookahead/backtracking. the
short answer is, one parse function need *arbitrary* lookahead. if ever
we were to make this truly streaming rather than just parsing arrays, we
would have to reconcile the two.)

(the parse function may or may not accept as a logical second parameter a
"selective event listener". if it does so we will use the platform
"block" argument so to implement this will be unobtrusive, and so we can
postpose specification with regards to whether passing an event handler
is formally part of this specification.)

as a result given the input state (the input scanner) that is passed to it,
the function either does or does not succeed. it may be overkill to
state this explicitly, but the success of the parse is a [#hu-003]
"discrete" value, specifically a boolean. there is no "sort of"
succeeding, it either did or it didn't (but certainly if this were not
the case it evokes some potentially interesting ramifications for how
some sort of fuzzy parsing could work; but that is not for today).

a call to a parse function that did succeed will typically result in the
side-effect of having mutated the input scanner (by advancing it across
one or more tokens). we have not yet worked with parse functions that do
not do this and so do not here prescribe it as a thing whose behavior is
defined, except to say "that might be interesting."

1) the parse function whose call did not succeed in parsing MUST result in
   false-ish. whether this result value is platform `nil` or platform
   `false` (the distinction between the two) MUST be ignored by the
   parse engine (itself probably a parse function).

   1A) if a parse function's call fails to parse yet it mutates the
       input scanner state, this beahvior is currently undefined.
       PERHAPS we will allow this one day - duping scanners is cheap; but
       currently this is undefined.

2) the parse function whose call did succeed in parsing MUST result in
   an "output node". the output node "shape" will be defined below.

   2A) if a parse function's call succeeds in parsing yet it does not
       mutate the input scanner, this behavior is currently undefined.
       PERHAPS we will define what this means one day. currently we can
       speculate that while possible, this might lead to infinte loops
       for some grammars.




### output nodes

the output node embodies a successful parse by the parse function. it
encapsulates (and exposes):

  1) any (or no) arbitrary single output value for the parse. this may
     be some arbitrarily complex datastructure (or "object"), this may
     be `false`, this may be `nil`. it is up to the grammar or algorithm
     writer.

     typically for "terminal" style parse functions this output value
     will be something atomic and primitive, like a string, (platform)
     symbol or number.

     it may be for some higher-level parsing functions that what this
     particular value is is ignored, depending on how that function builds
     its own output value. (imagine a function that produces a platform set
     given a stream of "flag"-style tokens. for such a production,
     to associate a particular value for this parse is meaningless, all
     that matters is whether or not the parse succeeded for this
     particular function.)




## node :[#here.A]: a jargon glossary

  + "head token": whatever token is at the front of the token stream at
    that moment; specifically when a parsing agent is not in the middle
    of parsing from it.
