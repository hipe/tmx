# the formal attribute narrative :[#024]

FOREWORD: this puppy is very old. it was rewritten once then lost in the fire,
and has since been obviated several times by other efforts. however, some time
in the distant future, everything may merge. that said, the below content was
formatted to fit this screen, but it otherwise often historic.



## :#storypoint-5 introduction (:#formal-attributes-vs-actual-attributes) :[#025]

(the fate of this node is discussed at [#053] "discussion of the..")

What is the esssence of all data in the universe? It starts from within. with
metaprogramming.

Let's take some arbitrary set of name-value pairs, say an
"age" / "sex" / "location" of "55" / "male" / "mom's basement"; let those be
called 'actual attributes'. You could then say that each pairing of that
attribute with that value, (e.g an "age of 35") is one "actual attribute"
with "age" e.g. being the "attribute name" and "35" being the
"attribute value."

Now, when dealing with attributes you might want to speak in terms of them in
the abstract -- not those actual values, but other occurences of particular
values for those attributes. We use the word "formal" to distinguish this
meaning, in contrast to "actual" attributes.

For example we might want to define 'formal attributes' that define some
superset of recognizable or allowable names (and possibly values) for the
actual attributes. For each such formal attribute, this library lets you
define one `Formal::Attribute` that will have metadata representing the
particular formal attribute.

To represent an associated set of such formal attributes, we use a
`Formal::Attribute::Box`, which is something like an ordered set of formal
attributes. Think of it as an overwrought method signature, or formal function
parameters, or a regular expression etc, or superset definition, or map-reduce
operation on all possible data etc wat. If the name "box" throws you off, just
read it as "collection" whenever you see it.

To dig down even deeper, this library also lets you (requires you maybe) to
stipulate the ways you define attributes themselves.

Those are called meta-attributes, and there is a box for those too..

So, in reverse, from the base: you make a box of meta-attributes. This
stipulates the allowable meta-attributes you can use when defining attributes.
With these you will then effectively define (usually per class) a box of
attributes, having been validated by those meta-attributes. Then when you have
object of one such class, it will itself have (actual) attributes.

(There is this whole other thing with hooks which is where it gets useful..)

To round out the terminology, the object that gets blessed with all the DSL
magic to create meta attributes and then attributes (and store them!) is known
as the "definer" (`Formal::Attribute::Definer`) which is what your class
should extend to tap in.

It may be confusing, but the library is pretty lightweight for what it does.
Remember this is metahell!



## :#storypoint-10

inspect the attributes defined (directly or thru parent) in this definer.

note this is the only method that is public out of the box. also your
attributes are mutable and not themselves private.



## :#storypoint-15

define an attribute in detail, or the existence of several attributes by name.



## :#storypoint-30

this method signature is heavily overloaded not just to be DSL-ly bc honestly
that is kind of annoying here, it is because we want `meta_attributes`
the plural form, with an 's') to be always the getter and never a setter for
the same reason of not liking overloaded method signatures. so it is an
unintended irony here.



## :#storypoint-35

retrieve the box that represents the metaattributes defined for this definer
creating it lazily.



## :#storypoint-40

a meta attribute is of course an attribute's attribute. users can define them.
e.g. `default`, `required`, these are common meta-attributes. I know what
you're thinking and the answer is no.



## :#storypoint-50

but when you have a collection of meta-attributes, where do *they* go!? note
this looks a lot like an attribute metadata, and might as well be one, except
that it is for representing collections of meta-attributes that should be
applied to all new attributes, which is similar but not the same as an
attribute metadata (for one thing it does not have a name associated with it.)
but notwithstanding it might should go away. imagine a prototype metadata
instead of this..



## :#storypoint-60

for now the formal attribute is itself modeled as a box, a box of meta-
attributes.



## :#storypoint-75

merge the hash-like `enum_x` into self whereby for each element if self has?
an element with the name, change it else add it.



## :#storypoint-80

merge the hash-like `enum_x` into self whereby if the `compare` box already
has an element with name, **add** the element iff it != the existing one.
this allows us to make minimal deltas, a logical requirement.



## :#storypoint-85

used here by `accept`, may also be used by subclasses by clients e.g to make a
custom derived property, like a label.



## :#storypoint-90

simply an ordered collection of formal attributes. think of it as a method
signature.. (sister class: Parameter::Set)



## :#storypoint-95

hash-like convenience constructor allows you to make an arbitrary ad-hoc
attribute set intuitively with familiar primitives. note this does not care
about metaattibutes. also there is a sinful "optimization" we throw in just to
be jerks.



## :#storypoint-105

result is a new box whose every element represents every element from this box
that has? `metaattribute`. Every element in the result box will have a name
that corresponds to the name used for the original element in the original
box, but the new element's value is the value of the original box element's
`metaattribute` value., .e.g:

    Foo.attributes #=> {:age=>{:default=>1}, :sex=>{:default=>:banana}, :location=>{}}

    Foo.attributes.meta_attribute_value_box :default #=> {:age=>1, :sex=>:banana}



## :#storypoint-110

wrapper around: produce a new enumerator that filters for only those
attributes that has? `mattr_name`. note it does not care if those meta-
attribute values are trueish, only if they `has?` that meta-attribute in the
box. (a most common use case is defaults - sometimes defaults are nil or
false. this is different than a formal attribute not having a default set.).



## :#storypoint-120

#experimental. we are considering adding a `with`-like ability to use a mattr
name instead of a block, so it would be like a `with` with an extra true-ish
check. but only if necessary



## :#storypoint-135

in case nil is returned from the reader, we don't behave as if we "have" the
value unless it has a default (which presumably is nil).



## :#storypoint-175

the default attribute definer for a typical object is its ordinary class. in
some cases -- e.g. if you are dealing with a class or module object and want
to use attribute definer for *that* -- you will want to redefine this method
to result in the singleton class instead, for reflection to work (which is
required for some kind of meta-attribute setters, etc)
