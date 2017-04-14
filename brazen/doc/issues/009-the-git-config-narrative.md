# the git config narrative :[#009]

## objective & scope

despite its name, this library's founding purpose is not for reading (or
writing) git config files per se. (whether it can do that is in fact outside
of its scope, but the answer is "probably, most of the time".)

rather, this library's objective is to implement a simple "entity"
datastore through the use of text files that follow a simple format;
text files that can be read *and edited* by human *and machine* alike.

if this sounds preposterous or useless, it is in fact neither: `git` already
employs this excellent game mechanic in its config system: you can use git
commands to change config settings programatically, but also you can edit
the config file(s) directly, by hand. the config files are then something
that readable *and editable* by human *and machine* alike; which is a dynamic
that we think is pretty neat.

this is one reason (but not the only one) why we have used pieces of git's
config system as inpiration for this effort.




## but then why `git` (config) specifically?

we implement our rendition of the *git* config file syntax specifically
because

  - it's complex enough for our needs without being too complex

  - it is well documented

  - it is part of a software ecosystem that has a huge enough distribution
    around the world that its popularity alone is a good justification for
    its use, notwithstanding any major CON's, of which there are none
    against our requirements.

however, using the git format specifically is a bit of an afterthought.
we can build out other document editors for other formats as necessary.

because of how tightly we try to use git's config syntax as acceptance
criteria for our efforts; we will continue to use the name unless outside
forces dictate that we do not.




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
