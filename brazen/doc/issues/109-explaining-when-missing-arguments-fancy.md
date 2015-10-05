# when missing arguments fancy [#109]

## intro

(NOTE: this is a transplant from [hl] which used to be part of the HUGE
 doc for the action intsance mehtods. theree is a *lot* of buried history
 in this document, all of which has been deemed no longer valuable.)



## content


oh man, talk about #view-template-ish'es, here goes: we are passed an event
structure that has within it both a syntax slice (think an array of formal
arguments), and full syntax (again same shape). the former is the series of
*all* the required arguments we failed to provide, and is made up of specia
argument objects that include their index into the full syntax.

for one, we only care about rendering the first argument, b.c it is redundant
and extraneous noise to state the rest. for two, if this is the weird case of
a required argument followed by an optional argument we want to be sure to
include the preceding optional argument(s) in the error message; because if
we did not then what we would say would be incorrect as an error of omission.

the effect of all this cleverness is not noticeable unless we have a
:#goofy-footed argument syntax that has optional arguments occuring before
required ones (covered).

:+#tombstone: eulogy for old [hl] action i.m's node
_
