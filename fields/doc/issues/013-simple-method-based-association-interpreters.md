# simple, method-based association interpreters  :[#013]

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




## document-meta

  - #tombstone-A [#fi-009.1] the seeds for the idea of normal normalization
    (in fact a rationalization against it).
