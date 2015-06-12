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

    @public_instance_variable   # :#tier-0 - public API-ish

    @_cozy_scope  # :#tier-1: used only in this file

    @__singleton_scope  # :#tier-2: only ever used for true-ish memoized ivars?

    @___alternate_for_above  # is there a difference with above?

the descriptions in the first mentioned source apply here.





## local variables - scope

we haved developed a bunch of weird idioms that help us read our code
with respect to how we name instance variables:


    a_normal_local_variable  # must be referenced more than once

    _as_a_method_parameter

      # when we use a leading underscore for a formal parameter of a
      # method, it means *do not* use that variable at all in the
      # method.



    _as_a_local_variable = ..

      # we use this convention often to signify that the variable is
      # only only ever referenced from one place (and usually nearby).
      # technically, using these variables "wastes processing", but we
      # do so to break up a long trainwreck and/or to document something.

      # when we see several of these in one scope, it often indicates
      # some code that is "hot off the press" and remains in a very raw,
      # debug-friendly state because it hasn't "settled" yet..



    with_one_trailing_underscore_

      #  • usually we use this to signify that this variable is the
      #    second such thing, where there is a counterpart first such
      #    thing in the same scope (and has the corresponding name
      #    without the underscore.)
      #
      #  • you will occasionally see two trailing underscores to
      #    indicate a "third such thing", but this is not recommended.
      #    typically we break such scenarios up into smaller scopes.
      #
      #  • we use this when it is necessary to avoid using a keyword for
      #    a name we want to use. eg. `end_ = r.end` for holding the
      #    "end" component of a range object.
      #
      #  • similar to the first bullet, we use this when it is necessary
      #    to avoid a name collision with a semantically similar
      #    variable in a surrounding scope.



      _we_will_combine_conventions_

      # a name like the above means that the value being held in the
      # variable is the "second such thing", and also that the variable
      # itself was not necessary, but is just there to break up a
      # trainwreck or help document.


      _SOMETIMES   # we use this crazy thing to .. etc
_
