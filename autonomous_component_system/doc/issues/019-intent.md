# intents :[#019]

(continued from [#003])

these different classifications of concern referred to above we call
"intents" - we consider [un]serialization one "intent", and API/UI
another. munging API and UI into one intent is itself a broad leap
the ramifications which we won't explore here, but is the theory behind
[br] in general.

the point is not for us to disover The Taxonomy of intents. (but if
it were, a good start might be [#]/figure-1). rather, the point is to
get a feel for "intent" as an "axis" (or "vector") that affects how
we approach the design and delivery of apps.


## the main thing..

..(that we learned from experience) is that *you want to keep
intent-specific expression out of the "model"*. that's it.
in fact, this thing is so "main" that we have re-worded our "design
tenet 2" ([#002]#Tenet2) to reflect this.

before we arrived at this rubric we used to abuse an `intent` meta-
component that would hold a symbol with values like `serialization`,
`API`, etc. this did not scale well and was ugly.
