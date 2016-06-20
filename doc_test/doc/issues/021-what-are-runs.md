# toward usage: "discussion runs" and "code runs" [#021]

every line of a comment block is either part of a "discussion run" or a
"code run." when we say "run" we simply mean a contiguous series of
lines of that kind (all within the comment block).

the TL;DR: of it is that an "indentation" of four (4) or more characters
expresses a boundary between a discussion run and a code run. for most
purposes it is probably sufficient to just remember this rule and things
will hopefully "just work".

but as simple as this rule may sound, what exactly is meant by it
and what its ramifications are can be surprisingly elaborate when you
have to implement it, as this document will show.

before we drill down any further, let's look at this simple example:

    hello i am some of your real code

    # hi i'm discussion line A
    # hi i'm discussion line B
    #
    #     1 + 1  # => 2

    more real code ..


despite its near minimality, this example gives us enough to keep busy
for a while:

    • the subject sidesystem only cares about what's in your
      comment blocks; i.e we're only looking at those four
      lines that start with '#', not the "real code" lines.

    • the first two of those lines are "discussion" lines. (how we
      arrive at this is explained later.) being as they are
      "discussion" lines, they are part of a "discussion run."

    • that blank comment line (the third comment line), that gets rolled
      into the discussion run too, because (as a rule) if you are in
      a discussion run and you hit a blank line, it's included in the
      discussion run (and so on for each such blank line) (#coverpoint-1).

    • that last line is a "code" line (part of a "code run", which in
      this example is only one line long). again, how we determine this
      is explained soon below.

so the question then becomes: how do we discern between a discussion
line and a code line? the short answer lies in the indenting: the
boundary between one run and another is created (only) by a "significant"
change in indent.

what this means exactly depends on which kind of run you are in. if you
are in a discussion run, then you transition to a code run (only) by an
increase in indent by four (4) (or greater) characters from the indent
of the above line. (indent is defined more formally soon below.)

conversely, when you're in a code run the transition back to a
discussion run is signalled (only) when the indent level goes back to
what it was last was at the last discussion run (or less). (#coverpoint-5)

as with discussion runs, in a code run any blank line encountered will be
rolled into that code run. (#coverpoint-6)

one small but essential missing piece is this: for each comment block,
the parsing always categorizes the first "contented" line of that comment
block as a discussion line and begins a discussion run with that line as
its first line. this is how we arrive at an initial level of indent from
nothing.

(what we mean by "contented" and what happens when all N lines of a code
block have no content, that is an edge case that is the subject of tests
only and we won't give it further discussion here. (#coverpoint-9))

with this algorithmic step of always starting things off with a
discussion run, the trade-off is that there is no way to express a comment
block that starts off with its first line being a code line; the syntax
simply does not support it. this is however a worthwhile tradeoff
because as we may see later we never want a code run without a preceding
discussion run.




## defining "indent" pseudo-formally

so one final question is, how do we determine the indent level of a
given line? formally:

  • indent (the kind we're talking about here) is a characteristic
    of only non-blank comment lines. (i.e it is meaningless to ask
    for the indent level of blank a comment line.)

  • the indent of any non-blank comment line is the number of space
    or tab characters between the formative '#' and the first not
    space or tab character on that line after the '#'.

    for example, with a string "  # foo\n" (representing a full comment
    line), EDIT



## an example about indent

recall that a transition from "discussion" to "code" happens when a
threshold amount of change in indent occurs between two *adjacent*
lines. what we didn't state explicitly above is that we keep track of the
"current indent" level, and that it can change from line to line,
as it does in this example (#coverpoint-2):

    some actual code

    # hello, I am discussion line A.
    #  still discussion line (B), because indent increased by 1.
    #     increase indent by 3 from above line. still discussion (C)
    #         but an increase by 4 gets you a code line (this line).

    some actual code


going from code back to discussion is particular too, as in this example:

    #       so you're discussing, right? (doesn't matter how much ind. here)
    #           then POW! here's a code line
    #          so what's this line, then?

while it wouldn't be clear given what we've said so far, the last line
above is a discussion line, because its content begins before the
imaginary threshold line established by the last discussion line.
(it then moves this imaginary line inwards to that point.) (#coverpoint-3)
_
