# formal parameter sharing :[#027]

we have run into the issue where old tests we made and stashed
pre-mid-january use what we now call the "isolationist" model, and the
mid-january we semi-formalized what we now call the "socialist" model.
here we define these models and explore the differences, in hopes of
arriving at a specification for the API for defining them.




## our "socialism" introduced

the "socialist" (as we use the term here) model is the theoretical
underpinning of [ze] in how it expresses an [ac] for its three bundled
modalities.

(our "socialism" is related to *actual* socialism only in that both
concepts employ *sharing* more than their sibling models. we adopt the
term used to describe social and economic systems only because it is
mnemonic with characteristics of the model we are describing; it is not
meant as an overt value judgement of one economic model over another.)

if actual socialism is concerned with the tension between the
bourgeois and the proletariat; our socialism is concerned with the
tension between [#ac-002]#DT1 *autonomy* (indeed the first design tenet
of the "autonomous component system"), and the intuitiveness of
desigining interfaces that share formal parameters across formal
operations.

(none of this should make sense at this point..)




## our "isolationism" introduced

the "isolationist" model didn't really exist as a model per se until we
realized that in some cases we wanted "socialism" and we didn't have it.
but despite that point (which has yet to be explained), the isolationist
model is itself a bit of a paradox when you think about why the [ac]
exists and what it encourages:

at its surface the [ac] encourages "autonomy", but just as important is
its gravity towards [#ac-002]#DT2 re-use. the first ever facility of
[ac] was a way to specify a component association that indicates a
"model" that makes re-use almost an afterthought: if nothing else, a
declaration of a "component association" is a function that results in
a model. for all but the simplest cases these models are provided as
references to classes/procs that exist "somewhere else". re-using the
same model is as easy as referencing the same const name in two places.

but [ac]'s native relationship with the formal parameters of operations
is a perhaps counter-intuitive break from the above theme: it its native
treatment of formal parameters, there is no built-in DRY-ness; there
is no built-in re-use: the formal parameters of an operation are
interpreted or infered by a wholly separate facility; one that does not
provide re-use.

(writing this leads us to consider that maybe a formal operation "wants
to be" a compound node.. pehaps that is the unseen forcing pulling at us
with all of this here..)




## a middle-ground for today:

whereas [ac] has its own facilty for interpreting/inferring formal
parameters, the [ze] will do so in this way:

  1) every formal operation defines a "scope set".

     regardless of which "bundled modality" we are in, any formal
     operation defines a [#031] "selection stack". from this stack
     we can derive the set of all "atom-esque" component associations
     and formal operations in those frames. we will refer to this set
     of nodes as the "scope set" below.

     (this concept is perhaps explored further in [#015].)

     B) a formal operation cannot "subtract" nodes from its scope-set.

        because its implementation would perhaps be impossible given the
        way [#012] API parsing works, it is not possible for a formal
        operation to "blacklist" certain parameters from its scope-set.

        although this *would* be possible given the way we think niCLI
        will work, we don't want to introduce an asymmetry between these
        two modalities. (and as for iCLI, who knows how that will work
        when we get there #miletone-9, but likewise etc.)



  2) every formal operation defines a :"stated set"

     the stated-set for a given formal operation is:

     A) (for proc-implemented formal operations) the set of formal
        parameters as expressed directly by the platform parameters
        of the implementing proc or method of the formal operation.

     B) (for non-proc implemented formal operations) the set
        of formals defined by the set of names in its `PARAMETERS`
        reflector (for now).

     for our purposes here these are just sets of names.



  3) the "socialist set" is:

         (2) ∩ (1)

     that is, it is every name from (2) that is also in (1).



  4) the :"bespoke set" is:

         (2) ∖ (1)

     that is, it is any names from (2) not in (1).
     we have flip-flopped on this at least twice. it may be a
     misfeature: this is a parameter without a model, so you will have
     to do your own validation.



  5) mapping parameter arity

     by default, every formal parameter defined by the scope-set is
     in effect optional for any given formal operation EXCEPT THAT:

     A) (EXPERIMENTAL)
        for proc-implemented formal operations: by default, all names in the
        stated-set are interpreted as being required.

        you can turn such a parameter into an optional parameter by
        using the DSL in the definition. for example:

            def __frobulate__component_operation

              yield :parameter, :foo, :optional

              -> foo, bar, baz do
                # ..
              end
            end

        in the above proc-based formal operation defintion, the
        parameters `foo`, `bar` and `baz` would normally have a parameter
        arity of "required" but `foo` has been made optional explicitly.

        (as a reminder, you must *not* supply default values (in the platform
        way) to the formal parameters of your proc or method.)


     B) for non-proc-implemented formal operations: by default, names
        in the `PARAMETERS` reflector are interpreted as being required
        unless they explicitly have the `optional` tag.




## for "procure bound call"

when we have a formal operation we can derive all of this:

  • we can always solve its scope-set (1).
  • we can always solve its stated-set (2).
  • since we have both (1) and (2) we can solve the socialist set (3).
  • since we have both (1) and (2) we can solve the bespoke set (4).

when both:

  • there is a non-empty argument value source
  • there is a non-empty bespoke set

then we need to parse any values "passively" out of the one using the other.

so, we will start by creating a *single* "index stack": this stack is a
snapshot of the whole ACS at this moment. keep in mind that from
invocation to invocation the entire structure of the ACS can change, so
there is little use in trying to preserve *anything* in between
invocations.. (but just in case, we'll tag this sentiment with #[#ac-023].)

*while* we are resolving nodes (operations or atom-esques) that are
requisites for this one invocation (and keep in mind we resolve these
recursively), we will make sure we don't cycle while resolving them. so
the index structure for one stack frame exists one-to-one with such a
step.

while producing each frame-of-index for the above, we will maintain one
box: the one box will add one item for every indexable node expressed by
the frame. this way we have a shorcut index to where each node is
defined.

with such an index we can look up parameter value knownness from the
scope set. also we can known the scope set at all, which lets us
calculate (3) and (4).
