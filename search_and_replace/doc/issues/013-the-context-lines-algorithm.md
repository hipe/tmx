# the context lines algorithm :[#013]

## :'going backwards for more lines of "before" context'

going backwards for more lines of "before" context involves:

  • first use any lines you cached in the rotating buffer
    when you were walking up to the "during" line stream.
    if the cache accumulated N lines, you are done.

  • otherwise (and you have not yet reached N lines):

    • if you have no previous block you are done.

    • otherwise (and you have a previous block)

      • determine the N' number of lines you still need through subtraction.

      • start a cache (array) of lines that you will eventually reverse.

      • ask the block for its "backwards stream".

      • with this stream request the next line.

      • if it had a next line,

        • add this to the cache of lines.

        • if we have reached N' lines, we are done.

        • otherwise, repeat from "with this stream".

      • otherwise (and it didn't have a next line),

        • if you have no previous block you are done.

        • otherwise (and you have a previous block).

          • ask this block for its "backwards stream".

          • with this stream request the next line.

          • if you have no next line, repeat from "didn't have a next".

          • otherwise (and you have a next line),

            • add this to the cache of lines.

            • if we have reached N' lines, we are done.

            • otherwise, repeat from "with this stream"

      • with the cache of lines (you will "usually" have at least one),

        • reverse this cache of lines. this is now a head-anchored
          sub-span of "before" context lines.

        • concat to this list any of the lines cached by the
          rotating buffer. this is now the complete-most list
          of "before" lines.




## "we reverse over matches blocks the expensive way, not the hard way"

the forwards counterpart to this method illustrates the main
challenge behind it: whereas static blocks have static lines
(making random access and so reverse-stream access to them
trivial), in a matches block (here) replacements can add any
arbitrary N and remove/mutate particular existing LTS's.

that is, when we as a matches block must "delineate" (either
forwards or backwards), we require constant boundary detection
between items of two unrelated streams (a general theme here).
the upstream implementation of the forwards counterpart to
this method reveals the complexity involved in this: it is not
difficult per se, but its code is not enjoyable to read either.

to implement this method along the same lines as its forwards
counterpart probably wouldn't be much more complex than the
implementation there, but it probably wouldn't be much less
complex either. and to try and abstract something shared between
the two might be of little value because of the asymmetry of
LTS's: they sit at the end (not beginning) of lines, so the logic
would be different enough not to warrant abstraction.

if this is the case, then we here postulate that the savings of
having "efficient" reverse line streams isn't worth the cost of
having twice as much such boundary-detecting code. (but etc: if
the value of performance increases then etc.)
_
