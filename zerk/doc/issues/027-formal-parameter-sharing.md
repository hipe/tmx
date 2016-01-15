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

our "socialism" is related to *actual* socialism only in that both
concepts employ *sharing* more than their sibling models. we adopt the
term used to describe social and economic systems only because it is
mnemonic with characteristics of the model we are describing; it is not
meant as an overt value judgement of one economic model over another.

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

  1) socialism is assumed. by default, the set of formal parameters
     of any given formal operation will *include* the set of all
     "atom-esque" component associations in its host stack frame
     (i.e compound node) and the zero or more stack frames below it.
     (this concept is perhaps explained in detail at [#015].)

     by default these assocations are adopted as *optional* parameters,
     which is in contrast to tendency (in both [ac] and elswhere here)
     to assume required-ness.

  2) to "bespeak" here means to "customize" or "indicate something extra."
     a formal operation can "bespeak" formal parameters both of and
     outside of the above set. (keep in mind that per the [ac], the
     default "parameter arity" is "required"; "optional" happens only
     by specifying it.)

     A) to bespeak a node from (1) and to do nothing (i.e leave
        it as optional) does nothing.

     B) to bespeak a node from (1) and make it required does this.
        (we may add a meta-component in [ac] for this.)

     C) to bespeak a node *not* in (1) adds it to the set of formal
        parameters for this operation. *NOTE* per [ac]: if not
        specified, a parameter arity of "required" is assumed.

  3) a "keyword" will be introduced & implemented
     (perhaps `do_not_inherit_formal_parameters_by_default`)
     that counteracts parts of (1): if anything in (2) refers to
     anyting in (1), the formal definition from (1) is still re-used.
     otherwise, formal parameters from (1) do not apply to the formal
     operation.

some example ramifications of the above points:

   • in an ideally zerk-like app, the only reason to use (2) would be
     to make certain optionals from (1) become required.

   • if you want to exclude only ceratain formal parameters from
     the list in (1), the only way to do this is to indicate explicitly
     the names of the formal parameters you *do* want. there is not any
     easy "blacklisting" facility for now.

   • conceptually the intention is that you cannot "clobber" items
     from (1) with "different" items in (2), rather you can only "map"
     items from (1) through modifications expressed in (2).

     however: (a) this is hopefully a mostly meaningless sentiment because
     hopefully *everything* about a component association is
     [#ac-002]#DT3 dynamic.

     (b) to change the argument arity would be nasty, and should be
     dis-allowed.
