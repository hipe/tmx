"""
## design objectives

this is a quick-and-dirty solution to the problem of parsing markdown
tables for the propose of verifying output during tests.

it's written to accomodate a "spiral downward"-style of testing, where
input is first parsed in a coarse pass, and then in subsequent passes
the results from the coarser passes are fed into it, progressively producing
structures with more granularity (and more stringent requirements).

such an approach aids in
[#010.6] "regression-friendly" testing, a philosophy where
you want coarser, more fundamental failures to trigger before more detailed
failures, so that the debugging search space grows or shrinks to match the
sope of the failure.



## concerns & justification

such an undertaking should trigger several "attack vectors" of smell:

    - why not use our existing business logic that parses markdown?
    - better still, why not use a purpose-built vendor library that already
      parses markdown (tables)? (we echo this concern in the asset code.)

currently, our answers to the above are:
    - reducing dependencies generally (e.g on vendor libraries) can be a good
      thing even when weighed against DRY-ism.
    - avoid dependency on our own business logic so e.g when our API or
      behavior or requirements change there, we are insulated from that here
      and our tests don't break because of it.
    - a custom-built solution gives us exactly what we need for testing,
      rather than more or less.
    - more specifically, our custom-built parsing can perhaps better
      accomodate our design objective of "spiral downward"-style parsing
    - a small, custom-built solution like this will have less non-neglibile
      overhead, almost certainly.


but nonethess it bears tracking the "smell vectors" and re-evaluating this
ground calculus whenever things change.
"""

import re


def line_sections_via_lines(lines):
    return _mad_parse(lines, _MadParseLineSections())


def table_via_lines(lines):
    return _mad_parse(lines, _MadParseTable())


def _mad_parse(lines, parse):
    for line in lines:
        parse.receive_line(line)
    return parse.finish()


class _MadParseTable:  # #pattern #[#458.Z.4] "mad parse"

    def __init__(self):
        self._state = 'receive_header_line'
        self._can_finish = False
        self._mutex = None

    def receive_line(self, line):
        getattr(self, self._state)(line)

    def receive_header_line(self, line):
        if '#' != line[0]:
            raise Exception(f'expecting header had {line!r}')
        self._header_line = line
        self._state = 'receive_table_header_line_one'

    def receive_table_header_line_one(self, line):
        self._header_row_one = _parse_markdown_row(line)
        self._state = 'receive_table_header_line_two'

    def receive_table_header_line_two(self, line):
        row = _parse_markdown_row(line)
        for cel in row:
            if dash_dash_dash_rx.match(cel) is None:
                raise Exception('expecting /{rx.pattern}/ had {cel!r}')
        self._header_row_two = row
        self._can_finish = True
        self._example_row = None
        self._item_rows = None
        self._state = 'receive_maybe_example_row'

    def receive_maybe_example_row(self, line):
        row = _parse_markdown_row(line)
        if example_rx.match(row[-1]):
            self._example_row = row
            self._state = 'receive_first_business_item_row'
        else:
            self._example_row = None
            self._item_rows = [row]
            self._state = 'receive_subsequent_business_item_row'

    def receive_first_business_item_row(self, line):
        self._item_rows = [_parse_markdown_row(line)]
        self._state = 'receive_subsequent_business_item_row'

    def receive_subsequent_business_item_row(self, line):
        self._item_rows.append(_parse_markdown_row(line))

    def finish(self):
        del(self._mutex)
        if not self._can_finish:
            raise Exception('never reached second table header row')
        return _MarkdownTable(
                self._header_line,
                self._header_row_one,
                self._header_row_two,
                self._example_row,
                self._item_rows,
                )


dash_dash_dash_rx = re.compile(r'^-{3}$')  # ..
example_rx = re.compile(r'(^|\W)example($|\W)')
# example_rx = re.compile(r'\bexample\b')  unbelievable - '(', ')' are etc


class _MarkdownTable:
    def __init__(self, _1, _2, _3, _4, _5):
        self.header_line = _1
        self.header_row_one = _2
        self.header_row_two = _3
        self.example_row = _4
        self.business_rows = _5


def _parse_markdown_row(line):
    return tuple(x for x in _yield_markdown_table_cel_strings(line))


def _yield_markdown_table_cel_strings(line):
    # we would use regexp but we don't know how to do scanner

    last_cursor = len(line) - 1
    cursor = 0

    act = line[cursor]
    if '|' != act:
        raise Exception(f'expected pipe had {act!r} at {cursor}: {line!r}')
    cursor = 1
    while True:
        next_pipe = line.index('|', cursor)
        if next_pipe is None:
            raise Exception(f'no closing pipe: {line[cursor:]!r}')
        yield line[cursor:next_pipe]
        if last_cursor == next_pipe:
            break
        cursor = next_pipe + 1


class _MadParseLineSections:  # #wish, #pattern #[#458.Z.4] "mad parse"

    def __init__(self):
        self._state = 'receive_initial_line'
        self._sections = []
        self._stop_OK = False

    def receive_line(self, line):
        getattr(self, self._state)(line)

    def receive_initial_line(self, line):
        if _is_blank(line):
            raise Exception('blank line when beginning of section expected')
        self._current_section = [line]
        self._state = 'receive_subsequent_line'
        self._stop_OK = True

    def receive_subsequent_line(self, line):
        if _is_blank(line):
            self._rollover()
            self._stop_OK = False
            self._state = 'receive_initial_line'
        else:
            self._current_section.append(line)

    def finish(self):
        if not self._stop_OK:
            raise Exception('empty file or file ended on blank line')
        self._rollover()
        a = self._sections
        del(self._sections)
        return a

    def _rollover(self):
        self._sections.append(self._current_section)
        del(self._current_section)


def _is_blank(line):
    return '' == line

# #born.
