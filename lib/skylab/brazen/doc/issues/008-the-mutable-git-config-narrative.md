# the mutable git config narrative :[#008]


## introduction

this is a rewrite and intended replacement for the stuff near (but not
at) [#cm-005] code molester's config file.

this is not intended to edit git config files per se. it is intended to
be a library used for creating new, modifying existing and reading from
existing config files; config files that happen to try and immitate the
syntax from the git cofig files.

we implement our rendition of the *git* config file syntax speficially
because it is complex enough for our needs without being too complex, it
is well documented and it should have a relatively widespread
distribution of understanding in the world.

however, using the git format specifically is a bit of an afterthought.
we can build out other document editors for other formats as necessary.



## note-1

we want to validate the section name early, before we put it into the
string, because otherwise an (accidental or intentional) "injection
attack" may be possible by for example including and endquote, a closing
square bracket, and a comment character in the section name argument.

we *assume* that we don't need to do the same with any subsection name
because of its syntax and the escaping we do. (the only character a
subsection name cannot have is a newline, and such a character will
hopefully correctly break when we parse the "line".)
