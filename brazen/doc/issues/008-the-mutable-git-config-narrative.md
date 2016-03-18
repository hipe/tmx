# the mutable git config narrative :[#008]


## introduction

this is a rewrite and intended replacement for the stuff near (but not
at) [#!cm-005] code molester's config file.

(the introduction in the parent document node to this node is also
relevant here.)




## note-1

we want to validate the section name early, before we put it into the
string, because otherwise an (accidental or intentional) "injection
attack" may be possible by for example including and endquote, a closing
square bracket, and a comment character in the section name argument.

we *assume* that we don't need to do the same with any subsection name
because of its syntax and the escaping we do. (the only character a
subsection name cannot have is a newline, and such a character will
hopefully correctly break when we parse the "line".)




## :#when-and-how-we-duplicate

currently we do it for tests only: we don't want to re-parse the same
string over and over again.




## :#understanding-the-mutable-collection-shell

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
something like a "shell" that makes it look like this, and some sort of
internal "kernel" that holds the actual data as it is.
