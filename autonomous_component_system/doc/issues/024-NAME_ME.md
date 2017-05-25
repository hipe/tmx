# the perist calls narrative

## prerequisite

see [#007] README for development.




## introduction

this is complex because we made it that way. deletions and insertions
into the list of calls that make up a report are generalized as an
"edit" that could perhaps involve a re-ordering as well as these two
other operations.

if we were able simply to discard all of the report section's child
nodes and rewrite them with the nodes we have in memory, it would be
easy and we could go home.

but we have given ourselves the daunting and perhaps false requirement
that this section of this mutable config document may contain arbitrary
other non-function nodes as well. when we edit the report we want to
preserve these nodes when it is appropriate to.




## the algorithm

partition the existing config file's "report" section into a
grouping we impose here: the section is composed of nodes. each
node either is or is not an assignment. and of those, the
assignment either is or is not a line representing a function call.

partition the section into groups of nodes ("spans") based around
these function calls. each span has one "main node" (the function
call) and the others in the span are children nodes (anything other
than function calls).

each such marshaled function call is parsed. on parse failure, we want
to discard the function call * perhaps * by turning that line into a
comment and placing this whole span e.g at the end or in some otherwise
undefined place within the section.



### defining terms near "function"

identity is not composition. the report may contain multiple instances
of the same function with the same curried args. although we may think
of this as "the same" function, it is being called in two different
places and can certainly have two different side-effects or results in
those various places.

to fortify the point, these various "same"-looking calls may have different
comments around them in the config file, or even different use of
whitespace in how they are represented in the file. two (or more)
different functions in the config file may have the same composition but
it does not mean they have the same identity.

because of what is perhaps a false requirement that we want our
persistence files to be human-readable *and* editable, we have to keep
in mind this difference between identity and composition as we re-write
the file.




## note-25

each span (consisting of a function and N number of non-function nodes)
is partitioned into a list of other spans whose function has that same
composition.

for each function in memory that we want to write back to persistence,
we first consult this hashtable to see if a node already exists for a
function with the same composition. if so we remove that node from the
pool and use it to write back to persistence (with all comments etc
intact).

(if not we create new nodes) (any nodes that are left in the pool at the
end of this process we do something crazy with.)
