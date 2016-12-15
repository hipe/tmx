# mondrian :[#008]

the goal of this would-be one off utility is to (in conjunction with
some visualization facility) to get a visualization of the various
structures defined in a file in terms of how "large" they are in terms
of number of lines they take up.

  - for now we're talking modules and classes, but one day we would
    like to include proc definitions and method definitions.

the purpose of this would be to know how large or small the various
components are so as to decide how to break up a large file into
smaller files.

because right off the bat this structural data is tree-like (modules,
for one thing, are nothing if not branch nodes); we're already thinking
about ways to visualize it..

yes, treemap.




## algorithm:

this extremely rough pseudocode is more or less based on the milestone
stack we just made for ourselves:

  1. get "tree data" from a const path
  1. build "shapes layers" from tree data
  1. render "ASCII matrix" from shapes layers
