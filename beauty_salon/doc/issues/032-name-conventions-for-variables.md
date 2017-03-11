# name conventions for variables  :[#032]


## foreword

some of these conventions are relatively new. large swaths of the code
exist that don't yet follow them to a tee; however the broader spirit of
these conventions has been around for years.




## intro

the names we design for our instance variables and local variables are
inflected by scope, shape, and other vectors described here.





## instance variables - scope

just like with [#029] consts and [#028] methods, there are tiers of
scope we adhere to when naming our instance variables:

    @public_instance_variable   # :[#here.1.0] - public API-ish

    @_public_instance_variable_when_above_convention_is_business_namespace_  # see [#here.1.1]

    @library_scope_  # see [#here.1.2]

    @_cozy_scope  # :[#here.1.3]: used only in this file

    @__ad_hoc_scope  # :[#here.1.4] - see

    @___singleton_scope  # :[#here.1.5] - see


the descriptions in the first mentioned source apply here.





### :[#here.1.0.5]

the convention `@_like_this_` (with one leading and one trailing underscore
in the ivar name) is used:

  - when the instance variable is part of a public API (i.e shared between
    two disparate code nodes) but [#here.1.0] cannot be used because for
    example it is reserved for business names.

  - similarly, when a depended-upon node (base class or mixin module) wants
    to "stay out of the way" of all other var namespaces.




### :[#here.1.2] - "library scope"

for this tier, first see the same tier over in [#028] the method name
conventions. when used for an ivar, this convention has a related but
very particular meaning: it means *either*:

  • that that this ivar is recognized and used by a dependency
    module (e.g a parent class), -OR-

  • that this ivar is expected to be used by a client module
    (e.g a child class), -OR-

  • that nodes "nearby" use this same ivar name with these same
    semantics, and as such this ivar is an abstraction candidate that
    may move into one of the above two categories.

more generally (and easier to remember), an ivar with this name is
expected to be accessed only within whatever sidesystem you're looking
at.



### :[#here.1.4] - "ad hoc scope"

an ivar with two leading underscores:

  • has the same restrictions as [#here.1.3]

additionally, in the normalest of cases this ivar will appear exactly
twice in the file: once where it is set to a value and once where it is
accessed.

more broadly we sometimes extend the semantics to indicate that although
the ivar occurs more than twice in the file, its "output point" is
restricted to one place (which is to say the cost of changing it is
generally lower than for a [#here.1.3] ivar).



### :[#here.1.5] - singleton scope

an ivar with *three* leading underscores:

  • has the same restrictions as [#here.1.3]

and furthermore the ivar is refered only ever once. in practice this is
only ever useful for ivars that memoize some trueish value in
conjunction with the `||=` operator.




### special names:

#### `@_`

the ivar `@_` is now being used for cases where there is a strong
parent-child or client-performer relationship between a "client" node
and an ancillary node. the subordinate node may chose to use this ivar
to hold the client node. this obfuscatey, magical name is used for
these reasons:

  • in such scenarios the ivar is often used so often that its brevity
    (and lack of all lexical content) actually improves readability by
    not adding noise to the code.




## local variables - scope (:#D)

we haved developed a bunch of weird idioms that help us read our code
with respect to how we name local variables:


    a_normal_local_variable  # must be referenced more than once

    _as_a_method_parameter

      # when we use a leading underscore for a formal parameter of a
      # method, it means *do not* use that variable at all in the
      # method.



    _as_a_local_variable = ..

      # see [#]explanation-of-this-convention below




    with_one_trailing_underscore_

      #  • usually we use this to signify that this variable is the
      #    second such thing, where there is a counterpart first such
      #    thing in the same scope (and has the corresponding name
      #    without the underscore.)
      #
      #  • you will occasionally see *two* trailing underscores to
      #    indicate a "third such thing", but this is not recommended.
      #    typically we break such scenarios up into smaller scopes.
      #
      #  • we also use this when it is necessary to avoid using a keyword for
      #    a name we want to use. eg. `end_ = r.end` for holding the
      #    "end" component of a range object (because `end` is a keyword).
      #
      #  • similar to the first bullet, we use this when it is necessary
      #    to avoid a name collision with a semantically similar
      #    variable in a surrounding scope. again, this can mean it is
      #    time to break things down into smaller method scopes..



      _we_will_combine_conventions_

      # a name like the above means that the value being held in the
      # variable is the "second such thing", and also that the variable
      # itself was not necessary, but is just there to break up a
      # trainwreck or help document.


      _SOMETIMES   # we use this crazy thing to .. etc




## :explanation-of-this-convention

when a single leading underscore is used in a local variable's name,
this means that the variable is not "necessary" in strict terms; however
in our universe you will find that we employ this convention quite
frequently (ergo we have a lot of local variables that are not strictly
necessary)..

1) in the less-frequently seen form, we use this convention to name a
variable that we do not use but sort-of have to assign. like:

    _sin, sout, serr, wait = ::Open3.popen3 'hack', 'my', 'box'

    # (we don't intend to use the 'stdin' handle ever)

this evolved from the useful platform feature of issuing a warning for
local variables that are assigned but not used. the platform will side-
step this warning if the variable name has one (or more) leading
underscore(s).

2) the more frequently-seen form is this: the variable is only ever
referenced from one place (and it should be "nearby"; most often in the
next expression after the current one (e.g the next line)).

although technically it "wastes processing", this convention is employed
to break up trainwreck of a long line of code, so that A) it is more
self-documenting and B) it is more amenable to step-debugging. it is our
contention that the "overhead" from this "waste" is typically a cost
well-spent in exchange for these benefits.

in [sn]  (referencing this subject doc node), the subject codepoint is
exemplary of this convention:

the significant outcome of the case expression to assign a single
variable, and nothing more. since the platform conveniently conceives of
these as expressions, it was redundant to name the variable three times.

also, in some branches of the case expression there are variables that
are assigned to and only ever referenced one in the same code block,
right below where the variables are assigned.

if we wanted to we could rewrite this whole "block" as a single (large)
in-line expreession in the place where the value is needed, but that
would be a beast to comprehend and debug.

..

also, when we see several of these in one scope, it can sometimes
be an indication of some code that is "hot off the press" and remains
in a very raw, debug-friendly state because it hasn't "settled" yet..

_
