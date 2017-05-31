# parameters normalization :[#028]


## overview

yet another #[#fi-012.7] normal normalization. needed to be developed
on its own; is candidate for unification.

  • check for missing requireds
  • defaulting
  • "soft" or "hard" failure in a modality adaptive way

we prepare "actual" arguments

  • into a variety of target-specific shapes
  • from a variety of input sources


possible target shapes might be:

  1) produce an "actual parameters" list (array) for a plain-old
     "platform" proc or method.

  2) write values "into" a session-like object using (what look
     like) `attr_writer`s.

possible input sources might be:

  1) an argument stream, off of which we will parse "passively"
     (stopping error-lessly at any first unrecognized token)

  2) a "parameters value reader" that allows random-access to
     "epistemic" meta-data about whether which values are known
     and if so what the value is.




## :"limited scope"

the ACS has some fortuitous emergent characteristics that make *this*
implementation of normalization simpler than previous efforts in this
family thread:

  • under [ac], if an ACS ("frame") *has* a component, then than
    component is already valid. there is no need to "normalize" the
    component itself further. (what is now deemed as a misfeature of
    [br] was that it used the same store (the "entity") to hold unsanitized
    modality values as it did to store these as the valid, ad-hoc
    structures they became.)
    :[#here.2.1]

  • our responsibility is only to traverse over the "expanse set"
    of formal *parameters* (not nodes, i.e not component associations
    or formal operations); and validate their presence for those
    parameters that are required. note that thus far we need never produce
    new components during this work, we need only check the values of
    existing components.
    :[#here.2.2]

  • because it's in scope, "definition-based" defaults get effected here
    too. (non-proc-based implementations may have their own form of
    effectively defaulting component values.) HOWEVER, a corollary of
    the above bullet and this one is that default values do NOT get
    put through component models to derive a value - the default values
    are accepted as-is.
    :[#here.2.3]




## approach

this first major rewrite occurred because the subject node was not written
in a way that was truly modality agnostic: although it was compartmentalized
into different files, its implementation was not "injective". in this
implementation, arbitrary new "parameter value sources" that have not yet
been invented will hopefully still work down the road with this same old
essential normalization axioms about defaulting and missing requireds.





## :#"Head parse"

as long as the parameter value source is not empty and it "matches"
one of the formal parameters from the dedicated collection, remove that
value from the PVS and store it in the parameter store. this is
continued until either the PVS is known to be empty or the PVS in
its current state does not match any of the formals in the collection.

for this modality (EDIT):

having only one formal argument is a special case: in this
arrangement we NEVER recognize named arguments, i.e the term
in the argument stream MUST be not named (i.e "positional").

NOTE we do *not* run these values through component association models -
the are raw and unsanitized, passed as-is to the implementation. this is
to make it easy for operations to add ad-hoc parameters to their
signature, but there is typo danger here - if the user mistypes a
parameter name in her formal operation signature, she may think she's
working with a sanitized component value when actually she working with
an unsanitized, "raw" value directly from the modality.





## :#API-point-A

the subject session promises that it will request this sort of stream IFF
the parameter value source is not known to be empty.




## normal normalization :#Algorithm

(as stated in the intro, this is a specialized form of the referenced
normal normalization, and is tagged as a candidate participant of a
future unification.)

in the defined ("formal") order, for each formal parameter:

  • we treat as equivalent the value being unknown and the value
    being known to be `nil`. this step was not designed per se but
    rather has emerged naturally from the work, and seems to work
    fine. both in these docs and in the code we unify these two
    cases into one that we refer to here as "effectively unknown".

  • if the value is effectively unknown and there is a default
    proc, produce a default value and use this as *the* value.
    (NOTE this default value is *not* run through a component model.)

  • if (at this point) the value is effectively unknown and it
    is required, memo this as a missing required field.

now, you have applied all defaulting that can be and needs to be
applied. as well it is known if there are missing requireds.




### :#API-point-B (that we must adhere to) maintains that:

the "expanse set" that was provided as an argument will be exercized in
its entirety - there will not (for example) be short-circuiting on the
first enountered error.

the "expanse set" is always held has a stream, and the #Algorithm
is always performed on each node in this stream in the order the
stream produces the items.
_
