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




## :#note-on-point-of-reference

with some event production expressions we're actually getting to the
point where there's "too much" context (albeit well formed, unique).

much as like we don't want a component to know whether or not it itself
has a name, we don't want the component itself to report its own name in
the events it has generated (from within its own scope):

for example, at the moment [mt]'s top controller node is called
"appearance". it has changed its "adapter" component from "A" to "B".

we don't want the generated message to be

    !"changed appearance adapter from A to B".

we want merely

    "changed adapter from A to B".




## wishes

• :#WISH-A: one day tie EN-like expression adaters in with expressive
  events so that individual component (models) can specifiy what verbs to
  use and so on (and maybe what expression structures to use too) much like
  we do with [near]  [#016] reactive tree models that specify how to
  inflect verbs, nouns, etc.
