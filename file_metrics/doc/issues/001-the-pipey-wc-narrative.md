# the pipey `wc` narrative ..

## synopsis

we just let `wc` do the work for us of totalling things..


## introduction

let "subject" be the system's `wc` utility. assume:

  • that each argument we pass to subject is a filesystem path
    that represents a file, which in actuality may not exist or
    be a directory, device, etc.

  • that for each argument passed to subject, subject will
    produce exactly one corresponding line of output.

  • that the stream to which the above mentioned line is written
    will be stderr or stdout respectively based on whether or not
    an error was encountered when treating that path as a file
    (e.g. "No such file or directory").

  • that IFF there were more than one argument passed to the
    subject, the total number of lines output by the subject
    (i.e the sum of any stdout and any stderr lines) will be N+1
    for any N number of arguments: we assume there will always be
    one final "X total" line where 'X' is the sum of file
    arguments.

    ergo we assume there will always be either one line of output
    or greater than two lines of output, never two.

on top of all that, we pipe all this to `sort -g`
(--general-numeric-sort), which doesn't mangle the position of our
"X total" line only because that line always has the greatest number,
hence always ends up at the end (where it started) after sorting!
EGADS!!
_
