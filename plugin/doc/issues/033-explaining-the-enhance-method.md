# contained DSLs through `enhance` .. :[#033]

#todo nascent pattern, describe it.

we tried other names: `confer`, `bestow`, `declare`, `define`, `extend_to`

advantages:
  • you don't pollute the module method namespace
  • having the DSL space contained makes it more traceable
  • having the DSL space contailed allows implementation to be atomic
