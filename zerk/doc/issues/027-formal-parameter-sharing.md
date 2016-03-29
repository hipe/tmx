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
interpreted or infered by a wholly separate facility; one that does not
provide re-use.

(writing this leads us to consider that maybe a formal operation "wants
to be" a compound node.. pehaps that is the unseen forcing pulling at us
with all of this here..)




## a middle-ground for today:

whereas [ac] has its own facilty for interpreting/inferring formal
parameters, the [ze] will do so in this way:

  1) every formal operation defines a :#scope-set.

     regardless of which "bundled modality" we are in, any formal
     operation defines a [#031] "selection stack". from this stack
     we can derive the set of all "atom-esque" component associations
     and formal operations in those frames. we will refer to this set
     of nodes as the "scope set" below.

     (this concept is perhaps explored further in [#015].)

     (for ease of implementation we may simply derive the scope set as
     all node names in the selection stack.)

     B) a formal operation cannot "subtract" nodes from its scope-set.

        because its implementation would perhaps be impossible given the
        way [#012] API parsing works, it is not possible for a formal
        operation to "blacklist" certain parameters from its scope-set.

        although this *would* be possible given the way we think niCLI
        will work, we don't want to introduce an asymmetry between these
        two modalities. (and as for iCLI, who knows how that will work
        when we get there #miletone-9, but likewise etc.)



  2) every formal operation defines a :#stated-set

     the stated-set for a given formal operation is:

     A) (for proc-implemented formal operations) the set of formal
        parameters as expressed directly by the platform parameters
        of the implementing proc or method of the formal operation.

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

*while* we are resolving nodes (operations or atom-esques) that are
requisites for this one invocation (and keep in mind we resolve these
recursively), we will make sure we don't cycle while resolving them. so
the index structure for one stack frame exists one-to-one with such a
step.

while producing each frame-of-index for the above, we will maintain one
box: the one box will add one item for every indexable node expressed by
the frame. this way we have a shorcut index to where each node is
defined.

(sidebar: an intentional side-effect of the above is that the name of an
atom-esque node must be unique in the context every selection stack
it could be in. i.e.: from any stack frame (compound node), take the
1-N frames that include it and each of its parent frames up to the root
frame. every atom-esque node in this set of frames must have a name that
is distinct from every other atom-esque node in the set of atom-esque
nodes in this stack of frames.)

with such an index we can look up parameter value knownness from the
scope set. also we can known the scope set at all, which lets us
calculate (3) and (4).





## :"Crazytimes"

this is a first stab at at algorithm for how we can assemble the kinds
of expressions we want to express when there are "deep unavailabilities":

1) each time we "enter into" the act of trying to "solve" a formal
   operation (either that of the top of the selection stack or any one of
   its dependencies, recursively); we push a special kind of new frame on
   to what we will call the :"trouble stack".

   • assumptions: all dependency graphs from all well-formed ACS's don't
     cycle. all branch nodes of such graphs correspond to operations
     (and vice-versa). all leaf nodes of such graphs correspond to
     atom-esque nodes (and let's just say vice-versa for now).

   • terminology: we'll call every branch node / formal operation that
     is *not* the "entrypoint formal operation" an "ancillary operation"
     (or just "ancillary" for short).




2) (this algorithm is a specialized variant of the [#ac-028]#Algorithm,
   which in turn is specialized variant of #[#fi-012] normal normalization.
   participants along this whole trail are all tagged as candidates for
   a possible future unification when all the dust settles (say, when
   #milestone-9). at writing this *seems* to be the most formally documented
   of the algorithms..)

   the resolution of any formal operation as far as we're concerned is
   in the act of resolving its 0-N defined parameters, and then (if this
   works) the act of executing the operation.

   each formal parameter is either a formal operation (a.k.a branch node,
   a.k.a "operation-dependency") or an atom-esque (a leaf node0.
   as a distinct classification, each formal parameter is either required
   or optional.

   what we'll refer to as "solving" is the general act of resolving a value
   for the parameter. in the case of formal operations, "solving" such a node
   means solving (recursively) each of its 0-N defined parameters, and then
   executing the operation without failing.

   for atom-esques, what we'll refer to as "solving" is the case of the
   parameter having a known value that is non-nil.

   for what we'll call "operation-dependencies", how we evaluate them
   is the subject of the next numbered section after this one; however
   what we do with their classification is referenced here:

   in pseudocode,
       autovivify a "reason list" as needed.
       this operation will have failed to solve IFF
       the reason list was created (i.e is nonzero in length).

       for each node in the "stated set" (actually a list),

         classify this node accoding to the logic in the next
         numbered section (extrapolate treatment of atomic nodes
         from what is described for operation-dependencies) and:

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
        end





### evaluating operation-dependencies :#C3

   (this is very similar to [#ta-009] general task-graph resolution, and is
   a candidate for a future unification of that trail. but currently there
   is so much specialization that that prospect is daunting.)

   what to do in the case of failure *of* an ancillary operation was an
   area of mystery for a while. now we have this theoretical answer:

   all relevant in-conditions to this problem are in terms of categories
   describing the classification and evaluation of the (operation-)
   dependency:

     • the dependency itself is either required or optional (exactly one).

     • the dependency either does or doesn't have its own requirements met.

     • the dependency that can execute either succeeds or fails execution.

   all possible relevant out-conditions to this problem are:

     • you can WIN (you may procede),
     • you can SKIP (you may also procede) or
     • you FAIL

   here is how we arrive at all possible out-conditions from all
   possible in-conditions:

     • you FAIL IFF ANY OF:

       • the dependency is required and it had missing dependencies

       • the dependency (required or optional) met its
         dependencies but failed on execution.

     • you SKIP IFF:

       • the dependency is optional and does not meet its dependencies.

     • you WIN IFF:

       • the dependency (required or optional) met its dependencies
         and succeeded on execution.

    as a "guarantee" that all relevant cases are covered correctly, we
    re-arrange the above as a permutations table (like a rule table):

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




## (disjoint comments)

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



### :#"c2"

the callers are defined below this method for reasons.

since it is a relatively :#"heavy lift" to build this [#]#scope-set
(yet we can't cache it because [#ac-002]#DT3 everything is dynamic),
we try to do this only when it is certain that we need to know it
(e.g any of its derivatives, i.e #socialist-set or #bespoke-set)

this :#"means" hash is a means to resolve every node in the scope set:
either through sharing or as a bespoke parameter. this is the backbone
of the evaluator (proc) that we will build below.

we create a :#"diminishing pool" that starts off as the set of all
names in the #stated-set.

for just a second, ignore how we get this stream - :#"as a stream" we
stream over every node name in the scope set, subtracting it from the
pool IFF it's in the pool (and it "usually" isn't - "usually" there are
more nodes in the scope set than there are in the stated set).

this stream, on the ground floor session the stream is produced at
this time. while we are producing each next node name we are also
indexing which frame each node name is found in. (doing this has the
side effect of ensuring name uniqueness in this scope stack.)
(more on what we do when we do this in #c3 below.)

if there are any subsequent recursive sessions, **WE REUSE** this same
work of indexing: as a useful (and unintended) property of scope
stacks, because a selected formal operation can only ever depend on
other operations that are in its scope stack, (and so on recursively),
all formal operations that could ever be in the dependency graph
(recursively) of the ground-floor formal operation will be in its
scope stack.

we :#"could optimize" this for recursive sessions - in those cases we
already have a plain old box for all the nodes in the scope stack,
and we could just use the set operators ( `Array#&` or whatever )
rather that iterating over items in a stream; but really: meh.




## :#"c3", :#c3

stream along the one or more compound frames that stand below the
top item (the formal operation), (in some direction?), and in
each such frame, stream along every node of that frame. for this
stream of all nodes selected in this manner, memo which frame you
found this node in.

the reasons :#"this box" is a box and not a hash are two

  • it verifies the uniqueness of all names in the scope stack

  • later, if we re-use it in a recursive session we will want
    its ordered-ness (yes hashes have ordered keys but meh)




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
