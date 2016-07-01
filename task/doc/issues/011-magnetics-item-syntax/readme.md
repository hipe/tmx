## what the heck

we aren't using parser generators for reasons both practical and
lofty, so what we end up with is an amout of "vobey" code here
for those simple, mechanical parts of our hand-written FSA of the
finite state machine depicted at figure-1 (which is a must-read if
you are reading this file at all).

we have written the crazy script (see the figure) which automates
the most tedius part of writing this by hand: the development of the
syntax happens mostly in the design document (first an analog
whiteboard and then the dotfile) which is powerful for this purpose
because change is cheap and visualization makes it easy to play
through example use cases while modifying the syntax as necessary.

then with the script pointed at that document and the subject asset
file, it then tells us the methods (and other code) we have to write
and modify. all that is left to do is the fun part.

although we could perhaps achieve more-or-less the same parse tree
through the use of simple regexes and (for example) a successive
series of `split` calls (and some hand-written validation thrown in)
we have chosen the path here instead for the reasons that:

  • it feels inelegant to parse over the same bytes of a string
    multiple times in this manner when we would rather just pass over
    the string once. (take "a-and-b-via-c-and-d": split on "via",
    then split each side on "and", then split each part on '-'.)

  • as the grammar gets more complex, the regex becomes a different
    kind of code mud than what we have here. (we have that one script
    described above which amplifies our mud-power).

  • regex matches are all-or-nothing and black-box so in that
    respect we lose the ability to whine mid-parse at the level of
    granularity we can do here.

  • implementing our FSA in the way we have done here was totally
    fun and rewarding and is arguably more scalable.

we use the following shorthands because they're more easy to type
and they serve as a visual reminder that there's lots of small,
arbitrary nodes here and at that low level, it may be better not
to worry about what things "means" but rathter that they exist
and have identity.

    BT="before term"    IT="in term"

the numbers are more or less arbitrary too but originally stemmed
from the three (then four) quadrant-esques of our whiteboard.
_
