# the mutable git config narrative :[#008]


## introduction

this is a rewrite and intended replacement for the stuff near (but not
at) [#cm-005] code molester's config file.

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
