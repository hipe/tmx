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


def abstract_document_via(lines, path=None):
    from text_lib.magnetics.scanner_via \
            import scanner_via_iterator as func

    scn = func(iter(lines))
    itr = _frontmatter_then_sections(scn)
    frontmatter = next(itr)
    sections = tuple(itr)
    return AbstractDocument_(frontmatter, sections, path=path)


func = abstract_document_via


def _frontmatter_then_sections(scn):

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
        for s in self.sections:
            for line in s.to_normalized_lines():
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

# #born
