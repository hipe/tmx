# the FUN parse curry narrative :[#011]

## :#storypoint-5

experiments with parsing.


## :#storypoint-55

a higher-level interface to the lower-level mechanics of the parser. because
they are curriable executable objects, parsers must remain mutable but should
only be mutated when they are created or spawned. the shell exists to insulate
the parser in its mutability to the rest of the system. more than just a
simple conduit, however, the shell also has mechanics of its own for wrapping
up the details of a higher-level parse, as opposed to a normalized parse. note
the shell is 1-to-1 with a parser, and should hold no volatile state
information of its own.



## :#storypoint-215

this just clobbers whatever is there without warning (which presumably is
acceptable behavior, to e.g a currying user).



## :#storypoint-235

starting from the spot on `a` that is the last "OK" spot, turn that spot into
an array of the remaining elements of `a`, including that spot.



## :#storypoint-290

it "consumes" the amount that was matched
