# thoughts on the abstract component system ("ACS") experiment :[#089]

(EDIT: the correct name is "[..] autonomous [..]" but we are holding off
on the file rename until etc.)

## principles & patterns

• model classes are implemeted as many small, "autonomous" components
  rather than needing to cram many different property-level concerns
  into one node.

• (new in this version) we attempt a consistent inteface whether the
  mutatee is more like a "collection" or more like an "entity" (because
  from our new perspective, entities are like polymorphic collections of
  components).

• that is, what can be conceived of as a "component" may be (for e.g):
    * an instance of a typical model class (i.e an "entity")
    * objects at the sub-entity level, that help to make up the entity
    * entire collections of entites can be conceived of as components

• components are mutated through "edit sessions" (referred to internally
  as "muation sessions"). if we ever apply this to a platform that likes
  immutable data, we have this assumption isolated conceptually.

• participating "compound components" (components that consist mainly
  of other components) define themselves in terms of a set (possibly
  ordered, depending..) of their "component associations".
  what in another library we called a "formal property" here is
  conceived of as a "component association", which consists of:

    * a name (imagine it is any string) that is unique in the context of
      all the other subject component's component associations.

    * a "component model" (needs only implement one method (see (5) below)).

    * a set of zero or more operation verbs (each string-like) that can
      deliver such a component to the subject component thru the
      execution of an "operation" during an edit session.

    * we are considering the different ways to provide an extensible
      grammar for edit sessions #tracked-by :[#120].




## how it is better (or worse) than [#001] entities?

• less minimum API - the way this necessarily alters the interface of the
  client class is simplified: for basic "inward reception" (below)
  without special features, there need be only the component association
  builder method(s), all of which have a namespace-safe name convention that
  is of the safe "generated form" variety.

    • also, `result_for_component_mutation_session_when_changed`
    • also, `result_for_component_mutation_session_when_no_change`

• dynamicism is heavily assumed - using [#001] we had to jump thru some hoops
  to allow the individual entity to have "dynamic formal properties".
  here, neither by default nor at all do we ever think that to reflect
  on the entity's formal associations should we look to its class.

  here, the "component association" is built anew on the fly as it is
  needed, by sending a message to *the entity* and not its class.

  the cost of this is potentially significant when we get to dealing with
  more than one entity of one class in one runtime, which we haven't
  yet (but hope to..)

• there is as yet no facility for what we used to call business-specific
  meta-properties. we want this, and will provision for it when its
  absence becomes at all painful. (again this is :+[#120].)




## the N tenets of the autonomous component system ("ACS") (experimental)

in summary:

1) in application code, ACS components are *not* constructed using `new`

2) new components are constructed by sending `edit_entity` to the class

3) existing components are mutated by sending `edit_entity` to the component

4) for "inward" purposes, associations are defined thru *instance* methods

5) simple or one-off models typically produce components thru `[]`

6) `interpret_component` is above for dedicated models

7) modifiers (experimental): `via`, `using`, `if` and `assuming`

8) verbs ("operations") are implemented wholly by the subject component


we may tag some (or all!?) of the various occurrences of these tenets in
the code because of how hot-of-the-grill experimental it all is and
consequently how subject to change it is.

(and yes, it may be folly to number these, because the composition may
be a bit arbitrary. as it is etc.)




here are each of the N tenets in-depth:

### 1) avoid using `new` for "external" construction of ACS components

the ACS conceives of "construction" as being distinct from the "building"
of a component. "construction" is a platform-specific activity that
involves sending `new` to the class which sends `allocate` to the class
and `initialize` on the resultant object, and always results in the object.

"building", on the other hand, is conceived of by the ACS as both the
initial construction of the object and the asssembling of it with other
components into a component that is valid for some purpose.

ACS deems "construction" as being out of its own scope entirely - it gives
you complete freedom to implement `initialize` in whatever way makes
sense to your needs.

it is tempting for us to want to cram the "building" concerns into the
"construction" methods, but in practice this is not a clean fit for
reasons.

it is the ACS's recommendation that neither the human nor the machine
send `new` to a participating class except in the ways proscribed below
in (2) and (7A) below.

because we are purists, we almost always set `new` to private on
participating classess for this reason, to enforce this design custom.




### 2) humans build new components by sending `edit_entity` to the class

the human may construct a component by sending an `edit_entity`
call to the component class IFF (perhaps tautologically) the particular
component class has "decided" to expose (i.e implement) this method.

that is, the component designer decides "autonomously" whether or not
to expose this method in an opt-in manner; it is not exposed by the
library unilaterally.

this library's `create` singleton method can help implement such
an exposure typically in one line.

for now, we recommend to use this same name (with "edit" in it) as the
method name used to edit existing entities (discussed below) as opposed to
a method name with a verb like "build", "create" etc. in it for this reason:
conceptually (if not in implementation as well) we can reduce the operation
of constructing a valid entity down to the two steps of 1) creating an empty
entity and 2) editing this entity as you would edit any other existing
entity. this reduction can simplify implementation because step (1) has very
few moving parts and step (2) needs to be implemented on its own anyway for
this distinct operation of editing an existing entity.

another quick side note, for now we use "entity" and "component"
interchangeably. in this method name use "entity" and not "component" because
the resultant name is something of a universal idiom here, and hints at our
longterm goals for this library.





### 3) mutate an existing component by sending it `edit_entity`

3) the human may mutate ("edit") an *existing* component by sending
an `edit_entity` call to the component instance IFF (likewise with
above) the particular component has exposed this method (but this time
as an instance not class method).

this library's `edit` singleton method can help implement such
an exposure typically in one line.

although this is arguably the most important facet of an
ACS-participating component, we have the least to say about it here.
each of the remaining tenets explore the all of the essential elements
that go into an ACS "edit session".




### 4) component assocations are defined thru instance methods.

a "component association" is the association of one model to another
thru a name and usually some "meta-components" about the association.

by "model" we may mean only in an abstract sense, like for example the
creation of an ad-hoc normalizing function just for the sake of this
component association.

for "name", imagine that we mean any string; but note that how the
association is actually "stored" internally is about to be revealed
(partially), and is not a string per se.

in the ACS a "compound model" is simply any model that defines
one or more associations like these.

naively we may try to classify each component-related activity as
either "inward reception" or "outward reflection". the activities
desribed in (2), (3), and (6) all fall into this "inward reception"
classification: given each component association name, the subject
component must determine which model to use to parse out a
component from the input. however, it is not the case that the
subject component needs to "outwardly reflect" *all* of its component
association names in order to accomplish these inward operations.

were it the case that the component needed to report *all* of its
component associations for whatever reason, we would call this
"outward reflection".

it bears mentioning that this dichotomy is only of limited use: if
we were to attempt an operation that validated an edit against some
idea of "required fields" (not yet implemented anywhere with ACS),
this operation "feels" inward but requires "outward reflection" too.
(this is why we call them "classifications" and not "categories".)

anyway, the fundamental requirement of all ACS compound models is that they
produce each model for each of their component associations thru a call to `__foo_bar__component_association` with the association name substituted in
for `foo_bar`. the rationale behind this perhaps strange-looking convention
is described at the end of this section.

we don't yet get into the important facet of association "arities"
("belongs to", "has many" and so on) as ORMs do but this is a
possibility for the future.

as a historical note, we used to define these component
associations *on* the model class as singleton methods, but we
opted to change this to allow for the component instance to change
what model serves its associations dynamically. the cost of this is
in awkward semantics, and we now need to construct the component
before we can build it.




#### the "generated form" method naming convention

the method name of `__foo_bar__component_association` has a *pair* of
*double* underscores nesting the *variable part*  of the method name.
(yes, a pair of a pair, or "meta-pair".) while this convention may
appear ugly at first, it exists with good reason and is central to the
ACS:

all methods for which part of the name will be generated must use
this "generated form". using this name distinct name convention for
such cases has at least two benefits:

• for the developer searching for code locations from which a method
  like this is called, she will not find the locations by searching
  for the method name as-is. this convention is a stark visual
  reminder of this. (instead, she may want to try searching for the
  non-variable part of the name.)

• employing this convention protects the component names in
  "business-space" from bleeding into the names in "mechanism-space"
  and vice-versa: provided that this name convention and this
  purpose are used one-to-one, we are "guaranteed" never to hit
  namespace collisions as we add component associations to our models
  or add/change the names of our implementation methods.




### 5) `[]` is the base case method for a model to implement for building

at its essence a component model is a function that produces a
component from "the input". if the component model does not employ
the technique described in the next tenet, it must employ the
technique described here: the "model" (described in (4) above)
will receive a `[]` message with the "argument stream", with which
it must attempt to produce the component.

reasons this technique may be useful include but are not limited to:

  • the "model" is implemented as a proc because it is simple

so that this technique supports components that are validly false-ish
(that is, that the component can validly have a value of `false` and/
or `nil`), the result of this call must be an object that responds to
`value_x` which must produce the component.




### 6) the build API for ACS-aware models that model true-ish components

if the model responds to `interpret_component`,
the ACS will use this means (instead of the means described above) to
attempt to produce the component.

we say "interpret" because this method is expected to interpret one
or more tokens off the argument stream to turn it into a (trueish)
object.

this method's semantics are *almost* like the `[]` described above.
a side benefit of implementing this method is that our API requirements
don't take up the common, idiomatic (and vague) `[]` name, in case your
e.g class would like to use it (or continue using it) for a different
purpose. but there is a cost too:

IFF the interpretation is a success it must produce the sub-component
itself, which to use this form cannot ever be validly false-ish (unlike
in (5)), which is not usually not a problem because typically the model
exposing this means already has a dedicated class (which is what received
the subject call), and all classes produce objects, and all objects are
trueish; hence we can overload these two concerns (whether thex
interpretation succeeded and if so, what the payload value is) into this
one value; for those models that have dedicated classes.

for a model that is mainly a compound model (i.e one that models a
component that consists mainly of other components), the library's
`interpret` function can help implement exposures like these typically
in one line.




### 7) the fixed set of modifiers.

zero or more "modifier expressions" occurr at the very beginning of
an operation expression. contrast:

    edit_entity :add, :person, "Myung"  # no `via` modifier

    edit_entity(
      :via, :social_security_number,
      :add, :person, 012_02_0122
    )                                   # yes `via` modifier

in the above, the second edit session has an operaton that uses a `via`
modifer (described below).

the implementation of modifiers is currently exploratory. #open [#120]
we intend to make it a more extensible API (and have them be less
hard-coded) once modifiers incubate for a while.



#### A) the `via` modifier

when interpreting an operation expression, the ACS will recognize a `via`
modifier as a way to change how the sub-component of that operation is
constructed. the `via` modifer takes any symbol as its one argument, and
that symbol will be interpolated into a method name that will be sent
to the component model to build the sub-component:

for example, if `foo` is the argument to the `via` modifer, the ACS will
send `new_via__foo__` to the component model, along with the main
argument from the operation expression.

(we may refer to the `foo` term as the "shape" in some contexts.)

this naming convention with the nested double underscores is
the "generated form" desribed in (4).

`via` modifiers are an assertion of shape with an expression of
intent: it allows us to implement a variety of ways that the input
can be created from a variety of shapes of input, and then specify
at construction time which way is supposed to be used; rather than
a more loosey-goosey process of type inferrence, that might lead to
unintended success or encourage poorly thought out design.

the result semantics of this form are (and must be) exactly as in (6),
ergo this form cannot be used for components that are validly false-ish.

to achieve the class-less-ness of (5) but still support this `via`
modifier, you would have to implement the desired behavior yourself
in such a proc-like.

A1) as a somewhat parenthetical aside, constructors like those defined
   for (A), when needed for human consumption must be exposed to the
   human thru the appropriate counterpart human names (e.g `new_via_foo`
   for `new_via__foo__`). an existence of the human-such form does not
   necessarily indicate the existence of the machine-such counterpart
   nor vice-versa: which forms to expose is a design choice for the
   particular component.



#### B) the `using` modifier

if the sub-component is resolved it is "delivered" to the subject
component thru the latter's implementation of the "operation method"
(e.g `__set__component`) derived from the operation verb in the edit
expression.

normally the singature of this call is (currently) `(x, ca, & oes_p)`
where `x` is the component and `ca` is  the component association
structure.

for each `using` expression in the edit expression, one corresponding
argument will be included in the above call in addition to the above
described arguments. these additional arguments are added in front,
in the order they occur in the edit expression.

this explanation makes no sense without an example, which can
be found in the dedicated spec file for this node.

but here's this too:

    edit_entity :set, :severity, :SEVERE

    # probably calls `subject.__set__component svrty, ca, & oes_p`
    # where `svrty` is whatever object, `ca` is a component assoc, etc.

    edit_entity(
      :using, :one,
      :using, :two,
      :set, :severity, :SEVERE
    )  # calls `subject.__set__component :one, :two, svrty, ca, & oes_p`




#### C) the (experimental) `if` expression

an `if` expression acts as a filter, determining whether or not the
we actually "deliver" the sub-component to the operation method.

this same behavior could be accomplished "by hand" by implementing
another operation method that does the conditional check (whatever
it is) in code, however we ship in here as this sort of "logic macro"
becauase of the sheer convenience it has for us when manipulating
collections.

allowing for the use of an `if` expression requires that the
subject component (class) implement a corresponding `test` method for
each of the (symbolic name) tests that are to be supported.

the semantics of these methods are similar to (8) in that the subject
component is called wih a "generated form" method, and passed the
same args as the default args described above in (B).

but rather than this method mutating the subject, it is supposed to
result in merely a true-ish or false-ish, indicating whether the
operation is "clear" for execution. (the method will often want to
emit events as well, as is described below.)

in cases where the delivery of the item is not clear for execution
(because the test method resulted in false-ish), the sub-component
*will not* be delivered to the operation method, but *the operation
will report that it succeeded*. this is in contrast to (D) next.

if a `not` symbol occurs immediately after the `if` symbol, it has
semi-special significance: this `not` is something like a reserved
word - you cannot have the symoblic name for your test be `not`, but
any other name is allowed.

currently the `not` keyword does not simply negate the result of
the test "expression" (method call); rather it calls a different
test method method that the test method that would be called
without the `not`:

   `if`, `foo`, ...  # calls `component_is__foo__`

   `if`, `not`, `foo`  # calls `component_is_not__foo__`

 you could also just:

   `if`, `not_foo`  # calls `component_is__not_foo__`

this makes it less a boolean negation operator and more syntactic
sugar. this is by design, because in practice we use these `if`
expressions as "soft assumptions" that check for a condition, but
don't outright fail if the condition is false (they merely skip the
delivery). for these purposes, we typically want to emit
informational events when the test conditions fail. we do the
weird thing with interpolating the `not` because we typically want
to emit different events based on whether the positive or negative
case failed. ("assumptions" are introduced below.)

there can only be one `if` expression per operation expression.
this is a design choice, because it would be ambiguous what the
boolean semantics are for multiple `if` statements (AND or OR?).

however note that there *can* be multiple `if` expressions in an edit
expression (max one per operation expression).




#### D) the `assuming` expression

this is like the `if` expression with different expected behavior
and result value if the tests fails: if an `assuming` test fails, not
only will the delivery of the operation be omitted, but the operation
expression results in false, preventing any subsequent operation
expressions in the edit session from being delivered.

because (for whatever reason) the semantics are less ambiguous
here, `assuming` expressions *can* be chained together.

although this is a *very* exploratory pair of features, here's a thing:

  we may want to have *the same* implementations for the affirmative
 `if` and the affirmative `assuming`, and another same implementation
  for the two negatives. it seems we always want to emit an event when
  these result in false. but really this is an application choice.




### 8) the operation verb

the ACS assigns no special meaning to the various one or more verbs to be
supported in edit sessions.

the set of supported verbs is determined entirely by the subject component
within the component associations it defines. each verb to be supported by
the subject component corresponds to one method that must be implemented by
that subject component.

note that with an edit session being defined as one or more operation
expressions, and an operation expression containing exactly one verb,
then for an ACS component model to be buildable or editable it must
define at least one such verb (and implementation method).

grammatically the only requirement by the ACS for these verbs is that:

  A) the operation verb cannot be one of the modifiers
     (keywords) described in tenet (7) (an ever expanding list..)

  B) the operation verb must occupy exactly one token (not more) (but of
     course you could use single underscores to model verbs of more than
     one word)


a verb `foo_bar` requires an implementation method of
`__foo_bar__component( x, ca, & oes_p )` where `x` is the object
component and `ca` is the component association structure. (the
semantics of the double underscore convention are explained in (4)
above.)

the true-ish- or false-ish-ness of the result indicates to the ACS
whether or not the "delivery" of the operation succeeded. an operation
that fails delivery will lead to more or less immediate exit from the
edit session, regardless of any remaining operations in the "queue" for
that edit session.

in cases of success, the implementor may chose to result in the same `x`
(component) that was passed to it so that this component "bubbles out" and
can be used as the final result of the edit session (which can be useful
for edit sessions that build or remove items where the caller may want to
do something with this item). but not this technique cannot be used for
models where the component can be valid-ly false-ish. (rather, look into
using the "value wrapper" if you really need to.)
