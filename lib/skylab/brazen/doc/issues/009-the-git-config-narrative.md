# the git config narrative :[#009]

## introduction

this is not intended to read/edit git config files per se. it is intended
to be a library used for creating new, modifying existing and reading from
existing config files; config files that happen to try and immitate the
syntax from the git cofig files.

we implement our rendition of the *git* config file syntax speficially
because it is complex enough for our needs without being too complex, it
is well documented and it should have a relatively widespread
distribution of understanding in the world.

however, using the git format specifically is a bit of an afterthought.
we can build out other document editors for other formats as necessary.



## known unimplemented features of the git config syntax

in each below bullet, we first present an excerpt from the "git-config"
manpage at the time of this writing, and then explain why we didn't
implement that feature.



• [after a section header] "All the other lines (and the remainder of the
  line after the section header) are recognized as setting variables".

  That part about being able to assign a variable in the remainder of
  the line after the section header, we didn't catch that detail when we
  first read it, so no effort has yet been made to implement this here.



• "If there is no equal sign on the line, the entire line is taken as name
  and the variable is recognized as boolean "true"."

  this feature sounds neat and it wouldn't be that hard to implement,
  we just haven't done it yet.



• "[t]here can be more than one value for a given variable; we say then that
  the variable is multivalued."

  we don't understand exactly what this means and we don't need this
  behavior yet so we have for now ignored it. (e.g do they mean commas
  or do they mean multiple assignments on multiple lines? probably the
  latter.)



• the git manpage states that the characters '1' and '0' can be used to
  represent boolean true and false. we do not recognize these
  interpretations: ruby has native support for booleans and does
  not use its integer type to hold boolean values, so it would be ugly for
  us to use integers internally to represent boolean values, hence we
  must decide at parse time which type to use to interpret these
  characters. we interpret '1' and '0' as integers becauase we need to.



• "Variable values ending in a \ are continued on the next line in the
  customary UNIX fashion."  We haven't done this yet because we don't
  need it and it's too hard (our tokenizer is line-based).
