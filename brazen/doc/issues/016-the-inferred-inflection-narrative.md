# the inferred inflection narrative :[#016]


## synopsis

tons of ridiculous haxs to infer natural langauge from class and module
names.




## the generaal algorithm

this module is expected to be used as a "module methods" module that
extends a class that represents and action and is named after a verb
(for e.g. `Add`).

furthermore that "action class" is expected to be nested in other
modules that represent a string of "words" that will probably make up
something like a noun phrase, e.g 'Fantastic::Widget::Add'.

in this above example there are 3 elements in the module path. the words
that make up the node names are of grammatical category
"adjective, noun, verb", respectively.

so from a module graph like the above, we could construe:

  "added a fantastic widget", "could not add a fantastic widget", etc.




## deciding what module names from which to derive meaning

typically we keep reading upwards until we hit a "stop" pattern in a
const name (like `Models_`). also we skip over the "box" (or "source")
module const name patterns (like `Actions`)

    Skorlab::MyApp::Models_::Widget::Actions::Add

in the above node path, `Models_` stops us from reading up to the
non-interesting "skorlab" and "my app".

in this document, we will refer to what is left over from the above
considerations as the "semantic node path". in the above examples, the
semantic node path is "widget add".




## :#the-flip

in the spirit of over-generalizing while at the same time making things
too ad-hoc, we do the following: we expect that semantic node paths in
this application may follow the pattern of:

    <noun phrase> <qualifier word> <verb>

for example,

    "data-store couch-db add"

the tendency is to go from general to specific (because taxonomies), but
to get an approximation of a natural language noun phrase we may have to
apply some translations (depending of course on the natural language).

in such cases for the phrases to tranform appropriately into
approximations of English we must put the (adjective-like) qualifier
word before the noun:

   "we have a couch-db collection."  ( NOT "we have a collection couch-db" )


at risk of jumping too far into the future, we do the above
tranformation only with the first two elements, assuming future
node-paths such as:

    "data-store couch-db connection add"

and:

    "a couch-db data-store connection was added successfully."





## :#to-determine-a-noun

to determine a noun: if there is a custom noun, use that. otherwise, if
there is a parent node, use that (assuming the common convention).

otherwise, if there is custom inflection with a verb (and since we have
no parent), assume that the class name is a noun. use that.  :#note-170




## further reading

this is vaguely but not directly related to the discussion at [#hu-066]
about how expressions are inflected based on the contrast between what
is expected and what is reality, over time.
