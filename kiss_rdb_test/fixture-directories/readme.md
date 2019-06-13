It is the case (isn't it?) that there will be no fixture files not associated
with a particular storage adapter.

(Oops except for "index" files but meh.)

Regardless, this will generally be the case and so at the top level here,
the numbers and names will correspond to etc. (Really there's no reason
to number them at this node but meh.)

Also keep in mind that that most functions ("magnetics") that process "files"
are written with an interface that just processes stream of lines, so they
can be ignorant of the underlying storage substrate (while still streaming).

We can leverage this fact to avoid "fixture hell" by writing the fixture
data directly from within the test cases (usually in cooperation with
`unindent`).

As such you'll see that we can often avoid using this directory entirely
if we want; and typically we just throw one or two files in here (per S.A.)
to make a nominal point of contact with the real filesystem as a sort of
integration test.


Also:

  - 👉 In any given subdirectory, always reserve `000` as no-ent.




## (document-meta)

  - #born.
