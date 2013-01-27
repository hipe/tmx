# Feature-tree of interface-related libraries


This document is a temporary thing to guide the effort
of unifying all of our command line efforts into one library.

It is a feature-tree of different features that
appear in the three different manifestations of CLI
parsers ("frameworks") in this codebase, with the following properties:

  * The grouping criteria is 1) a semantic taxonomy of the features and
      then 2) for a given abstract feature, list the surface
      manifestations accross the different libraries.
  * Do not (yet) include vaporware or "wishlist" features in this tree
  * This feature tree isn't guaranteed to be comprehensive
  * Features considered not part of the core engine (e.g. 'version'
      and other non-help officious features) may be omitted from inclusion.
  * Nodes of the tree may be pure grouping nodes


+ The Tree of existing features across the libs:
  + Features as the pertain to a "runtime":
    + Features as they pertain to the runtime selecting an action:
      + A default action may be specified
        + by at least one of:
            class, { string | symbol } of { surface | internal } name
