# towards usage: what are comment blocks? [#020]

internally there is a structure called a "comment block" that lies at
the inner working of the subject sidesystem. although this on its face
is an implementation detail, an understanding of comment blocks can
help bring an understanding of how the subject sidesystem is used.

as you probably know, in the platform language we have only one way of
specifying comments: with the '#' character (in particular contexts).

since we're being formal, we'll say that "comment" is defined as the
contiguous series of one or more characters where the first character
is one such '#', and the remaining (zero or more) characters are
whatever characters remain in the "line". (for a formal-esque
definition of "line", see [#sn-020].)

it's of course possible for a comment to occur after code occurs on a
line. by design we don't ever deal with such comments -- for whatever
reason it doesn't "feel" right to apply our special magic to comments of
this kind.

the kinds of comments we care about are those that occur with no code
before them on the line. (note it is still possible for such a comment
to have one or more space or tab characters before the '#'.) we'll call
such lines "comment lines".

so finally, when we say "comment block", what we mean formally is one or
more contiguous comment lines where each such line has its first '#'
character at the same "column" as the others in this comment block. in the
spirit of the subject sidesystem, we explain what we mean with some
examples:

if the '#' changes which column it is on, it forms a new comment block:

    this is some code

    # this is one comment block
     # this is another comment block


every comment line that lines up this way becomes part of the same block:


    # this is one comment block that has one line

        # this is another comment block
        # that has two lines. this is the second line.

      # this is a third comment block
      #  although this line has a local margin deeper than above,
      #   and this one too, all 3 lines are part of the same comment block.



one or more blank lines (where "blank" is `/\A[[:space:]]*\z/`) will
break a comment block:


    # this is one comment block

    # this is another comment block, because of the blank line above



but a comment line with blank *content* will not break a comment block:


    # this is the first line of a comment block
    #
    # this is the third line of the same comment block.



comment blocks (as exhaustively as we have defined them) are only the
beginning step towards understanding how the subject sidesystem
produces "test" documents from "asset" documents. to get there we'll
need to understand the two types of "runs" that we break comment blocks
into. (see [#021] "what are runs?".)




## (internal notes)

(we use [#022] "ELC's", so you're liable to break things if you change
the last "phrase" before the colon before each ELC.)
