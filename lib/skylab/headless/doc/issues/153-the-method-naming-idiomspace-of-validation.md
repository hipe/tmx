# the method-naming idiomspace of validation :[#153]


## purpose and scope

the goal of this article is to put forward formal meanings variously for the
stems "normalize", "validate" and morphological variants thereof so that we
may write code that more rigidly, consistently and clearly self-documents in
this regard.

there exist may mechanical variation in how a normalization method may mutate
its data and how it may effect behavior in response to any normalization (or
validation failure) that may occur. these variations include things like
whether or not and how ivars are used, vs. result values; and when it comes
to behavior, the implementation will depend on the event model in general
(but in a [#139] perfect world means something like emitting ad-hoc event
objects to listeners).

this document will not yet prescribe a convention for all of these facets
until we feel that we reached an adequate general convention. having said
this, we feel at this point comfortable prescribing some general conventions,
especially in regards to the semantic distinction to be drawn between
"normalization" and "validation":



## normalization

this document does not yet stipulate a particular shape for a method that has
as a stem the term "normalize", except to say that such a method may
potentially mutate either the particular business field or the whole object
as appropriate. it is very likely that we will stipulate that the result of
such a call be a boolean-ish indicating whether the field or object is valid
or not, that is, whether or not the data could be normalized (similar to
[#fa-019]).

(there exists [#fa-019] one particular normalization API documented
voluminously in all of ~3000 words. when the topic document reaches draft we
should cycle-back there and confirm that the language accords with this
convention.)

at first approach it is tempting to state that a `normalize_foo` method must
take 1 "foo" arg and must result in either a valid (and possibly mutated)
value of foo, or false-ish if the value could not be normalized.  however this
is not a good general solution for several reasons:

• for one, it is not clear if this method should mutate the argument (and also
  redundantly result with that same argument as a value), or always result
  in a new object, which makes zero sense to do in those cases where mutation
  is not performed. and when mutation is necessary, this operation may not
  be suitable for "large objects".

• for two, this does not cover the class of cases where a false-ish is a
  valid value. in such cases we cannot do the semantic overloading of the
  result value, because false-ish may no longer have semantic value if it
  has business value.

• for three, a normalization operation is rarely useful without an event model
  that it rests on top of. both when mutation occurs, or an unresolvable
  validation error occurs, it is so undersirable as to be useless not to call_digraph_listeners
  this information in some kind of event behavior; and the method shape of
  topic does not self-document what the event substrate is, if one even
  exists.

the [#fa-019] generalized normalization solution has resolutions for all of
these issues.



## validation in conjunction with normalization

• we draw a sharp semantic distinction between "validate" and "normalize": to
  "normalize" means that you are potentially mutating the data. to "validate"
  is simply to resolve a "yes" or "no" as to whether that field-ish (or whole
  object) is valid (but see more comments about validation below).

• formally "validation" is a specialized form of "normalization": not all
  normalization need necessarily result in mutation of the data; however a
  validation operation must never mutate the data (tautologically, by this
  defintion here we are offering).

• despite the above, whenever we are doing a normalization that is also a
  validation, the latter stem must be used in the method name, as opposed to
  the former. (if your logic dictates it, implement your "normalize" method
  simply by being a wrapper around nothing other than your "validate" method
  where appropriate).

• a "validate" may not mutate the particular business data in question,
  however this is not to say that a "validate" may not have side-effects; in
  fact it must: if the method name begins with "validate" (including the
  method that is named "validaate"), then it must behave in two ways:

    1) the boolean-ish-ness of the result value must reflect whether or not
    the field in question (or whole object as appropriate) is to be considered
    as valid: true-ish means valid and false-ish means invalid [1].
    we do not stipulate here whether there are shades of meaning different
    between the two false-ish values that we have availble to us in ruby,
    only that for the purposes of this discussion there is no difference.

    2) in the case of the "validate" call that results in false-ish (that is,
    the business data was invalid), this method call *must* effect behavior
    accordingly (i.e call_digraph_listeners any output event structures for e.g). if you want
    to write a validate method that has no side-effects, then you do not want
    a "validate" method but rather, see the next bullet.

  since we stated that a "validate" operation may not mutate the state
  of the business data (that is for "normalize"), then it necessarily follows
  that two calls to the "validate" method must effect the same behavior: that
  is, that if the field or object is invalid, that these two calls in a row
  must e.g call_digraph_listeners the exact same events. bullets below will discuss this.

• if you want something like a "validate" method that has no behavioral
  (or otherwise) side-effects, then you must not name your method with
  "validate" as as stem. name your method something like `foo_is_valid` or
  simply `is_valid` as appropriate; which, purusant to the [#095] name
  convention for methods that result in boolean-ish, confers that this method
  results in a semantic boolean-ish with no side effects at all.

• if you want something like a "validate" method that only emits events once
  and does not repeat itself, then you need something like a state machine,
  or better yet a dedicated builder class whose only job is to build a
  a valid object or call_digraph_listeners events as appropriate.



## footnotes

[1] if you are looking for something like [#sl-135] exist statii, keep in mind
that you must not result with an exist status from such a method. some
conventionally correct ways to accomplish such a thing might include:
  • (perhaps less attractively) set the exit status to an ivar as a side-
  effect of your validate or normalize method.
  • rename your method to something like
  "determine_any_error_exit_status_for_foo", which confers a lot of meaning,
  if it is given that all exit statii are integers: the "any" tells us that
  it may result in false-ish. hence this method must either results in an
  integer or false-ish. because "exit status" is qualified here as being only
  of the "error" variety, we know that if this method results in false-ish,
  then we are not in an error state; that the field is valid.  conversely if
  it results in true-ish when we know that we are in an error state and
  furthermore we have our exit status, all with no side-effects.
