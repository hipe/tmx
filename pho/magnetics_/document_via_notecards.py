"""
a document is ~somehow~ composed of 1 or more notecards. (how those notecards

came to be "flattened" into this one document is out of our scope here.)

Each notecard has zero or one heading, and then in its body string (lines)
any arbitrary subset of those lines can be a "header" (alla markdown) line
of any arbitrary "depth" (number of contiguous octothorps anchored to the
beginning of the string).

The trick here is how to decide what to do with the different headings
and in-body headers so that they coalesce to make a document that looks
"normal" for the target, but is also built from `body` blocks that look
"normal" in the context of our unwritten standard.

In detail:

  - Every notecard's (any) heading (when present) will express as either
    a heading (line) or the document title.

  - For those notecards whose body copy has headers, their most significant
    depth is one as stored. (I.e., write headers `# like this` normally.)

  - It seems from our current output target that headers of depth one are
    something of an imaginary "reserved" slot that's only used to express
    the title of the generated document, which (in turn) is expressed by us
    only in the frontmatter we produce, not in any headers in our body copy.
    (This is :[#883.3], and should be considered as *not* set-in-stone.)

  - As such, normally a body copy header of depth 1 gets "demoted" to have
    a depth of 2 and so on (at expression).

  - The "head notecard" (first one) in a document will always have a heading,
    and that heading will always be expressed as the document title (and so
    not as a header line).

  - IFF a non-head notecard has a heading, that heading will express as a
    header. This further demotes any body copy headers in that notecard
    by one more level of depth (at expression).
"""

import re


class Document_:

    def __init__(self, notecards):
        self._notecards = notecards

    @property
    def document_title(self):
        return self.head_notecard.heading  # guaranteed per [#883.2]

    @property
    def document_datetime(self):
        return self.head_notecard.document_datetime

    @property
    def head_notecard_identifier_string(self):
        return self.head_notecard.identifier_string

    @property
    def head_notecard(self):
        return self._notecards[0]

    def TO_LINES(self, listener):
        ast_itr = self._to_line_ASTs(listener)
        for ast in ast_itr:
            for line in ast.to_lines():
                yield line

    def _to_line_ASTs(self, listener):  # #testpoint
        idoc = _indexed_document_via(self._notecards, listener)
        if idoc is None:
            cover_me('make sure you use a monitor')
            return
        return _to_document_line_ASTs(idoc, listener)


def _indexed_document_via(notecards, listener):

    idoc = _IndexedDocument()
    see = idoc.see_indexed_notecard

    frag_iter = iter(notecards)

    frag = next(frag_iter)  # assume at least one notecard per document

    ifr = _IndexedNotecard(True, frag, listener)
    if not ifr.OK:
        return
    see(ifr)

    for frag in frag_iter:
        ifr = _IndexedNotecard(False, frag, listener)
        if not ifr.OK:
            return
        see(ifr)

    return idoc


def _to_document_line_ASTs(idoc, listener):

    is_first = True

    for ifr in idoc.indexed_notecards:
        if is_first:
            is_first = False
        else:
            o = _the_empty_line_AST()
            yield o
            yield o

        lineno = 0
        for ast in ifr.line_ASTs:
            lineno += 1
            if 'structured content line' == ast.symbol_name:
                ast = ast.dereference_footnotes__(lineno, ifr, idoc, listener)
                if ast is None:
                    cover_me('make sure you have a monitor')
                    return
            yield ast

    fn_ids = idoc.final_footnote_order
    if len(fn_ids):
        o = _the_empty_line_AST()
        yield o
        yield o
        footnote_definition_via = _footnote_lib().footnote_definition_via

    url_via = idoc.final_footnote_url_via_identifier
    for fn_id in fn_ids:
        yield footnote_definition_via(fn_id, url_via[fn_id])


class _IndexedDocument:

    def __init__(self):

        self.final_footnote_identifier_via_url = {}
        self.final_footnote_url_via_identifier = {}
        self.final_footnote_order = []

        self.indexed_notecards = []

    def see_indexed_notecard(self, ifr):
        for ast in ifr.footnote_definitions:
            url = ast.url_probably
            if url not in self.final_footnote_identifier_via_url:
                _use_id_int = len(self.final_footnote_order) + 1  # start at 1
                use_id = str(_use_id_int)
                self.final_footnote_identifier_via_url[url] = use_id
                self.final_footnote_url_via_identifier[use_id] = url
                self.final_footnote_order.append(use_id)
        self.indexed_notecards.append(ifr)


class _IndexedNotecard:

    def __init__(self, is_head_notecard, frag, listener):
        """.#wish [#882.F] without proper markdown parsing, this hurts to

        read and seems vulerable to missed matches and false-positives.
        .#here1 marks such places.
        """

        self.footnote_url_via_local_identifier = {}
        self._footnote_definitions_in_reverse = []
        # becomes `footnote_definitions` below

        self.line_ASTs = []

        self._listener = listener
        self.OK = False  # gets "re-initialized" to True later below

        # --

        from pho.models_ import header
        add_header_depth, hdr = header.decide_how_to_express_heading(
                is_head_notecard, frag.heading)

        if hdr is not None:
            self._add_AST(hdr)

        # requiring that footnote definitions are tail-anchored may or may
        # not help us avoid trickier parsing edge cases involving ``` blocks

        lines = list(_lines_via_big_string(frag.body))

        while len(lines):
            foot_def_ast = _footnote_lib().any_definition_via_line(lines[-1])
            if foot_def_ast is None:
                break
            # (Case212)
            lines.pop()  # #here2
            ok = self.__add_footnote_definition_AST(foot_def_ast)
            if not ok:
                return

        _ = self._footnote_definitions_in_reverse
        del self._footnote_definitions_in_reverse
        self.footnote_definitions = tuple(reversed(_))

        # let's just discard any interceding blank lines that came before the
        # footnotes at the bottom (& i suppose tail-anchored blanks otherwise)

        while len(lines) and '\n' == lines[-1]:
            lines.pop()  # #here2

        # GO HAM CRAY

        parse_context = _ParseContext(frag.identifier_string)
        _AST_via_line_normally = _AST_via_liner(parse_context, listener)

        def process_line_normally(line):
            ast = _AST_via_line_normally(line)
            typ = ast.symbol_name

            if 'content line' == typ:
                o = None
                if '][' in line:  # already tres hacky
                    from pho.models_ import content_line
                    o = content_line.any_structured_via_line(ast.line)
                if o is None:
                    o = ast  # (Case112)
                return self._add_AST(o)

            if 'empty line' == typ:
                return self._add_AST(ast)

            if 'header' == typ:
                _ = ast.new_via(
                        depth=(ast.depth + add_header_depth),
                        text=ast.text)
                return self._add_AST(_)

            if 'fenced code block open' == typ:
                # (Case133)
                _ = ast.build_alternate_line_processer__(listener)
                self._process_line_crazily = _
                self._process_line = process_line_crazily
                self._end_of_stream_is_OK_here = False
                return _okay

            if 'local footnote definition' == typ:
                cover_me("FOR NOW footnote definition must be anchored at end")
                return _okay

            assert(False)

        self._process_line = process_line_normally

        def process_line_crazily(line):
            # (Case133) experimental parse API. away when [#882.F]
            ok, done, ast = self._process_line_crazily(line)
            if not ok:
                self._close()
                return
            if done:
                del self._process_line_crazily
                self._process_line = process_line_normally
                self._end_of_stream_is_OK_here = True
            if ast is not None:
                self._add_AST(ast)
            return _okay

        # now do the work, a parse loop:

        self.OK = True
        self._end_of_stream_is_OK_here = True

        for line in lines:
            parse_context.lineno += 1
            _ok = self._process_line(line)
            if not _ok:
                cover_me('then what')
                self.OK = False
                return

        if not self._end_of_stream_is_OK_here:
            cover_me('unclosed multli-line code block?')

        self.notecard_identifier_string = frag.identifier_string
        del self._listener

    def __add_footnote_definition_AST(self, ast):

        fid = ast.identifier_string

        if fid in self.footnote_url_via_local_identifier:
            cover_me(f"footnote re-defined: {repr(fid)}")

        self.footnote_url_via_local_identifier[fid] = ast.url_probably
        self._footnote_definitions_in_reverse.append(ast)
        return _okay

    def _add_AST(self, ast):
        assert(hasattr(ast, 'symbol_name'))  # #[#022] wish for strong types
        self.line_ASTs.append(ast)
        return _okay

    def _close(self):
        self._process_line_crazily = None
        del self._process_line_crazily
        del self._process_line


def _AST_via_liner(parse_context, listener):

    def AST_via_line_normally(line):

        if '\n' == line:
            return _the_empty_line_AST()  # (Case154)

        char = line[0]
        if '#' == char:
            from pho.models_ import header
            return header.via_line(line)  # (Case112)

        if '`' == char and '```' == line[0:3]:
            return _fenced_code_block_lib().opening_via_line(line)  # (Case133)

        if '[' == char:

            # edge case: if this occurs at the start of a line, then FOR NOW
            # it better be a footnote reference. .. (clean up as necessary)

            from pho.models_.footnote import footnote_reference_regex_ as rx
            md = rx.match(line)
            if not md:
                _at_here = parse_context.say_at_where()
                reason = (
                        f'{_at_here}, '
                        f'what is the deal with this line: {repr(line)}'
                        )
                cover_me(reason)
                # (did something else before #history-A.3)

        from pho.models_ import content_line
        return content_line.via_line(line)

    return AST_via_line_normally


class _ParseContext:
    # experiment for better error messages
    # at #here2 we pop lines off the end of the notecard, but:
    # that shouldn't effect our line offsets (which count from beginnning)

    def __init__(self, iid_s):
        self.lineno = 0
        self.notecard_identifier_string = iid_s

    def say_at_where(self):
        return (
            f'in {repr(self.notecard_identifier_string)}.body'
            f' (line {self.lineno})'
            )


def _fenced_code_block_lib():
    from pho.models_ import fenced_code_block as _
    return _


def _footnote_lib():
    from pho.models_ import footnote as _
    return _


def _the_empty_line_AST():
    from pho.models_ import empty_line
    return empty_line.the_empty_line_AST


def _lines_via_big_string(big_s):  # (copy-paste of [#610].)
    return (md[0] for md in re.finditer('[^\n]*\n|[^\n]+', big_s))


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_not_ok = False
_okay = True

# #history-A.3: refactored from S-expressions's to AST's
# #history-A.2: document fragment moves to own file
# #history-A.1: introduce footnote merging
# #born.
