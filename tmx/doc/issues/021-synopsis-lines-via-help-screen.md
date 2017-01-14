# synopsis lines via help screen :[#021]

## synopsis

scrape help screens of mounted one-offs for use in [#018.B] deep listings.




## contextualization & intro

this was strapped on as a pragmatic afterthought, but became excellently
wicked in its way. the general idea is this: for any generic utility of
our that we have written a help screen for, try to derive is (for e.g)
two lines of summary as intelligently as is reasonably possible from the
lines of this help screen.




## overview of general rules

these are some disparate algorithmic axiomatic and other points:

  - something very similar to this was done at the ancient [#ze-054.1],
    (originally from [hl]), but it doesn't use
    [#ba-044] our preferred state machine lib so we have rewritten it.

  • you know what "sections" are. we don't formally define them here,
    but the state machine does.

  • "synopsis" is the preferred name for the section we are looking for.
    if any such section is found, use (up to) the first N lines of
    that section.

  • if there is no "synopsis" section but there is a "description"
    section, use (up to) the first N lines from that.

  • if there is no "description" section but there is a "usage" section,
    use (up to) the first N lines from that.

  • given the above 3 points, we must always parse every line of the
    entire help screen UNLESS AND ONLY UNLESS we found a synopsis
    section.

  • for now, we have no fallback behavior if none of the above 3
    sections are found.



## about unstyling :#note-1

it was once an option whether or not to unstylize (#tombstone-A)
but in practice it is never prudent to have this off: the parser
as is (and was) written will fall over for those roughly 1/3 of
~28 screens that style their section headers with ASCII styling.

cleverness is certainly possible here to try to preserve styling
for that content that we extract from the sections, but A) it
would really gum up the pipeline with complexity and B) having
styling *in* the synopsis lines looks too cluttered and
unbalanced anyway.
