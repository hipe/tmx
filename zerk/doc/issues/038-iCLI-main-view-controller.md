# [x]


## :#"descision A"

at calltime the ACS can produce whatever it wants
for the proc (because associations are dynamic): it can produce
no proc at all, it can produce a proc that produces a false-ish
value, it can produce a proc that produces the empty string..

if we end up with a false-ish in the following logic, it means
"don't display an entry for this node at all (either in name
or item text)."




## :#"decision B"

we could support multiline item texts by detecting if the proc
wants 2 parameters, but we haven't wanted it yet. if we do, maybe:

    lines = Home_.lib_.fields::N_lines_via_proc[ 2, @_expag, p ]




## :#"decision C"

with this the association (the ACS) can decide whether
or not to list the item at all, like for cases of effectively
unknown




## :#"decision D"

in the "entity table" it doesn't "look right" to include an
entry for compounds inline with the primitivesque properties.
that's perhaps the defining feature of this interface: that
the terminal nodes are always displayed in the 2-column table,
and the non-terminal nodes (and operations) can be reached by
"buttonesques" at the bottom of the screen.
_
