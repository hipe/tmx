# the control-flow method-naming idiomspace :[#0154]

the overblown title of this article is a formal way of saying something like
this: if a method results in true-ish then it means keep going. otherwise
(and it follows that the method result is false-ish), then it means stop now.
but that is just the general idea and not the general rule. it fact sometimes
it is just the opposite.

in a world where we employ mutually inconsistent signatures like the above,
name conventions are essential to disambiguate them. those name conventions
are the focus of this article.



## the "resolve_" family of constructions

this particular family of method names was the original motivator behind this
article. we use this stem often enough that it has become necessary to define
what is meant by the differnt forms it assumes.

in general a "resolver" method is for building and/or retrieving an object
or value. to say that it is "resolving" it rather than just to name the method
after the noun conveys that there is some work to be done, work that could
potentially result in a failure to yield the desired object or value, states
that in turn could potentially lead to side-effects behavioral and otherwise.

the "resolve_" class of methods has three forms, all prefixes: "resolve_some_",
"resolve_any_", and "resolve_" (not followed by "some" or "any"). each form
has a corresponding #de-vowelated form with "rslv_". we cover them one-by-one
below.



### the plain old "resolve_" (alternately: "attempt_[to_]") prefix

the plain old "resolve_" method (that is, any method whose name starts with
"resolve_" (or the #de-vowelated form "rslv_") and is not followed by "some_"
or "any_") must be used to conveny that:

  • your method will succeed or fail
  • its success or failure must be reflected in its result value
  • the result value must be interpreted as a control-flow boolean:
    true-ish means "success" / "procede", false-ish means "failure" / "cease"
    • shades of meaning different between the two possible false-ish values
      in ruby are not here prescribed. conversely we may one day proscribe
      this practice.
  • you must not piggy-back and have the result value double as a meaningful
    busines value. (consider "resolve_any_" for this, explained below.)

calling such a method may effect arbitrary side-effects:

  • it may call_digraph_listeners events or otherwise effect behavioral side-effects, for e.g
    to indicate that the desired value or object could not be resolved.
  • these methods often but not always have some business objects or values
    that they were used to .. resolve. such values *must* be stored to ivars
    in this case as appropriate: they cannot be returned as a result value.
    (this is a restatement of a point above.) (the remaining two forms are
    for this.)
  • as often as is not the thing being resolved may some abstract condition
    or confirmation about an external state.

it is for now undefined whether this method should be re-callable or
idempotent.


#### discussion

it may present a slight challenge to unlearn the habbit of using this name-
form in a manner that we used to, but is now deemed incorrect:

    fh = resolve_input_file_handle  # THIS IS NOW WRONG

    fh = resolve_some_input_file_handle  # this one of 2 possible replacements

    fh = resolve_any_input_file_handle  # this is the second one.

    if resolve_input_file_handle  # and this is the new correct usage
      @input_fh  # ...
    end

the above first line is incorrect because we are acting as if we expect
to get the business value back from the method call. in fact we must get
a control-flow boolean.

the reason we may no longer use the above form to return business values is
because just as often as not we are also employing a "resolve"-style method
in the manner described here, as something that resolves a control flow value.
but we cannot use the same form to cover these different signatures, that
leads to ambiguity, which is our anathema.

so we needed some form to cover this other signature, and no other form was
availble that did not sound awkward (we considereed "attempt_resolve_" for
this.) but since "some" and "any" are already constructions in broad use by us
and they cover the semantics more precisely, we tighted the meaning of plain
old "resolve_" down to this.



#### "attempt_[to_]" as a variant

in some cases it reads better semantically to use "attempt_[to_]" instead of
"resolve_", for cases where the thing you are resolving is more of a verb-
like action than a noun; but often verbs and nouns have isomporphs to one
another, so for e.g between the names `attempt_to_connect`,
`attempt_connection`, or `resolve_connection`, it can be chef's choice for
now. but use discretion and try to be consistent somehow. the bottom line
is that any and all of these surface forms in their use in the field must
comply to the criteria prescribed above.

as tempting as it may be we do not use the shorter but otherwise semantically
similar prefix "try_", to avoid any confusion with the popular language
construct from many languages that pertains to exception handling.

as stated above, the above pertains just to methods that begin with a
"resolve_" or "rslv_" *not* followed by "some_" or or "any_". we cover those
now:



### "resolve_some_"

in contrast to plain old "resolve_", the business payload of a call to a
"resolve_some_"-style method is in its result value.

the "some" in any method is generally an assertion that under normal, non-
exceptional circumstances the method call must be expected always to result
in some true-ish value.

• similar to a "build_" method described below, using this form in your method
  name is a promise that your method either results in the stated object
  or value, or raises an exception (directly or effectively) in such case that
  it cannot.

• the method body of such a method must not assign any resolved value to
  an ivar. the caller is free to do this as appropriate.

• as to whether this method may call_digraph_listeners behavior side-effects such as
  emitting events, see discussion below.

the reason you would say "resolve_some_" and not "build_" is because maybe
this method is not constructing a new object itself, but rather getting it
from somewhere else or from some (potentially deep) logic tree, or just
looking it up somewhere.

the reason you would say "resolve_some_" as opposed to the plain noun form of
the thing you are yielding is because you want to emphasize that this is not
memoized to an ivar, that is, that the work involded in yielding the target
value will be executed again if this method is called agiain.

this method may effect behavior side-effects (like emitting events).



### "resolve_any_"

in contrast to "resolve_some_", it is within the scope of "normal" for a
"resolve_any_" to result in false-ish if a resultant object is not available
or applicable. the caller must assume responsibility for the possibility that
the call resulted in false-ish.

in contrast to a plain old "resolve_", the business payload of this method
call is its result value.

• the method may result in a false-ish which is an indication that no such
  object or value is applicable or provided.

• the method itself must not set any ivars (but its callees may).

• as to whether this method may call_digraph_listeners behavior side-effects such as
  emitting events, see discussion below.



### discussion of the three forms

to summarize, the plain old `resolve_` form purports a result shape that is
to be interpreted as a control-flow boolean-ish, whereas the `_some_` and
`_any_` forms both purport a result (if "any" where applicable) that is to
be interpreted as the appropriate business value in the rest of their names.

a mnemonic for this this reasoning: "some" and "any" are result-shape
indicators, and because the plain old `resolve_` form doesn't have one, the
default is to assume that the result is a control-flow boolean. (this is more
of a pragmatic decision than any; that is, this is based off of how these
methods are usually used rather than ideological design principles.)



### is it ok to effect behavioral side-effects from these methods?

the short answer is "probably yes." because calling any form of a "resolve"
method generally means you are doing some non-deterministic or (perhaps only
slightly) non-trivial amount of work, then there is always a chance that you
will want to call_digraph_listeners informational events (if for exaple you want to state
explicitly that you are loading some default object because one was not
stipulated specifically in the request.)

certainly in the case of plain old resolve, it would be too limiting to not
allow the emission of events, because these methods are generally modeled to
wrap the handling of the kind of soft failure events events that you want
to report in the UI.

but keep in mind that for the "some" and "any" forms, they are not supposed
to memoize their results themselves, so calling them multiple times should
generally result in the same events being emitted multiple times, which is
usally not what you want.



## the "when" prefix and in-fix

the "when" construction when used must be used in conjuction with the other
naming conventions. it does not serve as a replacement for them.

the "when" prefix or in-fix may be employed to "soften" the specificity of the
method name in a manner we like to call an "inversion of emphasis": this
construction is employed to emphasize the conditions under which the method
is called rather than the behavior the method effects.

often we end up with chains of "when"-style methods that follow boolean
control-flow branches in the code:

    def resolve_foobric
      if :green == color
        resolve_foobric_when_green
      else
        resolve_foobric_when_not_green
      end
    end

each such method name conveys both its purported result shape and the
conditions under which it may assume to be called.

if "when" is used as a prefix (that is, it is at the beginning of the method
name) then the method must *not* have a meaningful result value.

if "when" is used as an in-fix (that is, not at the beginning) then the method
must have a meaningful result and that part of the method name before the
"when" must convey its shape or otherwise employ an idiom that acheives as
much:

    def validate_when_socket_busy # ..

(the meaning and result shape of a "validate" method is covered in [#154]
the method naming idiomspace of validation.)

clever use of "when" as a suffix may be employed in a method whose only
argument is something like an #endpoint-symbol, e.g

    def exitstatus_when endpoint_i  # ..





## Appendix: popular method name idioms not related directly to control-flow

although these idioms do not relate directly to control-flow, we could argue
that they do obliquely because you have to know their result shape to know
whether or not they should be used to determine flow of control. (but then
by this argument every method name relates to control flow. i suppose it
does.) but really actually this is just a list of popular method-naming
conventions that are not covered by the control-flow class of constructions
above.

rather than order them alphabetically, or more interestingly in order of
object lifecycle; we order them in descending order of popularity, because
there is a significant drop-off point somewhere below with regards to their
frequency of use.


### the "build_" family of prefixes

a method whose name starts with "build_" (or the #de-vowelated form "bld_")
must follow every point of this criteria:
  • it must result in a new object that it constructs.
  • the object must not be assigned to an ivar inside of the method body.
    (frequently the result a call to a builder method gets memoized
    mmediately to an ivar.)
  • more broadly this method must not have any side-effect as follows:
    the method itself must set no ivars or effect any behavior side-effects
    (e.g emitting events). (however methods it calls may have artibraray side
    effects but should not have any. see discussion below.)
  • there is a fuzzy distinction between when to use "build_" vs. [#094]
    "get_", but generally the former is for objects of business classes
    and/or stdlib classes, and the latter is for hashes, arrays and strings
    that may be mutated. generally the former is expected to be called once
    for the lifetime of the object (but not necessarily) and is often private
    whereas the latter is expected to be called multiple times and is public.

if there is is a chance that this building will result in a non-exceptional
failure and the method may result in e.g false-ish and/or effect behavioral
side-effects then this is not a builder method but a "resolver", specically
it sounds like a "resolve_any_*" as presented in [#154] the control flow
method naming idiomspace.



### the "begin_" prefix

semantically this is a "sub-step" of a "build".

currently a "begin"-style method may either result in or set an ivar to an
object that has "begun" being built but has not "finished" being built.
often it is the caller that is expected to finish the building of the object.


#### history

we used to use the stem "create" for this, but this practice was eliminated
as a convention and replaced with "begin" because of its potential for
confusion with "build".

we used to use the stem "start" for this, but this practice was eliminited
because of its potential for confusion with the operation of starting a
long-running daemon process, something we would like to do one day.
