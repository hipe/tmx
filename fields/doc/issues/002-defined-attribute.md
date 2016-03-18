# (will rewrite)

## :#storypoint-5 introduction (:#formal-attributes-vs-actual-attributes) :[#025]

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
