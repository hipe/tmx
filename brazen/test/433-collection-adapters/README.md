# numbering scheme (per [#ts-001.3])

being that storage adapters are supposed to become brazen's "thing",
we'll take a second to come up with some supposed ordering scheme.

general categories in ascending order of difficulty:

  - text-based, not requiring external processes or sockets
    (other than reads to the filesystem): our "git-config",
    maybe one day "OGDL", whatever else that is this simple

  - everything else

as for whether reddis vs. mysql vs. postgresql vs. couch vs. mongo
vs whatever is harder; we will have to leave this to a case-by-case
basis. this means we might break up categories of datastore:
it might go object-based to relational back to object based
(for example reddis to sqlite mysql to postgres to couch to mongo).

  - git config (031)
  - OGDL (094)
  - reddis (156)
  - sqlite (212)
  - mysql (282)
  - pgsql (343)
  - couch (406)
  - mongo (469)
  - xx
  - yy
  - zz
  - mm
  - qq
  - rr
  - bb
  - nn

we've taken our imaginary list and doubled it in size, out of
deference for how much we know we don't know.
