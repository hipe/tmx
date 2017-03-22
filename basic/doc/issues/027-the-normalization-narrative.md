(EDIT: this document is less fresh than [#fi-012] and has yet to be
reconciled with the larger narrative that document is part of. (at writing
[#045] holds this same classification.) however (again as with [#same] with
respect to [#same~2]) there might be enough non-overlap of ideas for these
documents to co-exist peacefully; however we should at least add references
in the remote larger narrative back to this one.

one more related note, probably only one of these documents should
exploit the cheeky "the new normal" as a section heading, and it should
probably not be this one.)


(we cram two different doc-nodes in here for now with the intention of
one day assimilating the older one into the newer one.)

# the new normal :[#027]

## synopsis

for a single, unified solution that is universally applicable,
recognizable, and poka-yoke; we have adopted this one method name,
signature and semantics:

    normalize_qualified_knownness <qualified-knownness>, & <oes_p>




## introduction

we have finally arrived at a normalization API we are happy with. here
we sing about it. you may be looking for the old [#045] normalization
document. that is the second half of this document.




## historical context

ideas put forth in the historical [#same] hold a snapshot of what was
going on when we synthesized these ideas.




## a broad view

broadly we conceive of normalization as both the process and modeling
therebehind of taking a given input data, determining whether or not it
is a member of the formal set of data defined by the particular
"formal value" for this "field", and then if valid potentially transforming
the argument data and somehow making this result value available.

as it would turn out, this conception of normalization is so broad that
it arguably encompases all of computing in our universe. this is an
isomorphicism we play with here and there to put this normalization
API to perhaps surprising use in some places, for example the possible
transformation and resolution of resources on the filesystem or even on
the network.

for what is a "URL" but a formal definition of some resource that you
expect to exist? if, given the input state (that is, the state of the
internet at this moment) the resource does not exist or cannot be reached,
it perhaps makes sense to approach this problem like other normalization
problems provided that the abstraction is not too leaky.

(and note too that URL's themselves have a formal structure that
defines the valid forms they may assume. so there's certainly more than
one way to "normalize" a URL, based on what your normalizing agent
(or "model", if you like) actually does.)

even an HTTP "PUT" operation can be conceived of as a normalization. you
model the formal behavior that you would like to occur (send a request,
get a certain kind of response) and then you apply it to actual values and
respond to the results declaratively rather than imperatively.

for now this is a merely a fun thought experiment but we intend to turn
it into something far more embarassing than that..




## normalizing vs. validation

in our universe, normalization is a superset of validation. validation
sounds like "is it valid?" and suggests that it results in a boolean
value of "yes" or "no". normalization is that and more (potentially). an
act of normalization can tranform the input value into a different value
when there is a business (or platform) need to do so (provided that the
input value is valid enough to be normalized).

in practice in the shape facilities provided by [ba] most normalizer
facilities do not actually tranform values, they just validate. but
nonetheless we maintain a uniform interface for these two related
operations, and use the name that is more correct (that of the superset).

subjectively the more interesting part of the normalization has to do
with emission of events. typically this is done when an input value is
invalid or perhaps even when the input value is valid but gets normalized.




## the normal value normalization method

a historical aside to give us some context to the scope of this:

this one subject method replaces all of what were once 5 (five)
 variants of it (each documented at the time (tombstone at end)):

    any_error_event_via_validate_x
    normalize
    normalize_qualified_knownness
    normalize_via_two
    normalize_via_three

perhaps we should conceptualize it as one of our :+[#ba-041] universal
abstract operations.

the method takes on arugment and optionally one block.

  • the argument is a [#ca-004] "knownness"
  • the optional block is a [#ca-017] selective listener.


understanding [#ca-004] "the states of knownness" is *essential* here,
and it is highly recommened that you read its doc-node before proceding.
we use a "knowness" structure to represent the argument and all of the
relevant metadata around it that we will work with..




### `nil` may be just another value

this "knownness" structure holds any argument value that may have been
passed from some "upstream" of information. this upstream may be a human
user, a human user behind a front client, another system, whatever.

with this knownness structure we can know whether or not the argument
value was provided by this agent, including whether the agent explicitly
passed `false` or `nil` for the value.

in our conception of normalization, having passed `nil` explicitly is
seen as having significance that may possibly be distinct from the value
having not been passed at all.

that is, we don't require that this distinction be made, but we allow
for the possibility that it might be, per the design of the client.




### you may change the value

depending on your definition for what is normal for that field
(and more broadly what is valid), you may transform the incoming
value into any other value (for example, convert a string "1" into
a native integer `1`). if it is already valid and normal as it is
you may leave it as it is.

in such cases where you want to change the value to make it "normal"
be useful to use the `new_with_value` method of [#ca-004] to create
a modified frozen dup of the incoming argument structure, but with
the new desired value.




### the semantics of your result

if based on your definition of normal this normalization was
successful, your result *must* be another or the same [#ca-004]-shaped
argument structure containing the new (or same) value for the argument
value. that is:

any true-ish result that you return will be assumed to be an object
of this shape. if the incoming result was itself already valid and
normal as-is, you may result in this same object as your result.

any false-ish result that you return will be assumed to signify that
the incoming argument value (or absence of value) was invalid.




### recommendations for side-effects

in cases where the value was invalid it is recommended that you use any
passed event handler to emit an event expressing as much. if no handler
was passed under such a case the behavior is up to your design, but
design something. what is recommended is that in the case where a
handler wasn't passed, you turn the event you would have emitted into an
exception and raise it.

in the cases where the value was changed significantly per normalization,
we recommended that you emit an informational event expressing as much.
if you did not change the semantic value of the event, but only the
type (for example, coverting "1" (the string) to `1` (the integer), it
is recommended that you *not* emit any event.

for all above cases be aware that an event handler may not have been
passed. anticipate this possibilty as apporpriate for the semantics of
the would-be event and/or the content in which your normalization will
execute.




## :#normal-normalizers

in the normal case a normalizer will be implemented something like a
specialized actor. the full lifecycle of normalization can be broken up
conceptually into two parts (at least):

    1) defining the formal property
    2) normalizing the actual property against the formal

this pairing of ideas relates exactly to the discussion of [#fi-025] formal
vs. actual values.

conceptually you can think of the formal property as a formal set of all
valid values for your field. or if you prefer you can think of it as a
grammar, a regular expression, a procedural chain of validation and
tranformation functions that you write, etc.




## something about currying..

should go here (EDIT)




## a plastic distinction between normalizer class and object thru currying

the paradigm behind a "prototype-based" object-oriented language like
Javascript is of course different than the idea behind class-based OOP:
with prototypes there is a fuzzier distinction between what is a class
and what is an object. (more accurately there are no classes)

the counterpart to a class in prototype-based langauge seems essentially
to bean object that gets duped
to make other objects. this different perspective has interesting
ramifications that we find useful to leverage specifically in this domain
of normalization.




(EDIT: the below is close to sunsetting..)



# the field-level custom normalization API (was [fa] 019)

This is the field-level normalization API.

experimentally:

    class Foo < F-ace::API::Action

      params [ :email, :normalizer, true ]     # the `true` means we'll do
                                               # it with an instance method..
      # ..

    private
                                               # note the form `normalize_<foo>`
      def normalize_email y, x, change_value_p
        if some_rx =~ x                        # if the email looks good,
          change_value_p[ x.downcase ]         # we weirdly downcase it
          true
        else
          y << "i hate this email."            # write errmsgs like this
          false
        end
      end
    end

  # or use the "inline proc" form:

    class Foo < ..
      params [ :email, :normalizer, -> y, x, p do
        if x.include? '@'
          p[ x.downcase ]  # call `p` with a normalized value if desired
          true             # "providedness" (treat this field as "provided")
        else
          y << "the definition of email is a string that contains '@'"
          false            # "providedness" (treat this field as "not provided")
        end
      end ]
    end

  # or you could have just as soon passed a proc (e.g constant) there.

in theory this API lets us focus on what normalization means for the
particular field, and insulates us from both how the data is stored and how
we are wired for eventing issues surrounding it, which in turn enables us
to make flexible, reusable normalizers. but there are lots of details:




## using the `normalizer` metafield

there exists in the F-ace API API recognition of a metafield called
`normalizer`. this metafield is associated with a (mandatory) value
which you must provide after the `normalizer` keyword in your field
specification. (in fact the meta-field `normalizer` has the value `true`
for its meta-meta-field `property`!)

this normalizer value must belong two one of the two classes: 1) it must be
the value `true` - OR - 2) it must be a callable (i.e it must respond to
`call`).

if the `normalize` metafield is `true` (the literal value) for a field with
the normalized name `foo_bar`, the system will assume that the agent will
respond to a method `normalize_foo_bar`. this method will serve as the
`normalizer callable`.

otherwise if the `normalize` metafield is assicated with a value other than
`true`, the system will assume that the value itself is the
`normalization callable` (e.g a proc, perhaps defined inline or perhaps
held in e.g a constant, or perhaps even as the result of some other proc).




## how is the `normalizer callable` is used, and when is it called?

when a field indicates itself as having a `normalizer` as described above,
the `normalizer callable` is guaranteed to be called whenever the agent
(e.g action) hits the normalization eventpoint during the course of the API
action lifecycle. this is true regardless of whether or not the particular
actual parameter was provided for this field (!).

(this is because there exist classes of normalization that expect to be run
whether or not an actual parameters was provided for that field, for
example, defaulting behavior.)

this system does not presuppose that the calling of the callable has any side-
effects on the agent itself, nor does it care whether or not it does.
what the system requires of the `normalizer callable` is that it report back
to the system various pieces of information pertaining to certain facets
of this particular combination of formal parameter and actual paramter.

we will call these facets "channels of concern". each channel of concern
manifests itself in some way in the interface that the `normalizer callable`
must follow. for now, there are three "channels of concern":




## what are the three channels of concern?

in brief, they are "is it invalid?", "is it provided?" and "what change
(if any) should we make to the value (or how should we mutate the object)?"
but underneath each of these there are details:



### channel of concern one: were there validation errors (and if so,
    what were they)?

defined broadly, a validation error is a "soft error" - it is something that
happens during the normal flow of the application, and is an occurence for
which there should be a smoothly integrated "user experience" to go along
with the event. (arguably a good interface will prevent invalid data from
being input at all, but that is a different challenge outside of this scope).

what we actually mean by any of this is tied very closely (for now) to the
specifics of how the `normalizer callable` signals validation errors back
to the system, which gets covered below.

a note of some detail - in implementation we may chose to represent the
"value" of this channel with a bitfield names something like `is_invalid`.
we might chose to name it this way and not the more conventially correct
`is_valid` (per Martin [#sl-129], avoid negatives in names) because the two
are not necesarily clean opposites, and here's where it gets subtle:

if for a given formal parameter, the "any provided actual parameter" is NOT
flagged as `is_invalid`, (that is, `is_invalid` is false-ish), then that is NOT
to say that there is an actual parameter that is valid, only that any actual
parameter is not invalid. huh?

well it may be that there was no such actual parameter provided. whether
or not an absent actual parameter should be considered as valid or invalid
is outside of the domain of this channel of conern. it's like: if you have no
driver's license in your wallet, then is that to say that you have an invalid
driver's license? splitting hairs at this semantic level of detail becomes
important when it comes to both interpreting the law and writing business
logic as software!

which brings us nicely to a separate channel of concern:



### channel of concern two: should the field be considered as having
    been provided?

one of the primary domains of responsibity for this agent-level normalization
algorithm is to ascertain a value for the particular `requiredness` of each
formal parameter, and then to ascertain a value for the particular
`providedness` of the corresponding actual parameter. in other words, one
of the main things the system does is check for missing required fields.

when a `normalizer callable` is provided for a field, it de-facto must
assume the responsibility of determining the particular `providedness`
of its associated field. how it communicates this state back to the system
is covered below. what happens when required fields are missing is
(fortunately for your callable) outside of the scope of field-level
normalization.



### channel of concern three: is the value we should store different than the
    value we received (and if so, what is this new value)?

this is the bread and butter of normalization: a data node comes in in
some particular shape, and you may want to change its shape for a variety
of reasons. possible reasons include but are not limited to:

  • consistency: you always want to say "st" and not "street"
  • efficiency: you want to convert integer strings into ints now
  • data-de-duplication: (basically a special form of consistency)
  • because there was a validation error [1]
  • encoding - internally you will hold these strings as UTF-8
  • because of the requirements of various storage contexts (volatile or
    otherwise) [2]
  • discrete internal representation [3]

[1] depending on your framework or algorithm, you may chose to leave the
invalid data "in" the field e.g for use in rendering it to the UI. that is
to say, there can be value in modeling invalid data.

[2] when we say "storage" we do not mean databases, disk, etc. we use
"storage" here stand for the abstract place that the field value will go,
whatever it is, (the "downstream") after the normalizer finishes with it.

[3] imagine you may have a bitfield with three (er) fields. it "comes in"
as e.g a byte or maybe a N-length array of possibly non-unique strings.
internally you may find and/or more optimal to represent this bitfield as a
struct of booleans (and it may be [#bm-008]). also, maybe you want such a
struct to be "stored" (e.g in an ivar) whether or not any fields "came in"
(whether or not any actual parameters were provided for this). a normalizer
fills this need.

the `normalizer callable` gets full autonomy in deciding whether and what
to change the received value (to) for the field. as hinted at way above, the
callable will always be called whether or not a value was provided, so the
callable is one means by which we may implement defaulting behavior (but
consider first using the `default` metafield for this, which takes a niladic
proc as its mandatory property).

so the callable decides `if` the field's value should change, and if so
`what` value to change it to, BUT the callable does *not* get to decide
`how` to actuate the change itself. the aspect of storage is outside of the
callable's domain of responsibility. the callable does not actuate the
change, only signal it.

this is an important point, because it lets us make re-usable normalizers
that can work across a variety of business domains *and* frameworks *AND*
modalities.

how the callable signals such a change back to the system is covered below.




## how can the callable signal signals back to the system along each of
   the three channels of concern?

the `normalizer callable` "attaches" to the system along four "control points",
which is a fun way of saying that it takes three arguments and has one result.
also we frame it this way because sadly we know that this interface, no
matter how perfect it seems now, must one day change.

covering each of these control points effectively documents the entirety of
the F-ace API API field-level normalization API. we present them here in a
fuzzily-narrative chronological order corresponding roughly to the sequence
in which they become significant:



### control point 1 - the incoming value from the upstream

the first significant control point answers question, "what value is
the field currently?", and comes in the form of the second argument to
the `normalizer callable` (the reason for the arguments' order is explained
below). we often name this variable `x` because its particular shape is
often unknown, depending on the callable's relationship to the upstream.

the `normalizer callable` can assume that this value is the currently "stored"
value for the field, and will continue to be so if no further signals are
indicated.

hypothetically `x` could be some kind of complex mutable object (i.e not
just a string, etc) that the callable is expected to mutate in some way as
part of its normalizing behavior, but at the time of this writing we haven't
employed this behavior in any of our normalizers.



### control point 2 - the notification yielder

the second control point is the `notification yielder`. to a developer with
familiarity with any other validation / normalization solutions in any other
framework, this facet of this system will likely seem much simpler than
whatever they have worked with before, for better or worse depending on the
developer's "perceived" "needs" `^_^`.

the `notification yielder` gets passed to the callable and is its *sole*
means to signal back to the system that a validation error occurred.
this corresponds with "channel of concern one above, which explains
what we mean by "validation error".

currently the only point of control on this yielder object is its `yield`
method (alias `<<`). for now, this method will likely expect strings to be
passed to it with surface-ready messages.

this typically looks something like:

  y << "input does not look like a frobulator - .."

every time the notification yielder is called it stands as a notification
to the system that a validation error occurred. (additionally the system
may chose to do something with the string argument, like display it.) often
a validation error having occurred is a signal to the system that some
future further path should not be taken with the agent, for example executing
it (if it is an action); but that depends on the system.

although currently this interface is very spare and its power limited, it may
evolve into a more sophisticated control object on which `<<` is just one of
serveral control points through which the callable can signal to the system
that some kind of error (or maybe one day non-error event) occured.

(this "more sophisticated object" has been dubbed "the #snitch", is used
prototypically in a couple of systems, and is and is tracked by [#051],
but it is beyond our concern for now.)

also it bears mentioning that this simple arrangement has proven
"powerful enough" to get our basic API's off the ground.

in nature as well as in our examples the notification yielder often gets the
variable name `y`. we employ this pattern frequently enough that we feel it
warrants an idiom that owns an entire letter of the alphabet (for now)
[#sl-130]. (more of the "historical reasons" of this: `y` was used to hold
the yielder in the first blog article (or email or something) succeeded in
demonstrating to the author how to do anything powerful with enumerators.)

this notification yielder gets passed to the callable as its first argument.
the reason for this position is explained below.



### control point 3 - the `value change` callback.

a `normalizer callable` changing the received value is not a foregone
conclusion. a normalizer may exist simply to ensure that the value is not
"bad", and if it is "good", it may leave it alone. however when the time comes
that the callable needs to change the received value to anything else,
the caller must do this through the `value change` callback:

if the `normalizer callable` wants to change the value that will be used
downstream to something other that the value that was received from the
upstream, it must do so by sending the new value to the `value change`
callback.

the reason it should not do this through a more straightforward means is
explained somewhat above, at "channel of concern three", which is the
corresponding channel of concern for this control point. we will offer other
reasons below, when we explain why the `value change` callback is the third
and final argument to the `normalizer callable` below.



### (final) control point 4 - the result of the normalizer callable.

the result of the call to the `normalizer callable` will be treated as a
boolean-ish indicating whether or not the field is to be considered as
having been `provided` or not. as described in "channel of concern two"
above, if your callable reports that the field is effectively not provided,
and the field is ascertained as `required`, then it will likely trigger
some kind of "required field missing" behavior, depending on the agent-level
normalization algorithm.

as `nil` and `false` may variously be valid values for your field depending
on what you are doing, the system leaves it to the callable to decide what
qualifies as having been provided. a default assumption in the absense of
any `normalizer callable` will likely be that a value of `nil` is interpreted
to mean that the field was not provided, and all other values (including
`false`) will be interpreted as meaning that the field was provided.



## synthesis: why are the arguments in this strange order?


to see it all put together, here is some pseudocode calling a
`normalizer callable` with the three arguments described in painful detail
above, and us receiving the result:

    # y = the `notification yielder`. send `<<` to it to indicate error
    # x = the value of the field received from the upstream
    # change_value_p = a proc to be called when the normalizer wants
    #     to issue a change in the value

    is_provided = normalizer_callable[ y, x, change_value_p ]


• `y` as the the first argument - although output arguments are a smell
according to Martin's _Clean Code_ [#sl-129], we have realized tremendous
modularity by using them throughout the system especially in dealing with
domains that render a lot of text. (in fact we can use Martin's axioms to
make a case *for* using output arguments but that is a digression..)

for better or worse, whenever we are passing a yielder to a method we
always (always) pass it as the first argument. we follow that convention here,
although this `y` has a more nuanced role to play that those of the text
renderers (hint: it is sometimes not just an ordinary yielder).

• `change_value_p` as the last argument - because we pass blocks to ruby
methods "at the end" we evoled the convention of passing callback functions
at the end just the same. the callable signals to the system to change the
value via a callback and not a return value in part because changing the value
may require work, and changing the value is not a foregone conclusion, *and*
the changed value may assume any form, including `nil` or `false`. hence it
would be impossible (or at least awkward) to signal to the system both that
work required to change the value should be executed, and what that particular
value is.

• `x` is the middle argument because `y` must go at the beginning and
`change_value_p` must go at the end. some design choices get made for us.

• `is_provided` as the result value - for two reasons: 1) the result value
is the most straightforward way to get a boolean value (or anything) back from
a method. 2) the result value as a "control point" wasn't being taken up
by anything else, for the above described reasons.

all of this will likely have changed by the time you finish reading it, but
thank you anyway for doing so ^_^
_




## document meta

  - #pending-rename - should be moved next to [#fi-012] and edited appropriately

:+#tombstone the documentation of the five sunsetted normalization methods
