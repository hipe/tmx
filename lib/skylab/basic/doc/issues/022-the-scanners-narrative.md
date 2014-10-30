# the scanners narratives :[#022]

## point of history

ownership of scanning (as the abstract idea) got "promoted" from here up
to [#cb-044]. what remains of this file are those parts of scannng that still
remain in this sidesystem.

so the timeline of this document was cleaved, and the other sidesystem
gets to keep the history because it formally owns the idea now. however
what appears below what moved from "that" document back into this one.
the point of all this is that if for whatever reason you are tracking
the distant DNA of these contents, look there, in [#cb-022], where the
bulk of this document moved to.




## :[#023] the array scanner narrative

in theory the array can be mutated mid-scan, but this is not tested so assume
it will not work right off the bat. internally this just maintains two
indexes, one from the begnining and one from the end; and checks current array
length against these two at every `gets` or `rgets`.

(leave this line intact, this is when we flipped it back - as soon as the
number of functions outnumbered the number of [i]vars it started to feel
silly. however we might one day go back and compare the one vs.  the other
with [#bm-001])





## :[#024] the string scanner narrative

minimal abstract enumeration and scanning of the lines of a string.
+ quacks like a simple scanner
+ better than plain old ::Enumerator b.c you can call `next` (gets)
    without catching the ::StopIteration.
+ future-proof: maybe it uses ::S-tringScanner internally, maybe not.


### the 'reverse' scannner

it is just a clever way of building a yielder that expects to be given with
`yield` or `<<` a sequence of zero or more lines that do not contain
newlines.
