TL;DR: space is tight so we had to go crazy allocating case numbers:

This is a special case of re-allocating case numbers for an existing test
suite with many existing cases to get it to fit in a crowded, new numberspace.

Because space is tight and our would-be allocation alogorithm has lots of
small points, all we do programatically is calculate the beginpoints and
midpoints of for each existing test file, allocated proportionally based on
how many test cases each file has.

👉 Start with info from our parent node about number of SA's, widith, center:

py -c 'hw=2500/16;pt=4219;print((pt-hw,pt,pt+hw))'  # half with, point

4063
4219 toml
4375

our space width: 312
number of test cases (including placeholders): 127 (determined below)
space per case: 2.45

👉 Begin the table with e.g `find` from the parent directory of this file:

```bash
$ find . -name 'test_*.py' | cut -c 3- > x.table
```

👉 Write a "label" for each test file so you get:

```bash
$ cat x.table

test_4080_traverse_identifiers.py traverse_IDs
test_4111_traverse_entities.py traverse_entities
..7 others..
```

👉 Order the lines of the file to be in the correct regression order.

👉 Put this perl one-liner in a bash script or perl script as you like:

```bash
$ cat case-list
#!/usr/bin/env bash

file = 'do me'  # the first command line arg, however you wanna sanitize that

perl -ne '/^(?:class| *#) Case(\d{4}(?!\.))/ && print "$1\n"' "$file"
```

About the above means of counting test cases in a file:
  - not language-aware, just a hack (but we exploit that fact for placeholders)
  - Perl is well-suited for this. `awk` lacks captured sub-expressions
    and all the others are more verbose b.c they lack perl's cypticism.

👉 Pipe the output of the above to `wc -l` to get a count of the cases.

👉 Generate another table (or just a report) with the case counts:

```zsh
$ head="foo/bar/baz"  # path to the topic test directory (our parent dir)
$ cat x.table|while read line;do IFS=' ' read -r -A arr<<<"$line";tail=${arr[1]};\
label=${arr[2]}; num=$(./case-list "$head/$tail"|wc -l);echo "$label $num";done

traverse_IDs 10
traverse_entities 7
retrieve 16
body_blocks 11
string_encoder 11
CUD_attributes 21
integrate_multi_line 5
CUD_entities 15
integrate_change_index 19
```

👉 For the total (just informational), `awk` is well suited here:

```bash
$ awk '{sum += $2} END {print sum}' x.other-table
127
```

👉 Finally, run our "space report" on this to get startpoints and midpoints:

```bash
$ cat x.other-table | dir-of-this-file/../script/space-report 4063 4375
```

The above outputs the beginpoint and midpoint of each test file.

By hand (lol) we start at the centerpoint and step backwards and forwards
hopping over a case number every five cases (or four hops), basically.




## note about the sub-directory of tests (note stowed away here)

In the test suite at this node, our progression through CUD is a bit more
nuanced and iterative: across several test files, within each file we run
through CUD in some or another proscribed order, but only for one level
of abstraction (as is reflected in the test names).

Furthermore at times we procede through the verbs in a different order than
conventional regression-friendly ordering of D-C-U for because (in one case)
DELETEs become more complicated in linked lists so we want them later.

All of this is is sort of illustrated in [#868].



## (document-meta)

  - #born.
