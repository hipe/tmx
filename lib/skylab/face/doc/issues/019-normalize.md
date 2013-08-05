# the API action class normalizer instance method API

This is the field-level normalization API.

experimentally:

    class Foo < Face::API::Action

      params [ :email, :normalizer, true ]    # the `true` means we'll do
                                              # it with an instance method..
      # ..

    private

      def normalize_email y, x, value_if_ok   # note the form `normalize_<foo>`
        if some_rx =~ x                       # if the email looks good,
          value_if_ok[ x.downcase ]           # we weirdly downcase it
          true
        else
          y << "i hate this email."           # write errmsgs like this
          false
        end
      end
    end

in theory this API lets us focus on what normalization means for the
particular field, and insulates us from both how the data is stored and how
we are wired for eventing issues surrounding it, which in turn enables us
to make flexible, reusable normalizers. but there are lots of details:

## using the `normalizer` metafield

there exists in the Face API API recognition of a metafield called
`normalizer`. this metafield is associated with a (mandatory) value
which you must provide after the `normalizer` keyword in your field
specification. (in fact the meta-field `normalizer` has the value `true`
for its meta-meta-field `property`!)

this normalizer value must belong two one of the two classes: 1) it must be
the value `true` - OR - 2) it must be a callable (i.e it must respond to
`call`).

if the `normalize` metafield is `true` for a field with the normalized name
`foo_bar`, the system will assume that the agent will respond to a method
`normalize_foo_bar`. this method will serve as the `normalizer callable`.

otherwise if the `normalize` metafield is assicated with a value other than
`true`, the system will assume that the value itself is the
`normalization callable` (e.g a proc, perhaps defined inline or perhaps
held in e.g a constant, or perhaps even as the result of some other proc).

## how is the `normalizer callable` is used, and when is it called?

when a field indicates itself as having a `normalizer` as describe above,
the `normalizer callable` is guaranteed to be called whenever the agent
(e.g action) hits the `normalize` eventpoint during the course of the API
action lifecycle. this is true regardless of whether or not the particular
actual parameter was provided for this field (!).

(this is because there exist classes of normalization that expect to be run
whether or not an actual parameters was provided for that field, for
example, defaulting behavior.)

this system does not presuppose that the calling the callable has any side-
effects on the agent itself, nor does it care whether or not it does.
what the system requires of the `normalizer callable` is that it report back
to the system various pieces of information pertaining to certain facets
of this particular combination of formal parameter and actual paramter.

we will call these facets "channels of concern". each channel of concern
manifests itself in some way in the interface that the `normalizer callable`
must follow. for now, there are three "channels of concern":

## what are the three channels of concern?


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


### channel of concern two: is the value we should store different than the
    value we received (and if so, what is this new value)?

this is the bread and butter of normalization: a data node comes in in
some particular shape, and you may want to change its shape for a variety
of reasons (consistency, efficiency, data-de-duplication, because there
was a validation error, because of the requirements of various storage
contexts (volotile and otherwise), encoding, etc).

the `normalizer callable` gets full autonomy in deciding whether and what
to change the received value (to) for the field. as hinted at way above, the
callable will always be called whether or not a value was provided, so the
callable is one means by which we may implement defaulting behavior (but
consider first using the `default` metafield for this).

so the callable decides `if` the field's value should change, and if so
`what` value to change it to, BUT the callable does *not* get to decide
`how` to actuate the change itself. the aspect of storage is outside of the
callable's domain of responsibility. the callable does not actuate the
change, only signal it.

this is an important point, because it lets us make re-usable normalizers
that can work across a variety of business domains *and* frameworks *AND*
modalities.

how the callable signals such a change back to the system is covered below.


### channel of concern three: should the field be considered as having
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


## how can the callable signal signals back to the system along each of
   the three channels of concern?

the `normalizer callable` "attaches" to the system along four "control points",
which is a fun way of saying that it takes three arguments and has one result.
also we frame it this way because sadly we know that this interface, no
matter how perfect it seems now, must one day change.

covering each of these control points effectively documents the entirety of
the Face API API field-level normalization API. we present them here in a
fuzzily-narrative chronological order corresponding roughly to the sequence
in which they become significant:

### control point 1 - the incoming value from the upstream

the first significant control point answers question, "what value is
the field currently?", and comes in the form of the second argument to
the `normalizer callable` (the reason for the arguments' order is explained
below). this variable is often named `x` because its particular shape is
often unknown, depending on the callable's relationship to the upstream.

the `normalizer callable` can assume that this value is the currently "stored"
value for the field, and will continue to be so if no further signals are
indicated.

hypothetically `x` could be a mutable object that the callable is expected
to mutate in some way as part of its normalizing behavior, but at the time
of this writing we haven't employed this behavior in any of our normalizers.


### control point 2 - the notification yielder

the second control point is the `notification yielder`. to a developer with
familiarity with any other validation / normalization solutions in any other
framework, this facet of this system will likely seem much simpler than
whatever they have worked with before, for better or worse depending on the
developer's "perceived" "needs" ^_^.

the `notification yielder` gets passed to the callable and is its *sole*
means to signal back to the system that a validation error occurred.
this corresponds with "channel of concern one" above, which explains
what we mean by "validation error".

currently the only point of control on this yielder object is its `yield`
method (alias `<<`). for now, this method will likely expect strings to be
passed to it with surface-ready messages.

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
prototypically in a couple of systems, and is and is tracked by [#fa-051],
but it is beyond our concern for now.)

also it bears mentioning that this simple arrangement has proven
"powerful enough" to get our basic API's off the ground.

in nature as well as in our examples the notification yielder often gets the
variable name `y` because this is the name that ruby uses for the yielder
object in its documentation for enumerators.

this notification yielder gets passed to the callable as its first argument.
the reason for this position is explained below.


### control point 3 - the `value change` callback.

a `normalizer callable` changing the received value is not a foregone
conclusion. many normalizers exist simply to ensure that the value is not
"bad", and if it is "good" they leave it alone. however when the time comes
that the callable needs to change the received value to anything else,
the caller must do this through the `value change` callback:

if the `normalizer callable` wants to change the value that will be used
downstream to something other that the value that was received from the
upstream, it must do so by sending the new value to the `value change`
callback.

the reason it should not do this through a more straightforward means is
explained somewhat above, at "channel of concern two", which is the
corresponding channel of concern for this control point. we will offer other
reasons below, when we explain why the `value change` callback is the third
and final argument to the `normalizer callable` below.


### (final) control point 4 - the result of the normalizer callable.

the result of the call to the `normalizer callable` will be treated as a
boolean-ish indicating whether or not the field is to be considered as
having been `provided` or not. as described in "channel of concern one"
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

    # y - the `notification yielder`. send `<<` to it to indicate error
    # x - the value of the field received from the upstream
    # `change_value_p` - a proc to be called when the normalizer wants
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
renderers.

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

• `is_provided` as the result value - for two reasons: 1) the return value
is the most straightforward way to get a boolean value (or anything) back from
a method. 2) the return value as a "control point" wasn't being taken up
by anything else, for the above described reasons.

all of this will likely have changed by the time you finish reading it.
_
