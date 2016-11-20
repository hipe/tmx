# feature injection through compounded operator branches :[#053]

this is an EXPERIMENT for helping to implement what is THE CENTRAL reason
for existence for both [tmx] and "slowie"..

it's premised on the assumption that there's two "operation" *instances*
that will be complicit in the merge..

  - it is assumed that each operation instance cna produce a fixed list
    (stream) of normal symbols representing its fixed set of available
    primaries at this moment, the start of the post-operation-resolution
    parsing. (note, though, that at this one moment each operation can
    produce any list it wants).




## hash collisions between branches :#note-1

what if two or more of the operator branches share the same key for
their branch items?

there used to be define-time collision detection (tacitly) between
the sets of names among the member branches (because we flushed *all*
"primaries" into one box at define time); but this implementation
changed (at first #history entry of the code file) and so now there
is not.

now if there is a set intersect among any two of the N branches,
behavior is undefined (but can probably be anticipated by knowing
that we use simple, predictable list iteration and stream mapping
to accomplish lookup and reflection, with no attempt at detecting
collisions there).
