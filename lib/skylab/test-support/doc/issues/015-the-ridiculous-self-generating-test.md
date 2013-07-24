# notes from the self-generating test

note that this is a test that
rewrites itself, so it is only useful when it does not fail, and is
not useful when it does. note too it is always "safe" to try and
generate test output from this file (e.g to stdout), just not
necessarily "safe" to try and run the resulting test file. the CLI is
essential for development and debugging. whenver the template changes
(in its number of bytes, specifically), this test should fail, only
the first time it is re-run HAHA! so not only is it self-destroying,
it is self-correcting. what a weird useless thing!
