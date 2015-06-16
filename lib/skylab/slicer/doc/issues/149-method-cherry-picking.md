# method cherry picking - experimental pattern :[#149]

(historical note, this was written just before the huge bundle revolution,
at the beginning of the headless earthquake)

this refers broadly to the conflagration of patterns, both experimental and
established, that facilitate *method* (not function) re-use, by means other
than adding a module to an ancestor chain (namely, inheriting from a class or
extending/including a module).

such techniques may be employed variously because we don't want to cloud
the ancestor chain with lots of cruft, we want to be explicit about where
and how we are re-using something, and/or because it's fun coming up with
new ways to do old things and then finding out whether they are better or
worse.

## implementations in the wild so far

### simple "proc in constant turned to method with `define_method`"

### procs stored in a box-like or struct-like, and then same as above

## facets

"touchers" are a more complex and powerful expasion of this idea, explored
at [#048].
