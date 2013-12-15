# the ghost modules of autoloader explained :[#041]

basic autoloading is the first and only facility to be made available out of
the box to all nodes in the skylab universe. as such, its module is put one
level under the toplevel module ::Skylab [sl], as ::Skylab::Autoloader.

the extended (and sometimes experimental) autoloading facilities -- things
like autovivification and recursion -- are given a home under MetaHell [mh],
which at present feels like an approrpriate semantic fit. as such, all of
the implementation for these live under ::Skylab::MetaHell::Autoloader. note
there are now two (2) distinct constants (modules) with the local name
'Autoloader'.

why are those semantically similar things in two different places?
because the extended behavior "feels" like it belongs in a library subsystem,
we put it there. it "feels" bloaty having all of it crammed under a prominent,
high-level node. but we don't put all of it there, because, as is stated above,
basic autoloading is a facility depeneded on universe-wide, and subsystems
are by definition not universally visible.

but in practice it is useful to conceptualize the basic autoloading as being
"logically" housed under [mh] even though it is "physically" housed under
[sl].

these, then, are the corollaries of the above:

  • *all* unit tests for autoloading, including basic autoloading and its
    child behavior nodes (like inflection), live under [mh], inline with
    all the other subsystem test suites.

  • ::Skylab::MetaHell::Autoloader becomes a "ghost" of ::Skylab::Autoloader:
    it is *not* merely a reference to the other - it needs to know its own
    location distinct from the first, for e.g. Rather, we include the one into
    the other so that its constants are accessible that way (this mitigates
    our need to use fully qualified names or "import" the constant explicitly,
    at risk of hiding what's really going on.) but the uptake is, note that
    the real ::Skylab::MetaHell::Autoloader has no real content of its own:
    it exists to pull in constants defined above it, and house modules below
    it.

  • one gotcha is that there end up being three (3) modules with the local
    name 'Autoloader': one, immediately under [sl]; two under [mh]; and three
    is the taxonomic ("folder-like") module under the TestSupport module for
    mh[]. use fully qualified names as necessary, or when verbose clarity is
    useful.
_
