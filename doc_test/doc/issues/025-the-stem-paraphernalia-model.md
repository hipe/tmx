# a stem paraphernalia model :[#025]

## overview

"paraphernalia" are the domain-specific "components" that we work with
to build tests using a test suite solution. "stem paraphernalia" are
generic reprentations of these in code meant to be test-suite-solution
agnostic and hopefully apply to most test suite solutions generally.
"stem paraphernalia" are critica part of the whole [#039] pipeline.



## defining and introducing "paraphernalia"

"paraphernalia" are the domain-specific "components" that we work with
to build tests using a test suite solution. they are phenomena like:

  - the "tests" themselves (but (as mentioned in [#018]) we avoid this
    term because it's too ambigous - it could mean a test file, it
    could mean an individual assertion.) they are a.k.a "test cases".
    we call them "examples" here. the popular platform solution (and
    probably most) realize tests as methods, with one method per test.

  - "contexts" - groups of examples and other contexts that can share
    setup components and plain old methods.

  - "assertions" (in their formal form may be called "predicates") -
    an individual assertion is what makes a test a test. it can cause
    failure, constituting the failure of a test. the popular platform
    solution uses `should` (as a method clal) to build and execute
    assertions. (frequently we just use `act == exp || fail` to save on
    overhead, but you won't see that here.)

  - "shared setup" is our general meta-category (i.e it may not have
    concreate representation in code) to be an umbrella to contain a
    variety of paraphernalia available in most test suite soultions,
    i.e the `let` memoizer builder, or our of-used `shared_subject`
    hack. `before :each` / `before :all` (again in the popular solution)
    ceratain belong in this category as well.


"setup" (methods). because we *always* implement these as models (or
if you prefer, plain old classes) we house these under "models" for now.

the reason we distinguish "stem" from "particular" is so that we can
re-use facilities across output adapters while allowing each particular
output adapter its own freedom to work with whatever paraphernalia is
appropriate for that solution (to the extent that etc).




## so what are "stem paraphernalia"?

"stem paraphernalia" are an attempt to generalize how we represent
paraphernalia in code *away* from particular test suite solutions,
so that we can begin to realize a plugin architecture and target different
test suite solutions and testing idioms pursuant to the user's choices.

(EDIT)




## spec-ish

  • the subject instance *MUST* implement one of the methods from the
    as is appropriate to produce its output; i.e. it is somewhat like an
    autonomous rendering component, but for now the caller must know
    which method is appropriate. experimental.
        • `to_line`
        • `to_line_stream`

  • the subject class *SHOULD* have ad-hoc custom constructor methods,
    tailored to the particular shape of its input data.

  • the subject class *OFTEN* takes a "choices" object in its constrution.

  • the subject *WILL TYPICALLY* provide a collection of "services"
    (methods) for an implementing "particular paraphernalia" to draw
    on in its implementation.


## notes

### :#note-1

we are hacking the parse of the assignment operator because to do it
correctly with regex is difficult..

  - #pending-rename
