# the methodic narrative :[#013]


## new notes

in the normalest case:

  1) a next value (assumed) is read from the argument stream.

  2) that value is written to the ivar derived from the attribute name.

some regularly required variations on the above normal case are:

  • the value might be arrived at through some other means.

  • the ivar might be some ivar other than the one that is derived
    from the attribute name.

  • the value that would have normally been used might be mapped in
    some arbitrary way.

  • it may be that (in conjunction with some of the operations above)
    another formal attribute should be used to fulfill some remainder
    of the interpretation operation.

examples (in alpha):

  • `component` is an ad-hoc, particular way to arrive at a value.
    to implement it will require aspects of the interpretation runtime.

  • a `custom_interpreter_method` is a full replacement for the entire process
    of interpreting the attribute value. it asssumes that some one-time
    preparations have been done on the "session".

  • a `flag` is an interpretation where the value to be used is `true`.

  • `flag_of` is to say "use this other formal attribute" but give it
    a value of `true`.

  • `ivar` indicates a non-normal ivar name to use.

  • `known_known` wraps the value that would have been used

  • (`optional` is out of this scope)

  • `singular_of` is a value map plus a formal-attribute swap.





## introduction to the legacy "iambic writers"

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
