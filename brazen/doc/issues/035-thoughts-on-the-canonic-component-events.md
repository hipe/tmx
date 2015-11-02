# thoughts on the canonic component events :[#035]

  • we started DRY-tracking these common sorts of events.
  • the common theme here is that they relate to *mutating* a collection

  • we have assigned them tracking node sub-identifiers. they are:

    • A - not found
    • B - deleted (removed, destroyed)
    • C - already added
    • D - added (created
    • E - no change
    • F - modified (updated, edited)

   the above order is inspired by "practical dev order for CRUD" [#sl-137]:H




## wishes

• :#WISH-A: one day tie EN-like expression adaters in with expressive
  events so that individual component (models) can specifiy what verbs to
  use and so on (and maybe what expression structures to use too) much like
  we do with [near]  [#016] reactive tree models that specify how to
  inflect verbs, nouns, etc.
