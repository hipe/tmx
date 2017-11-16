# argument scanner (in theory and in practice) :[#052]

## table of contents

  - scope :[#here.s9]

  - the design objectives (and main mechanic) :[#here.b.2]

  - when we advance the scanner :[#here.j]

  - how we advance the scanner :[#here.i]

  - the N-tiered architecture: overview :[#here.s12]

  - tier one of N: the token scanner [#here.C]

  - tier two of N: the modality adapters [#here.D]

    - code note: optional arguments generally and under API [#here.D.2]

  - tier three of N: the narrator [#here.E]
    - local conventions: these method categories [#here.E.2]
    - local conventions: normalization categories for methods [#here.E.3]

  - tier four of N: the argument parsing idioms ("omni") [#here.F]
    - code note: (see) [#here.F.2]

  - tier five of N (experimental): the narrator methods [#here.G]

  - ecosystem provision: trueish feature values [#here.1]

  - code note: local abbreviations [#here.H]

  - the multi-mode argument scanner - a proper introduction [#here.SUNSETTING.d1]
  - comments from the original construction site [#here.SUNSETTING.d2]
  - all about parsing added primaries [#here.SUNSETTING.d3]
  - on the interface of the subject "facilitator" performer [#here.SUNSETTING.d4]
  - this hacky "oncer" implementation [#here.SUNSETTING.d5]
  - for now we can take liberties [#here.SUNSETTING.d6]
  - "EEK" [#here.SUNSETTING.d7]




## scope :[#here.s9]

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




## the design objectives (and main mechanic) :[#here.b.2]

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

    (EDIT below is changing)
  - facilitate a sort of blacklist capability where particular primaries
    are designated to be non-accessible to the user, and are typically
    (although not necessarily) given a semi-hard-coded value instead;
    a process all of which should be fully transparent to the user.
    (below, primaries like these are referred to as "fixed primaries".)

    (EDIT below is changing)
  - facilitate a "front list" capability where the frontend (CLI) can
    add (or perhaps unintentionally mask) primaries not recognized by
    the back. this facility must be mostly transparent to the back.




## when we advance the scanner :[#here.j]

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




## how we advance the scanner :[#here.i]

post "2nd wave", if you want to interact with the argument stream at
a certain high level, you've gotta work with matches. (namely, tier 2
and above.)

at writing there is a hierarchy of three endpoints of matches: there are
feature matches and value matches. (currently there are two kinds of
feature matches (primary matches and operator matches) but this distinction
is superficial.)

these match objects hold the number of "carbon offsets" that were
traversed over the argument stream: simply, the number of tokens.
we call these "carbon offsets" and not just "offsets" just as a cheeky
way to differentiate form the many other kinds of offsets we work with.
(we do not, however, say "carbon" in the code.)

with grammars for traversing "normal" endpoint trees, the pattern is
always that some kind of feature token must be parsed immediately preceding
any kind of arbitrary business value (for example an integer or filesystem
path). post 2nd wave, you as the client will need to be "holding" the
relevant feature match in order to parse the value (in order to respect
[#here.j]).

notwithstanding the above provision, you as the client do not need to have
knowledge of *how many* offsets any match or matches are worth. it is enough
just to hold them. then (pursuant to [#here.j]) when you want to "sign off"
that this leg of the parse is complete, you pass the match to the scanner,
telling it to advance over the match. it is best practice to discard all
references to the match at this point.

(this idea that you should be ignorant of how many "carbon offsets" a
match is worth is especially relevant to the implementation of
`default_primary_symbol`.)

this whole setup makes parsing more transactional; and most importantly
it keeps the parse state out of the injected parser so that the client
is responsible for managing matches and can see where they are and what
is done with them.

finally, these match objects have a single boolean element (ish) of state:
it is a one-time mutex thing that is "ticked off" once the the token
scanner is advanced over the match. (this is saved our tail numerous times,
and made the code much less fragile than its predecessor.)




## the N-tiered architecture: overview (by way of case study) :[#here.s12]

our "first wave" of argument scanning spread quickly throughout the
ecosystem, propelled by its simplcity, power, and the robustity that
came from having grown it from the ground up with no dependencies.

however as it grew to accomodate various client requirements it began to
show strain along these two categories of painpoint:

  - one, it (as a class) grew far too big, violating the [#sli-129]
    single responsibility principle.

  - two, it suffered from too much state.

our solution was to break what was formerly two mechanisms into four.
but the two-mechanism solution is still instructive to understanding
the underpinnings of our N-tiered system today:

you would "inject" one argument scanner into an "omni branch". the
argument scanner was tailored to a particular modality (either API or
CLI, but imagine others), hiding modality details from its client. the
"omni branch" was a collection of all the features available at this
parsing step, that implemented the parsing at this step, in tight
interaction with the argument scanner.

our new N-tiered system is an expansion of these same ideas. each of
the subsequent N sections is an in-depth treatment of each tier.

(see fig.1 (graph-viz) as a complement to the rest of this document.)

our approach at explanation is bottom-up (i.e inside-out); a reflection of
a design principle we tried to adhere to here: as much as possible
we try to avoid letting the smaller components have to have any knowledge
"upwards" of the larger components; whereas the larger componets will
generally interact closely with the lower-level component below them.




## tier one of N: the token scanner :[#here.C]

  - very simple, small API (and code footprint (see!)), just for advancing
    over each token of "stream" (actually array) of tokens.

  - strong, intentional overlap with the [co] scanner
    (possible unification there at #open [#068])
    but with some extra exposures for peeking at tokens an arbitrary
    N places ahead of head.

  - *no* knowledge of modality. i.e we exploit our type-free platform
    language to to use *the same* class for multiple modalities.

  - (we can imagine some modalities that would *not* implement "parsing"
    with a plain old, linear scanner, just as food for thought.)




## tier two of N: the modality adapters :[#here.D]

  - this tier is exactly to accomodate the particular ways in which
    parsing for CLI and API differ (but imagine it for arbitrary other
    modalities).

  - note small code footprint

  - the "narrator" (for now with some apriori knowledge) makes
    certain kinds of mechanical requests down to the modality adapter.
    the modality adapter behaves in a way appropriate to the modality,
    but with an interface that is uniform across modalities.

  - for exmaple CLI might do fuzzy lookup but API does not. this
    difference is hidden within the modality adaptations for these two.

  - the following code note(s) may explain some more of these differences.




## code note: optional arguments generally and under API :[#here.D.2] :[#here.4.2]

the significance to us of formal parameters with optional arguments
is: they are a strange category of formal parameter; one that does not
have a straightforward analog outside of CLI.

since primary and operator tokens look the same under API (as hinted
at in [#here.b.2]); the effect is that under API with a primary with
an optional argument, we interpret *any* token after that primary as
belonging to that primary, effectively making the not-argument (and
possibly defaulting) form employable under CLI only.

(callers of API would need to know this.)

out of context, none of this probably makes any sense. the official home
of optional arguments is [#fi-014.8], which may explain more.




## tier three of N: the narrator :[#here.E]

although not the highest tier, this mechanism stands as the point of
contact for most client code. it's called "narrator" exactly because
it is meant to help produce client code that forms a readable "narrative"
summarizing the client's parsing grammar at a cursory reading.

(yes this description is also apt for the next tier.)

a central design principle at this tier is that the mechanism itself
is stateless (and immutable). the point is that wherever you are in your
code, you don't have to worry about what properites it does or doesn't
have at that moment. (this is a response to the biggest painpoint of
this code's predecessor; what lead to the massive re-architecting that
is now know as the "2nd wave" of argument scanning.)

generally its method can fall into two cateories:

  - methods that produce matches for features (i.e primaries or operators)

  - methods that produce "value matches" (probably in concert with the above)

the following sections will shed light on various architectural and
interface principles that inform the class.




## local coventions: these method categories :[#here.E.2]

it's reasonable to expect certain categories of behavior in a parsing
toolkit, and it's convenient for that behavior to be expressed in a
consistent way. some such categories:

  - when input doesn't parse against what is being asked about, it's
    useful in *some* cases (but not all) to have clear (but not overly
    verbose) error expression.

  - advancing the scanner is essential to parsing, but it's something
    we don't want to have to think about at a certain high level.

for our own sanity we try to have clearly defined terms we use to label
these categories of behavior. here's an overview of some ideas that have
emerged:

  - when the word "parse" is used in a method name at tier four or below,
    it has very specific meaning: the result is an immediately usable value,
    not a wrapped value (so provision [#here.1] applies). the feature or
    value is expected and so if it cannot be parsed, expression is emitted.
    and crucially: the token scanner *is* advanced over the relevant
    tokens in the scanner.

    as it would turn out, we have refactored all such methods *out* of the
    library: interaction with the rest of the library is more seamless if
    we encourage consistent parsing idioms. however we have left this
    description here to provide a point of contrast for the below points
    and for consistency with a possible future or other referrant bodies.

  - when the word "procure" is used in any method here (and probably any
    method in the ecosystem), it means that expression is emitted if the
    corresponding feature or value is not parsed. at tier four or below,
    methods with this word in the name result in a wrapped result on
    success, and false-ish on failure. the result is often (if not always)
    a [#here.i] match object.

  - when the word "match" is used in any method here, it means that a
    wrapped value is resulted on success and falseish on "failure"; but
    *nothing* is ever emitted and the scanner is never advanced. as such
    methods like these are considered more lowlevel, and can be used in
    the implementation of the other categories of method above.




### the specific method sections

we want methods that are logically (so structurally) similar to each other
to be close to each other. this criteria trumps the criteria of wanting to
group them by feature. so, the methods are grouped by method semantics
first, and then within each group, the methods are ordered by feature.

the first order is `parse_X`, `procure_X_after`, `procure_X`, `match_X`.
(so ordered because the former rely on the latter conceptually or actually.)

within each section, the feature order is something like: numbers, regexes,
features, .. (from higher-level to lower-level:)

  - `parse_X` - the highest-level form of parsing method, this form can
    only be used to parse entities whose valid value is trueish [#here.1].
    NOTE we have refactored this category away in this library, but we are
    leaving its description here to provide contrast to the other categories;
    and also because despite having no methods, the name convention remains.
      - assumes one or more? NO
      - advances the scanner? YES
      - on success, results in the value itself (not a wrapped value)
      - whines on failure? YES

  - `procure_X_after` - a special form used in conjuction with a feature
    match. used assuming the scanner hasn't yet advanced past the feature
    match (so that the client decides when to advance, and will typically
    advance (on entity completion) over two at once: over the feature token
    and over the value token).
      (the following four are same as in next section)
      - assumes one or more? YES
      - advances the scanner? NO
      - on success, results in a "value match"
      - whines on failure? YES

  - `procure_X` - like the above but no "after" mechanics.
      (the following four are same as in previous section)
      - assumes one or more? YES
      - advances the scanner? NO
      - on success, results in a "value match"
      - whines on failure? YES

  - `match_X` - one of the lowest level public API matching method categories,
      - assumes one or more? YES
      - advances the scanner? NO
      - on success, results in a "value match"
      - whines on failure? NO




## local conventions: normalization categories for methods :[#here.E.3]

(as a cheeky distilled overview, the methods we are disucssing are
matched by:)

    /\A_+procure_via( PLAIN_METHOD | MAP_FILTER_PROC | IS )_after\z/

ideally when we implement the parsing for a particular type of feature or
value, we would like it to be structured in a consistent way regardless of
the particular [#here.E.2] category of method or methods that is being
targeted. the proto-conventions here are a response towards that.

this is not fleshed out strongly as a convention, but nonethess
we want to keep these ideas here as a placeholder.

these capital-letter words appear in some of our methods: `PLAIN_METHOD`,
`MAP_FILTER_PROC`, `IS`. to avoid other (already taken) terms, we will
use "normalization" as the label for their category.

  - a `PLAIN_METHOD` receives a value match as its only argument. its
    result when trueish is interpreted to be a value match wrapping a
    valid value (either the original value or one translated from it).
    otherwise (and the result is false-ish), the method itsef must have
    emitted its own expression of failure.

  - a `MAP_FILTER_PROC` receives a value match. its result when trueish is
    interpreted exactly as above. when normalization is not possible, a
    client-provided block will be used for producing an expression of failure.

  - an IS normalizer is called with a method name to be used as a test
    method. the method receives the value match. its trueish/falseish
    result is uses as a yes/no indicating whether or not the value passes
    the criteria. on failure, an expression is derived from the method
    name.




## tier four of N: the argument parsing idioms ("omni") :[#here.F]

this mechanic (with its mouthful of a name, formerly "parse arguments via
feature injections", and always nicknamed "omni") is something of a sublime
confluence of two of our most essential tools: argument scanners and
feature branches.

like its below tier (narrator), it too is stateless. but unlike the
narrator, this mechanism is comprised of feature branch injections.



### compare to `getopt`

the best way to understand interaction with this this mechanism is to
understand the techniques of argument parsing in oldschool UNIX utilties.
we write this making no assumptions of familiarity there.

in shell scripts that use `getopt` (see its manpage), they traverse over
the elements (strings) of input arguments, at each argument token running
it through something like a switch statement, looking for a match.

when an option (in our lingo, "primary") is matched, either an argument
is consumed or not based on the [#fi-018] argument arity of the parameter
(i.e whether it is a flag or other). perhaps at this point the any value
is validated/normalized too.

this step is repeated until all input is consumed; emitting meaningful
expressions of error when appropriate.



### synthesis

the subject is like a deep (deep) abstraction of this idea. instead of
a switch statement (or similar), you inject the subject with one or more
"feature branches". the subject also holds the argument scanner.

at each step (or perhaps only one step), you run the head of the argument
scanner over the feature branch injections looking for a match. as matches
are made, *some agent* (see [#here.j]) will have to advance the scanner
appropriately. in this manner (as one of many) we repeat this step until
the argument scanner is consumed completely.



### also

note that it is possible to achieve useful parsing by using only the
mechanism at the tiers below the subject. some clients may opt to do
their own parsing at a lowel level.




## code note: used only in testing .. :[#here.F.2]

this `redefine` method is used only in testing. hypothetically you would
think this would be useful in production, where we keep an essential
grammar structure in memory and dup-and-mutate per invocation. however,
in practice we do not because many injections have a counterpart injector
(to implement the features), one which is tied to the invocation runtime.
so while the broad approach outlined here would be possible, it would
sacrafice code clarity with little performance gain.




## tier five of N (experimental): the narrator methods :[#here.G]

this is an experimental abstraction of patterns seen in several
clients. this is truly an experiment, because while it does reflect
pragmatic abstraction, it flies in the face of the founding drive
behind the 2nd wave and other current trends:

  - it's *very* stateful. some methods must be called in a certain
    order with respect to each other (in hopefully obvious ways).

  - it's a mixin module that writes to ivars, something we frown
    upon (hence the ugly ivar names, avoiding namespace collision)

  - clients would typically include this as a mixin module,
    something we generally trend away from as a violation of
    composition not inheritence.




## ecosystem provision: trueish feature values :[#here.1]

this tag marks places throughout the code universe who should know
about this provision: feature branches that want to participate in our
argument scanning must deal only in feature values that are trueish.
that is, neither `nil` nor `false` can be a feature value under this
system.

this provision is adopted because the concert of these two factors:

  1) in practice most feature values are at the least symbols if not
     arbitrary user objects, making this provision as cheap as free to
     adopt for all our real world use-cases

  2) it makes code much more readable and efficient when we don't
     have to wrap every value coming out of our feature branches.




## code note: local abbreviations :[#here.H]

  - `ff` = feature found
  - `fm` = feature match
  - `of` = operator found

and so on, possibly for { primary | operator | field } { match | found }




## "the multi-mode argument scanner" :[#here.SUNSETTING.d1]

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




## (EDIT comments from the original construction site) :[#here.SUNSETTING.d2]

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




## "all about parsing added primaries" :[#here.SUNSETTING.d3]

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




## on the interface of the subject "faciliator" performer :#note-1 :[#here.SUNSETTING.d4]

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




## this hacky "oncer" implementation :[#here.SUNSETTING.d5]

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




## for now we can take liberties with the :[#here.SUNSETTING.d6]

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




# "EEK" :[#here.SUNSETTING.d7]

EEK - when we reach the end of the argument scanner and we
ended on a "frontey" primary, then it's hard to hide the
existence of this hack completely from the backend. we are
in effect trying to tell the backend "we did not fail, but
this is not a item."




## document-meta

  - #pending-rename: from "the philosophy of X" to "the X architecture" maybe

  - #tombstone-A.1: during 2nd wave:
    - got rid of absurd justification of weird scanner advancing rules around default primaries
