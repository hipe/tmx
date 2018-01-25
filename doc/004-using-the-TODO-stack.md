# using the TODO stack

stupid simple issue tracking:

  - we are describing the "TODO.stack" file.

  - one TODO item per line. (need more lines? see [below](#b))

  - generally your final-most goal is the first line

  - generally add new lines to the end of the file

  - the "top" of the stack is the bottom of the file
    - "push" to the stack by concatting a line on to the file
    - "pop" the stack by removing the last line of the file

  - generally the items lower in the file get done sooner

  - typically if one item depends on another item, the depended-upon
    item will be lower in the file. (the depdended-upon item is
    "lower-level" line, and the needy item is the "higher-level" one.)

  - generally what you are working on now should be at or near
    the last line of the file.

  - add items when you think of them.
    - you can `echo "do this thing" >> TODO.stack`
    - clean up the ordering/wording whenever before your next commit

  - remove items when they're finished
    - it's fine to add and remove items without committing them as desired.

  - if you want to get silly, you can in effect track author and creation
    date with version control just by using version control alone, provided
    that you never edit the line once created (except to delete it).




## <a name=b></a>more details

  - if you want to describe your item in more than one line, your
    descripton belongs elsewhere. maybe break out a dedicated file.

  - this whole system could theoretically be superceded by
    [\[#002\]](../README.md#002) the node table (eventually): but that
    is unlikely to happen anytime soon because of how reliable and
    resilient and portable this system is..
