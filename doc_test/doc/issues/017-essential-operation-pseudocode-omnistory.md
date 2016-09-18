# essential operation pseudocode omnistory :[#017]

## synopsis

the actual algorithm is now in [#035]. this has become more history and
context.




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
particular innovation of this version (tentatively). as a sneak peek
of how they are being eliminated (but it won't fully make sense here):

  - branch down to core  - in "recurse", it should be that the software
      will pick the right file. in "synchronize", it writes to stdout.

  - chomp module - with synchornizing instead of generating this is N/A (A),
      and (B) the convention of how we structure now produces files that
      are more structurally consistent with each other (i.e now as opposed
      to then, each test file is generally run from within the same module,
      one such module per sidesystem, not one such module per test directory).

  - eponymous const - no more need to derive these for the same reason as above.

  - look for t.s - obviated by synchronization over generation.

  - output filename - obviated for same reason as "branch down to core"

  - setup for regret  - obviated by synchronization

  - subject proc  - obviated by synchronization





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

  - less stream-oriented, more document oriented

  - representation for two kinds of documents (asset and test).

  - the representation has two features. one is that it is lossless.

  - the other feature is that it is editable (in a particular way).




## our approach to developing the #forwards-synchronization-algorithm

the full forwards synchronization algorithm is made up of pieces that we
created/discovered iteratively, as we tried to apply our theory to our
practice piece by piece.

here we will introduce each of these pieces one by one, and with each
piece (which we my consider a "sub-algorithm") we first explore it in
depth, demonstrating how it is useful to use; and then (where releveant)
we will explore the shortcomings where our conceptual model doesn't quite
fit every detail of our actual model.

then in a subsequent section we will introduce a refinement (actually new
sub-algorithm) and repeat the above steps for that, and so on until our
conceptual model produces behavior that adequately satisfies our design
factors.

finally, we synthesize the sub algorithms into our final algorithm.

as it stands, each of these pieces and then the final synthesis all have
their own dedicated documents. the pieces are:

  1. the fine and dandy sub-algorithm [#033]
  2. the tree-pruning sub-algorithm [#034]
  3. [ maybe something about special anonymous nodes and shared setup nodes ]

we synthesize all of them here: [#035]



### edges

  • reference document is partly or more empty #coverpoint3-5




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
