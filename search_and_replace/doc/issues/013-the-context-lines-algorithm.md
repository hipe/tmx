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
