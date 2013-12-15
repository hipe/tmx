# understanding the config file model :[#005]

## `write` is very evented :[#006]

`write` - because so many different interesting things can happen when we
set out to write a file, we have a custom emitter class that models this
event graph that callers can use to hook into these event streams.

for one thing the file either does or does not already exist, and for these
two states we will variously use the verbs `update` or `create` respectively
in various symbols below.

we emit separate events immediately `before` and immediately `after` the file
is written to, which, when events on such streams are received by the caller
that has a CLI modality, they are frequently written out as one line in two
parts, with the reasoning that it is useful to see separately that the file
writing *began* at all and that the file writing *completed* (successfully)
-- and doing this in two separate lines may be considered too noisy -- however
having the first half of the line written out e.g. to a logfile might be nice
so that you have the filename recorded right before e.g a permission error was
thrown by the filesystem.)

the four symbols introduced above (`create`, `update`, `before`, `after`)
exist as taxonomic streams, and then additionally one stream each for the
four permutations of the two "exponents" for each of the two "categories"
exists ("before_create", "after_update") etc.

("taxonomic streams" are streams that exist only to categorize other streams
(kind of like folders, more like tags). they are useful if you wanted
subscribe only to certain sub-streams of events - e.g only the "after-"
related events or only the "update-" related events.)

other taxonomic streams used include `text` v.s `structural` (whether the
event is a string or a struct-ish of metadata (in the inheritence chain of a
given stream, first one wins here) -- this may help you decide
programmatically how to handle the event); and `notice` vs. `error` i.e. the
severity -- e.g you may only want to act on events when they are at a certain
level of severity to you.

this big graph of streams is best viewed with `pub-sub viz`, a command-
line tool that is part of pub-sub and works in conjunction with graph-viz
to display this graph visually.

(incidentally this and its two constituent implementation methods
is becoming the poster-child wet-dream of [#hl-022], which seeks
- possibly in vain - to dry up this prevalent pattern..)


## the meaning of `modified` :[#004]

the meaning of `modified?` may have changed since last you used it: it *used*
to mean: "does the file that is currently on disk have an `mtime` that is
greater than the `mtime` was when we last read it?" whereas *now* it means
"are the bytes we have in memory different than the the bytes that are on
disk?".

the old sense of the meaning may prove useful in the future to protect
against accidental overwrites, (as vi does for e.g) which is why we keep this
note here.

for those instances that are not (yet?) associated with a pathname, the
question of if it is `modified?` is meaningless and potentially hazardous if
misunderstood. In such cases we raise a sanity check exception.

for those instances that are not valid, the question of whether the object is
`modified?` should not be asked, because this library will try to prevent you
from writing such objects to disk. Likewise a runtime error is raised in such
cases.

