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

• :#WISH-A: one day tie EN-like expression adaters in with etc ..
