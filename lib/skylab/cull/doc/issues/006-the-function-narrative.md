# the function narrative :[#006]

## note-006

this "unmarshal" device was originally categorized as a model because
(by design) it does not follow the simple single-entry model of actor:
because it is convenient for implemention, we use this same class to
implement two different functions (that correspond to its two public
instance methods).

we almost created a new category for this sort of thing called
"perforomer" and then "device" - we wanted something distinct from
"actor" because this violates that categorization in that to use this
node, apriori knowledge of its interface required of it (something we
like to avoid generally)

"model" is not a good fit either, perhaps because an "unmarshal" is not
long-running, or perhaps because it has no data of its own, but rather
is a means to the end of other data (which again touches on the invisible
definition of actor).

"ancillary" works. "effecter" is a fun neologism.
