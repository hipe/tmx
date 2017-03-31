# "defined attribute" :[#002]

## introduction to the "meta-model"

i hope you like the word "meta" because we are going to use it a lot.

without introducing yet what we mean by "meta-model", "meta-association"
or any of the rest, we'll say that the work here represents a default set
of meta-associations that is available "out of the box" to clients of this
library; a set that is distilled from at least six years of thirteen (13)
different disparate libraries that all attempted more or less this same
mission of "modeling", but each offering their own weird twist of a solution.

like the astronauts of voltron teaming up to form their giant super robot,
this, then, is a distillation of all those efforts into one unified, self-
consistent (and dare we say "clean") library; a culmination of the most
useful of these ideas after having pared many (many) others away.




## introduction to this document and its node

rather than over-compartmentalizing theory from practice, we interleave
discussion of our particular libraries with the broader ideas they attempt
to manifest, as a means of explaining both the libraries and of the
"meta-model" theoretical framework they exist to test the rigor of.

the jump from the oldest section in this document (which is the next major
section) to the second-oldest (and the rest of them) is a span of more than
3 years. we haven't gotten around to modernizing this oldest section yet
for purely sentimental reasons.

the first contemporary section starts at [#here.C]. that same
identifier is also used as a tracking identifier for what we'll call the
"defined attribute sub-sub-system", which is a collection of closely
related libraries built around a theoretical framework introduced under
[#same] below.



### table of contents

(the numbering and ordering rationale of this is per [#bs-016.2] conventions.)

  - [#here.A]    introductory sections(s), table of contents & related.
  - [#here.2]    formal vs. actual (the old thing)
  - [#here.C]    feature overview of defined attributes, actors
  - [#here.F]    the "rabbithole" of axioms & corollaries
  - [#here.4]    weirdess in how requiredness is implemented
  - [#here.E]    the new lingua franca, maybe other narratives tied to code
  - [#here.G]    [ a formal doo-hah on "association" ]
  - [#here.H]    a formal doo-hah on "meta-associations"
  - [#here.9]    [ a formal doo-hah on "meta-meta-associations" ]  (STUB)
  - [#here.J]    [ a formal doo-hah on "N-meta associations" ]




## formal attributes vs. actual attributes :[#here.2]

(EDIT: very old. really needs rewrite.)

What is the essence of all data in the universe? It starts from within. with
metaprogramming.

Let's take some arbitrary set of name-value pairs, say an
"age" / "sex" / "location" of "55" / "male" / "mom's basement"; let those be
called 'actual attributes'. You could then say that each pairing of that
attribute with that value, (e.g an "age of 35") is one "actual attribute"
with "age" e.g. being the "attribute name" and "35" being the
"attribute value."

Now, when dealing with attributes you might want to speak in terms of them in
the abstract -- not those actual values, but other occurences of particular
values for those attributes. We use the word "formal" to distinguish this
meaning, in contrast to "actual" attributes.

For example we might want to define 'formal attributes' that define some
superset of recognizable or allowable names (and possibly values) for the
actual attributes. For each such formal attribute, this library lets you
define one `Formal::Attribute` that will have metadata representing the
particular formal attribute.

To represent an associated set of such formal attributes, we use a
`Formal::Attribute::Box`, which is something like an ordered set of formal
attributes. Think of it as an overwrought method signature, or formal function
parameters, or a regular expression etc, or superset definition, or map-reduce
operation on all possible data etc wat. If the name "box" throws you off, just
read it as "collection" whenever you see it.

To dig down even deeper, this library also lets you (requires you maybe) to
stipulate the ways you define attributes themselves.

Those are called meta-attributes, and there is a box for those too..

So, in reverse, from the base: you make a box of meta-attributes. This
stipulates the allowable meta-attributes you can use when defining attributes.
With these you will then effectively define (usually per class) a box of
attributes, having been validated by those meta-attributes. Then when you have
object of one such class, it will itself have (actual) attributes.

(There is this whole other thing with hooks which is where it gets useful..)

To round out the terminology, the object that gets blessed with all the DSL
magic to create meta attributes and then attributes (and store them!) is known
as the "definer" (`Formal::Attribute::Definer`) which is what your class
should extend to tap in.

It may be confusing, but the library is pretty lightweight for what it does.
Remember this is metahell!




## feature overview of "defined attributes", actors :[#here.C]

before explaining what every term means, we'll give you a broad overview
of the "defined attributes" facility using the langauge that we'll develop
throughout this document, as a broad (if jarring) introduction to both the
library and the language.

  - association sets of this sort are specified mostly with simply a hash:

    the association set definition has a surface form that is simply a
    hash whose keys are all symbols and whose values are all either `nil`,
    a symbol, or an array of "atomic" (i.e primitive) values that follow
    a particular grammar to be explained.

    these values of the elements of the hash express the [#here.H] meta-
    associations (if any) of each association. for example:

        {
          first_name: nil,
          last_name: :required,
          social_security_number: [ :required, :regex, /\A\d{3}-\d{2}-\d{4}\z/, :_sensitive ],
        }

    (the example is didactic. `regex` not a built-in meta-association.)


  - there is a fixed set of recognized "meta-associations"

    (this set is determined by the library, not the client.)
    (you are not expected to know what "meta-association" means at this point.)


  - you can also employ "cheap" arbitrary meta-associations

    if you want to associate any arbitrary ad-hoc, flag-like meta-
    associations to any one or more of your associations you may do so by
    using symbols that start with an underscore. (none of the fixed meta-
    associations will ever start with an underscore, as part of our public
    API.) as suggested, meta-associations like these cannot accept any
    (meta) arguments; they are "niladic" ("flag"-like).

    (this is a bit of a hack that exists because it's too useful not to
    have, and too easy not to implement in this manner.)


  - you can also employ "proper" arbitrary meta-associations inline :[#here.C.4]

    .. with the top secret meta-association API, which is perhaps a
    feature island but covered and tracked with [#same] and/or [#here.9].


  - [no] dynamic associations:

    contrary to [#012.J.3], collaborators of "defined attributes" were
    generally able to implement around the assumption that the involved
    set of associations is not determined at "invocation time", but rather
    that it is fixed per runtime. at one time this was relevant because it
    allowed collaborators to make an "indexing pass" to do some early
    calculations that could be be used (and re-used) during normalization
    of the association set; hence the original reason for creating an
    "association index" (at writing still perhaps the centralest node in
    the "defined attributes" library-family). however:



  - (however) static indexing has been mostly removed:

    when we assimilated to "one ring", we refactored-out two static array
    passes (#tombstone-C). generally, "indexing" each association around
    one or another particular category was useful then, and is not now.

    "interplay 3" below explores one reason why this is so.

    BUT NOTE something like "indexing" is still employed for the next
    point.


  - there is weirdness around how "requiredness" was/is specified and
    implemented is discussed at [#here.4].




## intro to & contextualization of "defined attributes" in plain-er language

what we refer(ed) to colloquially and in code as "defined attributes" is
formally a list of [#here.G] "associations". we may use these two terms
("attribute" and/or "association") somewhat interchangably, perferring one
over the other mostly for idiomatic and/or historic reasons. (these terms and
terms like them are given perhaps exhaustive coverage at [#012.appendix-A].)

for our purposes here, these associations express (somehow) their
"requiredness" (formally "parameter arity") and maybe they produce default
values, among other characteristics. these characteristics themselves have
a system of classification, which we refer to formally (again) as
"meta-associations".

the subject of "meta-associations" has its own [#here.H] dedicated section,
and yes, there is (or was) even a [#here.9] "meta-meta-association
justification".

if you're not angry enough already, there also is (or was (or will be)) an
[#here.9] "N-meta justification", at which point the rabbit hole will end.

(there used to exist two dedicated documents on these topics but at
 #tombstone-C we assimilated them into this one.)

it is recommended, however, that you begin here before consulting those
sources because A) they are intended to serve as more of a reference for
theory we lay out here rather than an authoritative source, and B)
(at writing) those documents are in much worse shape than this one (EDIT).

here, then, we explain what these classification mean and how
they are related.




## into the rabbit hole: experimental axioms, theories and corollaries thereof :[#here.F]

we'll say some stuff and derive some stuff off that. in so doing, we're
both building a "modeling grammar-space" (i.e a "meta-mdoel") and we're
demonstrating a critical method that can be used to assess modeling grammar
spaces generally.



### axiom 1: requiredness

let's accept this axiom:

  - every association is either required or optional.

let's contextualize & deconstruct this statement "completely":

  - for lack of a better name, we call this meta-association "requiredness".
    (names of meta-associations are nouns, and we frequently have to make
    nouns up for these names ("neo-logisms"). we also make up adjectives for
    meta-associations when apprpriate, like "defaultant".)

  - we can call this meta-association a "finite enumeration" because there
    is a known, bounded, discrete set of possible values it can be (in this
    case, "required" or "optional"). (using our arcane but robust lexicon
    of [#hu-003.056], a finite enumeration would instead be called a
    "unary category". that reference contains more than anyone could
    possibly want to know about the characteristics of such structures.)

  - we call this meta-association "universal" because it applies to
    every association. that is, for any association, there is one knowable
    and known value from the enumeration associated with it. (this
    universality is not in any way intrinsically axiomatic; rather, we say
    it's universal because it's useful for our purposes for it to be.)

  - it is impossible for an association to be both required and optional.
    to any reader any familiarity with the domain (or even just the words)
    it may sound obvious, indeed so obvious that to dissect it sounds overly
    technical or even obtuse; but we offer this in the terms of our critical
    model because this example exhibits an important characteristic of
    enumerations generally: enumeration values are mutually exclusive in
    their application to an instance. since requiredness is an enumeration,
    it is then impossible for an association to be both required and
    optional. again, this characteristic of mutual exclusivity in
    application applies to all enumerations.

  - furthermore still, we can call this meta-association "binary" because
    there are exactly two values (elsewhere "exponents") in the enumeration.
    i.e a "binary" meta-association is a kind of enumeration. ([#hu-003.032]
    is the authoritative (and tracking) reference on binary categories.)

so to restate this, "requiredness is a universal binary meta-association".



### detour: parameter arity

"classically" we conceived of "requiredness" as "parameter arity". as an
[#014] "arity space", it can have a broad range of values (possibly infinite)
that can be applied to an instance.

corollaries of a meta-model with this provision *were* interesting. for
example, is there any useful difference between, on the one hand, a
parameter arity of one plus a polyadic argument arity vs. (on the other
hand) an argument arity of one plus a polyadic parameter arity (whew!)?

if we cared to answer this, we would consult the table in [#014.G], and
then we would discover that it does not answer this question because for
whatever reason that system has allowed *parameter* arity to be polyadic
but it has not allowed for a polyadic *argument* arity.

this is the conclusion we come to on such matters today: for something like
at least 98% of our practical, day-to-day modeling needs it seems that
modeling "requiredness" in such a way was superfluous overkill. (in other
words, when we first discovered the hammer of "arity", we may have become
guilty of everything looking like a nail.)

parsimony holds that since it is usually (always, even) simple enough just
to say that an association is either "required" or it isn't, that we should
keep our meta-model simple, and stick with a universal binary here.

we're not sure but we have a hunch that this simplification will have
zero cost against our longterm goals of (wierdly) [#mt-015] generated
modality clients.



### detour: parameter arity (again)

however, there might yet be some use to this term of "parameter arity":
if we want to speak of the requiredness *of* certain meta-associations,
it may be confusing if we use this term "requiredness", since the term
is itself a meta-association. now, right out of the gate we don't even
know what this would mean because we haven't defined how we assert
requiredness, so let's do that:

  - if an association is "required" it must have an effective value that
    is any value other than `nil`. otherwise (and it is optional) there
    is no assertion of any kind applied to the value of the association.

for one thing, we haven't defined what we mean by "effective value" and
we won't bother doing this yet as it's a detail.

for another thing, there might be other useful definitions for how we assert
requiredness other than this one (for example we might say that that a
requiredness check passes for any "provided"/"known" value, or any other
arbitrary rules) but because we need some definition we'll use this one
because heuristically we have determined it to be the most broadly practical.

but now that we have a general sense for requiredness, both in terms
of how it looks when specified in a model and for how it can be applied
to an entity, we can use it (as a starting point at least) for for
business modeling and for meta-modeling..



### axiom 2: defaulting intro

using everything we've build up so far (and one thing we haven't introduced,
we'll say that

  - "defaultancy" is an *optional*, *binary* "finite state enumeration"

so, by "state enumeration" we mean something like the "finite enumeration"
introduced above, but with details added: whereas a "finite enumeration"
has a set of discrete values it can apply with, the finite *state*
enumeration has a set of discrete *states* that describe its valid values.
really, "state" is just a cop-out word here to mean "anything we describe."
the significant point is that such an association (used to describe meta-
associations) has all the properties of a "finite enumeration" and also
it required some describing in plain language (and then code) to specify
(and then implement).

so what that means for us here is that "defaultancy" if employed (because
it's optional, remember) has two valid states it can assume (by this
somewhat arbitrary meta-model):

    1) a defaulting can be specified by value
    2) a defaulting can be defined by function

[#012.E.2] justifies how it's useful to broaden the API for defaulting to
accomodate complexity, and in so doing it becomes necessary to allow
defaulting to fail. this is why we have provisioned (2), although note
that this provision is not strictly necessary; it just provides you with
a more powerful meta-model.

we could of course expand this list to accomodate other kinds of wild
defaultancies, or we could contract it to just (2) which can subsume
(1) with some cost. or we could contract it to just (1) and disregard
the above provision.

but for now let's just accept at face-value that we want both of these
two provisions in our meta-model, because what's more interesting is
what we'll derive from that in the section after next.





### detour: making optional things required

it's worth mentioning now we can convert most optional binaries to
required "trinaries" through the use of [#hu-003.092]
"the axiom of univeral applicability". it's a fancy, formal way of saying
that if one of N states is *possible*, then (almost) always one of N+1
states is *certain*, if you can make the "plus one" be "none of these/other".

(conversely, it then follows that you can take any required finite
enumeration and convert it to an N-1 optional finite enumeration, if one
of the states or "exponents" of the first enumeration the same value
(probably `nil`) that's used to represent "not provided". huh? nevermind.)

in this case we would simply state that that `nil` is one of *three*
valid states for defaultancy (provided  that `nil` isn't already a possible
value for any of the other states) but we don't because to us it doesn't
"sound" "natural" to say that defaultancy is a required meta-atrribute. whew!




## interplay 1: defaultancy and requiredness

as offered above, we're modeling defaultancy as an optional binary finite
state enumeration, and requiredness as a universal binary meta-association.

to restate what this means more naturally, every association is either
required or optional, and any association might be defaultant. if it is
defaultant it must be specified in one of the two available ways to
specify defaulting. (the fact that there are two ways to specify defaults
is somewhat arbitrary, but really so is the whole meta-model #[#here.theme-2].)

now, one of the earliest "clevernesses" of the subject library was the
axiomatic assertion that it makes no sense to say something is required
and also to provide a default for it (because if it has a default, it's
not really required, is it?). indeed, for some definitions of "defaultant"
this axiomatic assertion holds.

we then went so far as to work this into the meta-model deeply: if something
specified a default, this implied directly that the association was
optional. furthermore to state such an association as optional explicitly
was an argument error, because #[#here.theme-1] the meta-model wanted to
reinforce this axiomatic assertion to the model author.

so far so good, right? well the monkey wrench was thrown at us when
we had to provision for the real possibility that defaulting can fail
([#012.E.2], again).

given this new provision it then becomes meaningful to model an association
that is both required and has a defaulting function, because a required
association that has a defaulting function that fails should fail the whole
invocation whereas an optional association whose defaulting function fails
should not. whew!

hence our perfect, simple model didn't scale up to the power we wanted.
so we had to discard this axiomatic assumption, but only sort of:

recall the two ways of modeling defaultancy: 1) by value and 2) by
function. only one of them can fail: if you specify a default with a plain
old value, then there's no moving parts so there's no way for it to fail.

as such, for defaults that are specified by value the axiomatic assumption
can still hold and we can still effect the same active, assertive
implications of this (namely that optionality is strictly implied).
elsewhere in code we recognize this distinction and possibly use it to
dissuade from redundant specifications in models. in more detail, if it is
true that specifying a default-by-value always implies that the association
is optional, then it is always redundant to say so explicitly. it would be
like ordering your food "to go", and also "not for here" - not only is such
an expression discouraged, but the meta-model prevents it [#here.theme-1].




## interplay 2 (tentative/flickering): "nilifying"

another feature near which interesting "interplay" occurs is [#012.J.4]
"nilification". imagine any association that is not required, and for which
there is no defaulting, and for which there is no known value in the
"valid value store", and for which (finally) there is no corresponding
provided value in the argument stream. the question is, should this value
get "nilified" (that is, set to nil) in the store?

(ask this question for both a "normalize-in-place" scenario and for when
normalizing input from an external argument source.)

in a world where the answer is always "yes", then defining an association
as `optional` (and not providing any default) is equivalent to defining
the association as having a default of `nil`.

recall in the previous section that our meta-model might try to dissuade
us from a extraneous detail in our model by disallowing us to express an
association that is both optional and has a value-based default.

so if *that* provision holds as well as the one we introduced just now,
there are then two synonymous ways to express the same thing in this meta
model: either the `optional` modifier or a default of `nil`.

as is the meta-model's habit #[#here.theme-1], it wants try and prevent
synonymous expressions; i.e it would rather enforce one single way than
allow a variety of different ways of expressing the same thing, by the
rationale that if models are written consistently and concisely then they
are easier to understand, and conversely models that are harder to read and
understand may lead to more bugs, or make bugs harder to fix. (or more
enigmatically, [#ts-001.4.2] "all bugs stem from bad design".)

this provision (to the extent that it is implemented by the meta-model)
comes down to this: we can simplify things by forbidding the use of
`nil` as a value-based default. to accomplish the equivalent of this
meta-association (again with the provision that "nilifying" happens),
use the `optional` modifier instead.




## a semi-deprecated interplay 4, here for posterity and to exercise thought:

in [#012.F.B] we introduced the general idea of "extroverted" associations
as those associations that need special, inductive activation rather than
just being engaged passively by virtue of them being referenced by the
argument stream.

characteristics that would qualify the association as being classified
as "extroverted" include but are not limited to characteristics we have
presented in this grammar-space we have developed here so far: defaultancy
and requiredness. (these classifications relate to the two meta-associations
we have presented above as axioms.)

that is, if an association is defaultant it needs extra work to be done
at the end of a typical normalization (for most definitions of defaultancy),
regardless of whether or not a corresponding actual value was passed in the
argument stream. likewise (and more simply) if an association is required it
needs this same sort of special attention towards the end of the
normalization too, and in this case this is without regard to whether there
is any external argument source at all. (that is, if the implementation of
"requiredness" cannot "look beyond" that set of argument values that is
"provided" and/or already existent, then it is surely broken for any
imaginable definition of "requiredness", because otherwise what is
the point of requiredness?)

anyway, we refer to associations that need this kind of extra work as being
"extroverted", and the characteristic that unifies them is they have work
that needs to be done regardless of whether or not they have corresponding
actual values in the argument source and/or value store. we refer to the
algorithmic step(s) that do this work as the "extroversion pass".

so having said that, the corollary of this section was this: for an
association set (i.e "defined attribute set") that has *no* extroverted
associations, there is never a need to do this "extroversion pass" because
there are never extroverted associations that need special handling.

we used to call this "extroversion pass" the "normalization point", and
it was important because some clients (or enhancement libraries/base classes
for clients) needed to reconcile when this normalization point occurred: if
they didn't call it at all, then this would effectively break the
implementation of normalization; but if they called it at a point when the
"entity" (in whatever incarnation) was not yet "complete", then for example
"missing required" errors could engage prematurely.

one application of this corollary was that for those clients who "knew"
they didn't have any extroverted associations, they could disregard this
otherwise essential step (method call).

another application of this corollary was that for normalization algorithms
that did pre-indexing (as the subject library once did (and still does to
a lesser extent)), if they saw that they had no extroverted associations
at all then they could arrange things to skip the "overhead" of this
"extroversion pass" entirely.

both of these applications of this corollary, however, have been anulled:
for one thing, all of the participants that used to concern themselves with
the obligation of calling this "normalization point" are now served by a
[#012] unified normalization facility, freeing them from the responsibility
of worrying about if/when to issue this "normalization point".

but the other thing (the main thing) is the remainder of this section:

to restate ground covered in "interplay 2" above, if our normalization
algorithm provides [#012.J.4] "nilification", then every optional association with no
default value is (for practical purposes) is indistinguishable from an
association whose default value is `nil`.

now, to synthesize almost everything we have presented so far (grammatical
space and critical framework alike):

  - every association is either required or optional.

  - every required association is "extroverted".

  - every optional association is able to resolve a default value or it isn't.

  - every optional association that resolves a default value is "extroverted".

  - every optional association that does *not* resolve a default value
    effectively has a default value of `nil`, hence making this association
    also extroverted (IFF "nilification" is a provision).

if you accept the delicate cascade of all the above assertions, then
*every* association is extroverted, making extroversion itself an extraneous
categeory! what a wild ride!!

in practice, however, we want "nilification" to be a configurable choice
and not a universal rule. because of this (and apparently only because of
this), extroversion is still a category. regardless, it's a bit of an
exercise in semantics. what everything comes down to is that the more we
develop this meta model, the more we realize we will probably always want
a dedicated extroversion pass in our normalization.




## axiom 3: argument arity

"argument arity" is often a provision (requirement) of the meta-model, and
it [#012.theme-3] weaves throughout our discussion of normal normalization.
deconstructing argument arity in the same manner that we have done for
other meta-associations is a good exercise for our critical method, and
it is from this point that we embark on meditations that comprise the
following two "interplay" sections.

although [#same] and [#014] are more appropriate introductions to the
concept, here we offer this axiom:

  - argument arity is universal.

that is, it's reasonable to ask of *any* association, "what is its
argument arity?" (as with axiom 1, whether or not there is some deep,
intrinsic reason for this to be so; it is useful to us that we conceive
of it as being so, so it is #[#here.theme-2].)

to go further, the question is not "does it *have* argument arity"? but
"what *is* its argument arity?". that is, every association has one
(i.e it is universal).

so the next question becomes, what is argument arity?

  - argument arity is a finite enumertion (a concept presented above).

as with "parameter arity", this is immediate a contradiction in terms:
[#014] seems to suggest that arity spaces are unbounded; that there is
an infinite possible values that an arity space can be, whereas a
"finite enumeration" is by its very name sort of the opposite of this.

well as with parameter arity, we hold here that "argument arity" is just
a label. we're not acutally going to contemplate what different arities
would mean to us except a very small set, which we [#here.theme-1] simplify
down to these:

  - an argument arity of one (a.k.a "monadic", the default and so usually not named)
  - an argument arity of zero (colloquially and now formally called `flag`)
  - an argument arity of possibly more than one (colloquially and now formally `glob`)

so finally:

  - argument arity is a universal trinary finite enumeration

that is, every association will classify as having exactly one of the three
"exponents" listed above. how this axiomatic provision interplays with the
others is the subject of the following two sections.




## interplay 3.1: the `flag` argument-arity plus requiredness?

if a `flag` (that is, an association with an an argument arity of zero)
were to be required, this *would* have meaning with what we've presented
so far, because flags are a binary finite enumeration whose possible
values are (let's just say) `true` and `false`, and our definition for
passing requiredness is that the value not be `nil`, and `true` and
`false` both classify as "not `nil`".

however note that the (we think) typical [#br-002] "modality client"
implementation for a flag holds that either a `true` value is "sent
back" or no value is sent back at all. if this is the case then when
the flag is "off" it would always fail the requiredness check, unless
we take special care (in our normalization facility, probably) to default
such associations to `false`.

(what clients might do for flags is discussed at in more depth at [#012.F]
near "flag", which for our purposes states that while a client will send
back a `true` or `false` when it sends something back for a flag, there
is no guarantee it will send back anything at all.)

we could again apply [#hu-003.092] "the axiom of univeral applicability"
to say that an optional binary is the same as a trinary, and we could
then discuss what that means here; but our own empirical experience
suggests that this is too much splitting of hairs:

in practice it seems sufficient for the 98% case to think of a flag as
represented as a member variable (or the equivalent) that starts out as
false-ish (i.e `false` or `nil`) and then is "turned on" IFF it occurs
(in its only possible surface form) in the argument stream or equivalent.

in the now established [#here.theme-1] tendency of our meta-model to
dissuade us from expressing our structural design in a "strange" way
in the model when there is a less surprising (i.e more conventional)
way available (all in the interest of enforcing bug-deterrent design),
towards all of this we *might* say:

  - axiomatically, it doesn't make sense for a flag association to say
    anything about defaults. (strictly speaking the client could be
    sending back defaulted values for the flag and we wouldn't know it.)

  - in a similar simplification, we will offer that it only complicates
    things to allow a flag to be required.

however, in the tangles of the cut gordian knot we are leaving on the
floor we now see this: we can imagine cases where a "required flag"
(or something like it) would be meaningful and useful:

imagine a modal dialog box asking you to confirm something, or even
a simple "Y/N?" prompt at the command line: these atomic channels are
"required" in that *some* answer must be construed from the user; it is
not simply a matter of "if you don't say 'yes' we will assume 'no'".
(implicitly or explicitly the user may have the ability to "cancel out"
of the exchange, but this "no answer" case is not the same as the answer
of "no", just as it is in real life.)

if we were to want our meta-model to be capable of making this modeling
distinction (and we likely do), then (probably) either we again allow
the meta-model to model a flag as being required, *or* (if "flag" has
become too overloaded a term) for such a case we would model the
association as a required "binary enumeration"..




## interplay 3.2: `glob` and requiredness?

in a similar vein, if we were to model a `glob` (that is, an association
with an argument arity that is polyadic) as being required, somewhere we
would have to specify and implement whether or not (as internal
representation) the empty array passes this requiredness check. (probably
it should not.) we leave this as a lingering meditation for now.





## floating: ad-hoc normalization?

the "main" subject library's take on this seems to be that you can specify
an association "interpreter" (in the form of a method) and it circumvents
all the other kind of expression available here. the newer, model-oriented
effort (currently codenamed "EK") exposes a plain old ad-hoc normalization
API, but discussion of that happens in [#012] and is not interesting here.




## weirdness in how "required-ness" was/is specified and implemented :[#here.4]

TL;DR: parameter arity's default value is context-dependent, so if it's not
set explicitly on the association, you are no longer allowed to read it by
calling `parameter_arity`. the details:

for reasons that now seem arbitrary but that evolved from a desire
to keep our definitions concise while still being "intuitively" expressive;
there was/is strangeness in how "required-ness" was expressed and implemented
under the auspices of [#037] facility "C":

  - if every association in a definition set used neither the `optional`
    modifier nor modifiers that implied optionality (defaulting (and ??)),
    then this has the effect of every association being treated as optional
    (but note this was perhaps only under facility "C", as discussed below).

  - otherwise (and any one or more association either uses the `optional`
    modifier or modifiers that imply optionality), then the effect is
    semi-unsurprising: those associations that neither state `optional`
    explicitly nor imply it are required.

one "positive" design consequence of this is that a model with "many" (say,
five) associations in it didn't need to "clutter" its surface expression
by stating `optional` over and over again.

but this had problems:

  - there was no way to define an association set where every
    association was required.

  - the "spurious implementation" problem hinted at above and described below.

  - in an effort intended to be parsimonious but that proved shortsighted,
    we posed defaultancy as implying optionality (and hence made their
    corresponding modifiers mutually exclusive to reinforce this).
    we now assert that [#012.E.1] defaulting must be allowed to fail,
    and so it again has meaning to say an association is both required and
    has a default. (in more detail, providing a default automatically
    implies that a thing is optional IFF the default value is passed
    explicitly in the association definition. whew!)

the "spurious implementaton" problem is this: in one location in the code,
we would default the association's `parameter_arity` to `one` (meaning
required), but in another location we would effect the behavior we describe
above, of only checking for missing requireds if one or more of them
classifies as optional (`attributes/defined-attribute.rb:233` and
`attributes/normalization.rb:457`, respectively, under #tombstone-A).

this alone is cause for concern, but what's worse is that what we were
afraid of happening happened: some normalization implementations cared
about only the first part (they checked for missing requireds against
whether each association has a `parameter_arity` of `one`); and other
implementations honored the second part (i.e they effectively skipped a
missing requireds check when all are required); making for implementations
of normalization near required-ness that were globally inconsistent.

(this proved to be the nastiest part of assimilating facility "C" - issues
stemming from it cost at least a day.)

our fix for this (for now and for keeps, variously):

  - a function to determine requiredness of an association is a thing

  - as such, the lingua-franca is no longer streams but an
    an "association index" as discussed [#here.E] next.




## the new lingua-franca :[#here.E.2]

streams of associations ("attributes") used to serve as lingua-franca
between sidesystems: we would pass them between [ac], [ze], and it was
part of their public API so applications played along too. but then

  A) the yikes issue of [#here.4] was brought to our attention
     and so we wanted clients to be made aware of this through this
     explicit acknowledgement of it in our API.

  B) to make the passing of association collections happen via only
     streams of "native" associations like this, we realized it was a
     bit of a shoot in the foot because it's not extensible at all.

we call the subject class "cautious" because (perhaps as a hack, perhaps
not) this guy always reports an association as required if it was not
specified explicitly as anything (contrary to local convention).




## association? meta-model? :[#here.[G]]

we have gone on (and on) with these terms without stopping to define what
they mena. as for "association", our reticence in defining it is perhaps
by design.

really, a working definition for "association" would seem to be
"whatever is necessary to work with [#012] normal normalization".
but that facility has an injection API that reduces the requirement
for what an "association" is down to "anything trueish", apparently.

but here's some prior notes, sketching our "association theory" in brief:

  - a "model" is (largely) a list of associations

  - an association:

    - can have any arbitrary business characteristics

    - must have at least a name symbol

    - typically has values for the "meta-associations" we offer here

  - one broad cateogory of "meta-association" is "requiredness"
    (formally "parameter arity").

  - another broad category of "meta-association" is what we call
    "argument arity" (actually just an optional trinary for now).

after having completed this version of the library, we are off the opinion
that there is no useful strict definition for what an "association" is,
other than these generalities:

  - [ something about random access by some kind of key ]
  - [ something about it acting as a model, but only maybe ]
  - [ something about extroversion, but only maybe ]





## meta-associations? :[#here.H.1]

as we have done with "association" and "meta-model", we have used this
awkward mouthful of a term "meta-association" at length without really
describing exactly what we mean by it.

if associations are a formal system of modeling data, meta-associations are
a formal system for modeling those associations.

but the the question becomes, why do we insist on using the label
"association" for this other thing (characteristics of associations)?

there seems to be a human tendency to want to use different labels for
similar kinds of things at different scale. for example, we try to
"taxonomize" all life on earth into a hierarchical system of cateogries.
that much is fine, but why do we used different labels for these divisons,
based on the level ("kingdom, phylum, class, order, family, genus, species")?
granted, there are likely different properties the levels-of-division have,
but is the same not true of different strengths of earthquake on the
richter scale? of different tempuratures?

there's cities, counties/prefectures, states/provinces etc. (if memory
serves, japan has a quite ornate hierarchical system for such nested
geographic strucutres.) why is it 20 items to a box, 10 boxes to a carton,
20 cartons to a case, N cases to a crate, 6 crates to a shipping container?

anyway, we digress a bit, but what we suspect is the case is there are
different labels for the same kind of thing precisely because to use the
same word for different levels of the same kind of "container" might cause
confusion; that is it might be counter-utilitarian.

but contrary to this apparently tendency, in the case of our meta-model
we think it helps the meta-model reinforce itself by reinfocing itself
with .. itself. when writing software we are always looking for ways to
DRY things ups, and we have left such page un-turned in pursuit of DRYness
in our meta-model and normal normalization.

but putting aside semantics and epistemology, there *are* some practical
distincts between associations and meta-associations as they occur in our
nature: the most typical association in its purest practical form is an
instance of a class, whereas the most typical meta-association in its
purest practical form is implemented only through a sinlge method on the
"meta-associations-module" and any customization necessary on the
association class.

one other tiny point: when normalizing "business input" we typically
find "extroversion" an important concept. however we are not interested
in bothering with an "extroverted pass" when interpreting associations.
(it's not that we couldn't contrive things so that we could use one,
it's just that it feels too obfuscaed to do so). :[#here.H.1.1]



### other meta-associations? :[#here.H.2]

at writing there are 18 recognized "primary" modifiers for associations
(for the kind we are talking about here), but there is no reason to assume
this number won't grow or shrink over time; and there's little benefit to
discussing the particulars of the constituency of this list here.

the authoritative reference on the constituency of meta-associations
(for "defined attributes", anyway) is the corresponding code node tagged
with this subject identifier.

but also note there is the up-and-coming "EK" project, after which we
should give this whole document a good edit.

more interesting for our purposes is the kinds of categories that seem
to emerege *of* meta-associations.



### categories of meta-associations vs. primaries? :[#here.H.3]

it may or may not be useful to distinguish between a specific meta-
association *of* a value *to* and assocation (on the one hand) versus
the broader category of meta-association being discussed.

for example, `flag` and `glob` are particular values that the deep
"slot" of "parameter arity" can assume in any given association.

another way to describe these might be *deep* meta-associations versus
*surface* meta-associations; or "formal" versus "actual". but we might
rather sidestep this whole issue and just hope it is generally evident
from context which kind of meta-association we mean.

apart from this distinction, here are some of the cateogries of meta-
assocation we tend to find ourselves with, which may or may not be useful:

  - UI-level: description-related
  - parameter arity: required, optional
  - defaulting: default, `default_proc`
  - custom value interpretation: `known_known`
  - argument arity: `flag`, `glob`
  - fundamentalest meta-meta: (boolean, enum)
  - lower-level, governing interaction with value store (`ivar` only)
  - delegate the work of interpretation (component, other custom methods)
  - "hook"




## meta-meta-associations? really? :[#here.9]

remarkably, yes. but there's good news: we have distilled "these" down
to a single item ("flag"), and now the whole topic is more of a mental
exercise than an entrenched part of our modeling API.

at one point we thought that "the" meta-meta-properties were:

  - name
  - defaulting (optionally)
  - enumeration (optionally)
  - requiredness

so for example, most of our association classes have a concept of
`argument_arity` (or, they used to anyway), which was *required*
(requiredness), and which could be any of the appropriate arities
for flag, glob, or monadic (enumeration), and which defaulted to `one`
(defaulting). as the theory went, we could model all of our built-in
meta-associations using these four meta-meta-associations..

but whether or not this is a powerful or minimal set of base N-associations,
we no longer care..

recap: how did we get here?

  - the first step was to implement a system that allowed us to define our
    business models (as in, the things that make business entities)
    "declaratively", by defining associations. i.e the first step was to
    implement a system that interpreted associations. in so doing we imagine
    that interpreting the definition of an association isn't so much
    different than interpreting any other argument stream.

  - the next step was to generalize this association interpreter enough
    so that it could also be used to interpret meta-associations, the
    purpose being to give us the "feel" that interpreting a definition
    for a meta-association is (from some high level) not much different
    from interpreting the definition of an association.

    (around this time we formalized the idea of using plain old modules
    (classes once) and their methods as a means for defining the recognized
    set of N-associations.)

in more detail (and in the circumstantial way it worked out),

  - we unified 13 different modeling libraries.

  - then (about a year later) we unified 6 or whatever normalization
    algorithms into one algorithm ("one ring"), formally "normal normalization".

  - then, having in place the same (small) mechanism that interprets
    associations as does interpret meta-associations, we re-architected
    the API there so that we *use* normal normalization to implement this
    interpreter just as we use normal normalization to interpret any other
    argument stream.

  - this is how we now have normal normalization interpreting all of
    argument streams, association definitions and meta-association
    definitions. (but meta-meta-associations are hard-coded.)

but at some point along the line we started to think that maybe this is
a bit of a ruse. that maybe this is all a parlor trick and that we can't
really get the system to fold in on itself in any useful way..




## N-meta associations? really?  :[#here.J]

one of the central objectives of this effort has always been to answer
the question of how many levels of "meta" can be applied before
one of two things happens: 1) it stops being useful or 2) we lose or minds.

for whatever reason, the answer to both seems to be "only two" (levels of
meta). rationally or not, this is something of a disappointment to us.
we had hoped that if we could only just answer this paradox by finding
a perfect sweet spot of infinite recursion that we could rest easy.

after all, when dealing with a tree data structure, we don't keep ourselves
up at night asking how many sub-branches can a branch have. the answer
is "infinitely many" and we don't give it a second thought.

(to be continued..)




## further reading

[#003] & [#004] will eventually merge into this narrative as siblings #open




## document-meta

  - #tombstone-C [#009.1] two whole documents (one of which just happens to
    have had the same major identifier number as [#same]) were assimilated
    into this one. these document had lots of interesting history about the
    origins of most of the ideas here; but alas, for narrative flow it was
    best that their ideas all merged into one file.

  - a swath of body copy was moved here from a sibling document and
    almost fully rewritten and ~5x expanded.

  - :#tombstone-A (same as "#history-037.5.C" in "normalization") -
    the "FUN" methods and more "association index"-related, 1st pass
