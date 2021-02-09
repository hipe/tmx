"""NOTE

the idea of an "abstract document"
  - straddle hugo and pelican and github flavored markdown and whoever
  - probably one day do something with our local conventions like '[#123.B]'

in implementation:
  - we parse it by hand
  - writing a robust parser would be out of scope and seem absurd
  - so we just parse based on the first char being '#' on each line
  - which would break if e.g you had '#' as first char in a code fence
"""


import re as _re


def abstract_document_via_lines(lines, path=None):
    itr = _frontmatter_then_sections_OLD_WAY(lines)
    frontmatter = next(itr)
    sections = tuple(itr)
    return AbstractDocument_(frontmatter, sections, path=path)


func = abstract_document_via_lines


def PARSE_DOCUMENT_NEW_WAY_(lines, path=None):
    """Discussion:

    - Erase most or all of this comment block at some future date #todo
    - At #history-B.4 we were implementing "notecard body via document"
    - The local objective was, "get the file lines without any frontmatter
      lines or trailing special document meta section"
    - We began imagining parsing the document file lines with our familiar
      FSA pattern. *As* we were doing this, we knew that somewhere we had
      done something similar elsewhere
    - After only a few minutes, we searched for where elsewhere we did
      something like this; and found this module (file)
    - At this point it was too late. We liked the state machine approach so
      much better than the older (but not very old lol) way we were parsing
      documents (to make abstract documents from them)
    - But (A), refactoring the old way was out of scope
    - And (B), the side-by-side comparison is interesting

    The old way is about passing a line scanner around to ad-hoc funcs
    """
    # (#history-B.4 spike new way)

    # == States (this state machine pattern #[#008.2])

    def from_beginning():
        yield if_dash_dash_dash, leave_beginning_and_enter_frontmatter_state
        yield otherwise, leave_beginning_state_and_enter_body_state_and_retry

    def from_frontmatter_state():
        yield if_dash_dash_dash, exit_frontmatter_state_and_enter_body_state
        yield otherwise, handle_frontmatter_line

    def from_body_state():
        yield if_header_line, roll_section_over_because_matched_header_line
        yield if_start_code_block, enter_code_block_state
        yield otherwise, add_line

    def from_code_block_state():
        yield if_end_code_block, exit_code_block_state
        yield otherwise, add_line

    # == Can End On

    from_beginning.when_EOS = lambda: complain_about_empty_file()
    from_frontmatter_state.when_EOS = lambda: complain_ended_mid('frontmatter')
    from_body_state.when_EOS = lambda: yield_any_final_section()
    from_code_block_state.when_EOS = lambda: complain_ended_mid('a code block')

    # == Actions

    def leave_beginning_and_enter_frontmatter_state():
        # NOTE we do not actually keep the "---\n" line
        state.unparsed_frontmatter_lines = []
        stack.pop()
        stack.append(from_frontmatter_state)

    def handle_frontmatter_line():
        # Parsing it now would be trivial, but we let clients delay it to never
        state.unparsed_frontmatter_lines.append(line)

    def exit_frontmatter_state_and_enter_body_state():
        # NOTE we do not actually keep the "---\n" line
        res = tuple(state.unparsed_frontmatter_lines)
        del state.unparsed_frontmatter_lines
        stack.pop()
        enter_body_state()
        return 'yield_this', ('unparsed_frontmatter_lines', res)

    def leave_beginning_state_and_enter_body_state_and_retry():
        stack.pop()
        enter_body_state()
        tup = 'unparsed_frontmatter_lines', None
        return 'yield_this_and_retry_current_line', tup

    def enter_code_block_state():
        add_line()
        stack.append(from_code_block_state)

    def exit_code_block_state():
        add_line()
        stack.pop()

    def enter_body_state():
        state.current_header_AST = None
        state.current_section_lines = []
        stack.append(from_body_state)

    def roll_section_over_because_matched_header_line():
        md = state.previous_markdown_header_match
        md_hdr_AST = _markdown_header_via_matchdata(md)
        maybe = flush_any_previous_section()
        state.current_header_AST = md_hdr_AST
        return maybe and yield_this_section(maybe)

    def yield_any_final_section():
        maybe = flush_any_previous_section()
        return maybe and yield_this_section(maybe)

    def yield_this_section(tup):
        hdr, lines = tup  # #here1
        return 'yield_this', ('markdown_header', MarkdownSection_(hdr, lines))

    def add_line():
        state.current_section_lines.append(line)

    def flush_any_previous_section():
        hdr = state.current_header_AST
        lines = state.current_section_lines
        if not (hdr or lines):
            return
        state.current_header_AST = None
        lines = tuple(lines)
        state.current_section_lines.clear()
        return hdr, lines  # #here1

    # == Conditions

    def if_dash_dash_dash():
        return _hugo_yaml_open_and_close_frontmatter_line_rx.match(line)

    def if_header_line():
        md = _markdown_header_line_probably.match(line)
        state.previous_markdown_header_match = md
        return True if md else False

    def if_start_code_block():
        return _code_block_start_and_stop_lol_rx.match(line)

    def if_end_code_block():
        return _code_block_start_and_stop_lol_rx.match(line)

    def otherwise():
        return True

    # == Whiney actions

    def complain_about_empty_file():
        xx("empty file!")

    def complain_ended_mid(what):
        xx(f"file ended while in the middle of {what}")

    # ==

    state = otherwise  # #watch-the-world-burn
    stack = [from_beginning]

    def find_action():
        for cond, action in stack[-1]():
            yn = cond()
            if yn:
                return action

    for line in lines:
        while True:
            found = find_action()
            if not found:
                xx(f"no state transition found {stack[-1].__name} - {line!r}")
            tup = found()
            if tup is None:
                break  # fall through to process next line
            typ, x = tup
            if 'yield_this' == typ:
                yield x
                break  # fall through to process next line
            assert 'yield_this_and_retry_current_line'
            yield x
            # stay in loop to do line again

    do = stack[-1].when_EOS
    if not do:
        return
    tup = do()  # probably throws
    typ, x = tup
    assert 'yield_this' == typ
    yield x


def _frontmatter_then_sections_OLD_WAY(lines):
    from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    scn = func(iter(lines))

    # Parse any hugo-style frontmatter
    frontmatter = None
    if scn.more and _hugo_yaml_open_and_close_frontmatter_line_rx.match(scn.peek):  # noqa: E501
        frontmatter = _parse_hugo_yaml_frontmatter(scn)
    yield frontmatter

    # Parse the remaining zero or more lines

    def flush():
        res = _markdown_section_via(
            current_markdown_header, current_section_body_lines)  # see
        current_section_body_lines.clear()
        return res

    current_markdown_header = None
    current_section_body_lines = []

    while scn.more:

        md = _markdown_header_line_probably.match(scn.peek)
        if md:
            if current_markdown_header or current_section_body_lines:
                yield flush()
            current_markdown_header = _markdown_header_via_matchdata(md)
            scn.advance()
        else:
            current_section_body_lines.append(scn.next())

    if current_markdown_header or current_section_body_lines:
        yield flush()


def markdown_header_via_header_line_(line):
    md = _markdown_header_line_probably.match(line)
    assert md
    return _markdown_header_via_matchdata(md)


def _parse_hugo_yaml_frontmatter(scn):
    return {k: v for k, v in _parse_hugo_yaml_frontmatter_pairs(scn)}


def _parse_hugo_yaml_frontmatter_pairs(scn):
    for line in _hugo_yaml_frontmatter_body_lines_via(scn):
        md = _hugo_frontmatter_line_rx.match(line)
        if not md:
            xx(f"oops: {line!r}")
        key, value = md.groups()
        yield key, _unencode_yaml_quote_lol(value)


def _unencode_yaml_quote_lol(value):
    if 0 == len(value):
        return None

    if (md := _single_quote_rx.match(value)):
        quot = "'"
    elif (md := _double_quote_rx.match(value)):
        quot = '"'
    else:
        return value
    encoded_inner, end_quote = md.groups()
    if quot != end_quote:
        xx(f"didn't close quote? {value!r}")

    if '\\' in encoded_inner or quot in encoded_inner:
        xx("have fun, we've been down this road before")

    return encoded_inner


_single_quote_rx = _re.compile("^'(?:(.*)(.))?$")
_double_quote_rx = _re.compile('^"(?:(.*)(.))?$')


def _hugo_yaml_frontmatter_body_lines_via(scn):
    scn.advance()  # assume current line was match
    while not _hugo_yaml_open_and_close_frontmatter_line_rx.match(scn.peek):
        yield scn.next()
    scn.advance()


class AbstractDocument_:

    def __init__(self, frontmatter, sections, path=None, ncid=None):
        self.frontmatter, self.sections = frontmatter, sections
        self.path = path
        self.head_notecard_identifier_string = ncid

    def replace_sections_(self, sections):
        return self.__class__(
            self.frontmatter, sections,
            path=self.path, ncid=self.head_notecard_identifier_string)

    def to_summary_lines(self):
        if (dct := self.frontmatter):
            yield f"{len(dct)} elements of frontmatter\n"

        section_count = 0
        body_line_count = 0
        for sect in self.sections:
            section_count += 1
            body_line_count += len(sect.body_lines)

        yield f"{section_count} section(s)\n"
        yield f"{body_line_count} body lines(s)\n"

    def TO_HOPEFULLY_AGNOSTIC_MARKDOWN_LINES(self):
        # insert interceding newlines between sections IFF necessary (OCD)
        # (peloogan doesn't like a table immediately followed by a header)
        # .#[#882.U]

        if (0 == (leng := len(sects := self.sections))):
            return

        line = None
        for line in sects[0].to_normalized_lines():
            yield line

        for i in range(1, leng):
            if line and '\n' != line:
                yield '\n'

            for line in sects[i].to_normalized_lines():
                yield line

    @property
    def classified_path(self):  # assumes path
        if not hasattr(self, '_classified_path'):
            self._classified_path = _ClassifiedPath(self.path)
        return self._classified_path

    @property
    def document_title(self):  # grandfathered in
        return self.frontmatter['title']

    @property
    def document_datetime(self):  # #todo
        return self.frontmatter.get('document_datetime')


def _markdown_section_via(md_header, lines):
    # NOTE lines is "TMX-style mutable lines" BE CAREFUL

    # Will skip over the leading blank lines lol
    def these():
        itr = iter(lines)
        for line in itr:
            if _is_blank(line):
                continue
            yield line
            break
        for line in itr:
            yield line

    # Pop off the trailing blank lines lol
    while len(lines) and _is_blank(lines[-1]):
        lines.pop()  # ! 👀

    return MarkdownSection_(md_header, these())


class MarkdownSection_:

    def __init__(self, md_header, normal_body_lines):
        self.header = md_header
        self.normal_body_lines = tuple(normal_body_lines)

    def replace_header(self, new_header):
        return self.__class__(new_header, self.normal_body_lines)

    def to_normalized_lines(self):
        # NOTE hugo required a blank line before a bulleted list. let's see
        if self.header:
            yield self.header.to_normalized_line()
        for line in self.normal_body_lines:
            yield line


def _markdown_header_via_matchdata(md):
    octothorpes, opening, label_text, rest = md.groups()
    return MarkdownHeader_(len(octothorpes), opening, label_text, rest)


class MarkdownHeader_:
    # NOTE there is another header model class in this package (dedicated file)
    # unifying this one with that one is left as an exercise for later or never

    def __init__(self, depth, opening, label_text, rest):
        assert 0 < depth < 7
        self.depth, self._open = depth, opening
        self.label_text, self._rest = label_text, rest

    def replace_depth(self, new_depth):
        return self.__class__(new_depth, self._open, self.label_text, self._rest)  # noqa: E501

    def to_normalized_line(self):
        return ''.join(self._to_pieces())

    def _to_pieces(self):
        yield '#' * self.depth
        yield ' '
        yield self._open
        yield self.label_text
        yield self._rest
        yield '\n'


def _is_blank(line):
    return '\n' == line


_hugo_yaml_open_and_close_frontmatter_line_rx = _re.compile('^---$')
_hugo_frontmatter_line_rx = _re.compile(r'^([^ :]+)[ ]*:[ ]*(.*)$')
_markdown_header_line_probably = _re.compile(r'^(#+)[ ]*(\(?)([^)\n]*)([^\n]*)$')  # noqa: E501
_code_block_start_and_stop_lol_rx = _re.compile('^```')


class _ClassifiedPath:

    def __init__(self, path):
        eid, title_pieces = _interesting_parts_via_path(path)
        self._EID_ONE_DAY_, self.title_pieces = eid, title_pieces

    @property
    def derived_title(self):
        if not hasattr(self, '_derived_title'):
            self._derived_title = ' '.join(self.title_pieces)
        return self._derived_title


def _interesting_parts_via_path(path):

    # Split long path up in to dirname (discarded) and basename
    from os.path import basename as _basename, splitext as _splitext
    basename = _basename(path)

    # Split basename up into basename head and (discarded) extension
    basename_head, ext = _splitext(basename)
    assert '.md' == ext
    # (in some crazy future this might change and that's okay)

    # Split basename head up into entity identifier and the rest
    md = _re.match(r'(?:(\d+(?:\.(?:\d+|[A-Z]))*)[.-])?(.+)', basename_head)
    if not md:
        xx(f"regex oops: {basename_head!r}")
    eid, rest = md.groups()

    # Split the rest up into "title pieces"
    title_pieces = tuple(md[0] for md in _re.finditer(r'\w+', rest))
    return eid, title_pieces


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #history-B.4
# #born
