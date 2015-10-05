# the digraph narrative :[#025]

# :#storypoint-35

produce a new graph with the same members and the same associations but all
the directions reversed. (this algorithm or one like it is [#021] repeated
elsewhere.) in one pass accumulate the associations per node, in a second
pass blit them to the new graph.



# :#storypoint-45

create a new subset graph whose members consist of all the members whose
names do not appear on the list `name_a`, nor point (directly or indirectly)
to any of the nodes whose names appear on the list. make a 'black hash' - what
are all the nodes you can touch following the is-a relationships (from parent
to child this time) from the list?



# :#storypoint-55

experimental monadic node merger/getter that results in a (controller-like)
"bound" node (with experimental old-school predicate (`is`) syntax) (it is a
smell to toss our internal node structure around externally?)



# :#storypoint-65

the high level DSL-ish entrypoint for creating a graph. "absorbs"
[ symbol [..]] [ hash ], creating (where necessary) a node in the graph with
one such normalized name for each symbol, and for each key-value pair in any
provided final hash, creates where necessary a node with one such normalized
name for each key *and* another node for each value, and if necessary an
association from the former to the latter. (oh the values can be arrays
themselves, a flat list of symbols that etc.) (it makes a lot more sense when
you see the input data.)

if the second arg is provided it will be called with, for each new node that
is created in the process of this absorption, one *symbol* name of the node.



# :#storypoint-75

merge in a normalized_local_node_name of a node and zero or more target
associaiton names. if a third arg is provided it will be yeilded (with '<<')
each symbolc name that is added to the graph as a result of this operation.



# :#storypoint-85

from the graph's perspective, remove all nodes. doesn't do anything to the
nodes themselves. should be same as constructing a new graph.



# :#storypoint-95

result is a stream that represents the graph "flatly" as a series of edges.
each value the stream produces is an edge object (a copy of internal data).

("edge" is a synonym for "association" in this library.)

each edge has 2 values: the association's source and target symbols.

the order in which these associations arrive from this stream is based
on the order of the datastructure, not e.g a pre-order walk (so just a
loop inside a loop, not recursive).

also (and
perhaps strangely), for orphan nodes that both have no outgoing associations
of their own and are not pointed to by an association, they will each also
have representation in this enumeration, presented as a edge with the target
element being nil. for now we expend memory in order to present orphans in
their original order with respect to non-orphan nodes, but this may change.
