# about this fixture directory (tree)

## caveats (scope)

- whatever is covered by the participating tests is the
  authoritative reference over whatever is in this document.




## objective of this fixture directory (tree)

to confirm and validate that our [#063.2] help screen scraper works as
intended on the full scope of input cases it will face, we "quarrantine"
particular help screen outputs into plain text files (one file per screen)
so that these tests can operate (and the subject can be developed)
independently of the agents that produce the screens.




## its context in the universe

this fixture node and corresponding asset node was born in [tmx] but
moved to [ze] when we generalized the ability for loading and reflecting
of one-offs, such that these operations can be performed by arbitrary
sidesytesm, not just [tmx]  (for their own mounting of their own one-offs).

as such, to generate these fixtures anew as described near the "manifest"
here would require a full "tmx universe" installation; but since [ze] does
not formally require [tmx]  (nor should it), the ability to re-create these
fixtures as-is isn't guaranteed with a lone installation of [ze].




## our approach in detail

### how the help screen output (fixtures) were generated

at writing (with the target directory existing but empty),

    ./tmx/test/script/05-produce-one-off-help-screens -write-to \
      tmx/test/fixture-directories/dir-03-one-off-help-screen-dumps/generated

the above attempts to generate dumps for all one-offs. options exists to
target only some.

note we did not commit all of the (~28) files generated above.



### we generated a punchlist-style burndown list

it was useful to approach integration of the screens in a pragmatic order.
we lined up the screens into a rough development order (a "regression"
order) simply by starting with those with the fewest lines and working
towards those with the most.

we got the list of files in order with `wc` (word count) piped to `sort`:

    wc -l [..]/generated/* | sort > x

we then changed the order of columns around and simplified the path thru `awk`:

    awk '{ print("echo \"$( basename ", $2, ")\" ", $1) | "/bin/zsh" }' x > \
      [..]/manifest.generated.list



### then,

one-by-one we visually determined whether the help screen was in "color"
(i.e uses ASCII escape sequences) or "black and white", and added a
respective "C" or "b" to each line in our "manifest".



### when we were finished,

we version our "manifest" in part as a record of all the one-offs we took
a snapshot of and verified, and in part so we can reconstruct a regression
order from this list again in the future if it's useful.

we put the manifest "back" in alphabetical order by one-off identifer name
by the rationle that the number of lines in a help screen is more volatile
than the name of any particular one-off; and so a manifest file in this
order will be more resilient against the future.

(but note we have kept the line numbers as a field in the file, for
something of a snapshot.)




## document-meta

  - #tombstone-A: the dump (slice?) added in this commit replaces a
    similarly purposed single file that predates this effort by 18 months
