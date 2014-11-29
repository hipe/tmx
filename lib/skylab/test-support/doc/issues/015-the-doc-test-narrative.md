# the doc-test narrative :[#015]


## introduction

doc-test is an experimental for-fun tool that generates test-code from
comments. it is inspired by python's tool of the same name, although we
held off from looking at python's doc-test beyond a cursory glance in
the interest of coming up with ideas in a vacuum and then comparing
notes later when some point of "done-ness" is reached with this project.

currently "doc-test" must be classified as a "hack" because of the way
it parses comments: it does not do so in a langauge-aware way (yet).




## what it is not

doc-test tests are generally not a replacement for unit tests. although
doc-test tests can have high novelty value and are occasionally even
convenient, good regressable unit tests are often too numerous and too
low-level to be doc-test comments without looking silly and making a lot
of noise.

furthermore the fact that the doc-test spec is generated from the
code-file file makes the process too cumbersome when trying anything like
[#sl-129] "three rules-compliant" test-driven development.

after years of working with doc-test, our general rubric is that
doc-test is generally *not* good means of getting something complex to
work, although it *can* be a fun way to prove that something complex
*does* work.  it *is* a good way to demonstrate *how* something works.

for the simplest of classes/modules/functions however, doc-test may be
sufficient all on its own variously for providing coverage, developmental
guidance, and documentation.

that said, doc-test tests can always be a good compliment to good unit
tests, that if nothing else enhance the process of writing a little
comment in your code with a little usage example, by ensuring you that
the code actually works as is documented.




## introduction to the terminology and key concepts

some of your comments in your code may be "doc-test recognizable"
comments.

with such comments doc-test can output a spec-file from your code-file.
such spec-files will exist one-to-one with your code-file. (but this
does not mean you cannot have e.g hand-written spec files in addition to
this generated spec file for the same code file. we have developed
conventions for situations like these.




### knowing "comment blocks"

doc-test scans your document for "comment-blocks".

we intend for a future incarnation of doc-test to accomodate different
forms of comments, for example "C-style" comments demarcated by `/*` and
`*/`. when the time comes such behavior will be realized through the use
of "input adatpers" but that time is not yet now.

as such, the below examples will cover '#'-style comments.

with '#'-style comments, a "comment-block" is the comment-part of any
contiguous span of one or more lines that each have a comment that starts
with a '#' character that is at the same column as the others:

    this is some code

    # this is one comment block
     # this is another comment block


this pattern is "greedy" so it matches as many such lines as it can:

    this is some code

    # this is one comment block that has one line

        # this is another comment block
        # that has two lines. this is the second line.

      # this is a third comment block
      #  although this line has a local margin deeper than above,
      #   and this one too, all 3 lines are part of the same comment block.



one or more blank lines (with "blank" meaning `/\A[[:space:]]*\z/`) will
break a comment block:

    this is some code

    # this is one comment block

    # this is another comment block, because of the blank line above



but a comment line with blank *content* will not break a comment block;

    this is some code

    # this is the first line of a comment block
    #
    # this is the third line of the same comment block.



but comment blocks are only the beginning..




### intrdcution to the structural paraphernalia of test frameworks

this is the structure of a generated test document in the default target
test framework in the eyes of doc-test:


    the describe block
      |
      |- a context block or a test
      |
      |- a context block or a test
      |
      |- [..]



the outputted document always has one and only one describe block.
decribe blocks are furthermore never produced by any other means. so
this means that every generated describe block has a strict one-to-one
correspondence with a spec document, which in turn always has a strict
one-to-one correspondence with an input document (a code-file).

how we generate variously at this level the test nodes or the context
blocks (which themselves contain test nodes among other things) will be
covered below.




### outputted test framework paraphernalia

doc-test was designed from the beginning to accomodate different
output adapters to output test code for different test frameworks.
however currently we effectively hard-code doc-test to output test code
targeting only one framework, because we have only ever needed one
output adatper to date.

(technically this output supports at least two test frameworks, because
the "quickie" test framework that often use has a specification that is a
subset of the other test framework.)

as such a time when it is valuable to do so we will complete support for
different output adapters.




#### outputted paraphernalia for the default test framework

for one doc-test compatible input file doc-test will output the contents
of one complete spec file consisting of exactly one "describe block".
that describe block will contain as its child nodes one or more "tests" or
"context blocks". these constituent items may be intermixed in a freeform
manner, but the describe block will have at least one of them.

"context blocks" if employed are employed to support "before blocks"
and/or "let blocks". before blocks occur in two forms: `before :each`
and `before :all`. every context block will furthermore contain at least
one test.

in summary, the structures are:

  • a describe block
  • a context block
  • a test (in local jargon, maybe "example", "test case")
  • a `before :each` block
  • a `before :all` block
  • a let block

because they are implements of a target test framework, what these
implements actually *do* is outside the scope of this document.
the important point to make here is that doc-test will only output these
structures in a way that makes sense to (to the best of its abilities
which have resonable limitations). this generally means that
if there are no test nodes to output then there is nothing to output.




## how comment blocks are parsed, structure by structure

in order to explain how the various "test paraphernalia structures" are
"isomorphed" from the input, we first cover how each line of a comment
block is parsed, and in so doing introduce the intermediary parsing
structures that are relied upon throughout this pipeline:



### key concepts and elemental structures

  • it bears re-mentioning that currently doc-test is a hack, being
    not-yet language aware: we parse input files for comments in the
    dumb way which to date has been surprisingly OK but is certainly
    fallible and not robust enough to consider this production-ready
    software. however we have localized this vurnerability making it
    irrelevant to the rest of the system, allowing us to move on for now.


  • at the first filter, doc-test transforms an input file into 1)
    maybe a filesystem path and 2) a comment-block stream. the comment
    block stream will produce zero or more comment blocks.


  • a input file with no comment blocks cannot isomorph to a doc-test
    generated spec. that is, such an input will produce no payload
    output.


  • to the pipeline a comment block appears as a stream of one or more
    "comment content lines." on the surface, however, comment blocks
    manifest as the various surface forms of comment, for example
    as C-style comments or '#'-style comments (or whatever other form
    of comment we write input adapters for).


  • a "comment content line" is that part of a single-line comment that
    does not include the comment demarcator sequence (for example '#')
    or any characters before that sequence on the line; and in a multi-line
    comment it is the constituent lines of this comment not including the
    opening "/*" or closing "*/" demarcator sequences, or any of the
    characters outside of them.

    in all cases, a comment content line is zero or more non-newline
    characters followed by zero or one newline sequence. although as
    discussed at [#sg-020] the formal definition of "line" usually
    necessitates a trailing line delimiter sequence, for multiple
    reasons we do not have that requirement here:

      • a comment content line as the last line in a multi-line comment
        does not necessarily have a trailing newline sequence (and in
        practice rarely does). (however, non-final comment content lines
        in a multiline comment do necessarily each terminate with the
        newline sequence.)

      • in the edge case of a file whose last "line" is a single line
        comment with no trailing newline sequence, we still consider
        this a "line".


    this intermediary representation of comment as a series of
    "comment content lines" allows us to speak in the same terms and
    write the same code regardless of what surface form of comment we
    are dealing with.


  • from now on, when we say "line" assume we mean it as shorthand
    for "comment content line".


  • we will employ the concept of a "content character" below. a
    "content character" is any character not in the /[[:space:]]/ class,
    which according to our definition is:

        "Space or tab[ ,]newline carriage return, etc."

    we could not ascertain from the documentation what "etc." means.


  • we will employ the concept of a "local margin" below. generally the
    "local margin" refers to the column of the first content character
    on the previous relevant line. if there is no previous relevant line
    (because for example we are on the first non-blank line of a comment
    block) then the "local margin" is generally considered to be
    (when C-style comments) the column after the opening "/*" or
    (when '#'-style comments) the column after the '#'.

    we can think of the local margin as a discrete scalar (for example
    an integer offset or an ordinal counting number); but in practice we
    won't need to refer to a margin with some actual number. we only ever
    speak of it in relative terms, as being "shallower", "the same as"
    or "deeper than" the local margin of the previous relavant line (if
    any).



### how lines are classified

  • every comment content line will ultimately be classifed as either
    a "blank line", a "text line", or a "code line". these
    classifications are highly context dependant as will be explained
    below.


  • our definition of "blank comment content line" is expressed as a
    regular expression:

        /\A[[:space:]]*\z/

    that is, a string consisting of only zero or more characters in the
    whitespace character class (whatever that is).

    because we are consuming a line stream and the stream is supposed to
    preclude its produced lines from containing the newline sequence
    at anywhere other than the end of the string, we could define this
    pattern more tightly as something like

        /\A[ \t]*\r?\n?\z/

    but we opt for the more readable form and assume it will effect the
    same behavior.


  • any leading blank lines at the beginning of a comment block are
    disregarded. their classification is not memoized and they do not
    mutate the parse state at all except for the fact that their line
    is processed.


  • if the candidate line is a blank line but the nearest above
    classified line in this comment block (if any) is a text line
    (defined below), then the candidate line is ignored (that is,
    we do not even store the classification of this line). ergo text lines
    are never blank lines, and contiguous blank lines immediately after
    text lines are always ignored.


  • given a candidate line that is *not* a blank line (per above),
    this line will have a first content character. if that first
    content character's column is four (4) or more spaces deeper than
    the local margin (defined above), the line is classified as a
    "code line". otherwise the line is classified as a "text line".


  • if the candidate line is a blank line but the nearest above
    classified line in this comment block (if any) is a code line, then
    this line too is classified as a code line. that is, text lines
    *cannot* be blank, but code lines *can*.


  • if the candidate line is classifed as a text line and its first
    content character is one of '*', '+', '-', or it starts with
    /\A[[:space:]]*\d+\./ (that is, it looks like an item in an ordered
    list); we look for a first content character after that sequence. if
    one is found, the column number of this character becomes the local
    margin. otherwise the local margin is the column of the start of the
    first content character in the line (the '*', '+' etc).

    put another way, if your text line looks like a markdown list item,
    the local margin will be determined by the beinning of your content,
    not the location of the bullet character.

    we furthermore experimentally add "•" to this list, although it is
    not markdown.

the above rules of line classification will become relevant when we
define how we turn lines into the larger non-terminal structures defined
below.

this example synthesizes every point from above:

    #
    # the above leading blank line of this section is totally disregarded
    #
    #
    # the above blank lines are discarded because we are in a text span
    #    this line is three (not four) spaces deeper so it is text
    #       same here, still text because it's 3 deeper (not 4)
    #           but as soon as we are 4 lines deeper, this is "code."
    #                         code can go arbitrarily deeply: local margin
    #                         from the last text line holds throughout
    #
    #            the above blank line is code because code span, this line too
    #          but this is a text line again b.c it's 3 in from local margin
    #      this line moves the local margin back by one space
    #                         •    even though very deep, this is text line
    #                                 this too, because new local margin
    #                                     and then here is code because 4
    #
    #
    # above line is code, this line is text, below line is ignored
    #


#### how description strings are produced

in doc-test's conception of them, each of describe blocks, context
blocks, and test cases have exactly one description string. conversely
if a description string cannot be resolved from the input for the
particular element of test paraphernalia it is "trying" to make, then
that particular element is incomplete and cannot be output.

these are the paraphernalia structures that have description strings:

  • the describe block
  • the context block
  • the test case

the describe block's description by default will be generated (somehow) by
the input file path, possibly.


for context blocks and tests, these are the rules for how description
strings are produced: the lastmost text line before the firstmost code
line will be used as the input description line. for contexts (that by
definition have before blocks and/or `let` terms), this means the
lastmost text line before the firstmost code line that became part of
the before block and/or `let` term.

for test cases, this means the lastmost text line before the firstmost
code line that went into the test block.

as a corollary of the above, any trailing text lines in a comment block
are effectively ignored (but they are nonetheless encouraged to exist
when they make the inline documentation stronger).


##### transformations on description strings

once an input text line is resolved by the above rules, it furthermore
undergoes the following translations:

  • any trailing ":" or "," in a description lines is omitted in the output

  • any leading "so " in the description line is omitted in the output

  • any leading "it " in the description line is omitted in the output

  • any leading "it's " in the description line is transformed to "is "
    in the output

the above are cumulative, so "so it " will become "", for e.g.

the reason behind the "so " rule is because "so" is often used as a
connecting word to a text line (inteded for description) that comes
after a series of one or more text lines not intended for description.
this makes such lines read better in both of their two modalities (code
file and spec file).




## "before" blocks

this one approaches or perhaps surpasses the limit of decency of what
should be attempted with something like doc-test. all features are
experimental.

if the first "code-block" in a comment block does *not* have a
"predicate-operator", and there is at least one other subsequent test
block in this comment block, this code block will be output as a
"before-block".

but it gets worse:

if the first content character of the code block is [A-Z] or "class " or
"module " it will produce a `before :all` block, otherwise it will
produce a `before :each` block.

any trailing content lines of your before block that look like
`/\A[a-z_]+ = /` will be converted to `let` expressions.





## :#storypoint-15 notes from the self-generating test

note that this is a test that
rewrites itself, so it is only useful when it does not fail, and is
not useful when it does. note too it is always "safe" to try and
generate test output from this file (e.g to stdout), just not
necessarily "safe" to try and run the resulting test file. the CLI is
essential for development and debugging. whenver the template changes
(in its number of bytes, specifically), this test should fail, only
the first time it is re-run HAHA! so not only is it self-destroying,
it is self-correcting. what a weird useless thing!



## :#storypoint-115

we jump through hoops to allow the system to go through all of its motions
without a path just so that the template options can display without there
needing to be a valid input stream.
