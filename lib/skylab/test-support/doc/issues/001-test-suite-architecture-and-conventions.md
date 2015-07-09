# the system narrative :[#035]

## :#intro

the "system" node is part of [ts]'s public API, and provides a universally
consistent way for sidesystem to access these resources.

it is documented here because it is a #stowaway in the library node. it stows
itself away because it is too small to justify its own file. it stows itself
away in the library node because in practice the "API points" of this node
are just wrappers of somesort to procs defined in our "Lib_" node.

sidesystems should use this one central means to access system resources
because of #the-reasons-to-access-system-resources-this-way



## :#the-reasons-to-access-system-resources-this-way

it is convenient for tests to be able to write directly to stderr for e.g to
output debugging information. however, littering our code with hard-coded
globals (or constants, that albeit point to a resource like this
(an IO stream)) is a smell: on some systems or at some point in the future
we may want to access these resources via a different means. in some
environments we may want always to ignore such output, or write it to a
logfile.

from within this subsystem rather than accessing such resources "directly",
we instead reference such resources thru wrappers like these, which buys us
some slack for the future, i.e "future-proofs" this a bit.

and if ever we decide that this whole techinque is fundamentally flawed or
needs some kind of re-architecting, we at least have leashes on all the places
that do this.
