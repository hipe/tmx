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

    def to_line_sexps(self, listener):
        fi = _fragments_index_via(self._fragments, listener)
        if fi is None:
            cover_me('make sure you use a monitor')
            return
        return _to_document_line_sexps(fi, listener)


def _fragments_index_via(fragments, listener):

    mfi = _MutableFragmentsIndex()
    see = mfi.see_indexed_fragment

    frag_iter = iter(fragments)

    frag = next(frag_iter)  # assume at least one fragment per document

    ifr = _IndexedFragment(True, frag, listener)
    if not ifr.OK:
        return
    see(ifr)

    for frag in frag_iter:
        ifr = _IndexedFragment(False, frag, listener)
        if not ifr.OK:
            return
        see(ifr)

    return mfi


def _to_document_line_sexps(fi, listener):

    is_first = True

    for ifr in fi.indexed_fragments:
        if is_first:
            is_first = False
        else:
            yield _the_empty_line_sexp
            yield _the_empty_line_sexp

        for sexp in ifr.line_sexps:
            if 'parsed content line' == sexp[0]:
                sexp = __dereference_footnotes(sexp, ifr, fi, listener)
                if sexp is None:
                    cover_me('make sure you have a monitor')
                    return
            yield sexp

    fn_ids = fi.final_footnote_order
    if len(fn_ids):
        yield _the_empty_line_sexp
        yield _the_empty_line_sexp

    url_via = fi.final_footnote_url_via_identifier
    for fn_id in fn_ids:
        yield ('footnote definition', fn_id, url_via[fn_id])


def __dereference_footnotes(sexp, ifr, fi, listener):

    pc_itr = iter(sexp)
    sx = [next(pc_itr), next(pc_itr)]  # ballsy

    for sub_sexp in pc_itr:
        typ = sub_sexp[0]
        if 'footnote reference' == typ:
            label_text, local_id = sub_sexp[1:]
            _url = ifr.footnote_url_via_local_identifier[local_id]
            _final_id = fi.final_footnote_identifier_via_url[_url]
            sx.append(('footnote reference', label_text, _final_id))
        else:
            cover_me('ambitious')
        sx.append(next(pc_itr))  # omg

    return sx


class _MutableFragmentsIndex:

    def __init__(self):

        self.final_footnote_identifier_via_url = {}
        self.final_footnote_url_via_identifier = {}
        self.final_footnote_order = []

        self.indexed_fragments = []

    def see_indexed_fragment(self, ifr):
        for fd in ifr.footnote_definitions:
            url = fd.url_probably
            if url not in self.final_footnote_identifier_via_url:
                _use_id_int = len(self.final_footnote_order) + 1  # start at 1
                use_id = str(_use_id_int)
                self.final_footnote_identifier_via_url[url] = use_id
                self.final_footnote_url_via_identifier[use_id] = url
                self.final_footnote_order.append(use_id)
        self.indexed_fragments.append(ifr)


class _IndexedFragment:

    def __init__(self, is_head_fragment, frag, listener):
        """.#wish [#882.F] without proper markdown parsing, this hurts to

        read and seems vulerable to missed matches and false-positives.
        .#here1 marks such places.
        """

        self.footnote_url_via_local_identifier = {}
        self._footnote_definitions_in_reverse = []

        self.line_sexps = []

        self._listener = listener
        self.OK = False  # gets "re-initialized" to True later below

        # --

        add_header_depth = _do_the_do(
                self._add_sexp, is_head_fragment, frag.heading)

        # requiring that footnote definitions are tail-anchored may or may
        # not help us avoid trickier parsing edge cases involving ``` blocks

        lines = list(_lines_via_big_string(frag.body))

        while len(lines):
            foot_def_sexp = _footnote_definition_sexp_via(lines[-1])
            if foot_def_sexp is None:
                break
            # (Case212)
            lines.pop()
            ok = self._add_footnote_definition_sexp(foot_def_sexp)
            if not ok:
                return

        _ = self._footnote_definitions_in_reverse
        del self._footnote_definitions_in_reverse
        self.footnote_definitions = tuple(reversed(_))

        # let's just discard any interceding blank lines that came before the
        # footnotes at the bottom (& i suppose tail-anchored blanks otherwise)

        while len(lines) and '\n' == lines[-1]:
            lines.pop()

        # GO HAM CRAY

        def process_line_normally(line):
            tup = _sexp_via_line_normally(line)
            typ = tup[0]

            if 'content line' == typ:
                if '][' in line:  # already tres hacky
                    return self._maybe_parse_line(tup)

                return self._add_sexp(tup)

            if 'empty line' == typ:
                return self._add_sexp(tup)

            if 'header' == typ:
                depth, rest_s = tup[1:]
                self._add_sexp(('header', depth + add_header_depth, rest_s))
                return _okay

            if 'multi-line code block open' == typ:
                self._process_line = process_line_crazily
                return self._add_sexp(tup)

            if 'footnote def' == typ:
                cover_me("FOR NOW footnote definition must be anchored at end")
                return _okay

            assert(False)

        self._process_line = process_line_normally

        def process_line_crazily(line):
            md = _end_of_multi_line_code_block_rx.match(line)
            if md is None:
                self._add_sexp(('multi-line code block body line', line))
                return _okay
            self._process_line = process_line_normally
            return self._add_sexp(('mutli-line code block end', line))

        self.OK = True
        for line in lines:
            _ok = self._process_line(line)
            if not _ok:
                cover_me('then what')
                self.OK = False
                return

        del self._listener

    def _maybe_parse_line(self, tup):
        line = tup[1]
        md_itr = re.finditer(_find_iter_rx_s, line)
        for first_md in md_itr:  # once
            break
        if first_md is None:
            return self._add_sexp(tup)

        def unpeek():
            yield first_md
            for md in md_itr:
                yield md

        # this could deffo false match, like "`[xx][yy]`" (in backtics) :#here1
        # this is why we need proper parsing one day #open [#882.F]

        sx = ['parsed content line']
        cursor = 0

        for md in unpeek():
            begin, end = md.span(0)
            sx.append(line[cursor:begin])  # even if the empty string
            sx.append(('footnote reference', md[1], md[2]))
            cursor = end

        sx.append(line[cursor:])  # even if empty string
        return self._add_sexp(tuple(sx))

    def _add_footnote_definition_sexp(self, sexp):

        fd = sexp[1]
        fid = fd.identifier_string

        if fid in self.footnote_url_via_local_identifier:
            cover_me(f"footnote re-defined: {repr(fid)}")
        self.footnote_url_via_local_identifier[fid] = fd.url_probably

        self._footnote_definitions_in_reverse.append(fd)
        return _okay

    def _add_sexp(self, tup):
        self.line_sexps.append(tup)
        return _okay


_find_iter_rx_s = (
        r'\[([^\]]+)\]'
        r'\[([^\]]+)\]'
        )


_end_of_multi_line_code_block_rx = re.compile('^```')


def _do_the_do(add_sexp, is_head_fragment, frag_heading):

    if is_head_fragment:
        # all head fragments have headings [#883.2], expressed elsewhere
        assert(frag_heading is not None)
        add_header_depth = _normal_header_depth_to_add

    elif frag_heading is None:
        # non-head fragment with no heading (Case121)
        add_header_depth = _normal_header_depth_to_add

    else:
        # non-head fragment with YES heading (Case115)
        add_header_depth = _normal_header_depth_to_add + 1
        add_sexp(('header', add_header_depth, frag_heading))

    return add_header_depth


_normal_header_depth_to_add = 1  # #[#883.3]


def _sexp_via_line_normally(line):

    if '\n' == line:
        return _the_empty_line_sexp

    char = line[0]
    if '#' == char:
        md = _header_rx.match(line)
        begin, end = md.span(1)
        number_of_octothorpes = end - begin
        rest = md[2]
        # --
        return ('header', number_of_octothorpes, rest)

    if '`' == char and '```' == line[0:3]:
        return ('multi-line code block open', line)

    if '[' == char:
        sexp = _footnote_definition_sexp_via(line)
        if sexp is not None:
            return sexp

    return ('content line', line)


_header_rx = re.compile('^(#+)(.+\n)$')


def _footnote_definition_sexp_via(line):
    md = _footnote_definition_rx.match(line)
    if md is None:
        return
    _ = _FootnoteDef(md[1], md.string[md.span()[1]:])  # `post_match`
    return ('footnote def', _)


_footnote_definition_rx = re.compile(r'^\[([0-9a-zA-Z_]+)\]: *')


class _FootnoteDef:

    def __init__(self, id_s, s):
        self.identifier_string = id_s
        self.url_probably = s


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


_the_empty_line_sexp = ('empty line', '\n')
_not_ok = False
_okay = True

# #history-A.1: introduce footnote merging
# #born.
