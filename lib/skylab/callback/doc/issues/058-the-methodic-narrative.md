# the methodic narrative :[#058]


## introduction by way of an explanation of the mechanics

who cares about history. it's the hero we deserve, and the one we need
right now.

the simplest iambic parsing mechanism we have yet come up with to allow
for writing arbitrary methods to parse arbitrary symbols is this: at
parse time we check for a `private` instance method whose name is the
concatenation of the current symbol name and `=`.

we use this pattern because typically such methods are never otherwise
created: because there is no unawkward way to call a private method
that ends in `=`, if we find one we assume it is in the employement of
this algorithm.

as well no such protected or public instance methods exist in ::Object
(that is, method whose name ends in `=`); so if you don't add any
yourself, this whole namespace is wide open to your business symbols.

but we add the private requirement just as an extra added sanity check
on top of this, and perhaps for those occasions when we may want to use
a `=` method in the typical way but at the cost of reducing our business
symbol namespace. but don't do this.




## :#note-515 (:+[#sl-117])

(from the original, business location)

ya know it's funny i really gotta tell ya somethin', we hate writing
and re-writing this same kind of normalization logic for every
application (nil out ivars, apply defaults, whine about missing
requireds), but the alternative (so far) has been the bloated and obtuse
[cb] entity property hooks API.

(edit: this was before the simplification and in part the inspiration for it)

hand-writing these 20 lines each time may just be worth the cost savings.

also we could just push this method itself upwards..




## experimental extension to the "simple" iambic parsing (:#note-650)

for this extension here, rather than checking for the existence of
private methods that end in `=` at parse time, we cache these name
mappings at code file load time, which a) will perhaps speed things up
for certain of our parsing use-cases and b) allow us to edit this cache
itself to reduce or modify syntax from that which is defined by those
"magic methods" that are private and end in `=`.

to do this the syntax must reside in classes and not just (as with
upstream library) modules, because from the instance methods, the
memoization container must be reachable, which in this case is the ivar
namespace of the class. this is why we have decided to keep this
extension out of the out of the box extension panoply, because while
this mechanism here may be more efficient, is decidedly no longer simple.
