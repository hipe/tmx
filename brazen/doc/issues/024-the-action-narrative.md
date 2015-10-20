# the action narrative :[#024]

## the list of shared concerns (between model & action)

  • actionability - identity in & navigation of the reactive model
  • description & inflection & name
  • placement & visibility
  • preconditions
  • properties
  • event receiving & sending




## :#note-70

if you override this method and result in a bound call from it you can
effectively short-circuit further processing while resulting in any
aribtrary result value from a surface component, even false or nil;
without beforehand knowing what the result scheme is from the surface
modality.




## :#note-100

the selective listener proc that is our argument is from some outside
agent (like a top client of some sort).

this is the crux of making an event model with selective listeners: it is
this outside proc that gets to decide whether the event should even
necesarily be produced. but once we hear back a "yes" from this
callback, it is up to "us" to decide how the event is built.

when the action receives a potential event (eg from one of its
collaborating actors), we call our received selective listener
with the same channel, and if it wants the event we wrap it.




## visiting:

### :[#023.A]:

this tag tracks the experiment (fruitful so far) of using `expression`
as a special, "magical" level-2 channel name. "events" on this channel
are assumed not to have representation thru event objects but rather are
assuemd to be "expressions" that express themselves into the expression
context in the block when called.




### :[#023.B]:

`data` as similar to above, but what is assumed of the block is that it
produces some arbitrary `x` that the client must do something with
(typically "manually").




#### :[#.C]

(this normalization point, does nothing out of the box)
