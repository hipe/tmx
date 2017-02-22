# common events :[#007]

## caveat

these "common events" predate this current host library by quite a bit.
they have been moved here from the library in which they were conceived
because this is the rightful home for them semantically; however, they
carry with them many conventions that have been superceded by new
conventions discovered since their inception.




# a flat taxonomy of the commonest kinds of events

  • we started DRY-tracking these common sorts of events.
  • the common theme here is that they relate to *mutating* a collection

  • we have assigned them tracking node sub-identifiers. they are:

    - :[#here.1]: not found
    - :[#here.2]: deleted (removed, destroyed)
    - :[#here.C]: already added (ergo cannot add because of this)
    - :[#here.4]: added (created)
    - :[#here.E]: no change
    - :[#here.6]: modified (updated, edited)

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




## ([#here.8] is inline - it's about how we derive names)





## wishes

• :[#here.G]: one day tie EN-like expression adaters in with expressive
  events so that individual component (models) can specifiy what verbs to
  use and so on (and maybe what expression structures to use too) much like
  we do with [near]  [#016] reactive tree models that specify how to
  inflect verbs, nouns, etc.
