# IO tee notes :[#014]

## synopsis

Inspired by (but probably not that similar to) Perl's IO::Tee,
an IO::Mappers::Tee is a simple multiplexer that intercepts
and multiplexes out a subset of the messages that an ::IO stream
receives.

Tee represents its downstream listeners as (effectively) elements
of an ordered hash; that is, the order in which they were added is
remembered and they are retrieved by their key, usually a symbol.
(we refer to this structure as a "box".)




## implementation

this is too small for its own file, so we do this weird old trick
to create it dynamically the first time it is used; which regresses
better while avoiding creating a miniscule orphan.




## history

note that the file that originally housed this node became [#024] the
mocks.
