# the plugin manifesto :[#008]

as we write this we are undertaking a full "underhaul" of the whole
[pl] sidesystem.

(EDIT whole document, when underhaul nears completion)




## objective, scope, and approach

"toolkit", not one-size-fits-most one-stop magic DSL

no subclassing

independent, isolated components




## description of problem

the potential smell with the delgator pattern is that it broadens too much
the interface of the delegator. it smells of a violation of the SRP
("single responsibility principle", attributed by [#sl-120] Martin to the
original authors): when you delegate you add to the scope of things that your
object does (or merely gives the appearance of doing); which can be a bad
thing in itself.




## document-meta

  - :#tombstone-A: was originally about the "delegation" DSL, and in
      that document (this document), explained the smells therein.
