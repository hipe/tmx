# the external functions experiment :[#010]

the experiment is this: what if we recognize universally a very small
API for property-like objects to adhere to (that would be an interface
in java) that has this:

  • `description_proc` - can be nil. ..

  • `name` - a [#ca-060] name function

  • `default_proc` - can be nil. ..

  • `parameter_arity` - any symbol

  • `argument_arity` - any symbol


rather than expect every formal-property-like structure in the universe
(see [#001] the long list) to descend from the same base class, we simply
assume all implementations adhere to the above inferface.

in the subject node (which should not be the only place for this kind
of thing), we define a set of functions *assuming* this set of (meta)
properties. the functions themselves are not bound to particular property
objects as they are in the traditional object-oriented model, rather they
are just functions that operate on inputs with a known shape.

then, modality- and/or domain-specific concerns can just use our
functions and/or write their own functions (or more likely implement their
own base classes) for their own higher-level and domain-specific needs.

this way, higher-level modules do not depend on lower-level modules, and
the lower-level modules do not depend on the higher-level modules.
instead, they both depend on this abstraction.


## advantanges to this approach

  • client libraries do not all "depend" on this library to the same
    degree of coupling that they would if we used the traditional OOP
    approach with a god-like base class. they do not need to load this
    library just to model properties.

  • "the client decides the functions" might become a thing


## disadvantages to this approach

  • client code is function-oriented instead of object oriented, so it
    looks less readable depending on the reader:

        Field_::Is_effectively_optional[ prp ]  # now

        prp.is_effectively_optional_  # then




## derivatives of the two arities

• there is a huge treatment on the subject (some of which is modalities-
  specific) at [#fi-014]. it's a relatively huge document (~600 of these
  lines).

• maybe one day we will move that document to the subject's sidesystem
  and assimilate this content into that one.

• but for now:

    | parameter arity | argument arity |
    |                 |                |
    | zero            | [all]          |  conceptual only. like voldemort,
    |                 |                |  its name shall not be spoken.
    |                 |                |
    | zero_or_one     | zero           |  a "flag" (checkbox, boolean, etc).
    |                 |                |
    | zero_or_one     | one            |  a "field" that is optional that
    |                 |                |  takes a value.
    |                 |                |
    | one             | zero           |  mostly conceptual. a "required
    |                 |                |  flag" is suprious. (but
    |                 |                |  `--force` might be an example.)
    |                 |                |
    | one             | one            |  a required field (takes a value)
    |                 |                |
    |                 |                |
    | zero_or_one     | zero_or_more   |  these are effectively
    | zero_or_one     | one_or_more    |  almost the same. [1]
    | one             | zero_or_more   |  a "glob" parameter where it is
    | zero_or_more    | one            |  acceptable to pass no value.
    |                 |                |
    | [0|1]_or_more   | [0|1]_or_more  |  weird to have polyady on both, but
    |                 |                |  ok. it might work as expected.
    |                 |                |
    |                 |                |
    | one             | one_or_more    |  a "glob" parameter but also a
    | one_or_more     | one            |  required field. at least one
    |                 |                |  value can be provided, and more
    |                 |                |  than one can be processed.
    |                 |                |


TODO: use `permute` to generate all this etc. waiting for [#dt-012])


[1] there is perhaps an esoteric distinction to be made between
receiving an empty list versus not receiving a value at all.
it's a bit like whether there is a known known of emptiness versus a
known unknown [#ca-004].


## xx
