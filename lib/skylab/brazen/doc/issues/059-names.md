# names :[#059]


"actual value" vs. "formal value" is defined [#mh-025] here.

"property" generally means the formal property as object. we now may use
this generally to refer to the structure representing the metatdata for
this formal, business-specific conception that we have referred to
in the past variously as "attribute", "parameter", "field" in our
[#mh-053] various takes on this through history.

`property_value` is one method you can use to get the actual value from
the formal value's name.

"argument" has two meanings: for one it is the values that actions hold
and model, as opposed to the values that entities hold and model, which
we call "properties." the other meaning will be presented below.

some of the action's arguments may parse into property values for the
entity being described. those that do not may describe details of
desired behavior that the entity may need to know about. those values
from the perspective of the entity we call "parameters". so "properties"
are intrinsic characteristic of the entity, and "parameters" are
characteristics of this invocation of the action (those that did not
become "properties").




## a pair :[#cb-055]

when we group a name and a value in a general way we call this a "pair."
always the means of accessing this pair's constituents must be with the
methods `value_x` and `name_i`. avoid `to_a` because our conventional
ordering of this pair is "value, name" (volatility order) not
"name, value" (the more familiar, idiomatic order of these terms).
since our convention is at oods with the idiom and the idiom is at odds
with our convention, we opt to formaize this order as undefined.




## a trio

the other meaning for "argument" is now known formerly as "trio".
the "trio" is the grouping of the following three things:

  1) the formal value ("property" above) as object
  2) a boolean-ish indicating whether or not any actual value is to be
     considered as "known" i.e "provided" for this formal value.
     true-ish means "known", false-ish means "not known"
  3) the actual value (if (2) is true.) if (2) is false, this value
     has no meaning.

it might read better to have a variable called "arg" as opposed to "trio",
but whenever we need to avoid ambiguity we will say "trio". but note we
we may still use the name "arg" for this in some contexts.

we may also call the above a "bound property".

whew!




## summary

`argument` - what actions handle. also, an informal name for "trio"
`pair` - value and name
`parameter` - a (non-property) argument in the eyes of the entity
`property` - what entities handle. also an object modeling the formal value.
`trio` - formal property (or argument), boolean, any value
