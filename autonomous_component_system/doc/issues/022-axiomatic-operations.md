## axiomatic operations :[#022]

## intro

we call them "axiomatic" to stand in contrast to the "formal" operations
that clients of [ac] will typically define.

the theory (that we are testing experimentally at this commit) is that
for every "compoundesque" component (what we often call "an ACS"), there
are upwards of N "axiomatic operations" that we may have to execute
(somehow) on that component
(where N is 4).

a bit like a "RISC" architecture (1990's!), from these axiomatic
operations we define other, highter level operations (namely, the
performers that make up the bulk of this library).




## constituency

they are (again, theoretically):

  1) read a component association given a symbolic name

  2) produce a "streamer" (that can produce streams) of "nodes"

  3) read a component value

  4) write a component value

from these four, we can (in theory) do just about everything we want to
be able to do with the ACS..

the interface details of these are in flux and are the domain of the
respective methods et. al involved in their representation and
execution. but for now:

  • (3) & (4) take as an argument *only* a "asc" (no block),
    and (within this libary) their result is assumed *always* to be
    a "knownness" (perhaps the known unknown singleton).

    * in this library, the association will be assumed to be associated.

    * we anticipate overloading the result of this to be false-ish for
      special circumstances *elsewhere*.

  • (1) results in false-ish IFF the association effectively (e.g actually)
    doesn't exist.

  • (2) is a moving target for sure..
