# the action narrative :[#024]

## the list of shared concerns (between model & action)

  • actionability - identity in & navigation of the interface tree
  • description & inflection
  • name
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
