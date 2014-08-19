# the melt narrative :[#063]

## introduction

melt is insanity. turn every '#todo' in the codebase into an open node
in the manifest - ** and change the code accordingly **. ( i don't know
why but i used to think this was such a big deal. )




## :#note-110

Each time you want to change a line in source code, cache up all
the changes you want to make to each line that is in the same file
and patch the file all in one atomic action. (This pattern could of
course be broadened, with some work, to make a patch for a whole
codebase [#028].) (but note it is annoying b/c of the atomicicity
of node ids and you need the correct id for the patch, so you want
to be sure you do it right.)





## :#note-170

You are taking out the todo tag and message from the line, and replacing
it with a node identifer (number). This operation may leave you with
extra whitespace in the remainder of the line. To avoid having obtuse,
unreadable node identifiers, we will fill the remaining available
space with an excerpt from the original message, ellipsified to fit
within whatever space remain in the line.

(parts might get pushed up one day, tracked by [#hl-045])




## :note-210

arrived at heuristically, min num words from msg to
bother including in the replacement line - (too few sounds dumb,

an interesting nlp problems similar to summarization :+[#it-001]
