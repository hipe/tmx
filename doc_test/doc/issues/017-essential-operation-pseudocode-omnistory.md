# essential operation pseudocode omnistory :[#017]

## objective & scope

something we never did but should have done was this, the first step
of the [#sl-137].G: we decide on what our "essential operation" is, then
write it out in pseudocode. but to get there we'll approach it from even
farther back:




## where we came from

the major shift from the previous version of this is that this one
relies on inference rather than configuration: *all* of these features
that once were specified through configuration (parameters and the like)
we want instead to have the same ends accomplished through a totally
different means.

a major aspect of the previous version was an experiment, and the
experiment was a success: the results were conclusive. our hypothesis
was not sound. the hypothesis was "can we have all of a test file
generated and still provide value for general use?" and the answer was
no.

the strain from this faulted premise was evinced by the ever-growing
set of parameter-functions. parameter-functions were there to compensate
for the lack of information in a code file that was still necessary (or
wished for) in a test file (the interplay between these two files being
essentially the soul of this whole sidesystem). but in practice they
were awful: it was too much API where there should be none.

these are the [parameter] functions that we are eliminating:

  • branch down to core
  • chomp module
  • eponymous const
  • look for t.s
  • output filename
  • setup for regret
  • subject proc

every single one of these existed to tell the code generator to do
something differently than would have been done otherwise. and without
exception, every single one of them (as behavior) is obviated by the
particular innovation of this version.




## the particular innovation of this version

our solution to the problem is to not solve the problem at all, but
rather to avoid it by not creating it. the best substrate for specifying
details about a document is the document itself. so here we will
re-apply a methodolgy we first applied long ago, in the now sunsetted
"code molester" sidesystem.

the idea we are about to present would in theory grant us not only
respite from the smells described above, but it would also allow us
a magic we have only dreamed of: the reverse synchronization.



### the particular innovation of this verison: don't "generate", "synchronize"

hypothetically we can get what we want if rather than generating
documents in a one-way manner (from code document to test document), we
can just edit an existing document with information from the "source"
document.

  => something about the iso one way and the other way


## requirements

in this rewrite what we are imagining is:

  • less stream-oriented, more document oriented (see-1).

  • representation for two kinds of documents (asset and test).

  • the representation has two features. one is that it is lossless.

  • the other feature is that it is editable (in a particular way).



## stab

for a sense of how forwards synchronization is supposed to work,
start with this example:

    asset file              test file before

          A                      D
          B                      B
          C                      E

                             test file after

                                 A (added)
                                 D (uninvolved)
                                 B (modified)
                                 C (added)
                                 E (uninvolved)

we can arrive at the above by these rules:

  • every single node from the source will
    be written as-is into the destination.

  • if the source exists in the destination (by name),
    overwrite the content of that node what that of the
    source. (we won't bother checking if the content is
    the same, probably.) ((B) demonstrates this.)

  • if it does not exist and it is the first item
    in the source, prepend it to the destination document.
    ((A) demonstrates this.)

  • otherwise (and it does not exist and is not first),
    place it immediately after the node that is above it
    in the source (in the destination).
    ((C) demonstrates this.)

  • nodes that (by name) exist in the destination that
    do not exist in the source will remain in the destination.
    ((D) and (E) demonstrate this.)

some characteristics of this set of rules are:

   • the only way that forwards synchronization takes away
     information is when a (B) case overwrites what is in
     the destination. otherwise information is only ever added
     to the destination.

   • whenever you change the "name" (actually description)
     in either the source or destination, the connection between
     these two nodes is broken and when you sync you may end up
     with duplicate content under different names.


## reverse

"reverse synchronization" is the idea that you might want to fix some
code in your *generated* test code and then write that code *back* into
the *asset* document. it's crazy.

for the hypothetical reverse synchronization we would not simply
mirror the above rules because for whatever reason, what we want
in the "reverse" direction is not in complete symmetry with what
we want in the forwards direction. here we want only to "write back"
the content inside the nodes (and in so doing we only support some
kids of dootily hahs..).
