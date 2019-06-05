# script lib doc

## objective & scope

a nexus for all things CLI DRY'ed from scripts. the development rubric is
that we let this library evolve practically and iteratively; not as much by
design.



### our :[#608.6] "holy 6" internal API for CLI components

#### _(don't get attached to the number "6" - it might increase)_

(there used to be an [#608.5] older way but at #history-A.1 it was sunsetted.)

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

(the client can use `@property` ..)




## <a name="node-table"></a>the node table

(this is a [\[#002\]] node table.)

|Id                         | Main Tag | Content
|---------------------------|:-----:|-
|[#610]                     |       | line stream via big string
|[#608.7]                   | #trak | track fellows whose CLI exitstatus is "guilty til proven innocent"
|[#608.6]                   | #trak | this other approach to a library interface (see)
|[#608.5]                   | #trak | this one approach to a library interface (see)
|[#608.4]                   | #trak | all the places you write this same `--help` regex |
|[#608.3]                   | #trak | in the future DRY up places where you do this common isatty thing |
|[#608.2]                   |       | external tracking |
|[#607.B]                   |       | as referenced |
|[#607]                     |       | [internal tracking] |
|[#604]                     | #wish | for strong type |
|[#603]                     |       | [the help screen parser] |
|:[#602]                    | #open | track that one issue with argparse (should patch) |




## (document-meta)

  - #history-A.1 (as referenced)
  - #broke-out & expanded
