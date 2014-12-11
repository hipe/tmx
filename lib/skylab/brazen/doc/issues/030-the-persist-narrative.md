# the persist narrative :[#030]


## persisting one entity

in the same vein of the previous "hole", we run down some alternative
verbs for this interface point and why we didn't use them:

"write" sounds too much like writing a file to a filesystem. "save"
sounds too much like we are using a PC in the 1980's. "store" is OK but
again it hits close to "storage and retrieval" which is a paradigm we
overlap with but do not quite fit cleanly into.

if we were really cool we would not have to call "persist" at all: the
object graph could just write itself entirely "at the end" (of some
kind). but we are not here to write the next killer ORM (for now).


    persist_entity <entity>, & <on event selectively>


that is all. if we are using the necessary elements of our model model
then hopefully reflection will make all the magic happen. we expect that
the result value will be `ACHIEVED_` (that is, `true`) if this works and
if it doesn't we will send an event event (sic) to the [#069] selective
event listener `<on event selectively>`, and our result will be the
(if the result is consumed) the result of the callback, otherwise `nil`.
