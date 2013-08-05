# the magical significance of nil

in a few place `nil` is taken to mean "not set" and conversely
**anything other than nil** can be taken to mean "set" (including false).

this has ramifications for:

1) determining whether a parameter is missing
2) determining whether to apply a default to a parameter
3) determining whether the field-level custom normalization function
   succeeded in normalizing the field (or not .. [#019] is the authority
   on this.)

the third one is super janky and will probably change..
but the other two are this way for now.
