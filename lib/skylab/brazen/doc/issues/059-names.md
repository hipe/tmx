# names :[#059]


"actual value" vs. "formal value" is disucssed elsewhere.

"property" generally means the formal property as object.

`property_value` is one method you can use to get the actual value from
the formal value's name.

"argument" has two meanings: for one it is the values that actions hold
and model, as opposed to the values that entities hold and model, which
we call "properties." the other meaning will be presented below.

some of the action's arguments may parse into property values for the
entity being described. those that do not may describe details of
desired behavior that the entity may need to know about. those values
from the perspective of the entity we call "parameters".

when we group a name and a value in a general way we call this a "pair."
always the means of accessing this pair's constituents must be with the
methods `value_x` and `name_i`. avoid `to_a` because our conventional
ordering of this pair is "value, name" (volatility order) not
"name, value" (the more familiar, idiomatic order of these terms).
since our convention is at oods with the idiom and the idiom is at odds
with our convention, we opt to formaize this order as undefined.

the other meaning for "argument" is now known as "trio". the trio is
the grouping of the formal value as object together with and any actual
value, as well as a boolean indicating whether or not the actual value
is to be considered as "known" or "provided". we may still use the name
"argument" for this in some contexts.

we may also call the above a "bound property".

whew!

in summary,

`argument` - what actions handle. see also "trio"
`property` - what entities handle
`parameter` - a (non-property) argument in the eyes of the entity
`pair` - value and name
`trio` - formal property (or argument), boolean, any value
