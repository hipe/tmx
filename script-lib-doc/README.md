# script lib doc

## objective & scope

a nexus for all things CLI DRY'ed from scripts. the development rubric is
that we let this library evolve practically and iteratively; not as much by
design.



### our :[#608.6] "holy 6" internal API for CLI components

(At #history-A.3 we sunsetted the description of this API. At #history-A.2
we sunsetted the use of the API itself. At #history-A.1 we sunsetted [#608.5]
the related API that preceded this one.)



## <a name="node-table"></a>the node table

(this is a [\[#002\]] node table.)
(Our range is compound: 600-608, then ??)

|Id                         | Main Tag | Content |
|---------------------------|:-----:|---|
|[#608.21]                  | #open | track CLIs that have known bugs
|[#608.20]                  |       | track CLIs in the world that use BSD-style options
|[#608.S]                   | #wish | #feature:just-in-time-parse-parsing
|[#608.18]                  |       | document about new CLI theory & "engine"
|[#608.17]                  |       | FSA about parsing usage lines
|[#608.P]                   |       | curses yikes: a point about focus
|[#608.15]                  | #prov | #provision: mock STDIN, STDOUT, STDERR must ..
|[#608.M]                   | #prov | curses yikes: #provision: topmost interactable starts as selected
|[#608.L]                   |       | curses yikes event model
|[#608.11]                  | #wish | command aliases
|[#608.J]                   | #refa | can you employ decorators w/o a starting method
|[#608.9]                   |       | [see]
|[#608.8]                   | #trak | track places where we render parse error context
|[#608.7]                   | #trak | expression shape: convert category into first line prefix
|[#608.6]                   |       | sunsetted. for now this identifier is retired.
|[#608.5]                   |       | SUNSETTED this one approach to a library interface
|[#608.4]                   | #trak | "mad parse" (whatever that is)
|[#608.3]                   | #trak | in the future DRY up places where you do this common isatty thing |
|[#608.2]                   |       | [see]  [#608.2.C]: magic names like 'buttons'
|[#607.P]                   | #open | curses yikes: prune unused functions in tests and assets
|[#607.N]                   | #wish | stylesheet
|[#607.M]                   | #wish | conditional buttons
|[#607.L]                   | #open | fix the display issues with the wide unicode gif by using a double-wide space
|[#607.K]                   | #open | curses yikes: disappearing buttons
|[#607.J]                   | #open | this worst bug with cheap arg parse grammar grammar
|[#607.I]                   | #open |
|[#607.H]                   | #open | curses yikes: maybe one day, host directive stipulation in result class
|[#607.G]                   | #open | sunset the common upstream argument parser module
|[#607.6]                   | #trak | hidden CLI's that use cheap arg parse that are okay
|[#607.E]                   | #refa | there's no way this is right
|[#607.D]                   | #open | curse yikes documentation
|[#607.C]                   |       | curses yikes: track this tiny thing
|[#607.B]                   |       | as referenced |
|[#607]                     |       | [internal tracking] |
|[#606]                     | #open | [the unified diff parser]
|[#605.6]                   | #open | [resourceser] needs specification/objective/scope. currently inconsistent & not DRY
|[#605.5]                   | #trak | end state with runs (diff stdout & stderr) moves
|[#605.4]                   | #trak | mock STDIN that plays back lines
|[#605.3]                   | #prov | #provision: coding life is easier if we say you need 5: sin, sout, serr, argv, enver
|[#605.2]                   | #trak | we assume (and occasionally assert) that "line" means "newline terminated"
|[#605.1]                   |       | this one stdout/stderr tracking toolkit
|[#605]                     |       | [external tracking or whatever you want]
|[#604.2]                   | #open | known limitation of our arg parsing
|[#603.2]                   | #open | jagged and flattening help screen desc blocks (see `dp bs -h`)
|:[#602]                    | #open | track that one issue with argparse (should patch) |
|[#601.5]                   |       | [CLI canon]  (placeheld)
|[#601.4]                   |       | [expect help screen]  (placeheld)
|[#601.3]                   |       | [expect treelike screen]  (placeheld)
|[#601.2]                   |       | [expect STD's]  (placeheld)
|[#601]                     |       | (numberspace for testing modules)




## (document-meta)

  - #history-A.3 (as referenced)
  - #history-A.2 (as referenced)
  - #history-A.1 (as referenced)
  - #broke-out & expanded
