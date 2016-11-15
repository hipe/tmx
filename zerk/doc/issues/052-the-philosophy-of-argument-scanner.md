# argument scanner (in theory and in practice) :[#052]

## (document scope)

(current everything is in here: code notes, adapter notes, everything.)




## scope

this is a fun experiment being frontiered by [tmx] but being housed here
in [ze] as an optimism about its potentially more broad utility.

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




## here is a description for all "multi-mode" argument scanner constructions:

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
