# who should be the option parser receiver?

in light of the grand re-architecting of [#037], who should now be the
receiver for the option parser? surface or mechanics? although going with
mechanics may "feel" right, we go with surface for now, so that user clients
can remain blissfully unaware of the mechanics until they need to. but it
will bring up other issues..
