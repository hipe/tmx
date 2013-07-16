# this strange hybrid explained

unlike most other subprodcuts, `bnf2tretop` "ships" as a standalone file
yet integrates with the `tmx` supernode *and* has an extensive test suite,
for which it is superficially structured like a conventional subproduct.

ths cost of such simplicity up there is a bit of complexity doen here:
the script has a `$PROGRAM_NAME` check at the bottom of the file so that
it can be run either as an executable or be used to load the client
without running it, e.g. for being loaded for use by the test suite.

the main script must and should run as a standalone file - all other files
including core.rb and load.rb must and should not be necessary for it to
run standalone. these files exist only for 2 reasons:

1) load.rb creates a wall of API insulation that assuages the
(extensive) test suite's need from having knowledge of this arrangement.
the test suite may simply load this file and then procede ignorantly,
as if this were a conventional tmx subproduct and not a single standalone
file (maybe).

2) given the conditional execution at the end of the script, when running
under the `tmx` supernode this sub-product will not integrate like the
other one-off front-files under bin/ do. left to its own devices, when
run under `tmx`, this suproduct loads and then finishes - that is,
blank screen of death.

this sup-product is a bit of a special hybrid, then (for now) because it
doesn't define a CLI client in a traditional place, yet it doesn't run
simply by loading its front file under bin/. putting the below lines in
allow `tmx` to find and build the client.

the role of core.rb, then, becomes different in this scenario. core.rb is
loaded by the supernode and then it is expected to find a Foo::CLI::Client::
Adapter. core.rb is necessary neither for the test suite to run nor the
standalone script to run.

for some of the same reasons above, we do not load the root `skylab` node
at first in the test setup - we want to be sure that our main file
loads cleanly without depending on *anything* other than ruby. also we
experiment with the different const name casing seen here, for
reasons of #robust-fullness to jangle the loading and name correciton,
and for some of the reasons cited above. whew!
