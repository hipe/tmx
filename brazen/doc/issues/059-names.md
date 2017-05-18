# names :[#059]

## prerequisites

to understand how "actual value" is distinct from "formal value",
see [#fi-002.2].




## "property"

"property" generally means the formal property as object. we now may use
this generally to refer to the structure representing the metatdata for
this formal, business-specific conception that we have referred to
in the past variously as "attribute", "parameter", "field" in our
[#fi-001] various takes on this through history.

for some deep context, consider that we are now conceptualizing a
"formal property" as a sort of [#ac-002] "association" structure. (the
relationship between these two is tracked by [#122]).

`dereference` is one method you can use to get the actual
value from the formal value's name symbol.

some of the action's arguments may parse into property values for the
entity being described. those that do not may describe details of
desired behavior that the entity may need to know about. those values
from the perspective of the entity we call "parameters". so "properties"
are intrinsic characteristic of the entity, and "parameters" are
characteristics of this invocation of the action (those that did not
become "properties").




## "argument"

as a name for a phenomenon in code, we now recommend against all usages
but one for the word "argument":

  • only use "argument" to refer to the actual value passed by a user
    (or client, etc). for example, `@argument_box` is an appropriate use
    of the term "argument" - it is a box whose names are symbolic and whose
    values are the actual values that the user passed to the action.

we used to allow the term "argument" to refer to a qualified knownness
structure (below). we now recommend against this because it is too confusing
alongside "pairs" and "unqualified knownnesses".





## a pair :[#ca-055]

(this used to be a simple, dedicates struct; but is now under the [#co-004] stack)





## a "qualified knownness"

see [#ca-004] for a full treatment on this.




## summary

`argument` - what actions handle.

`pair` - value and (of some particular shape) a name.

`parameter` - in the eyes of the entity, an argument that is not a property.

`property` - what entities handle. also an object modeling the formal value.

`qualified_knownness` - see [#ca-004]




## document meta

  - #history-A: when the "pair" structure went away
