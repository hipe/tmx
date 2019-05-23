"""
a document is ~somehow~ composed of 1 or more fragments. (how those fragments

came to be "flattened" into this one document is out of our scope here.)

Each fragment has zero or one heading, and then in its body string (lines)
any arbitrary subset of those lines can be a "header" (alla markdown) line
of any arbitrary "depth" (number of contiguous octothorps anchored to the
beginning of the string).

The trick here is how to decide what to do with the different headings
and in-body headers so that they coalesce to make a document that looks
"normal" for the target, but is also built from `body` blocks that look
"normal" in the context of our unwritten standard.

In detail:

  - Every fragment's (any) heading (when present) will express as either
    a heading (line) or the document title.

  - For those fragments whose body copy has headers, their most significant
    depth is one as stored. (I.e., write headers `# like this` normally.)

  - It seems from our current output target that headers of depth one are
    something of an imaginary "reserved" slot that's only used to express
    the title of the generated document, which (in turn) is expressed by us
    only in the frontmatter we produce, not in any headers in our body copy.
    (This is :[#883.3], and should be considered as *not* set-in-stone.)

  - As such, normally a body copy header of depth 1 gets "demoted" to have
    a depth of 2 and so on (at expression).

  - The "head fragment" (first one) in a document will always have a heading,
    and that heading will always be expressed as the document title (and so
    not as a header line).

  - IFF a non-head fragment has a heading, that heading will express as a
    header. This further demotes any body copy headers in that fragment
    by one more level of depth (at expression).
"""

import re


class Document_:

    def __init__(self, fragments):
        self._fragments = fragments

    @property
    def document_title(self):
        return self._fragments[0].heading  # guaranteed per [#883.2]

    def to_structured_lines(self, listener):
        return _SLs_via_fragments(self._fragments, listener)  # SL=struct. line


def _SLs_via_fragments(fragments, listener):  # SL = structured line
    """you can't output any until you've processed all.
    """

    frag_iter = iter(fragments)

    frag = next(frag_iter)  # assume at least one fragment per document

    assert(frag.heading is not None)  # guaranteed per [#883.2]

    for sl in _SLs_via_body_with_header_adjustment(1, frag.body):
        yield sl

    for frag in frag_iter:

        # each subsequent fragment is NOT guaranteed to have a heading
        s = frag.heading
        if s is None:
            # if it does NOT have a heading (Case121)..

            # add ONE to the depth of every header so that headers of
            # depth one become #[#883.3] depth two.

            for sl in _SLs_via_body_with_header_adjustment(1, frag.body):
                yield sl
        else:
            # non-first fragment headings get our shallowest header depth
            # #[#883.3] which is depth two (Case115)
            yield ('header', 2, s)  # ..

            # since we are using the heading as a header, hopefully it will
            # be unsurprising that we want any actual headers in the body to
            # have a depth that is subordinate to the header for the whole
            # fragment.

            for sl in _SLs_via_body_with_header_adjustment(2, frag.body):
                yield sl


def _SLs_via_body_with_header_adjustment(add, frag_body):

    for tup in _structured_lines_via_body(frag_body):
        typ = tup[0]

        if 'header' == typ:
            depth, rest_string = tup[1:]
            _use_depth = depth + add
            yield('header', _use_depth, rest_string)
        elif 'pass thru line' == typ:
            yield tup
        else:
            assert(False)


def _structured_lines_via_body(body):
    for line in _lines_via_big_string(body):
        if '\n' == line:
            yield ('pass thru line', line)
            continue
        char = line[0]
        if '#' == char:
            md = _header_rx.match(line)
            begin, end = md.span(1)
            number_of_octothorpes = end - begin
            rest = md[2]
            # --
            yield ('header', number_of_octothorpes, rest)
            continue
        if '[' == char and _footnote_definition_rx.match(line):
            cover_me('runs of footnote')
        yield ('pass thru line', line)


_header_rx = re.compile('^(#+)(.+\n)$')
_footnote_definition_rx = re.compile(r'^\[[0-9a-zA-Z_]+\]: ')


def _lines_via_big_string(big_s):  # (copy-paste of [#610].)
    return (md[0] for md in re.finditer('[^\n]*\n|[^\n]+', big_s))


# == coming soon: document_fragment_via_definition ==


class _DocumentFragment:  # #testpoint

    def __init__(
            self,
            identifier_string,
            heading,
            heading_is_natural_key,
            body,
            parent,
            previous,
            # next ..
            ):

        self.identifier_string = identifier_string
        self.parent_identifier_string = parent
        self.heading = heading
        self.heading_is_natural_key = heading_is_natural_key  # not used yet..
        self.body = body
        self.previous_identifier_string = previous


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #born.
