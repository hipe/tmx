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
