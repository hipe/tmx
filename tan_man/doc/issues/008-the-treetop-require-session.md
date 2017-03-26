# the treetop require session :[#008]




## [#.A]

maintainting a *global* cache of the grammars we have loaded is
certainly nasty, but here's the justification:

when a client wants to load a grammar (identified by a filesystem
path), we don't want the client to have to worry about whether or not
that grammar has been loaded already. this is exactly the game mechanic
of the platform `require` method, which is why we have named this actor
that.

the constant namespace is constant, and that's just the way it is. once
a constant is set, it must not be set again. we are using normalized
filesystem paths as keys into those constants. if a given path points to
a constant that has already been resolved, we result in that value.
otherwise we attempt to load the grammar, with all the fireworks that
entails.



### even more detail

in "production" we expect that this whole issue is not as much of an
issue as in testing. in testing we call subject once for each test, in
order to produce a parser for the relevant grammar (there are several).

in production we cache the parser class itself away somewhere reasonable
(EDIT - confirm this) so when we call subject  it is when a load is
actuall necessary (i.e only the first time).




# :+#tombstone: overwrought shell stuff
