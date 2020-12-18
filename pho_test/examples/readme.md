Discussion:

Somehow we made it all these years without ever having an "examples" directory
in version control. Always the closest we came was our byzantine assortment of
fixtures directories, that we saw always a superior cultural artifact to a
plain old examples directory (a religious belief that's hard to shake).

It's occuring to us now that in fact a plain-old "examples" directory does have
its own utility value; in practice they can serve as visual tests and tooling,
as well as being essential for didactics.

Probably because of OCD DRY-ism we are going to commit a cardinal sin of using
files in this `examples/` directory for files that are BOTH examples and test
fixtures, but we will consider this a hidden implementation detail of our tests
for now. Mainly we just want to introduce ourselves to the "feel" of having a
directory called `examples/`.

If #eventually this package sees publication, this directory should be at the
top level (and not as it is now under the tests directory). We haven't put it
at the root of the mono-repo only because it's a bit too anemic yet for that.



# (document-meta)

  -  #born
