# the test library node called "expect screens"

## objective & scope synopsis

  • is a reconception of "expect interactive"
    * seeks to be a replacement for it (details below)

  • is intended *not* to be used for anything ther than zerk interfaces

  • uses the "dangerous memoize" pattern




## details

it is necessary to be able to test these interactive, command-line based
applications as produced by "zerk". the problem is exactly like the problem
of testing interactivity in a web browser (although much simpler) and
our effort at a solution is inspired by the efforts in that space.

our previous solution fore this was "expect interactive" which had
significat, (show-stopping) emergent shortcomings as a byproduct of its
intrinsic design traits:

  • it runs the system under test in a separate process, making
    interactive debugging there impossible and stack traces difficult to
    see on the system under test.

  • the use of `select`, while necessary under such an architecture; was
    both clunky and expensive.

this reconception, then,

  • runs the system under test in the same process as the tests

  • the system under test's STDIN is stubbed to provide canned answers
    per the DSL defined by the subject library - each test context is defined
    as a sequence of strings representing lines of input for that
    scenario. (as before)

  • the system under test's STDERR (STDERR is the only output stream
    used by zerk, because semantically a zerk interface's output is
    UI-centric and informational; it is never data payloads that should
    be redirected somewhere) .. its STDERR will be mock-like: the
    sequence of bytes (sometimes in the form of lines thru `puts` but
    sometimes also occuring as `write`) will be partitioned to coincide
    with the "input moments" from writing to STDIN.




## anaylsis

this seems to work well except for the nasty part where we throw..
