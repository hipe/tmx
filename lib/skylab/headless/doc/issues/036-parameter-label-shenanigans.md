## Parameter Label Shenanigans :[#036]

This is asking for trouble but we will wire it correctly. Imagine a
world.. The intersection of name functions and fp's etc.

+ `parameter_label` - it is no longer something the pen does! ..
  it it within the scope of responsibility of the formal attribute
  holder to do it.  that means that:
    + sub-clients always propagate it up
    + actions check if they have fp's for fa's, and if so, check if
      they have the parameter, and if so, propagate *that* up to be
      rendered, and if not, propagate up the original request,
    + clients stop the buck.
_
