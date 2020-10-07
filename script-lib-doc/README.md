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
|[#608.13]                  | #wish | argument arity `<like-this>?`
|[#608.L]                   | #hole |
|[#608.15]                  | #prov | #provision: mock STDIN, STDOUT, STDERR must ..
|[#608.J]                   | #refa | can you employ decorators w/o a starting method
|[#608.8]                   | #trak | track places where we render parse error context
|[#608.7]                   | #trak | expression shape: convert category into first line prefix
|[#608.6]                   |       | sunsetted. for now this identifier is retired.
|[#608.5]                   |       | SUNSETTED this one approach to a library interface
|[#608.4]                   | #trak | "mad parse" (whatever that is)
|[#608.3]                   | #trak | in the future DRY up places where you do this common isatty thing |
|[#607.J]                   | #open | this worst bug with cheap arg parse grammar grammar
|[#607.I]                   | #hole |
|[#607.H]                   | #hole |
|[#607.G]                   | #open | sunset the common upstream argument parser module
|[#607.6]                   | #trak | hidden CLI's that use cheap arg parse that are okay
|[#607.E]                   | #refa | there's no way this is right
|[#607.4]                   | #hole |
|[#607.C]                   | #hole |
|[#607.B]                   |       | as referenced |
|[#607]                     |       | [internal tracking] |
|[#606]                     | #open | [the unified diff parser]
|[#605.5]                   | #trak | end state with runs (diff stdout & stderr) moves
|[#605.4]                   | #trak | mock STDIN that plays back lines
|[#605.3]                   | #prov | #provision: coding life is easier if we say you need 5: sin, sout, serr, argv, enver
|[#605.2]                   | #trak | we assume (and occasionally assert) that "line" means "newline terminated"
|[#605.1]                   |       | this one stdout/stderr tracking toolkit
|[#605]                     |       | [external tracking or whatever you want]
|[#604.2]                   | #open | known limitation of our arg parsing
|[#603]                     |       | [the help screen parser] |
|:[#602]                    | #open | track that one issue with argparse (should patch) |




## (document-meta)

  - #history-A.3 (as referenced)
  - #history-A.2 (as referenced)
  - #history-A.1 (as referenced)
  - #broke-out & expanded
