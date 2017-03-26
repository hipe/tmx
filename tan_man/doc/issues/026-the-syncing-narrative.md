# the syncing narrative :[#026]

as an exercise we want to know what it "feels like" to process an
incoming graph as a stream and not tree: certainly there are "large"
graphs in the world that we might want to process; we've seen them,
and for such "huge" datasets, needing to read the whole dataset in
as one big tree will certainly be a deal breaker for the significantly
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

this node is a "front" compoent that parses the incoming stream line
by line with the above syntax. with each data item (node or edge) that
it parses from the above, it passes it to a "session" component which
effects the backend manipulation of the graph.
