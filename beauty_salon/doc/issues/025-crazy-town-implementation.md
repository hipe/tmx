# crazy town :[#025]

xx

    somehow parse the code selector

    somehow parse the replacement function

    for each file
      attempt to parse the file
      if error, explain and skip to next file
      (or maybe actually fail out entirely - be atomic - user should cull the file list)

      somehow get a stream of features by applying the code selector to the sexp

      for each feature (occurrence of a match),
        somehow pass this (with sufficient context) to the replacement function
        put the result into a queue of line-level changes

      at the end, add our list of line-changes to some kind of structure
        associating it with a reference to the file (just a path)

    (now you have a structure that is a list of file-changes)
      (this is past the point of failure.)

    output the diff from that.
