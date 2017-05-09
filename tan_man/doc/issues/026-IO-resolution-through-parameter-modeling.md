# IO resolution throuh parameter modeling :[#026]

## micro intro

please buckle up because we're going to be justifying two separate but
related "essential" features of advanced modeling at once, as well as
introducing a domain-specific neologism.

(also, it would appear this is a newer version of content in [#021.B])




## introducing "byte upstream" and "byte downstream" :[#here.1]

as it works out, many (most?) of the actions in this application are
involved with reading from or manipulating The Document in some way.

the most convenient way to approach operations related to The Document
is to classify them in terms of their relationship to reading from the
document and writing to it, as we will do in the next section.

because it can be done and it seems to be pretty universally applicable
to the specific case, we think of reads and writes as manifesting as a
"stream" of "bytes" either as input or as output, as appropriate. (we'll
expand on this point in the next section.)

as a shorter way to say "input stream" and "output stream" (and as a
bit of a nod to language we picked up from `git`), we may refer to
such streams as an "upstream" and a "downstream", respectively.

because (as stated) it might be most useful to model these as streams
of bytes, you'll see us say "byte upstream" and "byte downstream".

finally, it's often useful to use as currency not the streams themselves
but "references" that can produce (and sometimes re-produce) the streams
when needed. so you'll hear us say "byte upstream reference" and
"byte downstream reference" which you can probably safely think of as an
input stream and ouput stream (even STDIN and STDOUT, if you are familiar).

(the final few paragraphs are redundant with (and supercede) their
corresponding ideas in [#ba-062.3] "the byte stream manifesto".)




## more specifically,

in order to read from the document, every such action must resolve a
means of input (a "byte upstream reference") (add, ls, rm).

those actions that mutate the document must also resolve a means of
output (a "byte downstream reference") (add, rm).

(one special classification of actions even introduces a third
direction of "x-put" called "hereput" that we talk about at [#here.B].)

as a bit of an aside, there are actions that may (for certain modality
adaptations) want to customize such parameters to effect a defaulting
of, say, the `pwd` (current working directory); but such a retrieval
of this system "service" must *not* happen from the microservice layer
itself, because it is not appropriate for a true microservice to be
dependent on such a volatile property such as the `pwd`. the relevant
uptake here is that like all other formal associations, these ones
might be customized per modality (near #masking).

more broadly the thing to note about all this is two key points:

  1. that the associations like these (there are several) all have
     characteristics that are part of a common "semantic sub-system"
     (sub-domain) that while pertinent to these actions, is not
     pertinent to what we consider "common associations".

  1. that it would feel folly to re-model these same associations
     (parameters/properties) over and over again for the perhaps dozens
     of actions that all use some subset of these common associations.

for an example of the first point, from the discussion above we might
say there's this idea of a "throughput direction" for an association
to have: some associations might be related to resolving an input (an
"upstream reference"). others might be related to resolving an output
(a "downstream reference"). some associations (as we will see) will
be concerned with both. (and again some will have to do with this weird
idea of "hereput" as discussed below.)

however it is not the case that all associations in all applications
should necessarily even have to "know" what a "throughput direction"
is, much less represent values for this "custom meta association".

for better or worse, all of the above has been heralded as the
quintessential use-case for application-specific meta-associations:

here, then, is the frontier use-case for the "nouveau" rewrites of
both shared common associations (here "parameters") and custom meta-
associations.




## our fundamentals of syncing and this weird idea of "hereput" :[#here.B]

if we wanted to break down the fundamentals of what it means to
"synchronize" ("sync" for short) in our context; we might say it means
to "merge" (somehow) one graph and another graph to produce a third
graph.

for many practical cases, it may be more familiar to imagine a
synchronization as involving only two graphs, where you merge one
graph "into" the other graph.

however, even for such an operation we can still conceive of the
underlying mechanics as involving three graphs with the added step that
the third graph (in effect) replaces the second graph. we might do so if
doing so can provide a useful RISC-like reduction of the problem space.

but none of this should make sense at this point.

because "input" and "output" are household names, we use those as
labels for two of these three formal graphs. because we need one
more label for our one more graph, we (for now) use this weird.
neologism "hereput":

    [ input graph ] + [ hereput graph ] = [ output graph ]

(EDIT an example would be in order)

(#spot1.2 tests this)




## reading graphs in a stream-centric (not tree-centric) manner

as an exercise we want to know what it "feels like" to process an
incoming graph as a stream and not tree: certainly there are "large"
graphs in the world that we might want to process (we've seen them);
and for such "huge" datasets, needing to read the whole dataset in
as one big tree will certainly be a deal-breaker for the significantly
large dataset, whereas stream-based processing could hypothetically
scale "infinitely".

although still on the "backend" the internal datamodel is still one
big tree, that need not be the case in the future.

for now this means hackish regexes and a simplified subset of syntax
we support. in the future etc.

the syntax subset we parse against is something like:

    FIRST_LINE [ NODES ] [ EDGES ] LAST_LINE

each above component has a corresponding *simple* regex written
below. each incoming line is matched against the appropriate regex(s)
which classifies the line, moving the state machine forward when
appropriate. data captured from the match against the line is processed
*at each data line* as it is encountered.

the above means that the import process is not atomic: if a
syncronization for some reason fails midway through, the operation may
still have lasting changes on the internal entity, reflecting whatever
lines were processed successfully.

(but note that the persist operation is performed by the action not the
synchronizing facility so currently such a failure would hypothetically
not write to disk.)




## "features" and ramifications of the hand-written parser

*minimal* provisions are made to ignore some comments and to
unescape some escape sequences in quoted strings, but this is by
no means robust or complete; but rather just a proof of concept.

this will not work for all valid graph files but the syntax subset
is expressive enough for all of our needs: that of expressing only
any labels of nodes and minimal associations ("edges") between
nodes.




## local architecture

this node is a "front" component that parses the incoming stream line
by line with the above syntax. with each data item (node or edge) that
it parses from the above, it passes it to a "session" component which
effects the backend manipulation of the graph.
