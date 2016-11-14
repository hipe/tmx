# the operator branch structure pattern :[#051]

## beginnings

for driving an argument scan, a popular choice of ours lately is
to use a plain old hash as a logical "branch" structure, with each
of the hash's entry pairs acting as the possible "branch items":

the head of the scanner (or a normal symbol derived from it) is
tossed as a key against the hash. if an entry is found in the hash,
the value of the entry is used (somehow) to drive the next step of
the parse.

(often the values in the hash are method names, but this entirely
the choice of the caller. compare a more conventional implementation
of such a "control-flow structure" by switch statements (platform:
case expressions) or if-else chains, which could be used similarly.)

to date this pattern has served our needs well and has discovered
broad usage, becoming a near founding principle of the [#052]
argument scanner stack.

a small sliver of strain, however, appeared when we wanted to apply
this useful pattern to cases where the "representational structure"
was "normal", but something other than a hash.

(specifically we mean a filesystem directory: instances of this
strain were tracked by [#051]. at writing instances are
1x [ze] and 1x [ts]).

as such, we now conceptualize the above described hash as a concrete
example of an abstract "structure-pattern" endemic to parsing with
argument scanners. we have tentatively dubbed this structure-pattern
"operator branch".





## first swing at a definition will be via the subject

the objective of the subject, then, is twofold: 1) let a directory
act sort of like one such hash for the purposes of argument-scan-
driven parsing; and (2) approach a formalization of such an
interface so that one day we can have hashes, directories (and
whatever else) be façaded behind adapters so that the argument
scanner stack can be refactored so that it parses not against
hashes but against operator branches.

(we will probably want the ability to aggregate a series of these
nodes into a compound such structure too.)
