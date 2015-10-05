# how nodes are generated :[#014]  (formerly "the specer narrative :[#025])


(reminder to self: this document continues the narrative started in [#015])


## introduction


in order to produce test code from comments, doc-test models the
relevant parts of your content in intermediate representations of
unit-test-like paraphernalia that are intended (on paper at least) to be
independent of specific testing libraries. these "nodes" then get fed to
an output adapter which renders them as the final output file.

these "nodes" represent the various testing paraphernalia like contexts,
before blocks, and examples. these nodes are generated from streams of
spans. spans are either of the `text_span` or `code_span` classification.

these parsing rules (and corollaries) apply to this end:

• multiple contiguous text spans have no meaning to us and as such only
  the last one is ever regarded (where text spans are used; if this is
  even possible given upstream parsing logic).

• a code span without an immediately preceding text span has no meaning
  to us and as such will be ignored.

• a trailing text span in the comment block has no meaning to us and
  will effectively be ignored. (but use these anyway whenever they
  bolster your coment).

what the above amounts to is that what we are typically looking for is
the pairing of one text span followed by one code span. this is the kind
of thing that makes up several kinds of node.




## how examples are built

for a code span to be considered an example, for now it has to have the
magic "# =>" sequence somewhere in it.

here is a minimal example of generating an example:

    this is some code

    # the hello symbol equals the hello symbol:
    #
    #     :hello  # => :hello


the above input has one comment block which has (what parses to) two text
lines and one code line, i.e a text span and a code span.
so, the above input generates the following structure:

    + example node with description "the hello symbol equals the hello symbol"

the output adapter is expected to render such a structure accordingly.
other, more interesting examples will be provided below.




## how description strings are produced

in doc-test's conception of them, each of describe blocks, context
blocks, and test cases have exactly one description string. conversely
if a description string cannot be resolved from the input for the
particular element of test paraphernalia it is "trying" to make, then
that particular element is incomplete and cannot be outputted.

these are the paraphernalia structures that have description strings:

  • the describe block
  • the context block
  • the test case

the describe block's description by default will be generated (somehow) by
the input file path, possibly.

for context blocks and tests, these are the rules for how description
strings are produced: the lastmost text line before the firstmost code
line will be used as the input description line.

for contexts (that by definition have before blocks and/or `let` terms),
the text line used is the lastmost text line before the firstmost code
line that became part of the before block and/or `let` term.

for test cases, the text line used is the lastmost text line before the
firstmost code line that went into the test block.

as a corollary of the above, any trailing text lines in a comment block
are effectively ignored (but they are nonetheless encouraged to exist
when they make the inline documentation stronger).


### transformations on description strings

once an input text line is resolved by the above rules, it furthermore
undergoes the following translations:

  • any trailing line delimiter sequence is removed

  • any trailing ":" or "," is removed

  • any leading { "so" | "then" } [","] " " is removed

  • any leading "it " is removed

  • any leading "it's " is transformed to "is "

the above are cumulative, so for e.g "so it " becomes "".

the reasons behind the ":" is this: because it is so often used in our
documentation right before a code example, it becomes redundant and
noisy always to include it in the output.

the reason behind the "it "-related rules is because it reads better in
spec-like output not to repeat the "it" term in the description string
given that for test examples the word `it` *is* the method name (but note
we may move this logic and logig like it up and out to the output adapter).

the reason behind the "so " rule is because "so" is often used as a
connecting word to a text line (inteded for description) that comes
after a series of one or more text lines not intended for description.
this makes such lines read better in both of their two modalities (code
file and spec file).




## how "before" blocks (and supporting ancillary nodes) are built

this approaches or perhaps surpasses the limit of decency of what
should be attempted with something like doc-test. all features are
experimental.

if the first "code-block" in a comment block does *not* have a
"magic predicate sequence", and there is at least one other subsequent
test block in this comment block, this code block will be output as a
"before-block".

but it gets worse:

if the first content character(s) of the code block is [A-Z] or "class "
or "module " it will produce a `before :all` block, otherwise it will
produce a `before :each` block.


here is an example of a minimal before block:

    this is some code

    # subclassing Foo is really fun:
    #
    #     class Bar < Foo
    #     end
    #
    # then, build your Foo subclass instance like normal:
    #
    #     foo = Bar.new
    #     foo.wiz  # => "waz"


the above input generates the following structure:

    + a context node with:
      + a before all block
      + an example node with the description "build your Foo subclass instance like normal"



### the `let` hack

any trailing content lines of your before block that look something
like `/\A[a-z_]+ = /` will be converted to `let` expressions.

here is an example of the `let` hack:

    this is some code

    # wizzie wazzie
    #
    #     some thing that happens before each
    #
    #     oh_hai = My_Thing.new
    #
    #     oh_hey = ha hooie
    #
    # jimmy jam used to be in janet jackson's band
    #
    #     1  # => 1

the above input generates the following structure:

    + a context node with:
      + a before each block
      + a let expression
      + a let expression
      + an example node

that's all!
