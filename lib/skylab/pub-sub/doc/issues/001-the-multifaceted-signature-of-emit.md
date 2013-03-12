# The Signature of Emit

Life is much easier and more readable if you assume a syntax like:

  emit type, *payload

where `payload` is often a single string.


However, remember these other important and essential variations of emit():

  + when the event has no metadata, like `emit :done`
  + when you are [re-] emitting custom event object, like `emit my_obj`
  + emissions with structured metadata: `emit :nerk, ferk: "blerk" ..`

Etc.  For this reason we have to assume that emit() takes one or more
parameters and we have no idea the shape of the parameters.


## what to do about it

In some applications an action will somehow get a hold on a particular
event (e.g. from an API call), and want to re-emit its own "version" of
that event; and by that we mean take the same payload of the previous
event, but emit a new event that has a different stream name and is
under the different event stream graph of that new action.

A hackish way to accomplish this that saves on lines of code *and*
memory *and* execution time is simply if the new event's @payload_a
member is simply a pointer to the exact same array of the original
event. This is a big experiment, and will definately pose problems
unles we agree that:

1) @param_a should be one-time write only immutable, and should always
be the exact contents of the `rest` args to the original `emit` call or
equivalent.  Further sub-processing of payload args should be considered
derived properties stored in e.g other ivars.

2) it then follows that useful higher level operations
on the payload (like "message") will be derived properties that will
live e.g in instance methods, and we will have to accomodate that when
the event is effectively changing classes.
