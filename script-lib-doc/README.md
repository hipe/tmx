# script lib doc

## objective & scope

a nexus for all things CLI DRY'ed from scripts. the development rubric is
that we let this library evolve practically and iteratively; not as much by
design.




## a fun dilemma: two competing approaches for a library interface

at writing (at #born) we have two competing categories of API for how CLI
clients interact with this library. there's:

  - [#608.5] this one experimental boy (see currently in a `script/`), and
  - [#608.6] our newer, more straightforward "holy 6" (below).

here we introduce the newer way and then compare/contrast PRO's and CON's after.



### the newer way: the "holy 6" :[#608.6]

#### _(don't get attached to the number "6" - it might increase)_

the "holy 6" are 6 attributes typical CLI clients are expected to have:
  - stdin
  - stdout
  - stderr
  - ARGV
  - OK
  - exitstatus

the first four are straightforward and should be familiar to anyone who
has written for CLI (indeed, we call them the `_CLI_4` in an oft-used
glob variable).

(note that `ARGV` is capitalized and not the others, as a point of
specification here. this is mostly due to arbitrary historic details of how
we would access ARGV on other platforms. be advised that we might change this
to lower case for consistency.)

the last one (`exitstatus`) is again something that should be familiar,
but it will tie-in to our discussion of `OK`, which deserves a little
explanation:

although it is not necessary for CLI's to "know about" exit statuses,
we consider its use a best practice. the exit status is an integer that the
CLI will send back to the calling entity. (we consider it a poor practice
for the CLI ever to call `exit()` directly.) so..

the "holy 6" API pattern differs from its [#608.5] forebear fundamentally:
instead of a tightly defined but somewhat obtuse use of a response object
with a `result_values` dictionary and so on; under this newer API, library
functions can simply write to `OK` and `exitstatus` attributes directly..



### PRO's and CON's against the [#608.5] older way

(this section is a stub and I can help expand it.)
(write this when you do #open [#607.c] or just demolish all trace of the
old way.)




## <a name="node-table"></a>the node table

(this is a [\[#002\]] node table.)

|Id                         | Main Tag | Content
|---------------------------|:-----:|-
|[#608.6]                   | #trak | this other approach to a library interface (see)
|[#608.5]                   | #trak | this one approach to a library interface (see)
|[#608.4]                   | #trak | all the places you write this same `--help` regex |
|[#608.3]                   | #trak | in the future DRY up places where you do this common isatty thing |
|[#608.2]                   |       | external tracking |
|[#607.c]                   | #open | probably refactor all [#608.5] into [#608.6] |
|[#607.B]                   |       | as referenced |
|[#607]                     |       | [internal tracking] |
|[#604]                     | #wish | for strong type |
|[#603]                     |       | [the help screen parser] |
|:[#602]                    | #open | track that one issue with argparse (should patch) |




## (document-meta)

  - #broke-out & expanded
