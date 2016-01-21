# imperative phrase wall of text :[#014]

the presence or absence of any apparent next phrase in the stream
is distinct from whether that phrase parses all of its parts off
of the stream successfully, which in turn is distinct from whether
the operation is received without failure upon delivery.

we need subject clients to be able to distinguish between reaching
the end of the stream vs. encountering a failure to build some of
the parts - some such failures raise argument errors but others do
not: a "soft failure" might occur if (for example) a valid component
cannot be resolved because whatever happens to be in the argument
stream fails against whatever arbitrary business-specific logic the
component model expresses in its construction method.

so there is a MANDATORY two-point interaction with each next phrase
object in concert with parsing the argument stream:

because "imperative phrase" is the toplevel grammatical structure;
whenever there is anything in the stream, it is interpreted to be
the beginning of such a phrase. as such, each next `gets` on the
our stream will always result in a subject IFF there is anything
left in the argument stream.

the second interaction MUST occur in lockstep, after the first and
before the next first (as it were): to keep it simple, *all* of the
parsing happens when we try to convert the parse to a ("deliverable")
unit of work:

if the result of this call is true-ish, the result is a deliverable
(i.e. "unit of work") that the parsing client should memoize for
later. otherwise (and the result is false-ish), this is an indication
that the parse failed in some soft way (which should have coincided
with an emission). such a failure MUST trigger the failure (i.e
stopping) of the whole parse.
_
