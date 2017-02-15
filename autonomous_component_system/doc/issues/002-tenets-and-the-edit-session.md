# thoughts on the abstract component system ("ACS") experiment :[#002]

## design tenets

these tenets are a distilled expression of the "principles & patterns"
to be explored next, as well as observed tendencies that manifest
throughout the project. we give them identifiers because they are referred
to elsewhere in documentation. they are distinct from the 8 API tenets
to be introduced in a subsequent section of this document. it is worth
noting that some of these tenets were decidedly derived from the work
after it was effected, rather than informing it.

also the tenets are not hard-and-fast rules, but rather guidelines the
violoation of which should occur only with good reason.

• :DT1: autonomy: a component must be able to effect its own behavior
    without depending on any client (i.e would be "parent") component
    to the furthest extent possible.

    ([#ze-027] "formal parameter sharing" explores the converse of this.)

• :DT2: DRY-ness/intent-agnosticism: the structure, constituency and
    any behavior written into a component at this level must be done so
    in a way that is not particular to any one [#019] "intent". so the (for
    example) expression or interpretation logic should be represented in
    a way that can apply to as many different intents as is reasonable.

    the gravity towards DRY-ness also manifests prominently in the
    implicit facility of "model sharing", something the [ac] encourages
    without really even being aware of it.

• :DT3: dynamicism: the constituent list of a compound node's
    components (in both actual *and* formal sense) must never be assumed to
    be static. likewise meta-components of component associations.

• :DT4: conservatism: it is better to determine earlier that you won't
    need a structure, rather than to build it and not use it.




## principles & patterns

• model classes are implemeted as many small, "autonomous" components
  rather than needing to cram many different property-level concerns
  into one node. #DT1

• (new in this version) we attempt a consistent inteface whether the
  mutatee is more like a "collection" or more like an "entity" (because
  from our new perspective, entities are like polymorphic collections of
  components).

• that is, what can be conceived of as a "component" may be (for e.g):
    * an instance of a typical model class (i.e an "entity")
    * objects at the sub-entity level, that help to make up the entity
    * entire collections of entites can be conceived of as components

• one way that a component is mutated is through an "edit session"
  (which may be referred to interlally as a "mutation session").
  if we ever apply this to a platform that likes immutable data,
  we have this assumption isolated conceptually.

• participating "compound components" (components that consist mainly
  of other components) define themselves in terms of a set (possibly
  ordered, depending..) of their "component associations".
  what in another library we called a "formal property" here is
  conceived of as a "component association", which consists of:

    * a name (imagine it is any string) that is unique in the context of
      all of the "custodian ACS"'s component association names.
      (the meaning of "custodian" is explained in [#006].)

    * a "component model" (needs only implement one method, #Tenet5.)

    * a set of zero or more operation verbs (each string-like) that can
      deliver such a component to the subject component thru the
      execution of an "operation" during an edit session.

    * for advanced usage, you can extend the DSL that can be used by
      your component assocations: you can add to the set of supported
      "meta-components" your own custom ("business-specific") ones
      by subclassing the base component association class.
      a test example of this here (and real examples elsewhere) is
      tracked with [#013].




## how it is better (or worse) than [#fi-034] entities?

• no subclassing or mixin modules or load-time DSL's -

  the ACS has a much simpler *minimum* API than its predecessor.
  participating classes need only implement particular methods with
  names matching patterns to express their associations and operations.

  most of the methods you will write to be picked-up by the [ac] will
  be of the "generated" variety (explained [#]:gen below); so there is
  a far lower-than average likelihood of of one of these methods having
  a name conflict with another method in the same class but outside of
  this concern.

  (nonetheless your participating classes should probably be "dedicated".)

  there are no mandatory *instance* methods that you must define.

  there are some *optional* methods you *can* define to hook-in to the
  library to achieve "special" behavior; but those methods are in a
  short enough list that we can cover all of them here.

    • [ the ~ 4 "axiomatic operations" that can be hooked-in to at [#022] ]
    • `result_for_component_mutation_session_when_changed`
    • `result_for_component_mutation_session_when_no_change`

  (see tombstones at end of this file for historical names too.)


• dynamicism is heavily assumed -

  with our [#001] predecessor we had to jump thru some hoops
  to allow the individual entity to have "dynamic formal properties".
  here, neither by default nor at all do we ever think that to reflect
  on the entity's formal associations should we look to its class.

  here, the "component association" is built anew on the fly as it is
  needed, by sending a message to *the entity* and not its class.

  we used to provide a caching mechanism for component associations,
  but it turns out that in practice we always seem to want our assocs
  to be dynamic anyway (but there's a tombstone for this if interested.)




• an ACS does not express its tree thru use of the platform module system,
  (nor the filesystem tree that usually isomorphs with this). the ACS
  instead expresses its tree thru explicitly stated component associations.
  this means that each association is effectively loaded lazily, freeing
  us from [#br-065] stubbing hacks. also it means that module (and
  filesystem) structure can stay flat as the application tree evolves.



• one minor point is that the Tenet7 "modifiers" part of
  "transitive operation" syntax are in a hard-coded set of about 4 keywords.
  there is as yet no plan to make this soft-coded. however this doesn't
  really have an equivalent in [br] so it's not relelvant anyway.




## the 8 introductory tenets of the autonomous component system ("ACS")

(2, 3, 7 & 8 relate only to the "classic" transitive operations.
1, 4, 5 & 6 are still essential.)

the tenets are:

• the library itself will *never* use `new` to construct a component. :Tenet1

• humans might construct new components thru `edit_entity` class method :Tenet2

• humans might mutate existing components thru its `edit_entity` method :Tenet3

• component associations are defined through instance methods :Tenet4

• the simplest component models are defiend by proc-likes :Tenet5

• more complex component models (2 kinds) are defined with classes :Tenet6

• modifiers (experimental): `via`, `using`, `if` and `assuming` :Tenet7

• the operation verbs of mutation sessions are defined in the assoc.. :Tenet8


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
participating classes for this reason, to enforce this design custom.




### 2) humans build new components by sending `edit_entity` to the class

(EDIT: nowadays, intent-specific adaptations often auto-vivify
components as needed, so this technique described in this sections is
not broadly applicable.)

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
thru a name, usually a reference to a "model" of some sort, and maybe
some "meta-components" about the association.

by "model" we may mean only in a loose sense, like for example the
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
produce each model for each of their component associations thru a call to
`__foo_bar__component_association` with the association name substituted in
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




#### the "generated form" method naming convention :gen

the method name of `__foo_bar__component_association` has a *pair* of
*double* underscores nesting the *variable part*  of the method name.
(yes, a pair of a pair, or "meta-pair".) while this convention may
appear ugly at first, it exists with good reason and is central to the
ACS:

all methods for which part of the name will be generated must use
this "generated form". using this distinct name convention for
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

(we are in the midst of developing an experimental new form for the
above that is only for "compound models" tracked with [#003]#compounds)

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
the subject call):

to the extent that user-defined classes produce objects, and all
such objects are trueish; we can overload these two concerns (whether
the interpretation succeeded and if so, what the payload value is) into
this one value; for those models that have dedicated classes.

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

the implementation of modifiers is currently exploratory. #open #[#008]
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

a `via` modifier is an assertion of shape with an expression of intent.
(but we don't mean "intent" in the [#003] sense, just the non-technical
sense.)

the `via` modifier allows us to implement a variety of ways that the input
can be created from a variety of shapes of input, and then specify
at construction time which way is supposed to be used. it is an explicit
way to declare what the shape is of the argument you are passing, lest
we be tempted to fall back on a loosey-goosey process of type inferrence,
that might lead to unintended success or encourage wishy-washy or
implicit intefaces.

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

THE ABOVE CHANGES NOW

for each `using` expression in the edit expression, one corresponding
argument will be included in the above call in addition to the above
described arguments. these additional arguments are added in front,
in the order they occur in the edit expression.

this explanation makes no sense without an example, which can
be found in the dedicated spec file for this node.

but here's this too:

    edit_entity :set, :severity, :SEVERE

    # probably calls `subject.__set__component qk, & oes_p`
    # where `qk` is a qualified knownness wrapping the value and the
    # association (of :SEVERE and "severity").

    edit_entity(
      :using, :one,
      :using, :two,
      :set, :severity, :SEVERE
    )  # calls `subject.__set__component :one, :two, qk, & oes_p`




#### C) the (experimental) `if` expression

(EDIT: this is very detailed and should be moved to its own document,
accompanied by the next section about `assuming`.)

an `if` expression acts as a filter, determining whether or not the
we actually "deliver" the sub-component to the operation method.

this same behavior could of course be accomplished "by hand" by
implementing another operation method that performs the conditional
check (whatever it is) in code.

however we have nonetheless bundled this "logic macro" into the
syntax experimentally because of the readability and expressive
conciseness it provides when implementing common operations on
collections (near dup-checking and the like).

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
word - you cannot have the symbolic name for your test be `not`, but
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

there can only be one `if` expression per imperative phrase.
this is a design choice, because it would be ambiguous what the
boolean semantics are for multiple `if` statements (AND or OR?).

however note that there *can* be multiple `if` expressions in an edit
expression (max one per imperative phrase).




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

(this section has been moved to a dedicated document: [#009])
