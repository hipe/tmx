
## disjoint code-notes

### :note-1

we do not intend for these exceptions to be caught. their only purpose
is to assist the developer in addressing and correcting the problem.
the only reason we have made a custom exception class is to make the
generated message more testable.



### :note-2

we might change this so that a false-ish value will lead to the stream
being halted (and released?)
