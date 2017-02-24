# [x]

## movie ticket metaphor

(quick preamble: the things that we now call "node references" (and
"loadable references") we used to call "node tickets" (and "load
tickets"). so now that we don't call these things "tickets" any more,
the movie ticket metaphor perhaps doesn't ring as much clear salience;
but it is nonetheless an illustrative and ample metaphor.)

how is the movie ticket different than the movie? the ticket (in this
analogy) is the sole means you get to the movie theatre movie. yet
the ticket itself is not the movie: just because you have the ticket
doesn't mean you have seen the movie. in fact it is even possible
that you could have the ticket and never see the movie, as sad and
weird as that would be.

to carry the metaphor further, the ticket is "lighter" than the movie
in terms of time-cost to acquire it, and in terms of how much
information is in it. but as for what you have the potential for in a
deterministic sense, having the ticket is equivalent to seeing the movie.


## the loadable reference then

the loadable reference, then, stands as an adapter between the (mostly generated)
human-facing client (implemented with "frames") and the ACS
component. currently both of the following distinct purposes are served
by this same subject:

  1) so a parent node can know *about* the node (e.g to give it
     screen representation) without having to load every detail
     (resource) of the node.

  2) to interpret, represent and deliver characteristics that this
     modality is concerned with but that the ACS itself is ignorant
     of, like special hotstrings or custom-made UI components.

(a note of history, the subject expression pre-dates "node reference",
which grew conceptually from it.)
