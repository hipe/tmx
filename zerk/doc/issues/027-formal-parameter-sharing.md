# formal parameter sharing :[#027]

([#013] is an introduction to the ideas explored in-depth here.)

we have run into the issue where old tests we made and stashed
pre-mid-january use what we now call the "isolationist" model, and the
mid-january we semi-formalized what we now call the "socialist" model.
here we define these two models, explore their differences, and finally
define the specification of our API that can effect them in concert.




## our "socialism" introduced

the "socialist" (as we use the term here) model is the theoretical
underpinning of [ze] in how it expresses an [ac] for its three bundled
modalities (API, non-interactive command-line interface (nCLI), and CLI).

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
interpreted or inferred by a wholly separate facility; one that does not
provide re-use.

(writing this leads us to consider that maybe a formal operation "wants
to be" a compound node.. pehaps that is the unseen force pulling at us
with all of this here.. :#here)




## a middle-ground for today:

([#015] is a subsidiary of the subject node, but its #"stated values"
intro is a succinct summary of the below.)

whereas [ac] has its own facilty for interpreting/inferring formal
parameters, the [ze] will do so in this way:

  1) every formal operation belongs to one scope-set (defined here):

     every formal operation is (virtually if not actually) associated
     with a particular kind of [#ac-031] selection stack:

     • there is always at least a root component node. such nodes are
       always compound, so there is always at least this such frame on
       the stack.

     • virtually (and so far actually) there is always a top
       frame that is a special kind of frame for the formal operation.
       the details of this frame are a concern of the particular modality.

     • as such, such selection stacks are always 2-N items tall.

     • this stack is used for "indexing", and because [#ac-002]:DT3
       ACS trees should be considered entirely dynamic, this selection
       stack should be taken to represent an ephemeral "snapshot" of the
       tree as it stands for the purpose of this invocation, and so
       should not be memoized or cached beyond this scope.

     as such, every such selection stack sits atop a virtual stack with
     1-N frames, each frame being compound (i.e wrapping a compound formal
     node). every such stack defines a scope-set:

     a :#scope-set is a derivative of any all-compound stack. it is the
     set of all formal nodes within it that are either formal operations
     or (of the component associations) such nodes that are either
     primitivesque or compound.

       • an application of this concept becomes important in [#015]
         niCLI option parsing.

       • as decided by the modality we may simply derive the scope set
         as being the set of all formal nodes in the selection stack.

     B) a formal operation cannot "subtract" nodes from its scope-set.

        because its implementation would perhaps be impossible given the
        way [#012] API parsing works, it is not possible for a formal
        operation to "blacklist" certain parameters from its scope-set.

        although this *would* be possible given the way we think niCLI
        will work, we don't want to introduce an asymmetry between these
        two modalities. (and as for iCLI, who knows how that will work
        when we get there #miletone-9, but likewise etc.)



  2) every formal operation defines a :#stated-set:

     the stated-set for a given formal operation is:

     A) (for proc-implemented formal operations) the set of formal
        parameters as expressed directly by the platform parameters
        of the implementing proc or method of the formal operation.

        for e.g, of this platform proc:

            -> foo, bar { foo + bar }

        the set of formal parameters inferred from it have the names
        `foo` and `bar`.


     B) (for non-proc implemented formal operations) the set
        of formals defined by the set of names in its `PARAMETERS`
        reflector (for now).

     for our purposes here these are just sets of names.



  3) the :#socialist-set is:

         (2) ∩ (1)

     that is, it is every name from (2) that is also in (1).



  4) the :#bespoke-set is:

         (2) ∖ (1)

     that is, it is any names from (2) not in (1).
     we have flip-flopped on this at least twice. it may be a
     misfeature: this is a parameter without a model, so you will have
     to do your own validation. (more on this below and elsewhere.)

     NOTE if your model expresses bespokes, it not presently (nor
     probably ever) elligible to be expressed under iCLI.

     :[#016]




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




## for :"procure bound call"

when we have a formal operation we can derive all of this:

  • we can always solve its scope-set (1).
  • we can always solve its stated-set (2).
  • since we have both (1) and (2) we can solve the socialist set (3).
  • since we have both (1) and (2) we can solve the bespoke set (4).

when both:

  • there is a non-empty argument value source and
  • there is a non-empty bespoke set

then we need to parse any values "passively" out of the one using the other.

so, we will start by creating a *single* "index stack": this stack is a
snapshot of the whole ACS at this moment. keep in mind that from
invocation to invocation the entire structure of the ACS can change, so
there is little use in trying to preserve *anything* in between
invocations.. (but just in case, we'll tag this sentiment with #[#ac-023].)

*while* we are resolving nodes (operations or primitivesques) that are
requisites for this one invocation (and keep in mind we resolve these
recursively), we will make sure we don't cycle while resolving them. so
the index structure for one stack frame exists one-to-one with such a
step.

while producing each frame-of-index for the above, we will maintain one
box: the one box will add one item for every indexable node expressed by
the frame. this way we have a shorcut index to where each node is
defined.

(sidebar: an intentional side-effect of the above is that the name of an
primitivesque node must be unique in the context every selection stack
it could be in. i.e.: from any stack frame (compound node), take the
1-N frames that include it and each of its parent frames up to the root
frame. every primitivesque node in this set of frames must have a name that
is distinct from every other primitivesque node in the set of primitivesque
nodes in this stack of frames.)

with such an index we can look up parameter value knownness from the
scope set. also we can known the scope set at all, which lets us
calculate (3) and (4).





## :"Crazytimes"

this is a first stab at at algorithm for how we can assemble the kinds
of expressions we want to express when there are "deep unavailabilities".

(we now try to honor our [#030] unified language in the below.)

1) each time we "enter into" the act of trying to "solve" a formal
   operation (either that of the top of the selection stack or any one of
   its dependencies, recursively); we push a special kind of new frame on
   to what we will call the :"trouble stack".

   • assumptions: all dependency graphs from all well-formed ACS's don't
     cycle. all branch nodes of such graphs correspond to operations
     (and vice-versa). all leaf nodes of such graphs correspond to
     primitivesque nodes (and let's just say vice-versa for now).

   • terminology: we'll call every branch node / formal operation that
     is *not* the "entrypoint formal operation" is an
     "operation-dependency".




2) (this algorithm is a specialized variant of the [#ac-028]#Algorithm,
   which in turn is specialized variant of #[#fi-012] normal normalization.
   participants along this whole trail are all tagged as candidates for
   a possible future unification when all the dust settles (say, when
   #milestone-9). at writing this *seems* to be the most formally documented
   of the algorithms..)

   the resolution of any formal operation as far as we're concerned is
   in the act of resolving its 0-N stated parameters, and then (if this
   works) the act of executing the operation.

   each stated parameter has at least the following three axes of
   categorization, the derivation of which may relate to each other but in
   the end amount to exactly three ~[#hu-003] "exponents" that describe this
   stated parameter, one for each of these three axes of categorization:

   A) is the "sharedness" of this formal parameter:

      as introduced above, the stated parameter is either in the
      #socialist-set or the #bespoke-set. when latter, we will say that
      the stated parameter is `bespoke`. when the former, this parameter
      is in effect a reference to some formal node in the scope stack with
      possibly some customization added. as such we call it an
      "appropriation" (or say it's "appropriated" or "appropriative" as
      linguistically (er..) appropriate.) the possibility of cusomtization
      is why we don't just say "shared" or "socialist", as we will explore
      further at (C) below.

      so the exponents of this category are `appropriated` or `bespoke`.


   B) is a categorization that we might call the "shape":

      this set of exponents can be arrived at as being the unique set of
      the non-distinct leaf node exponents of this taxonomic (and perhaps
      logical) tree:

      if the stated parameter is `appropriated` (per (A)),

        • use its "formal node category"; that is, it's either a
          "formal operation", a "compound" or a "primitivesque".

          * if compound, see #"why we do not appropriate compound nodes" below

      otherwise (and it's `bespoke`),
        • treat this formal parameter as "primitivesque".

      so the exponents of this category are "formal operation" and
      "primitivesque".


   C) is the "requiredness" of this formal parameter: it is either
      required or optional.

      the meaning, representation and handling of this meta-attribute is
      perhaps identical to those in the other implementation in this family
      strain of algorithms; namely that if an actual value is effectively
      unknown for a required formal parameter, the operation is
      effectively unavailable.

      the value here comes from the formal operation itself: even if this
      formal parameter is an "appropriated" formal node, its "requiredness"
      is a characteristic that only has meaning in the scope of this
      particular formal operation. i.e the "requiredness" of the same
      appropriated formal node can vary from formal operation to formal
      operation.

   let "solving" mean the act of resolving a value for a parameter.
   for each stated parameter,

     assume we know its "sharedness", "shape", and "requiredness".

     if the shape is "primitivesque",
       an actual value is "solved" for this stated parameter if
       it has a known value that is non-nil.
       (for now we glossing over appropriated vs. bespoke..)

     otherwise (and the shape is "formal operation"),

       solving such a stated parameter means solving (recursively) each
       of *its* 0-N stated parameters, and then executing the operation
       without failing.

   the second branch of the above IF-ELSE pseudocode is what we'll call
   an "operation-dependency", that is it's when an operation depends on
   another operation. how we evaluate these is the subject of (3),
   however what we do with their classification is referenced here:

   in pseudocode,

       we will autovivify a "reason list" as needed:
       this operation will have failed to solve IFF
       the reason list was created (i.e is nonzero in length).

       for each node in the "stated set" (actually a list),

         classify this node accoding to the pseudocode in (3)
         (extrapolate treatment of primitivesque nodes from what is
         described for operation-dependencies) and:

           when failed
             add an appropriate reason to the reason list
           when skip
             do nothing
           since solved
             add { this evaluation or its value } to "the store"

        now that we have gone through every node,
        if the reason list was created
          we have failed. the reason list is our significant result.
        otherwise
          we have succeeded. "the store" is our significant result.
        _





### evaluating :#Operation-dependencies (:"o.d")

   (this is very similar to [#ta-009] general task-graph resolution, and is
   a candidate for a future unification of that trail. but currently there
   is so much specialization that that prospect is daunting.)

   what to do in the case of failure *of* an operation-dependency was an
   area of mystery for a while. now we have this theoretical answer:

   all relevant in-conditions to this problem are in terms of categories
   describing the classification and evaluation of the operation-depdency:

     • the dependency itself is either required or optional (exactly one).

     • the dependency either does or doesn't have its own requirements met.

     • the dependency that can execute either succeeds or fails execution.

   all possible relevant out-conditions to this problem (for a given o.d) are:

     • you can WIN (you may procede),
     • you can SKIP (you may also procede) or
     • you FAIL

   here is how we arrive at all possible out-conditions from all
   possible in-conditions:

     • you FAIL IFF ANY OF:

       • the dependency is required and it had missing
         required dependencies of its own.

       • the dependency (required or optional) met its
         dependencies but failed on execution.

     • you SKIP IFF:

       • the dependency is optional and does not meet its dependencies.

     • you WIN IFF:

       • the dependency (required or optional) met its dependencies
         and succeeded on execution.

    to re-arrange the above as a permutations table (like a rule table):

        if..          | and..                   | then:
        deps not met  |      was required       |  FAIL
        deps not met  |  was not required       |  SKIP
            deps met  |     its execution fails |  FAIL
            deps met  |  its execution succeeds |  WIN

   the main things to note here are:

     • an optional dependency *can* cause the whole thing to fail IFF its
       own execution fails (provided that it gets to the point of executing).

     • there are two distinct kinds of failure. we may make a dedicated
       event class for one or both of them, one that is expressive.





4) the final result of the entrypoint formal operation (WHEN REASON)
   is hopefully some kind of tree..




## :"why we do not appropriate compound nodes"

to try and appropriate as formal parameter a formal node that is "compound",
this is now and probably always will be undefined: this is the "wrong" way
for an operation to reach a compound node (by this selfsame decree):

the set of all compound nodes available to an operation is exactly its
selection stack, and so in the interest of a streamlined API, access to
an entire compound node should be in this manner. in practice, it is not
something that we have wanted, probably because it doesn't "make sense"
for an operation to need a compound node, probably because compound
nodes are typically container objects that are just semantic groupings of
operations and primitivesques that "seem related" as opposed to being a
descrete, definite "thing" in themselves.

(but note if we indludged this thought #here it would change all this.)




## "continuations" (code-specific, disjoint with each other.)

### :#"c1"

here in the recursive session we decide to emit into the selfsame
emission handler that "belongs to" the originating session. in the past
in similar sitations we have tried to do clever tricks by building
handlers that "contextualize" the emitted events at each step to that
the session can emit in the same manner, unaware of whether or not it is
a recursive session. but our experience is that such a setup is
confusing and is more trouble than it is worth..

..so here we allow that the handler is already set and recognize what it
is.





## :"c5"

shared parameters such as these have actual values that exist
either directly in the zerk tree already as ivars, or they exist
latently as the results of would-be operation calls.

whether the formal is proc-implemented or non-proc-implemented,
we need to transfer these values to the actual (intermediate)
store that will ultimately be used to execute the operation.

assuming [#ac-028]:#API-point-B, we are being called once for each
parameter of the "stated set" ("expanse" there) in order to apply
defaults and find missing required parameters.

so we piggy-back onto this second fulfillment fulfillment of this
first need too EEK
_
