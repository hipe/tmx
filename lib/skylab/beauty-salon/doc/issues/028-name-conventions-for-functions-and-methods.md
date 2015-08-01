# name conventions for functions and methods :[#028]

## synopsis

how a method is named with respect to the use of underscores expesses
its "API scope". here is a summary of the N tiers of scope:

    this_is_a_public_API_method   # #tier-0: no leading or trailing underscores

    this_method_has_library_scope_  # #tier-1: one trailing underscore

    this_method_is_called_only_once_outside_this_file__  # #tier-1.5

    _we_call_this_cozy_scope  # #tier-2: one leading underscore

    __we_call_this_one_off_scope  # #tier-3: two leading underscores

    ___SHOUTWORD_this_method_is_never_called  # (only used during develoment!)




## sneak preview of scopes


### :#tier-0: "public API"

this method is part of the public API of the node that defines it. to
change this method in terms of signature or effective behavior is a
viloation of semantic versioning (semver.org).

note that this scope is only with respect to the node itself. if there
is a "public API" method defined on a node that is itself private to a
library, the method does *not* then become part of the public API of the
library. the scope of the node itself [#031] is a sort of "contract"
between the node and its intended audience. the scope of the methods
on the node is a sort of "sub-contract" with this same audience. this
whole paragraph may change.




### :#tier-1: "library scope"

this strange looking but often used convention has a variety of similar
meanings:

  • if you're seeing this in a method call, the method is defined
    somewhere "above" the node you found it in, but still in the same
    library (usu. sidesystem).

    if you're reading this as a method definition, it is intended to be
    used only from within nodes "below" yours.

    we see this particular use often in our tests by test support
    methods that are used in more than one file but still just a part
    of the test suite itself and not an external library.

  • we often use this convention to indicate that the method has a
    definition in something like an abstract base class - the method
    is intended to be used by instances of child classes of the base
    class. if you're seeing this in a call, it means you proably want
    to look to a parent class (or just module) for the definition.

  • "collaborator" - if you're calling such a method and you are
    crossing library (i.e sidesystem) lines, this means you are
    knowingly circumventing the public API of the object, and you run
    the risk of getting broken if its implementation changes.




### :#tier-1.5:

a method name with two trailing dashes (that is not employing the
convention for methods with generated names) is used to indicate that
although this method is used by this library only (like in tier 1),
it is only called from one location outside of this file. so it
indicates that the cost of changing this method is lower than if it were
tier-1.




## :#tier-2 and :#tier-3

"cozy scope" means the method is not called outside of the file it is
defined in. "one-off scope" is cozy scope but furthermore the method is
only ever called from one place. the significance of these tiers
corresponds exactly to the same tiers described in [#029].





## introduction


we say "function" to give these ideas a bit of platform independence;
however in the context of the current host platform, when we say "function"
we always mean "proc" or proc-like.

this is a re-creation of a document lost in the [#br-092] fire. it will be
better this time.


## the list of conventional method prefixes/suffixes/names.. :[#.A]

..and an introduction to their semantics.

+ `build_` (and often `bld_` per [#.D]) - result is a new instance of a
  class (either library, stdlib or corelib) that is not one of the
  classes described by `get_` below. the object may or may not be
  initialized in some special way as decribed by the method name. this
  method must have no side-effects. (oops also see [#031] for the same
  thing written 10 months prior)

+ `_by` used frequently for method that necessarily take procs;
  although this is also used when it is linguistically natural sounding
  given the following formal argument(s).

+ `calculate`, `calculate_*` - method must take a block. result of method
  block (as determined by the user) be the result of the call to this
  method. the block will be executed in the
  context of some special agent and *not* that of the caller; as such
  this type of method is intended for an explicitly contained employment
  of some particular DSL or another. this method *may* have side effects.
  [#141] expression agents are exemplary of this.

+ `call` - for proc-like objects (typically [#cb-045] actors or
  [#br-001] entities), must do the same as `[]` for this object.
  in these kind of objects, arguments are a (non-iambic) (positional)
  arglist. must not be used for non-proc-like classes. :+[#.E]

+ `curry_with` - see the #iambic family of method name conventions

+ `edit_with` - see the #iambic family of method name conventions

+ `execute` has a strict API meaning for a lot of our libraries as the
  one #hook-out method the client must supply. it must take no
  arguments. [#cb-042] actors exemplify these semantics, as well as many
  of the base-classes called something like "action" in many of our
  frameworks :+[#.E]

+ `[..]_for_[..]` - this is becoming a convention for "#hook-out"
  methods (defined somewhere): e.g `foo_bar_for_biff_baz` is a method that
  produces a "foo bar" for the "biff baz" library. if you see a method
  defined like this, you might be able to infer that it is called
  somewhere outside of the scope you are looking at; that it is a
  "#hook-out" method that a different library calls of your objects.

+ `[_]from[_]` - this meaning is explicitly not defined conventionally.
  use "from" how you like, but do not use it if you can use `via`.

+ `get_` - result is the result object of having allocated new memory
  for and initialized an object that is either of a native "primitive
  data structure or type" or a ubiquitous low-level utilty class (stream,
  box, hash, array etc). see [#.B] dedicated section on this. this method
  must have no side-effects.

+ `flush` is our "go-to" name for something that cannot fail and
  produces the "payload result" of the [#cb-042], "actor-ish" perhaps
  with some irreversable internal side-effects that make this method not
  idempotent (but perhaps yet idempotent).

+ `init_` has at least two distinct meanings: 1) as `init` it is a
  specialized initializer when it is not practical or possible to use
  `initialize` (e.g a `dup`ed object that gets initialized by a
  parent. `init_copy` is a suggested default name for this (to
  compliment the platform-recognized `initialize_copy`). 2) `init_foo`
  should typically init the ivar `@foo` in a way that cannot fail. if it
  may fail (as would be evinced by a result value) use [#031] `resolve_`.
  `init_ivars` is a popular method name employed in [#cb-042] actors for
  initting those ivars that cannot in the current state fail to be
  initted.

+ `invoke` - deprecated as a bareword method name. used a lot in legacy
  frameworks to be an entrypoint method that takes arguments. it is
  deprecated because it expresses neither what it accepts or what shape
  its result is. :+[#.E]

+ `[_]make[_]` - this verb used in perhaps *any* method name should
  confer this one meaning only: this method results in a generated
  class. as well, all methods (and function-likes) that produce a class
  should use this verb unless there is a good reason not to.

  if you were going to use this verb the semantics described here to not
  fit your method, consider (see) `build`.

+ `new_with` - see the #iambic family of method name conventions below.

+ `on_` see [#.C] method naming conventions around events below.

+ `produce_`, `_produce[_]` - result is the subject object as described
  by the rest of the method name. whether or not new memory is being
  allocated for this object is explicitly undefined (contrast with `build_`
  and `get_`). sometimes we use this when we know that our result is a
  memoized instance but want the ability to change that decision in the
  future.

+ `reduce_with` - see the #iambic family of method name conventions below

+ `resolve_` - has a dedicated [#031] document that needs a rewrite.

+ `run`, `run_` - reserved for starting a long-running process :+[#.E]

+ `via_` will one day have its own section #todo

+ `when_`, `_when_` - often takes no arguments, must be private when using
  this convention: this starts the name of a method whose role is as a node
  in a logical branch tree (if X then `when_foo` else `when_bar` etc).
  the rest of the method name is a natural description of the condition
  (`when_password_is_correct`, `when_wrong_password` etc to prefernce).
  use is encouraged along with other conventions, in which case the word
  may get bumped off the front of the method name (`via_X_when_Y`).

+ `which[_..]` - see #name-shootout below

+ `where` -  see #name-shootout below

+ `with` - see the #iambic family of method name conventions below

+ `work` is our "go-to" name for the interesting body of ..er.. work
  that is done in an [#cb-042] actor's `execute` methods after the
  un-interesting initting and validation is performed. a method with
  this bareword name must not accept any arguments. this is a lazy method
  name - it should only be used if the behavior that occurs in the method
  is exactly that as described by the name of the containing class.

+ `resolve_[..]_then` in a framework action, this is a call to a library
  method that will try to resolve the `[..]` (to ivars) and then IFF
  successful, call the client's `via_[..]` method. (this makes more
  sense if you see it (originated in [sg]).)

+ `to_`, `_to_` - the second form is explicitly not defined conventionally
  here. use it as you would like to naturally. (but use `via` instead if
  you can, because whereas `bar_via_foo()` is unambiguous,
  `foo_to_bar` is ambiguous with respect to whether the argument
  is `foo`, `bar`, or both.

  the first form (`to_`) is used in the platform idiomatic way, e.g
  `to_a` etc. `to_stream` is a popular one in this universe (it used
  to be `to_scan`, and before that `get_scan`, and still it has the
  same underlying sematics as the `get_` prefix).




### the `get_` prefix semantics as a nod to an ObjC convention :[#.B]

(NOTE: there is some spurious confusion btwn this node and [#hl-094] )

it is perhaps a misunderstanding of the convention, but we base these
semantics off of something we read in the [#sl-142] hilleglas book: "In the common
idioms of Objective-C, a method prefixed with `get` takes an address
where data can be copied. [..]" [3][3]  We take a very liberal
interpretatin of this convention to make it one of ours: whereas in the
Obj-C case the `get_` method presumably allocates memory to carry out
the said copying, we use the `get_` prefix to apply more broadly to all
of those methods that allocate memory towards their result
object and are not already covered by `build_` (that is, this convention
is for the simpler operations, `build_` is for the more complex ones.)




## :[#.E]

`invoke` `execute` `run`, and ( `call`, `[]` ) have distinct meanings and
consistent signatures within modalities. these are reserved names in the
sense that if they are used they must accord with the conventional
semantics. this tag tracks their occurrences under this document node,
at which a semantic proscribement for each name can be found.




## naming conventions around events :[#.C]

because most of these are method naming conventions we put this node
here but there are some that are not.

+ "handle" - this word must be used in the method name IFF that method
  takes no arguments and results in a proc form of an event handler.
  we do not define the signature of the event handler proc here.
  we do not proscribe a method visibility here - use the visibility that
  is appropriate for the method.

  these methods will often constitute a "getter" to provide a proc that
  will be consumed by a "setter" or named iambic term whose name starts
  with (see below) `on_`.




+ `maybe_receive_event` - this has a fixed signature and is the
   preferred way for an object to expose event reception.



+ `on_` - this looks good as an iambic property name in an argument
  stream or setter method in a DSL for setting handler procs, but
  otherwise we don't like it for public method names, per the below
  rule about "receive". we now discourage `on_error`, `on_info` etc
  and rather prefer something like `on_event_selectively` where the
  caller does the dispatching herself (see `receive` below).

+ `on_event` as a named argument this is what to use if your event model
  is non-selective, but we prefer (see below) `on_event_selectively`).
  do not use this for a method name unless it is an old-fashioned DSL
  setter.

+ `on_event_selectively` as a named argument this is now the preferred
  means of passing event handler from caller to actor. do not use this
  name for a method name unless it is an old-fashioned DSL setter.



+ "receive" - this word must be used in the method name IFF that method
  constitutes an exposed means of [selectively] receiving event
  objects or other arbitrary event-driven data or .. events.

  ergo these methods must be public. for private methods that are
  conditional branch nodes of for example a public "receive" method,
  see `when_` above.

  "semantic routing" of the event is the concern of the receiver not
  the sender: whether a given event is interpreted as for example
  informational vs. an error vs. a payload event is ultimately a product
  of the design of the event receiver. indeed, the same kind of event
  can be interpreted variously as error or not based on circumstances
  that are the private concern of the receiver (for example, action).

  as such we discourage sematically charged names like `receive_info`
  and `receive_error`. just use `receive_event` and let the receiver
  sort it out.

  it is necessary to mention that in practice for convenience and "tight
  code" the receiver often falls back on the value in the `ok` tag of
  the event to determine its semantics which effectively lets the sender
  steer the handling of the event in these cases - but this must not be
  assumed to be always the case - ultimately it is the receiver that gets
  to make the final judgement on how an event is to be interpreted.

  it is fine to use this prefix for methods that signify and/or pass
  events between familiar, ad-hoc or low-level objects:
  `receive_prepared_foobric` where "foobric" is some business-specific
  concern, or even events without metadata (`receive_termination_signal`).

  see #signing below.



+ `receive_event` - this is the old-schoool, simpler, non-conditional
  form of exposed event reception method. it has a fixed, monadic
  signature of one argument (the event) and cannot take blocks.



+ "send" - this word must be used in the method name (but must never be
  the only word) IFF that method privately sends an event object outward
  from "inside" itself.

  ergo these methods must be private. if you want a public method that
  receives events, see "receive" above.

  typical examples implementations of such a method include sending an
  event "upwards" by calling the `receive_event` method of a parent node,
  or sending an event "outward" to a modality adapter.

  see #signing below.




### :#signing

when we use the verb "sign" in the context of events we mean the process
of in some way adding more context to an event to make it clearer for
example under what action it occurred. we are not yet sure whether it
makes more sense to "sign" an event in a sender method or a receiver
method; so as such we are encouraging the use of more descrptive names
for methods that sign the events they produce or transform.




## the :#iambics method naming convention family

the meta-classification of "iambic" applies tautologically to method
name conventions that apply to iambic methods. that is, if any method
has a name that is covered by any of the below conventions, that method
must accept [#cb-046] "iambic" arguments; conversely no method covered
by any of the below conventions can accept anything other than iambic
arguments (and perhaps a block pursuant to the particular method).



### sidebar: a moment for meta

   +---------------+ +--------------------------+ +-----------------------+
   | a method name | | a method name convention | | a meta-classification |
   +---------------+ +--------------------------+ +-----------------------+
          ^                      |    ^                       |
          |                      |    |                       |
          +----------------------+    +-----------------------+
           is a classification for     is a classification for

### (end sidebar)



note that this meta-convention is not very restrictive because
specification for iambics is itself not very restrictive. in fact,
whether or not the term "iambic" could formally be applied to any syntax
is not formally defined here, but suffice it to say "maybe".

to go even further, there may exist methods that accept iambic
arguments to which none of the below conventions apply; but that must
be because the particular method is not a good semantic fit for any of
the below classifications.

broadly we classify the below method name conventions along these axes:

  • does the method mutate the receiver?

  • is the method's meaningful result (if any)
      the same kind of thing as the reciever?

we have worked and re-worked this constituency and its surface symbols
so that its members:

  • most naturally fit with the host natural language

  • without being overly redundant with each other in their semantics

  • all the while being optimally mnemonic (i.e poka-yoke)


of the method name conventions in this family, a method whose name is
covered by any of these conventions must have meaning that corresponds
to those conventions. conversely any method with any meaning that is
covered by the below (for some definition of "good fit") must employ the
below pertinent convention(s).

this is the comprehensive constituency of this family:

+ `curry_with` - receiver has an actor shape. result must be an actor of
  the same sort, modified (or even the same) per the characteristics
  expressed in the literal iambic argument.

  with actors, whether or not the receiver and (separately) result is
  class-like or instance-like is not a meaningful distiction. they are
  both actor-like and that is the extent of the specification.

  this could be easily confused with `new_with` unless you remember that
  this one is for actors and `new_with` is for with class- (or
  instance-) likes actors are never interacted with in class-like way.

  summary: ( mutates receiver: no. result is receiver-ish: yes. )



+ `edit_with` - receiver may be some arbitrary business object or may be an
  "edit shell" (representing an interface to an edit session of some sort
  (e.g of a business entity)). this is the conventional method name used for
  that public method of the edit shell that accepts a literal iambic.

  summary: ( mutates receiver: yes. result is receiver-ish: no. )



+ `new_with` - receiver is a class-like OR instance-like. if receiver is
  class-like, result is a would-be instance of that class. if receiver is
  not class-like, result is of same shape as receiver. this is like calling
  `new` on a class, but in a form expressly made for accepting literal
  iambics.

  summary: ( mutates receiver: no. result is receiver-ish: maybe. )



+ `reduce_with` - receiver is a collection (ideally a stream) or something
  with a collection sub-shape. result is ideally of the exact same shape
  as the receiver, but may be corelib collection object like an
  ::Enumerator, or a ubiquitous collection object like stream or box.

  summary: ( mutates receiver: no. result is receiver-ish: yes. )



+ `with` - if this method name followed the meta-convention implied by the
  rest of the constituency, we might call it something like `call_with`.
  but we let it occupy a whole (and quite essential) single word of the host
  natural language because of how much of a consistently natural-sounding
  fit it is in code-use.

  the receiver must have [#cb-042] actor semantics (but may have other
  shapes as well). if the receiver (actor) supports this method then the
  receiver supports iambic calls and vice versa. since the receiver is
  an actor, whether the call has side-effects on the receiver itself is
  unknowable and inconsequential; the result is always the yield of the
  call and the yield of the call is always the result.

      proxy = Build_wazoozle_proxy.with :upstream, foo

  whether or not it is OK to call a `with` with no arguments is
  explicitly not defined here, but may be so in the future (one way or
  the other). regardless of any existing specification here, as with any
  iambic call the particular actor may always chose to raise argument
  errors (or otherwise act) when the request is un-normalizable, as
  may be the case of the empty iambic, dependng on the actor.

  summary: ( mutates receiver: no. result is receiver-ish: no. )



## :#name-shootout: "that" vs. "where" vs. "which" vs "with"

spoiler alert/TL;DR: we don't use any of these names except the last
one.

### "which" wins over "where"

currently the method name `where` is reserved and must not be used
because we either do or do not want to collide with the semantics of
the same SQL keyword, and we are leaning towards the latter:

at first we used `which` in its lieu, because we found it a more
natural fit:

   contrast:

       users.where :first_name, "John%"  # less natural sounding

       users.which :first_name, "John%"  # more natural-sounding

       users.with :first_name, "John%"   # most natural-sounding, but "with"
                                         #   has a strong convention already

in the host natural language it seems that "which" typically modifies a
noun phrase and takes a verb phrase, whereas "where" modifies a noun phrase
(that is often of the semantic category of "location") and/or takes a
sentence phrase. contrast:

       cats which have six toes
       a cafe where i can get wifi
       a restaurant where hungry people like to eat
       an arrangement where i can wear my leopard costume

in the above examples we see that "where" is usually (but not always)
used for places, and always takes a sentence phrase as an "argument".
"which" on the other hand (in our examples) always modifies a noun
phrase and always takes a verb phrase as an argument.

for fun:

    |  host word |         modifies  |          "argument"  |
    |     "that" |    a noun phrase  |       a verb phrase  |
    |    "where" |  usually a place  |   a sentence phrase  |
    |    "which" |    a noun phrase  |       a verb phrase  |
    |     "with" |    a noun phrase  |       a noun phrase  |

so we prefer "which" over "where" for three reasons:

  1) we don't want you to assume that our semantics match exactly the
     semantics of the SQL keyword.

  2) our "query"-like methods typically operate on collections of
     "things" (and result in typically smaller collections of those
     same "things"). "which" is more natural than "where" for this
     to the extent that our above examples are a fair sampling of the
     host natural language.

  3) our "query"-like methods typically take arguments that are more
     like verb "predicates" and less like sentence phrases:

         my_property_stream.which :is_hidden



### "that" wins over "which"

we would prefer using the less ambiguous "that" over "which", because
in contrast to "that"; "which" can be used for two distinct purposes,
one as a qualifier and one as a parenthetical:

    cats, which are mammals
    cats which have six toes

both of the above phrases are meaningful and both have the same (or
similar) construction with regards to "which", but the "which" serves
different functions variously in the above two phrases:

we can infer from the first phrase that all cats are mammals. however we
cannot infer from the second phrase that all cats have six toes. perhaps
because of our careful use of the comma, this distinction is made more
clear; but (thankfully) commas will not be used to bolster our method name
conventions.

instead consider a similar construction but with "that" instead of
"which":

    (!) cats that are mammals
    cats that have six toes

the first phrase is meaningless: all cats are mammals, therefor adding
"be a mammal" as a qualifier is meaningless to be applied to the collection
"cats". however the second phrase above means the same thing as all the other
example phrases about cats with six toes. "that have six toes" is a
"qualifier" that reduces the collection to a smaller (or same sized)
collection.

because "that" has a tighter set of meanings when used in this way we
would prefer it but keep reading..



### "with" loses in general

we would prefer the more succinct "with" to "which" if it were always
applicable and didn't already have a more natural-fitting name
convention being applied to it.

    cats that have six toes
    cats with six toes

if we can meaningfully omit the "has" (maybe because it can be assumed to
be the default verb) then we are left with the noun phrase "six toes".
because the "argument" is a noun phrase and not a verb phrase we use
"with" and not "which".

however, in practice the "predicates" to our queries are rarely noun
phrases (they are often verb phrases):

    actions.with :is_visible  # awkward because "is visible" is VP not SP
    actions.which :is_visible  # OK except for the subject-verb agreement

as well, "with" has an existing convention that is a better fit than
this one.



### the sad conclusion

while writing this manifesto something occured to us: keeping in mind
that our end goal in this was to find the perfect name convention for a
query-effecting method, we realized that we already have a strong
candidate word for such a thing: "reduce". `reduce_by` (in the pantheon of
[#cb-044] stream methods) has a strong, unambiguos meaning and syntax. the
kind of method we are describing here has the exact same semantics but a
diffenent syntax: it takes an iambic literal instead of a block. hence
we must follow suit with the existing word, so please see `reduce_with`.




## the method naming shibbloleth :[#.D]


### edit: half redundant with an earlier section
### edit: the simplified version:

synopsis:

these conventions are adopted (where they are adopted) not because they
are pretty but because they make the code optimally refactorable, by
letting you know immediately the cost of changing the method's interface
or removing it. (the narrower a method's scope is, the less it costs
to change). they are:

  • `a_method_with_no_leading_or_trailing_underscores` *may* be
     universally public. this is the most expensive kind to change.

  • `a_method_with_one_trailing_underscore_` is either "library private"
     or "node protected", scopes that are similar in "size" generally,
     but not the same. for "library private", other nodes within the
     "library" may call the method, but none outside of it. this is
     comparable in "scope" (not mechanics) to java's `package` scope.
     (but we don't yet have a rigid way that we express the boundaries of a
     "library" - often it is a sub-sub-top-level node.)

     for "node protected", this method is visible to the current node and
     its children nodes. ("node" is defined in the next bullet).

     as well we will sometimes use this scope for "collaborators" - if
     two disparate nodes need intimate knowledge of each other and an
     exposure method is needed (perhaps experimentally) just for this
     end, we may use this scope.

  • `_a_method_with_one_leading_underscore` is "node private" - only the
     "node" (class, module, or file; author's choice) itself can "see"
     the method. if class, this means that not even subclasses can "see"
     the method. likewise if module, objects that have this module in
     their ancestor chain cannot "see" the method either. this may be
     comparable to java's "private" scope.

  • `__a_method_with_two_leading_underscores` - we call this an
    "aesthetc" method for reasons explained below. its definition is
    straightforward: this is a method that is called from only *one* code
    location (and that one code location is within the node).

    we call this "aesthetic" because the only "reason" to make such a
    method is for the human advantages that come from having small,
    modular methods. unlike with other classifications of methods here,
    this sort of method does not contribute to the DRY-ness of the code:
    because it is only called from one code-location, its logic does not
    "need" to be encapsulated, it just looks better to do so.

    this has the second narrowest scope possible for a method to have,
    the first being a method that isn't ever called at all. (such
    methods should be removed so we don't have a special convention for
    them.) as such, this method is the cheapest to refactor.



### the original version

this convention is not pretty, but that is not its point: it evolved
pragmatically (and quite suddenly) as a way to build code optimized for
malleability by being faster to refactor.

this is a bit of a contentious pattern, but one we find utility from:
for certain kinds of classes/modules, we may abbreviate certain words of
certain of their method names in a regular way.

to absolutely *anyone*
who hasn't read this, the effect may just appear as messy and erratic,
but there is in fact a simple set of rules governing this obscure
shorthand. this section describes both the pattern behind this chaos
and the utility of it.

in summary the pattern has to do with visibility and at some level is
comparable to the [#029.G] three levels of visibility as expressed by
trailing underscores of const names. what we mean by "visiblity" and how
this may be different than the visibility you are familiar with will be
explained below.

the fundamental rubric is this: if a method name has one or more words
that is abbreviated (not including idiomatic or business acronyms like
"IO", "HTTP" etc), then this abbreviation indicates that the method is
variously API private or API protected in some way (what these mean is
explained below).

conjunctive words (whether conventional themselves or not) like "and",
"via", "from" are never abbreviated. abbreviation of a word never
removes the first letter of the word. acronyms are never further
abbreviated.

first, we will describe the three patterns of abbreviation, then we will
describe what these respective patterns mean.

consider a method whose would-be name is this:

    resolve_upstream_IO

the "stem words" that make up this method name are these three:

    resolve upstream IO

we cannot abbreviate "IO" any further because it is already an acronym.
but we can abbreviate the other two:

    resolve -> rslv

    upstream -> upstrm

note that to abbreviate a word typically means to remove the non-initial
vowels from it.

so if we were to abbreviate this method name "all the way" it would look
like this:

    resolve_upstream_IO  # before
    rslv_upstrm_IO       # after

but we don't typically do that. what we *do* do sometimes is this:


### we might abbreviate some part of the *first half* of the method name:


                      `resolve_upstream_IO`
                         |              \
                      (first half)    (second half)
                         |                \
                         V                 \
                      `resolve`         `upstream` `IO`
                         |                  |
                         V                  |
                      (abbreviated)         |
                         |                  |
                         V                  /
                       `rslv`              /
                         |                /
                         V               V
                         `rslv_upstream_IO`


### *or* we might abbreviate some part of the *second* half:


                      `resolve_upstream_IO`
                         |              \
                      (first half)    (second half)
                         |                \
                         V                 \
                      `resolve`         `upstream` `IO`
                         |                  |
                         |                  |
                         |             (abbreviated)
                         |                  |
                         |                  V
                         |             `upstrm` `IO`
                         |                /
                         V               V
                         `resolve_upstrm_IO`


### *or* (for completeness) no abbreviation at all:


                      `resolve_upstream_IO`
                         |              \
                      (first half)    (second half)
                         |               |
                         V               V
                       `resolve_upstream_IO`

if the method name was abbreviated in the *first* half, it means that
this method is "API private" (explained below). if the method name is
abbreviated in the second half, it means this method is "API protected"
explained below.

(mnemonic: if the hard to read part is at the beginning of the method,
it says "turn back now", i.e it is more private than if the hard-to-read
part is at the end; hence private not protected.)

if the method is not abbreviated at all, it *may* mean that the method
is part of this node's public API, depending on what kind of node it is:

if a method (anywhere in our universe) has one or more abbrevable words
and that method does not employ the abbreviated forms of the words, this
method is part of the node's public API if (not IFF) this same node
employs one or more of other categories of visibility (i.e `protected`
and/or `private`) elsewhere in the node as evinced by the presence of
abbreviations of some of the words of some of the method names.

conversely, **abbreviations may not be used anywhere in the method
names of this universe unless they are in exhibition of the semantics of
the conventions described in this document**.

to break up a method name into "halves" like this requires that there
exist more than one "abbrevable" [2][2] word in the method name. given
the surface form of a method name having undergone this transformation,
to decode whether or not the abbreviation took place in the first or
second half will probably require some apriori knowledge: you may have
to know (or be able to infer) what the "stem words" were in the first
place, and which of the words are un-abbreviated not because of our
"first-half/last-half" dichotomy, but because they are unabbrevable:


    build_rdbl_IO


the obsurely abbreviated form of "readable" above comes as the middle
word in a method name with three words. but because we know that the
word "IO" cannot be abbreviated, then we know that the word that was
abbreviated was effectively at the end, making this an API-protected
method as opposed to an API-private one.

for methods with more than two abbrevable words, it is recommended
that you only abbreviate at most one word (unless you are being
intentionally obscure perhaps for something you expect to be a
shortlived or an especially volatile hack that should be cleaned up for
"production"). which word you chose to abbreviate must be determined by
the above rules: the word should be either the first or last
abbrevable word, and which it is determines whether it indicated a
private or protected method with respect to the node's API.

a method with only one abbrevable word may not employ this convention
unless the method has more than one word and the abbrevable word falls
clearly on one "half" or the other and it falls on the correct half that
expresses the level of visibility the method is designed with:

    build_IO       # an API-public-looking form
    bld_IO         # the API-private form
    (none)         # you can't make an API-protected form
    build_IO_obj   # ..unless you hack it by adding an extra word

a method with zero abbrevable words cannot (of course) employ this
convention at all, but as is hinted at above, sometimes you can hack the
name around to make it fit with the convention (and methods with only
one word in their name should probably be avoided generally anyway
except for those few idiomatic ones we have).

as for what these levels of visibility actually mean, this is the subject
of the following section.




## what do "API public", "API protected" and "API private" mean?

(spoiler alert for the eager and precocious: these three levels of
visibiy have semantics similar but not the same as the three levels of
visibility decribed by [#029.G] the trailing underscore convention for
const names.)

recall from [#.B] that when we say "node" in the context of the
native platform usually (but not always) mean "module" (e.g "class").

an "API public" method is part of the "public API" of the node as is
defined by semantic versioning [1][1]. note that, perhaps confusingly,
this has nothing to do with the levels of method visibility as is
granted by the `protected` and `private` keywords of the host language:

a method can certainly be part of a node's public API and still be
private, for example. this is exactly because classes can be sub-
classed, and modules can be mixed in. when an API class is subclassed
or an API module mixed-in, the client node needs to know whether the
private and protected methods of that API node are stable and reliably
free from behavioral change given this version of the API, just as much
as it would be with a public method (but broadly this hits on what
we may sometimes consider a :+#smell discussed #here).

"API protected" and "API private" methods are decidedly outside of the
domain of semantic versioning: if a method is "API private" it means
that that method can be called by the defining node *only*: it can be
known about and called from only the class *itself* or module *itself*
that defined it (and *not* even subclasses of that class!).

if a method is "API protected" it means that that method can only be
known about from inside of the "sidesystem" (but we may change this to
"library" if we ever define that formally.)




## the smell of the shibboleth :#here

we employ this convention because in the short-term it is valuable to
do so: when we see what looks like an API-private method, we know that we
must not call it if we are outside of the node, and that if we are inside
the node (refactoring/debugging/featuring it) we are allowed to change
its signature, its name, or even delete it altogether.

this same dynamic applies to an API protected method, except that it has a
larger scope of dependency, and so more things can break when you change
it; and you can take that scope into account as you consider changing it.

in practice this has proven compellingly valuable during refactoring - we
know immediately by looking at a method (either definition or call) what
its API scope is and accordingly how much cost will be incurred (roughly)
if we try and change it.

however, (and we aren't sure yet), this entire name convention may just
be a bandaid over a deeper problem for which there is a simpler
solution: in short the solution may be smaller nodes (classes and
modules). [#cb-042] actors have proven useful to this end: when viewed
logically actors have no public methods -- they are interacted with like
procs. actors have a single exitpoint method (`execute`) and so since no
one outside of the actor can call the actor's methods anyway, there is no
need to indicate the level of visibility of the methods: they are all
effectively API-private so we don't need to obscure them with
abbreviations at all.

so in theory the more we employ lots of small actors rather than god-
classes and modules, the less we need to use this convention. (but even
in new code, it hasn't gone away completely yet!)




## the plasticity of visibility and the utility therein.

keep in mind, too, that it is generally trivial to "open up" an
API-private method into an API-protected one: you simply search and
replace the name within the current file only. (remeber, by defintion a
change to an API-private method will be restricted one file.)

to change a method from API-protected to API-public is accordingly less
trivial but perhaps still trivial because (again by definition) your
changes will be restricted to the scope that is associated with
API-private-ness as defined above.

so if you ever find yourself wanting to use a method that is
"inaccessible" to you by the rules of this three-tiered method
API-visibility, it is not the case that you should avoid using this
method. rather, simply open it up as necessary.

if with every new method you write you start by making it API private
and then open it up one level as you need to, method by method as your
system grows, what you end up is the de-facto public and protected API's
of all your classes as they evolved emergently. this is how this convention
came about in the first place, was as a means to this end.




## references

[1]: http://semver.org

[2] : "abbrevable" is an abbreviation of "abbreviable" which is an
     abbreviation of "abbreviatable", which is a neologism meaning "a
     word that can be abbreviated by the rules described herein." we,
     like the general public, will not use these terms outside of this
     document.

[3] _Cocoa Programing for Mac OS X_, fourth edition, Aaron Hellegas &
    Adam Premble, 2012 Pearson Education, Inc. (page 79, ¶ starting with
    "Most Java programmers would name this method `foo`"
