# introducing tagged argument lists :[#042]

(EDIT: these are now called :#iambics)

they have properties

  • always readable - can be more redable than hashes, because nesting
    can be implemented by the parsing, not the argument structure

  • when signatures change upstream, downstream doesn't have to know
    about it - it can just glob arguments

  • "easier" to merge than hashes
