# principal algorithms :[#004]

## :principal-algorithm-1

in summary: whenever there is a "state change" in the data stored under
this particular adapter node, we try to build and "send" a new image.

in detail (and sometimes pseudocode):

whenever the adapter ACS receives an event that a component changed, we
let this serve as notification that the state of the "appearance" data
under this adapter has changed.

first we send the signal upwards expecting that our custodian listener
will trigger persistence. breaking the classic "selective listener"
event model, we react based on the result from sending this "signal":

if for some reason the persisting failed, we will "cancel out" of this
procedure, resulting in the received failure result.

otherwise (and the persisting presumably succeeded), we ask ourselves:

are all of the components that are necessary to make an image present in
this ACS? if no then *this is not a failure*. it's not possible to
provide all the necessary values in a single invocation. hence we emit
an informational expression possibly listing the remaining required
fields, and we result in the original result from above.

otherwise (and the answer is "yes"), we do this:

we built a "snapshot" box during the check for missing requireds.
this "snapshot" is simply a box with qualified event knownnesses as
values. we pass this box off to some performer and let it do the rest of
the work.




### :"we used to abstain from calling this normalize"

(EDIT: the below is in the present tense, should be in past now.)
(do NOT erase this whole hog! the theory it brings up is important.)

we don't call this step `normalize` (despite the strong gravity from
the [#br-087] normal normalizer) because (quite interestingly) under the
ACS it is perhaps meaningless to speak of a "normalizer" in the old
sense. or more accurately, the scope of responsibility for a
normalization step is smaller under ACS:

under ACS, an ACS does not directly mutate its components, and is blind
to the idea of "normalizing" them - they must simply "come out" valid or
not come out at all.

(whereas under the classical [br] model, an "entity" was a mutable
structure that starts out holding unsanitized data and then thru
normalization, its member data is is made valid, or not.)

the referenced classical algorithm expresses itself into a semi-arbitry
three steps: defaults, custom normalization, and a "requiredness" check.
(one is semantically a subset of another but may need to come first as
a separate step in some cases. one is an "aggregate" operation that must
come last.)

under ACS we would like defaulting to work differently. (see the section
on defaulting in this document.)

"custom normalization" *is* what the "model" of ACS is for. so it needs
not to be given treatment here.

that means that only the final step of the classical algorithm needs
a counterpart here: that of checking for missing requireds. and that is
why we call this method what it is called, and not `normalize`.




## defaulting

..should be triggered when the topmost ACS is being built and is not
coming from serialization, or something similar. defaulting should
not be seen as reliable. do not assume defaults are effected ever.
