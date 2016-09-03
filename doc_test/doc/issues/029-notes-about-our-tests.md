# notes about our tests :[#029]

## :#note-4

to fit with the API for a generated [ze] client to "express" these,
we use [#ze-025] whose semantics (`express_into_under yielder, expag`)
might seem weird because

  A) the emissions we do make go up through the modality client via
     its listener; we do not write directly to the output yielder
     here and

  B) the main "expression" we do is really into the filesystem at
     this point.

so we hide that weirdness here because there is a chance that that
remote API point may evolve to fit scenarios like this; however at
writing we think that the remote #hook-in method API is a good,
one-size-fits most solution.

as for the suject (test support method), there's no good single
support library to put this in - we want it in both magnetic tests
and API/functional tests.




## :#note-1

during development of a gem we often swap-out the gem in the gems
directory with a symlink that points to the development version of
that gem (in our our "project directory" or wherever).

a side-effect of this is the filesystem path that any given file
resolves for itself through the use of `__FILE__` will vary based
on whether the file is "in front of" or "behind" the gem boundary.

that is, imagine a test file that we run from the command line. it's
a plain old file on the filesystem that we invoke "directly". this
file is what we're describing as being "in front of" the gem
boundary. this file and any files loaded relative to this file can
know their own "real" filesystem path thru the use of the `__FILE__`
magic.

but that test file always loads the core test support file, and that
file always loads the gem. once we load that gem, the files that are
loaded from the resources in that gem will be "behind" the gem
boundary. this means that when they use the `__FILE__` reader they
will resolve a path that is under the symlink, not the "real"
directory.

ANYWAY - what happens next will AMAZE you: we walk upwards
*backwards* from the *end* of the path trying to find a directory
that A) we assume is guarateed to be found and B) won't have a
name-change based on what we described in the above. that directory
is `test`. by this means we convert the real filesystem path to the
corresponding path that is under the symlink directory.

the silliness with reversing the string at the beginning and again
at the end is only because our "path entry scanner" is written to
work in the manner most string scanners work: from the beginning of
the string to the end. if we cared about the cost of this we could
try to write a scanner that scans from the reverse but A) we don't
and B) internally we use ::StringScanner which doesn't do this
either, and while scanning for ::File::SEPARATOR from the end of the
string is trivial enough, like we said we don't care :P





## :#note-2

the "resolve test directory" magnet given a search for "X" under
"/a/b" will check for "/a/b/X", "/a/X" and "/X" *regardless* of
whether "/a/b" and "/a" exist. we *cannot* sanely cover the above
for the myriad noent cases without mocking the filesystem, something
that for now we abstain from in the interest of simplicity.

but we can at least cover one of noent cases if we add this check
here. whether this check should be moved to the magnet is an open
question.





## :#note-3

kinda fun but kinda scary - accepting that our units of work might
be expressed in any arbitrary order separate form the order in which
the stream produced them, but yet *ALL THE WHILE* writing to *THE SAME*
event log - what we'll do is: when *ANY ONE* of these units of work's
emissions are requested, *ONLY ONCE* per unit of work will we use this
tailor made "shave" (basically pop) method of the event log to
*REMOVE* those emissions and memoize them into the associated tuple.




## :#note-5

these tests use a mocked system but a real filesystem, an arrangement
that has particular justification and particular consequences. first,
the justification:

  - mocking a filesystem (tree) feels cludgy when the real filesystem
    is so much better at being a filesystem (tree), in terms of
    ergonomics and transparency - using a real-filesystem (tree) as a
    test fixture requires zero prerequisite API knowledge.

  - similarly but conversely, using the real system feels too cludgy
    when our only interaction with git is a few `git status` commands:

      - "shipping" with a fixture "project" is not really feasible

      - touching/producing such a project on-the-fly seems like overkill

      - using the selfsame project is nasty:
        - we should not assume that the installation against which the
          tests are being run is a git checkout
        - some tests need to modify the files under version control.
          doing this against "selfsame" files seems really wrong.

when using the real filesystem and executing a test case that under normal
execution is expected to modify those files, we have at least two choices:

  1) have a "fixture tree" representing a filesystem tree with structure
     and content that reflects a particular starting state for a one or
     more tests; copy this whole structure recursively to a mutable,
     temporary location; execute the operation against this temporary tree;
     make assertions against this temporary tree; then (during test cleanup)
     remove the whole tree ("recursively").

  2) rather than copying the whole tree recursively, allow the test to
     modify the *original* (and only) copy of the fixture tree (yes the
     one that is part of the distribution, i.e in version control) and then
     after the operation under test has been executed and the assertions
     have been asserted, carefully restore this tree to its original state
     (byte for byte).

the (2) way is kind of crazy, but has the advantages that for simple
scenarios it requires less code and executes faster. however care must be
taken when developing this way that you are always able to restore the
tree to its pristine state when an unexpected fatal error occurs before
the test can restore it.
