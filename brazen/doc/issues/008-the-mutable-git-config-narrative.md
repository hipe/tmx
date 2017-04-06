# the mutable git config narrative (all notes for development) :[#008]

## objective & scope

making these config documents "mutable" (editable) while preserving
comments and arbitrary formatting is enough of a challenge that it
warrants its own foundation here, as a complement to the more general
[#009] introduction to (immutable) "git config" files.




## table of contents

  - [#here.a(ph)] - intro, table of contents, historical synopsis
  - [#here.b(ph)] - our simple grammar and its ramifications
  - [#here.C] - on the importance of parsing
  - [#here.D] - ramification one of our grammar: two states
  - [#here.E] - peeking (inline)
  - [#here.F] - ramification two of our grammar: façades
  - [#here.G] - immutability of atomic elements

  - [#here.xx] - historical synopsis




## our simple grammar and its ramifications

  - our grammar is simple enough to implement with this hand-written
    parser. (if it were more complex we would consider other options.)

  - the grammar is line-oriented. the non-terminal symbols of our
    grammar never span multiple lines, probably.

  - every line of a valid parse will fall into exactly one of these
    three categories: either it's a blank-line-or-comment-line, or
    it's a section line, or it's an assignment line.

  - every assignment line will be (and must be) associated with the
    last section line that came above it. as such it is grammatically
    invalid for any assignment line to occur before the first section
    line of the document.

  - sections do not nest per se. there are "sub-sections", but
    grammatically the difference between a section and a sub-section
    is uninteresing: a section becomes a sub-section when it is given
    a sub-section name.




## a general point on the importance of validation/normalizaton/parsing :[#here.C]

all section names, subsection names, assignment names, assignment values,
and even comment strings must be at least validated (if not parsed) to
ensure that the config file is not corrupted by byte sequences that
won't subsequently parse on their way in.

(EDIT: the older telling of the same:)

we want to validate the section name early, before we put it into the
string, because otherwise an (accidental or intentional) "injection
attack" may be possible by for example including and endquote, a closing
square bracket, and a comment character in the section name argument.

we *assume* that we don't need to do the same with any subsection name
because of its syntax and the escaping we do. (the only character a
subsection name cannot have is a newline, and such a character will
hopefully correctly break when we parse the "line".)





## on implementation: how the grammar effects parsing (2 states) :[#here.D]

we said above that every assignment line must be associated with a
section (or sub-section) "collection" node. as such, when beginning
to parse a document we start out in a "state" that only allows for
two of our three categories of line:

at the beginning of documents, we can only process
blank-line-or-comment-lines, or a section line. encountering an assignment
line from this beginning state must express a parse error.

but once we find the first section (or sub-section) line then all
assignment lines we encounter after that will always be OK.

once we establish




## ramification of our grammar: façades. :[#here.F]

in a world where we only want read-only operations on an immutable
documents of this grammar, it is enough to model the document as a simple
tree of limited depth: on the first level it is a flat list of N sections
(perhaps indexed by section and subsection name somehow); and each section
is merely a similarly flat list of assignments, again possibly indexed
somehow.

but when we want lossless mutability, we have to represent every byte
that's in the file in the parse tree somehow, and that includes whitespace
and comments.

(EDIT the rest of this section is the old copy..)

the internal representation of a document is an an array of nodes: each
node can be a { blank or comment } line or a [ sub ] section. so note
that we store the coment nodes "in line" with the section nodes.

this is useful for faithfully unparsing the document (i.e keeping the
comments and whitespace intact), and doing so in a straightforward and
resuable manner; but these extra nodes "get in the way" when we are
trying to get to the content nodes.

this is what the shell is for. the shell is a façades that let us
interact with the document as if we had a contiguous array of sections,
even though internally we do not.

this exact same arrangement holds for the assignments within a section:
when we are operating on assignments (adding and removing them), it is
convenient to do so as if there is a list structure of contiguous
assignments, even though in actuality there may be whitespace or comment
nodes interspersed between the assignments. so here as well we have
something like a "shell" that makes it look like this, and some sort yy<D-2>




## about immutability and duplication :[#here.G]

new in this edition, we conceive of as immutabile the "atomic", line-level
elements (namely, comment-or-blank-like elements or assignment elements;
i.e the two that aren't the one "collection node", i.e the section).

(some exceptions to this generalism may exist in legacy code, and the
methods facilitating this have been given SHOUTCASE names (although not
all shoutcase methods are in service of this particular legacism).)

as such if you want to "change" the values of these elements you have to
(in the "collection" element) replace the whole element with a new element
that has the same name and the desired value.

not only is immutability "good practice" generally, but this
makes deep-duping documents more straightforward like so:

under this model every element is either a "collection" node (documents,
sections) or an "atomic" node (assignments, comment- or-blanks). the
collection nodes can be mutated at any point during their lifetime (by
the simple adding to, removing from and replacing in of their array) and
so when a document is to be duplicated it is these collection nodes that
need to be duplicated recursively (mainly in regards to their array).

however the "atomics" are to be treated as immutable. as such
when duplicating a document we can share the same atomic nodes
across several documents; allowing the implementation of deep
duping to be straightforward.

the dirty secret about all this is that we are preoccupied with it mainly
because it makes testing much less clunky and more performant when we can
easily start with a known document "prototype" (or fixture) and duplicate
it deeply and then modify this copy and test against that, rather than
having to parse the document from a string or build it up "by hand" over
and over again for each test.





## further reading

[#028.3] will talk about file-locking, which while being peripherally related
to mutable documents, is also a wholly separate concern.





## historical synopsis

(most recent at top)

  - #history-A was probably the first massive overhaul of subject.
    in it we saw an explosion of something like 10 smaller files break
    out of one huge file.

  - this started out as an replacement for the stuff near (but not at
    [#!cm-005] code molester's config file.


## document meta

  - :#history-A: was perhaps the first massive overhaul of the
    "git config" (mutable) node.
