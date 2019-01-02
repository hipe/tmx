---
title: using the TODO stack
date: 2018-01-25T10:19:38-05:00
---
## foreword

on 2018-12-08 we "exploded" our monstrous TODO stack into very many
graph viz files and effectively deprecated its use to the extent detailed
in this document.

however, we persist in using the TODO stack facility
(currently a file with one line)
for the purpose of keeping short-term
reminders within the working time of one commit.

longerm what would be nice is the same user experience of using the
TODO stack (because after all, we still experience time linearly and have
to chose tasks to do one after the other); but having it be somethng like
a view produced by our new way.

what follows is the body of this document as it existed before we
deprecated the practice such as it was.




## stupid simple issue tracking:

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
