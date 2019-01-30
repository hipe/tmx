import re


class Scanner:
    """many others like it, but this one is ours

    attempts to wrap up higher-level behavior we always end up wanting
    when we hand-write our parsers.

    this attempts to improve deficencies, short-comings, or ill-fits from
    the competition

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
            return None
        else:
            self._position = m.end()
            return m.group(0)  # ..

    # == READ ONLY things

    def rest(self):  # name from ruby thing
        return self._line[self._position:]

    def eos(self):
        return self._length == self._position

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
            self.MUTATE_ERROR_STRUCTURE(dct)
            return dct
        self._listener('error', 'structure', 'input_error', struct)

    def MUTATE_ERROR_STRUCTURE(self, dct):  # todo
        dct['position'] = self._position
        dct['line'] = self._line  # #todo

    def _match(self, pattern):
        return pattern.regex.match(self._line, self._position)


def two_lines_of_ascii_art_via_position_and_line_USE_ME(  # #todo: coverage isl
        position, line, lineno=None, expecting=None, expecting_any_of=None,
        did_reach_end_of_stream=None,
        ):
    """given a possibly long line and a position, render it in 2 lines.

    something like this:

        "class Foo::Bar::09…"
        "----------------^"

    the second line is an ASCII "art" arrow pointing to the position.
    in effect, "zoom the camera in" to the area of interest in the string,
    possibly cutting of some left portion and some right portion of the
    string. use ellipsis to show cut-off as necessary.

    although this ONLY uses those first two arguments, for convenience this
    accepts the known superset of components of structured input errorrs.
    """

    pos = position
    left_side_max_context_characters = 8
    right_side_max_context_characters = 5
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

    _styled_excerpted_line_excerpt = repr(_)  # :#here

    # --
    _num_bars = pos - camera_left_pos
    _ascii_arrow = f" { '-' * _num_bars }^"  # glyphs ..
    # YIKES leading space above to jump over open quote from #here, BUT
    # by using `repr` you could get screwed in indeterminite ways..
    # --

    yield f"{indent}{_styled_excerpted_line_excerpt}"
    yield f"{indent}{_ascii_arrow}"


class pattern_via_description_and_regex_string:

    def __init__(self, desc, rx_string):
        self.description = desc
        self.regex = re.compile(rx_string)

# #born.
