# argument scanner (in theory and in practice) :[#052]

## (document scope)

(current everything is in here: code notes, adapter notes, everything.)




## scope

this is a fun experiment being frontiered by [tmx] but being housed here
in [ze] as an optimism about its potentially more broad utility.

(and EDIT a redux is spiking in [cm].)

at its design and creation, it was meant to accomodate a CLI syntax
that a bit resembles that of the unix `find` command. specifically,
this is where we get the term "primary" is from that oft-used (but
unexplained) term in the manpage of `find`.

but of course we said, "if we can implement such a syntax for a CLI,
can we instead implement a similar syntax for an API operation, and
from that infer how it would be expressed for CLI?"

if there is a "founding principle" of this sub-library, it is that the
the backend operation can realize any syntax it is able to bound only by
the constraints of our semi-standard (but still in flux) internal
scanner interface.

we can then adapt the operation to a particular modality by "injecting"
into the operation an argument scanner adapted to the particular modality.




## the design objectives

the grand hack here (a proposed solution to a problem we've been solving
in various ways for years) is to meet these design objectives:

  - allow the ad-hoc syntax of an API operation to be expressed for
    CLI in a more-or-less straightforward, regular way token-per-token
    so if you become familar with one syntax, learning to use the other
    is almost trivial. (the "almost" is the subject of the next points.)

  - towards the above, allow the backend API to interpret arguments in
    an "API way" when those arguments are represented in a "CLI way".
    typically this means converting "primary" names "-like-this" to
    names `:like_this` (that is, strings to symbols and the rest), and
    perhaps some ad-hoc translations of value terms, typically from
    certain string name conventions to symbol name conventions similar
    to that example.

  - facilitate a sort of blacklist capability where particular primaries
    are designated to be non-accessible to the user, and are typically
    (although not necessarily) given a semi-hard-coded value instead;
    a process all of which should be fully transparent to the user.
    (below, primaries like these are referred to as "fixed primaries".)

  - facilitate a "front list" capability where the frontend (CLI) can
    add (or perhaps unintentionally mask) primaries not recognized by
    the back. this facility must be mostly transparent to the back.



## the argument scanner "canon" :[#here.1]

(new for [cm], needs to be more evenly integrated into the docs..)


### the `scan_primary_symbol` method

  - assume some unparsed exists

  - result is always `false`/`true`, representing whether it
    did not/did successfully parse a primary-*looking* token
    from the scanner head.

  - when false, *no* state is changed at all (as far as is
    perceptible). more below.

  - otherwise (and true), the scanner is advanced (as applicable)
    and the effective result of the parse is memoized and
    available (only) under `current_primary_symbol`. (see below.)

details/corollaries:

  - the `current_primary_symbol` is an "unsantized normal symbol",
    meaning *not* that it's necessarily "valid" for whatever the
    client is parsing (that's the client's domain, not the
    subject's); but rather it means that the scanner considers
    whatever was as the head as being "well-formed" enough to be
    placed under consideration to this end. what *this* means, in
    turn, varies from modality to modality.

  - since the result produced by `current_primary_symbol` is only
    ever (and always) affected by a call to the subject method
    that results in `true`, a call to `current_primary_symbol` will
    (typically) only ever be invalid before you've ever parsed any
    primaries, and forever after that it will always (typically)
    produce some symbol.

  - see "why does.." next



#### why does `scan_primary_symbol` advance the scanner?

as an implied byproduct of `scan_primary_symbol` having produced a `true`
result, the subject (not client) will have advanced the scanner head
just *past* the relevant token (where applicable). why we keep
saying "where applicable" is explained here:

the general convention is that scanner is *not* advanced past
the relevant portions of the input stream until the corresponding
structure being produced by the parse is validated as being "correct".

advantanges to this approach can include but aren't necessarily
limited to:

  - it can be easier to implement error reporting that is scoped
    to a desired level of granularity when the scanner head is
    pointing to just after whatever was last (validly) parsed.

  - this convention can make it easier to implement grammers with
    a certain amount of ambiguity without ever having to backtrack.

following this convention, then, it would make sense that the
scanner head having moved over the primary token would signify that
the whole primary expression had been parsed successfully.

because it's decidedly outside of the subject's domain to know
what "correct" is for any given business domain, it would then
follow that the client (not subject) should be the one to move
the scanner head over the primary token (in effect "signing off"
that that part of the parse is complete).

however (finally), we discard this convention in the case of
primaries because for clients that expose a `default_primary_symbol`,
the above semantics create confusion at these multiple points:

the confusing question becomes, "if the last primary produced
was arrived at by defaulting, should the next call to `advance_one`
move over the imaginary token that in reality wasn't there, or the
real next token (that doesn't correspond to the primary you just
'parsed')?"

if the answer is the latter, then it is almost guaranteed that
some clients would accidentally hop over a token they didn't intend
to. but if the answer is the former (probably the more natural
choice), then it becomes fragile state that the scanner implementation
has to manage ("what's that you say? advance one? well if the last
primary I produced was defaulted, then i'm going to ignore this and
note that I did this by resetting my state back to normal."). this
situation itself seems guaranteed to trip some clients up.

our cutting of this gordian knot comes in the form of avoiding the
question entirely by saying instead, "if there was ever any primary
token to advance over, we have certainly done it already."

the cleanliness of this solution, then, becomes shorter in code
to implement than the documentation we produce explaining it.





## "the multi-mode argument scanner"

### a proper introduction

the "flagship" and more complicated of the two argument scanner
implementations, this is a compound scanner made up of up to 3
kinds of sub-scanners that parse the argument stream (or give the
appearance of doing so) in ways that achieve CLI-specific needs
while still looking like an argument scanner that a backend API
operation can draw from.

as each next sub-scanner is exhausted in the queue, the next one
becomes the active. the typical scan is complete when the last token
is drawn from the last sub-scanner.

hypothetically this scanner could function with any permutation of
the below three sub-scanners being variously active or not; but
the sub-scanners will always execute in the following order relative
to each other:

  - front tokens
  - fixed primary pairs
  - user scanner

the first is for (in effect) prepending plain old symbols to the
argument stream, for use in routing the request to a particular
backend operation.

the second is how we implement default values (probably as a resulf
of primary subtraction).

the third wraps the ARGV and effects the CLI-specific form of
"primary" syntax.




### (EDIT comments from the original construction site)

(EDIT the below are drawn from comments from the original construction
of the first argument scanners. although they are still relevant, the
previous section is now better written and prehaps redundant.)

  - both because we had to parse the operation name off the ARGV
    before we could know which operation we want to build the
    adaptation for AND because it's more explicit, we tell our
    adapter explicitly the path to the backend operation we are
    calling with `front_scanner_tokens`.

  - each `subtract_primary` has the effect of making that primary
    not settable by the CLI. in most cases we provide a "fixed"
    value for it that to the backend is indistinguishable from a
    user-provided value.

    (note for later: the way we used to do this in [br] was awful)

  - finally with `user_scanner` we pass any remaining non-parsed
    ARGV (which, of course, is written in a "CLI way"). the adapter
    attempts to make the underlying user arguments available to the
    operation for it to read in an "API way" with name convention
    translation as appropriate.




## "all about parsing added primaries" :#note-2

assume that some caller is the backend operation driving the
whole parse (pursuant to our [#052] founding principle). it
will (reasonably) break if we pass it a formal branch item for a primary it
doesn't know about, and that's exacty what "added" primaries are
(typically but not necessarily - but the following handling
still holds regardless).

as such they must be parsed by us and not the backend. because
added primaries could occur anywhere in the argument stream, and
because the subject method is typically the workhorse that the
backend uses to drive parsing logic, we sneak this handling of
added primaries here in this method as something of a hacky
stowaway.

an added primary has the option of interrupting "normal" program
flow by resulting in false-ish. otherwise its palpable effects
must all be in the side-effects effected by its proc when called.

the idealized target use cases are for parsing '--help' and parsing
'--verbose' variously: implementations for the former typically
flow around normal execution and those for the latter typically
don't.

as for parsing the argument values to these primares as necessary,
we can still realize "arbitrary" syntaxes for frontend-only primaries
using the same techniques available to us on the back, it's just that
A) the code is on the front and B) you might be able to make some more
assumptions because of your more narrow modal scope (i.e if you are on
CLI you can assume all elements of ARGV are strings).




## on the interface of the subject "faciliator" performer :#note-1

TL;DR: strange, session-heavy inteface for reasons

given the particular argument scanner's head and a "operator branch",
the (two) various argument scanner implementations probably solve
for a formal primary in more or less the same way from some certain
high level. and regardless, in cases of failure they should express
with the same expression behavior in the interest of DRYness (all
else being equal).

HOWEVER, there is no central `execute` method here: rather, that
sequence of steps that each client is expected (more or less) to
take is manifested here as a series of method exposures. it is the
responsibility of the client to fill a logical "skeleton" of
calls to these methods:

  - with arguments appropriate to that client

  - honoring the implicit assumptions some of these methods make
    about side effects existing from logically previous methods

we have architected this in such a manner only because when we
did it the "other" way it was a tangled soup of many (many)
"hook-out" methods, made more tangled by the adapter architecture
of CLI's muli-mode argument scanner.




## this hacky "oncer" implementation :#note-2

a `once` method (here) is a method defined on a module (class probably)
that when called defines a method on that class that is intended to be
called at most one time per instance.

the subject proc produces a proc meant to constitute the method
definition body for such a method. such a proc must be produced once
per particpating class.

the participating instance must initialize its own `@_lockout_` ivar
with a plain old empty, mutable hash. (we have opted to go this route
instead of mutating the participant's singleton class at runtime.)

the implementation is more hacky than it would otherwise need to be
(with the awful use of sequential integers to generate method names
to serve as the actual implementing method to be called at most once)
because `instance_exec` can't send a block argument to its block argument
(sic), yet we want the participating methods to be able to use block
arguments.

do not let this hack leave this file without finding a better solution
for this.




## for now we can take liberties with the :#note-3

for now (and don't expect this to stay this way forever
necessarily), we can model the definition for an added primary
as a set (here, list) of only procs:

  - one callback proc for handling the parse
    (this proc must be niladic)

  - zero or one proc for expressing the primary's description
    (this proc if provided must be monadic)

given that in the above structural signature the formal procs
happen to have arities that are unique to their formal argument,
we can allow that the argument procs are provided in any order,
using only their arities to infer the intent of the argument.

we can furthermore treat any passed block indifferently to a
positional argument. all of this together is meant to expose a
loose, natural syntax where the user can use the block argument
for whichever (if any) purpose "feels better" for the use case.

for now (in part) because this is so experimental, we take
safeguards to ensure that what is required is provided, and that
the procs do not clobber each other.




# :#note-4

EEK - when we reach the end of the argument scanner and we
ended on a "frontey" primary, then it's hard to hide the
existence of this hack completely from the backend. we are
in effect trying to tell the backend "we did not fail, but
this is not a item."
