# tagged throughput :[#031]

## objective & scope

the narrative precursor to this is [#012] block, which we may refer to
below as "the reference". our objective is to justify why we conceived
of "tagged throughput" and then to define it semi-formally.




## what is tagged throughput?

this is pretty much the center of the project: our main game
mechanic is that replacements can add or remove line breaks to
matches that themselves can overlap with line termination
sequences (as expounded at the reference).

we must target a rendering agent that:

  • is line-stream-oriented - whatever our "throughput" format
    is here, it must be able to chunk (or otherwise) so that each
    item in such a stream corresponds exactly to one output line.

  • needs to know the following about any given character of
    content in the throughput stream:

      • is it part of a match (or replacement) or is it
        surrounding context (i.e not part of a match)?
        (it must be one or the other.)

      • if part of a match,

        • which match is it part of (in terms of match identifier)?

        • is the match replacement engaged or not?
          (it must be one or the other.)

it bears mentioning earlier than later that we will used this same
"tagged throughput stream" (produced again) per file to write the final
output documents, so any corruption here will likely corrupt there too.

SO, experimentally we propose this (new) format: the "throughput"
will be as a common stream (as before) (i.e the first false-ish
item that the stream signifies that the end has been reached).
but unlike before, the elements of this stream are now simple
primitives as opposed to "sexps".

the items of this stream follow a complicated but discrete syntax with
respect to one another:

  => you are always within either "static mode" or "match mode".
     these two constitute the exhaustive members of a category (not
     classification) system for throughput characters. that is, any
     character in the throughput is a member of exactly one (not zero,
     not multiple) of these categories. (but note this is not the only
     category system we will be using in the subject system.)

     the keywords `static` and `match` signify (among other things)
     which of these modes we are now "in". we call such a declaration a
     "mode categorization" because it declares the mode category of
     whatever characters are about to be emitted (as described below).

  => every such stream must start with a mode categorization.

  => a mode categorization must be followed by one or more
     "character segments". it is these character segments alone
     that will represent each character of (the relevant lines
     of) the source document and/or the replacement text.

  => a `static` mode characterization is followed immediately
     by one or more character segments.

  => a `match` mode categorization is accompanied by two further
     datapoints before its necessary character segments:

         1) an integer constituting the match identifier

         2) a symbol indicating whether or not the replacement
            is engaged (and represented following) - { `orig` | `repl` }

     so it looks like this:

         `match` INTEGER { `orig` | `repl` } { character-segment }

  => this is one type of character segment:

         `content` STRING

     • the content string must never include a
       line termination sequence ("LTS").

     • the content string must be at least 1 character long.
       (i.e if you have an empty string you have no character
        segment to output here.)

  => this is another:

         `LTS_begin` STRING
         [ `LTS_continuing` STRING ]
         `LTS_end`


the "LTS" syntax allows for the LTS itself to be "interrupted"
by a mode categorization: there is only one formal LTS that is more than
one character long, but if this were to have a mode change in
the middle of the sequence (i.e in between its two characters),
we want this fact structurally represented in our throughput. so,
such a change would need to use this special "continuing" keyword
to make it explicit for the interpreting agent to see this is
what happened.

as a contrived but minimally didactic example:

if you were substiting UNIX-style LTS's with DOS-style LTS's by
replacing the empty boundary that preceded a "\n" (but does not
already follow a "\r") WITH a "\r" (whew); and you ran this
against a file with only one line which was empty,

our `tagged throughput` of this "matches block" (which would also
be that of this entire file) would be something very much like:

     `match` 0 `repl` `LTS_begin` "\r" `static`
       `LTS_continuing` "\n" `LTS_end`


`match` says we are about to see content of a match
(or replacement). `0` means its the 0th match (in the block??)
`repl` means we are about to see the replacement characters, not
the original characters. `LTS_begin` mean a line termination
sequence is starting, and the next atom is necessarily zero or
more character(s) of that LTS

when `static` then hits here, it tells us we are leaving the `match`
portion of the tagged characters and entering a non-match portion of
the document. (we could just as soon indicate another `match` here.)
but we are still in the middle of this particular LTS. so
`LTS_continuing` is there to tell use we intend to continue it.
necessarily, character data follows follwed by the `LTS_end` keyword.

the reason the `content` type of character segment does not share
this more complex syntax is because we don't give special
treatment to any other "special" sequences other than LTS's at
present. i.e LTS's are the only multi-character "syntactic
structure" that we are aware of, we are (by design) ignorant of
all others (as we should be).
