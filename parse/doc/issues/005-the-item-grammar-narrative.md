# the item grammar narrative :[#005]

## pillars of the rewrite

  - no subclassing

  - stream the parse - parse only what you need

  - simple yet flexible: "meta-attributes" are always implemented as
    modules, built-in meta-attributes for 80% use case




## introduction

"the item grammar" is designed for parsing a simple class of grammars
simply. you define your grammar as:

   • set F of zero or more "flag" keywords ("adjectives")
   • one "keyword" keyword
   • set M of zero or more monadic parameters ("prepositional phrases")




## example

image a grammar defined in shorthand as:

    [ `hot`, `cold` ] `tea` [ `with`, `and` ]

what this shorthand means:

  • `hot` and `cold` are the available niladic ("flag") parameters.
  • `tea` is *the* keyword.
  • `with` and `and` are the avaiable postfixed monadic parameters.

the below productions should be able to be parsed by this, with comments
indicating otherwise as necessary.


    tea
    hot tea
    hot cold tea
    cold cold hot tea

    tea with  # NO - will bork when it can't consume the value

    hot tea with milk

    hot tea with milk and sugar

    hot tea and sugar with milk   # it might not make sense

    hot tea with milk and cold sugar  #  NO - adjective can't appear late

    hot tea with milk saukraut  # NO - strage word
_
