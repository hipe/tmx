import re


class Scanner:  # #[#008.4] a scanner
    """many others like it, but this one is ours

    attempts to wrap up higher-level behavior we always end up wanting
    when we hand-write our parsers.

    this attempts to improve deficiencies, short-comings, or ill-fits from
    the competition

      - declaratively associate a business description with your regex
      - our higher-level doo-hah with error message generation
      - smaller API: you must use our custom pattern class to define symbols

    the permutations are something like "{skip|scan} [required]".
      - we have only created the ones we needed for our use case but etc
      - currently there is no lookahead/peek variants but that is only bc above
    """

    def __init__(self, line, listener):
        self._length = len(line)
        self._position = 0
        self._line = line
        self._listener = listener

    # == SKIPS

    def skip_required(self, pattern):
        m = self._required(pattern)
        if m is None:
            return None
        else:
            return self._advance_for_skip(m)

    def skip(self, pattern):
        m = self._match(pattern)
        if m is None:
            return None
        else:
            return self._advance_for_skip(m)

    def _advance_for_skip(self, m):
        end = m.end()
        width = end - self._position
        self._position = end
        return width

    # == SCANS

    def scan_required(self, pattern):
        m = self._required(pattern)
        if m is None:
            return
        return self._advance_for_scan(m)

    def scan(self, pattern):
        m = self._match(pattern)
        if m is None:
            return
        return self._advance_for_scan(m)

    def _advance_for_scan(self, m):
        self._position = m.end()
        return m.group(0)  # ..

    # == READ ONLY things

    def rest(self):  # #cover-me
        return self._line[self._position:]

    def eos(self):
        return self._length == self._position

    @property
    def pos(self):
        return self._position

    @property
    def listener(self):
        return self._listener

    # ==

    def _required(self, pattern):
        m = self._match(pattern)
        if m is None:
            self.__emit_input_error_for_single_pattern(pattern)
        else:
            return m

    def __emit_input_error_for_single_pattern(self, pattern):
        def struct():
            dct = {'expecting': pattern.description}
            self.mutate_error_structure(dct)
            return dct
        self._listener('error', 'structure', 'input_error', struct)

    def mutate_error_structure(self, dct):
        dct['position'] = self._position
        dct['line'] = self._line

    def _match(self, pattern):
        return pattern.regex.match(self._line, self._position)


def two_lines_of_ascii_art_via_position_and_line(position, line):
    """given a possibly long line and a position, render it in 2 lines.

    something like this:

        "class Foo::Bar::09…"
        "----------------^"

    the second line is an ASCII "art" arrow pointing to the position.
    in effect, "zoom the camera in" to the area of interest in the string,
    possibly cutting of some left portion and some right portion of the
    string. use ellipsis to show cut-off as necessary.
    """

    pos = position
    left_side_max_context_characters = 8
    right_side_max_context_characters = 20  # was 5 before #history-A.1
    indent = '    '  # 4x
    ellipsis_CHARACTER = '…'
    # --
    # show at most N characters to the left of the position
    # so move the "camera" to the right if necessary
    if left_side_max_context_characters < pos:
        camera_left_pos = pos - left_side_max_context_characters
        did_cut_off_left_side = True
    else:
        camera_left_pos = 0
        did_cut_off_left_side = False

    # don't count a trailing newline in width calculations *or* production

    if len(line) and '\n' == line[-1]:
        line = line[:-1]

    # show at most M characters to the right of the position
    # so we might cut off a right portion of the string
    line_length = len(line)
    width_to_right_of_pos = line_length - pos
    if right_side_max_context_characters < width_to_right_of_pos:
        camera_right_pos = pos + right_side_max_context_characters + 1
        did_cut_off_right_side = True
    else:
        camera_right_pos = line_length
        did_cut_off_right_side = False

    # --

    _ = line[camera_left_pos:camera_right_pos]

    if did_cut_off_left_side:
        _ = f"{ellipsis_CHARACTER}{_[1:]}"

    if did_cut_off_right_side:
        _ = f"{_[0:-1]}{ellipsis_CHARACTER}"

    _styled_excerpted_line_excerpt = _

    # (used to do repr() above, gone at #history-A.1)

    # --
    _num_bars = pos - camera_left_pos
    _ascii_arrow = f"{'-' * _num_bars}^"  # glyphs ..
    # --

    yield f"{indent}{_styled_excerpted_line_excerpt}"
    yield f"{indent}{_ascii_arrow}"


class pattern_via_description_and_regex_string:

    def __init__(self, desc, rx_string, *flags):
        self.description = desc
        self.regex = re.compile(rx_string, *flags)

# #pending-rename: move this to that one place
# #history-A.1
# #born.
