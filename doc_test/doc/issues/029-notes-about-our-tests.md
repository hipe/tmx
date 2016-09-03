# notes about our tests :[#029]

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
