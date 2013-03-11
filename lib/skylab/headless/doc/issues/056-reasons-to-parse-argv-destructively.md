# reasons to parse argv desctructively

tl;dr: "parsing argv is often descructive because it facilitates
  agnostic progressive chaining"

details:

conventional practice holds that when you call a method, it does *not*
mutate the parameters unless it is very explicit about doing so.

when it comes to parsing e.g `ARGV`, however, (and the same idiom will
apply to other parsing applications), we often do it destructively (e.g
we typically shrink (or otherwise (4)) the length of ARGV, ideally
down to zero), for the reasons that in our (1) chaining, when we are
trying to be (2) progressive it allows to be (3) agnostic.

(Now, before going on it bears pointing out that when we talk about
mutating `ARGV`, it need not be the literal actual global `ARGV` that
is getting mutated: it is just an abstraction. but from the perspective
of all nodes including the rootmost node, all they know is that they
have an `argv` and that they should mutate it.. which brings us back
to the point being made which is "why?":)


(1) what is meant by "chaining?"

by "chaining" we mean that ARGV consumers typically make up a chain
(or "sequence" if you prefer), often resolved (progressively!) from a tree.

The first consumer of ARGV is the "modality client" (or "application" if you
prefer) and then, usually from the first argument in ARGV it resolves
a node that it itself a consumer of ARGV, and (either effectively or
literally) passes control on to that node, and possibly so on,
recursively.

Each of these nodes forms an element in a chain until you hit on one
node that doesn't do this any more (the terminal link as it were), in
which case the request is typically finished being processed and
it can collapse down to a response / result.


(2) what is meant by "progressive"?

As mentioned in the intro we want our chaining to be "progressive".
This simply means that it is not "atomic", that the parsing happens
in discrete steps. It is not that we create one big regular expression
and parse the ARGV all in one go (in most cases, anyway) --
each node gets a chance to chip away at it bit by bit.

(If, however, you need your parsing to be "atomic" at some level,
you can accomplish this and still fit within this paradigm by
duping `ARGV`, parsing the dupe, and then mutating `ARGV` iff
your parse was successful. Some of our client libraries have employed this
algorithm in the past).


(3) so what does the "angnostic" mean in "agnostic progressive chaining?"

By being "agnostic" it means that we don't want the side-effects of
our operations to assume any particular frameworks or libraries.
The only given is the almighty mutable array. If we had to rely
on meaningful return codes, on emitting particular events, on resulting
in some sort of struct or object, it would couple us too tighly to
that solution. By relying only on this one simple policy stated here
it allows nodes from one client libary to interoperate relatively
smoothly with nodes from a different client libary, something we
do ad nauseum!

~ yay! ~
