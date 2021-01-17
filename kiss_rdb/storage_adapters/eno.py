"""
This feels bad but maybe it's not that bad

- (The really coarse proof-of-concept was finished in 1 hour)
- Think of it as a stand-in for a feature we wish we had in the vendor parser
- It might be the case that this parses all documents that follow our
  more restricted version of eno (whatever that is)
- Today at #birth it's used for determining which of several entities
  in a file has been edited (thru `git diff`)
- One day this might be useful for use in seeing the changes made in arbitrary
  commits for use in generating an attribution log
"""


def sections_parsed_coarsely_via_lines(lines):
    # (this one popular type of implementation of a state machine [#008.2])

    # == States

    def from_beginning_state():
        yield looks_like_section_line, on_begin_section

    def from_section_state():
        yield looks_like_simple_or_list_field, on_field_according_to_type
        yield looks_like_blank_line, on_blank_line
        yield looks_like_beginning_of_multiline_field, on_begin_multiline_field
        yield looks_like_section_line, roll_over_section

    def from_list():
        yield looks_like_list_item, append_list_item
        yield any_other_line, pop_out_of_list_and_redo

    def from_mulitline_field():
        yield looks_like_end_of_multiline_field, on_end_multiline_field
        yield any_other_line, add_line_multiline_field

    # == Tests

    import re

    def looks_like_section_line():
        return '#' == line[0]  # kiss

    def looks_like_list_item():
        return list_item_rx.match(line)

    def looks_like_beginning_of_multiline_field():
        if (md := ml_field_simple_rx.match(line)):
            state.last_match = md
            return True

    def looks_like_end_of_multiline_field():
        return state.match_this_to_find_end_of_multiline_value == line

    def looks_like_simple_or_list_field():
        if (md := field_identifier_rx.match(line)):
            state.last_match = md
            return True

    def looks_like_blank_line():
        return '\n' == line

    def any_other_line():
        return True

    # == Actions

    def roll_over_section():
        # leave the current line on the doo-hah
        res = flush_section()
        parse_section_line()
        return 'yield_AST', res

    def on_begin_section():
        parse_section_line()
        stack.append(from_section_state)

    def parse_section_line():
        md = section_line_rx.match(line)
        assert md
        octos, rest = md.groups()
        state.section_line = _SectionLine(line, len(octos), rest)

    def on_field_according_to_type():
        md = release_last_match()
        rhs, = md.groups()
        if rhs is not None:
            state.current_section_components.append(_FieldLine(line))
            return
        state.list_lines.append(line)
        stack.append(from_list)

    def append_list_item():
        state.list_lines.append(line)

    def pop_out_of_list_and_redo():
        lines = tuple(state.list_lines)
        state.list_lines.clear()
        state.current_section_components.append(_List(lines))
        pop_stack()
        return 'retry_line', None

    def on_begin_multiline_field():
        state.match_this_to_find_end_of_multiline_value = line
        state.multiline_field_lines.append(line)
        stack.append(from_mulitline_field)

    def add_line_multiline_field():
        state.multiline_field_lines.append(line)

    def on_end_multiline_field():
        state.multiline_field_lines.append(line)
        lines = tuple(state.multiline_field_lines)
        state.multiline_field_lines.clear()
        del state.match_this_to_find_end_of_multiline_value
        state.current_section_components.append(_MultilineField(lines))
        pop_stack()

    def on_blank_line():
        state.current_section_components.append(_blank_line_component)

    # == Regexen

    section_line_rx = re.compile('(#+)[ ]+([^ ].*)')
    list_item_rx = re.compile(r'-[ ][^ \n]')
    ml_field_simple_rx = re.compile('--[ ](?P<rest>.+)')
    field_identifier_rx = re.compile(r'[a-zA-Z][a-zA-Z0-9_]+:[ ]*([^ \n].*)?$')

    # ==

    def flush_section():
        sl = state.section_line
        del state.section_line
        res = _Section(sl, tuple(state.current_section_components))
        state.current_section_components.clear()
        return res

    def release_last_match():
        res = state.last_match
        del state.last_match
        return res

    def pop_stack():
        assert 1 < len(stack)  # never pop out of the first frame
        stack.pop()

    # ==

    state = from_beginning_state  # #watch-the-world-burn
    state.current_section_components = []
    state.multiline_field_lines = []
    state.list_lines = []

    # ==

    stack = [from_beginning_state]

    for line in lines:
        while True:  # while retry on this line
            found = False
            for test, action in stack[-1]():
                if test():
                    found = True
                    break
            if not found:
                xx(f'oops: {line!r}')
            direc = action()
            if direc is None:
                break
            typ, val = direc
            if 'yield_AST' == typ:
                yield val
                break
            assert 'retry_line' == typ

    # We're making several assumptions here that would be broken on general
    # cases but might hold for all of ours..

    if 2 != len(stack) or from_section_state != stack[-1]:
        s = stack[-1].__name__
        xx(f"file ended mid-construct, or need more logic to handle ending in {s!r}")  # noqa: E501

    yield flush_section()


class _Section:
    def __init__(self, section_line, components):
        self.section_line_AST = section_line
        self._components = components

    def to_lines(self):
        yield self.section_line_AST.line
        for c in self._components:
            for line in c.to_lines():
                yield line

    @property
    def line_count(self):
        num = 1
        for c in self._components:
            num += c.line_count
        return num


class _SectionLine:
    def __init__(self, line, depth, label_text):
        self.line, self.depth, self.label_text = line, depth, label_text

    def to_lines(self):
        yield self.line

    line_count = 1


class _List:
    def __init__(self, lines):
        self._lines = lines

    def to_lines(self):
        return self._lines

    @property
    def line_count(self):
        return len(self._lines)


class _MultilineField:
    def __init__(self, lines):
        self._lines = lines

    def to_lines(self):
        return self._lines

    @property
    def line_count(self):
        return len(self._lines)


class _FieldLine:
    def __init__(self, line):
        self._line = line

    def to_lines(self):
        yield self._line

    line_count = 1


class _BlankLine:  # singleton
    def to_lines(_):
        yield '\n'
    line_count = 1


_blank_line_component = _BlankLine()


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #birth
