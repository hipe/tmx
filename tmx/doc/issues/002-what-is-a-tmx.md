## what is *a* tmx? :[#002]

at its essence "tmx" is nothing more than an automagic bundling of other
facilities.

if a gem wants itself to be exposed thru tmx, at least three things must
be true:

  1) the gem must be installed, and installed in the "main" gem
     directory (whatever `Gem.paths.home` points to).

  2) the gem's name must have a particular prefix (for now, "skylab-").

  3) the gem must have one or more executables in its `bin` directory
     that have the prefix "tmx-".

the bulk of the implementation here is just jumping thru hoops to make
the [br] client allow us to "mount" "top clients" as if they were
reactive nodes in our own model.
_
