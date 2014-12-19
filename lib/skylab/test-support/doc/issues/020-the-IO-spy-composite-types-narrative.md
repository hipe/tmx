# the family of IO spy aggregations :[#020]

this describes and contrasts the different ones. see also [#023] "the IO
spy" for a description of the components these aggregate.


## the IO spy triad

the simplest of the IO spy family [#020], this grew out of one-offs in tests
that were a response to attempting to simplify what was at times an obtuse
or annoying interface for the spy aggregation (whatever it was).

this is merely a struct of three members geared towards the three standard
streams. we may upgrade it from a struct to a class as soon as we need to
but it must always support `to_a`, `values`, `members`.

see IO spy group (below) for a description of its advantages over this.


## the IO spy group

see also the comparable but simpler 'IO spy triad', part of [#020] the same
family - it may be a good fit for specifically testing CLI apps.
however this has the advantage over that that this will maintain the order
of events on these channels with respect to each other, as opposed to
that which may group the events first by channel, and then by order.

this node manages a group of special stream spies, creating each one in turn
with `IO.spy.group#for` with a name you choose for each stream spy.

When any of those stream-likes gets written to (with `<<`, `write`, `puts`,
e.g) and that data has a newline in it, this puppy will create a "line"
struct out of the line which simply groups the name you chose
and the string (the struct hence has the members `stream_symbol` and `string`).

(If you have added line filter(s) with `add_line_map_proc`, this will be
applied to the string before creating the metadata struct out of it.
This might be used e.g. for unstylizing lines during testing.)

With this struct all that this Group object does is push it onto its
`lines` attribute for later perusal by the client.

So effectively what this gets you is that it chunks the stream of data
into "lines", writes these lines sequentially in the order received to
one centralized list / queue / stack.  **NOTE** dangling writes without
a trailing newline will not yet be flushed to the queue and hence
not reflected in the `lines` list. flushing could be provided if necessary.)

this is all just the ostensibly necessarily convoluted way that we spoof a
stdout and stderr for testing.
