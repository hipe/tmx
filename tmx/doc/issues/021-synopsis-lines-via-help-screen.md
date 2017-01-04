# synopsis lines via help screen :[#021]

## synopsis

furloughed but interesting. might come back for #open [#018], [#019] & [#020]




## intro

this was strapped on as a pragmatic afterthought, but became excellently
wicked in its way. the general idea is this: for any generic utility of
our that we have written a help screen for, try to derive is (for e.g)
two lines of summary as intelligently as is reasonably possible from the
lines of this help screen.

these are some disparate algorithmic axiomatic and other points:

  • something very similar to this was done at the ancient [#054.1],
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
