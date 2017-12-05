# the melt narrative :[#063]

## introduction

melt is insanity. turn every '#todo' in the codebase into an open node
in the manifest - ** and change the code accordingly **. ( i don't know
why but i used to think this was such a big deal. ) ( wait, now that we
re-write it, yes it kinda is. )




## :[#here.B]

Each time you want to change a line in source code, cache up all
the changes you want to make to each line that is in the same file
and patch the file all in one atomic action. (This pattern could of
course be broadened, with some work, to make a patch for a whole
codebase [#028].) (but note it is annoying b/c of the atomicicity
of node ids and you need the correct id for the patch, so you want
to be sure you do it right.)




## :[#here.B]

below, we associate the steps with numbers because their order is
important. we will explain why the order is the order it is in after
the orders are presented.

start a mutable patch session for the content of this one file.
of this file, with each qualifying todo line (i.e it has a message
after it),

  1) create a node (unpersisted yet) via the message
  2) add the node to the collection (now that you have an ID)
  3) add the single line change to the mutable patch.

at the end of the file,

  1) end the node collection mutation session
  2) apply the patch.

in the first sequence: we can't add a line to the patch file until we
know what the ID is. we don't know what the ID is until we've added the
node to the collection, and we can't add the node to the collection
without the message. so we must start with creating a node with the
message.

in the last sequence: if adding a node to the collection only adds
information, while applying a patch to a file takes information away
(and then adds it), we want the more destructive operation to happen
second so that if the other operation fails, no information is lost.




## TODO check for relevance :[#here.C]

You are taking out the todo tag and message from the line, and replacing
it with a node identifer (number). This operation may leave you with
extra whitespace in the remainder of the line. To avoid having obtuse,
unreadable node identifiers, we will fill the remaining available
space with an excerpt from the original message, ellipsified to fit
within whatever space remain in the line.

(parts might get pushed up one day, tracked by [#ba-032])


specifically the algorithm is something like this: add words to the
excerpt so long as the next word would not put your over the limit,
taking into account spaces and ellispes, etc




## :note-210 (detached, hovering)

arrived at heuristically, min num words from msg to
bother including in the replacement line - (too few sounds dumb,

an interesting NLP problem similar to summarization :+[#hu-001]
