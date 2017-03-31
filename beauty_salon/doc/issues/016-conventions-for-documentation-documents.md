# conventions for documentation documents

## intro

(the purpose of this document is to hold the next section so this section
is just a placeholder sketch.)

  - usually markdown, but hypothetically any format

  - an individual document should not be "too long" (>1500 lines) or "too short" (<15 lines)

  - we have our own weird custom markup conventions that should be documented
    eventually..




## philophy of documentation..

is a bit beyond the scope of this document. suffice it to say documentation
can be a liability just as code can be.




## introduction to emerging T.o.C conventions :[#here.2]

we have an emerging set of conventions for how they are ordered and how
the identifiers of their sections are allocated and what they mean:

  - the toplevel sections of a document sometimes (but not always)
    get their own sub-identifer to the document; where if the document
    has the identifier `[#999]`, a section might be identified with
    `[#999.A]` or `[#999.2]` or any other similar identifier. (note that
    within any document, we only use its actual number once in the first
    line of the document, and thereafter use `[#here]` to signify the
    identifier of the host document.)

  - new letters/numbers are allocated in happenstance order; i.e, when
    we need a new identifer we select the next available one from the
    "pool" of available letters/numbers.
    (sometimes we "placehold" identifiers, which we won't get into here.)

  - every letter and its corresponding number (1-26) occupy the same "slot"
    ("A" and/or 1, "B" and/or 2 and so on) such that if you're using any
    particular letter, then its corresponding number is not available and
    the reverse. whether you should use the number or the letter to refer
    to a given "slot" is determined in this way: typically a sub-identifer
    starts out using the letter, and if you ever find that you want to refer
    to that sub-identifer from somewhere outside of the host sidesystem, we
    "upgrade" it from letter to number.

    this way, if you're ever shuffling sub-identifiers around, you know that
    those that are numbers are more of a hassle to change. related detail
    in the next bullet.

  - ocassionally if even more OCD is desired, we start out using a lowercase
    letter IFF a section is referred to only from within the same host
    document. then if we need to refer to it from somewhere in the host
    sidesystem, we "upgrade" it to an uppercase letter. and see the previous
    bullet. (you will also see the "#hereN" pattern used similarly to
    refer to different points from within the same document.)

  - when you run out of letters, it's probably time to break a large
    document out into smaller documents. "aesthetically" (and perhaps
    arbitrarily), 5-6 sections "feels like" a good number, 12 sections
    is "plenty". beyond this we don't proscribe what to do here.

  - but here is the most important point: the order in which the sections
    appear in the table of contents should correspond to the order in which
    the sections appear in document; and it is this order that is the
    "suggested narrative order" that the sections are meant to be presented
    in to the new reader. although they are often spuriously related, this
    order does *not* correspond directly to the lexical order of the section
    identifiers (because it's natural during the lifecycle of a document
    to start a new section at arbitrary narrative points).




## formatting of the markdown itself

we use markdown headers, bulleted lists, code sections, and other line-level
styling (emphasis, keywords) in hopefully unsurprising ways.

  - in older documentation we accidentally used an actual bullet glyph
    at the head of items in bulleted lists. this #todo needs to be corrected
    globally.

  - for better or worse we only ever use a "level one" header in the
    first line of the document. (hypothetically this would allow several
    documents to flow together in for example one long web page.) (but
    under that rational there would be nothing wrong with using multiple
    level-one headers in a document, but meh.)

  - "level two" headers indicate "toplevel" sections. these headers should
    have exactly four blank lines before them (as the host section of this
    copy does.)

  - "level three" headers (which occur much less frequently that level two
    headers) should have exactly three blank lines before them. (nothing
    similar is proscribed for level four headers and below.)




## "document meta" sections

this is a weird one:

  - sections such as these (if to be used at all) must occur as the
    last section in the document.

  - as is the case with the host section of this body copy, such sections
    should consist primarily of a bulleted list.

  - the first line of each item in the bulleted list is not meant to
    be edited *at all* after it is first written and comitted to version
    control (where applicable). these first lines use special tags
    that signify the historical significance of an event that occurred
    corresponding to the commit that saved that line.

  - fortunately for us, it just so happens that we have an actual
    "document meta" section after this one:




## document meta

  - #born to hold the explanation of the numbering scheme near
    table of contents (about sub-identifiers, which is relatively new); but
    note that most of the conventions explained in this document pre-date
    this articulation of them by years and years.
