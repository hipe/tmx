# thoughts on the abstract component system ("ACS") experiment :[#023]

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

  • components are mutated through "edit sessions" (same as
    "muation session").




## the 9 tenets of the autonomous component system ("ACS") (experimental)

we may tag some (or all!?) of the various occurrences of the below tenets in
the code because of how hot-of-the-grill experimental it all is and
consequently how subject to change it is.

(and yes, it may be folly to number these, because the composition may
be a bit arbitrary. as it is etc.)

  1) in an ACS, participating components are *never* created directly with
     the `new` constructor. the following tenets after this one comprise a
     (perhaps exhaustive, comprehensive) list of how in the ACS components
     are constructed and mutated by the human and machine variously both.

  2) the human may construct a component by sending an `edit_entity`
     call to the component class IFF (perhaps tautologically) the particular
     component class has "decided" to expose (i.e implement) this method.

     that is, the component designer decides "autonomously" whether or not
     to expose this method in an opt-in manner; it is not exposed by the
     library unilaterally. this component class must follow (9) described
     below.

     this library's `create` singleton method can help implement such
     an exposure typically in one line.

  3) the human may mutate ("edit") an *existing* component by sending
     an `edit_entity` call to the component instance IFF (likewise with
     above) the particular component has exposed this method (but this time
     as an instance not class method).

     this library's `edit` singleton method can help implement such
     an exposure typically in one line.

  4) the machine will construct the simplest of sub-components by sending
     to the "association" from (7) `[]` with the argument stream.

     such components are the sort that may be conceived of as "properties"
     in other contexts: they are typically best represented simply as
     native primitive "types" like integers, strings etc. that do not
     warrant a dedicated class.

     so that this technique supports components that are validly false-ish
     (that is, that the component can validly have a value of `false` and/
     or `nil`), the result of this call must be an object that responds to
     `value_x` which must produce the component.

  5) the machine will effect constructions of typical complexity by
     sending to the "assocation" from (7) `interpret_for_mutation_session`
     which must accept an argument stream.

     for a component that is mainly a compound component (that is, it
     consists mainly of other components), this library's `interpret`
     singleton method can help implement such an exposure typically in one
     line.

     IFF the interpretation is a success it must produce the sub-component
     itself, which to use this form cannot ever be validly false-ish (unlike
     in (4)), which is not usually not a problem because typically the
     formal component using this form already has a dedicated class (which
     is what received the subject call), and all classes produce objects,
     and all objects are trueish; hence we can overload these two concerns
     (whether the interpretation succeeded and if so, what the payload value
     is) into this one value; for those components that have dedicated
     classes.

  6) the machine will effect constructions that employ the `via` modifier
     in their operation "predicate" by sending to the "assocation" from (7)
     a call to a method with a name like `new_via__foo__`, where "foo" is
     the value of the argument that was passed thru `via` (called "shape").

     the result semantics of this form must be exactly as in (5).

     `via` modifiers are an assertion of shape with an expression of
     intent: it allows us to implement a variety of ways that the input
     can be created from a variety of shapes of input, and then specify
     at construction time which way is supposed to be used; rather than
     a more loosey-goosey process of type inferrence, that might lead to
     unintended success or encourage poorly thought out design.

     note the method name above (`new_via__foo__`) has a pair of double-
     underscores around the "variable part":

     this particular method naming convention with the pair of double-
     underscores we call "generated form". we employ this convention for a
     method's name IFF that method will be called by its name having been
     generated. as such, the code locations from which such a method is
     called will not be findable simply by searching for occurrences of its
     full name. this convention is a reminder of that. (instead, perhaps
     try searching for occurrences of the non-variable part of the name.)

     all such methods whose names when called are "constructed in parts"
     in some manner must employ this convention.

     B) constructors like these may be exposed to the human thru the
     appropriate counterpart human names (e.g `new_via_foo`). existence of
     the human-such form does not indicate the existence of the machine-such
     form and vice-versa: which forms to expose is a design choice for
     the particular component.

     to achieve the class-less-ness of (4) but still support this `via`
     modifier, you would have to implement the desired behavior yourself
     in such a proc-like.

  7) for any of (2), (3), and (5) to be implemented by this library, the
     participating subject component class must express each of its
     "associations" thru singleton methods with appropriate names, where
     each such name begins with the name of the association and ends with
     `assocation_for_mutation_session`, and the beginning part (the
     "variable part") is nested in a pair of double-underscores (i.e
     the "generated form" described in (6)).

     e.g the class must produce the association called "foo" with a method
     called `__foo__association_for_mutation_session`. the mixed value that
     is produced by this method call is known as "the assocation".

     (we don't yet get into the important facet of association "arities"
     ("belongs to", "has many" and so on) as ORMs do but this is a
     possibility for the future.)

  8) as for the typical subject components produced by (2) and (5) IFF it
     has successfully built *all* of the sub-components for this edit
     session, it will be constructed with a call to a singleton method like
     `new_via__foo_and_bar__`, for assocations "foo" and "bar".

     the composition **and order** of the terms is determined soley by
     their composition and and order in the `edit_entity` call. this is
     so to keep the implementation light and fast, a consequence of which
     is that more responsibility is on the caller to know about the
     "correct" order of the components.

     this is in the spirit of [#029] the rubric of "no synonyms": a design
     objective is that the expressions read naturally, however it is not
     our goal that all possible natural expressions be interpretable as edit
     session expressions.

     however of all the tenets describe here, this point of this
     tenet is probably most experimental and subject to change.
     fortunately if we change our API to support arbitrary ordering of
     the components, it will be backwards compatbile with what is
     declared here.

     failure should not typically be effected at this point, because the
     various sub-componets are to be assumed to be all valid, and this
     is a simple component system; where the parent structure should
     merely be the sum of its parts; but depsite this the subject
     component has the "autonomy" to fail at this point if it choses to.

     B) exactly as (6B).


## notes


### :#note-15

in contrast to the "edit" macro-operation below, the "create"
macro scans for each head-anchored contiguous `set` predicate,
resolves it, and then (IFF all are resolved successfully) passes
them as arguments to the appropriately named constructor of the
subject class. (this is the "autonomy" of our ACS: each sub-
component resolves itself independently without first going
thru the parent component. the parent component receives only
the finished child components.)




### :#note-70

in contrast to the "create" macro-operation above, the edit macro
mutates non-atomicly an existing entity, attempting to execute
completely each predicate one by one, stopping the macro
operation early IFF one sub-failure is encountered (although we
could chage this to be more atomic, with some work). but note
that as it is now, this macro may fail while still having mutated
the subject "partially".




### :#note-215

the current token parses as a modifier. every modifier implies
one or more operations. if it implies one it's a special case:
we can expect the remainder of the parse (in this call) to be
handled by that one operation, for which a dedicated operation
instance can parse the input "autonomously", allowing it to
parse classes of non-terminals other than the two prescribed
here (i.e "flag" and "one argument"). (this is not implemented
yet..)

otherwise, we 1) parse this modifer, memoizing its presence
and possibly its value as appropriate for the modifier, and 2)
we reduce the pool of available operations down to only those
implied by this modifier while 3) rebuilding the modifier box
appropriately so that it reflects only the modifiers still
available based on the operations still in the pool. whew!

then we can try to detect any next modifier and so on until
we stop seeing modifiers.




### :#note-340


this is no ordinary, static parse structure: as you receive each
one as an item in your input stream you *must* send to it either
`resolve_components` or `execute_fully`, othewise the subsequent
parse will be broken. this is so because the components are free
to implement their own own parsing autonomously, so we're unable
to parse each subsequent operation until the current one is done
fully. if we tried to make this happen transparently it would be
too transparent: we want to know immediately when the components
fail to resolve in a given operation, and be able to distinguish
this from ordinary end of stream.
_
