"""
start by reading [#872] (it's pretty short).

the vendor toml library has a `dumps` function that stringifies
dictionaries into toml, but this has no means of producing multi-line
toml "surface strings", and even if it did we would anyway want a way
to configure its encodng behavior to meet our requirements.

so, a "string encoder" decides how we will represent a string in toml,
in terms of which of the four kinds of surface strings to use (see our doc),
and whether the string *can* even be allowed in to our storage, and if so,
exactly how to place the string into the file in terms of byte-for-byte
surface bytes (or "file bytes").

as for the specific constraints we enforce on strings, the authoritative
source for this is the unit tests!
"""

import re


class string_encoder_via_definition:

    def __init__(
            self,
            smaller_string_max_length,
            paragraph_line_max_width,
            max_paragraph_lines,
            ):

        assert(smaller_string_max_length < 79)  # idk
        assert(paragraph_line_max_width < 151)  # idk
        assert(1 < max_paragraph_lines)

        assert(smaller_string_max_length < paragraph_line_max_width)

        self.smaller_string_max_length = smaller_string_max_length
        self.paragraph_line_max_width = paragraph_line_max_width
        self.max_paragraph_lines = max_paragraph_lines

    def encode(self, string, listener):
        return _encode(string, self, listener)


def _encode(string, o, listener):

    # smaller_string_max_length = o.smaller_string_max_length
    paragraph_line_max_width = o.paragraph_line_max_width
    first_too_high_paragraph_line = o.max_paragraph_lines + 1

    line_no = 0

    line_iter = lines_via_big_string_(string)

    semi_encoded_lines = []

    def use_line_no():
        if 1 < line_no:
            return line_no
        _yes = has_one_more_line()
        return line_no if _yes else None

    def has_one_more_line():
        had_one_more_line = False
        for _ in line_iter:  # #once
            had_one_more_line = True
            break
        return had_one_more_line

    paragraph_had_one = False

    for line in line_iter:
        line_no += 1
        if first_too_high_paragraph_line == line_no:
            _yn = has_one_more_line()  # silly feature
            _whine_about_too_many_lines(listener, _yn, line_no, line, o)
            return  # (Case4185)

        if paragraph_line_max_width < len(line):
            _whine_about_line_too_long(listener, use_line_no(), line, o)
            return  # (Case4183)

        itr = _special_chars_rx.finditer(line)

        had_one = False
        for md in itr:  # #once
            had_one = True
            break

        if not had_one:
            semi_encoded_lines.append(line)
            continue

        paragraph_had_one = True

        escd_line = _escape_line(md, itr, line_no, listener)
        if not escd_line:
            return  # (Case4187)

        semi_encoded_lines.append(escd_line)

    """DISCUSSION: this is all experimental and in flux. originally the idea
    was, the encoder (us, here) would decide how to encode things based on
    thing like

    👉 whether the string was infact multi-line (more accurately, whether it
    has one or more newline character),

    👉 and things like whether it had any special characters.

    (hypothetically and perhap, the four permutations of the above two
    questions could determine which of the four surface forms of string
    you would use..)

    BUT NOW we think we might let the client make final decision of how
    to store the thing..
    """

    # (Case4188) - one line
    # (Case4182) - the empty string

    return _SemiEncodedString(
            has_special_characters=paragraph_had_one,
            semi_encoded_lines=tuple(semi_encoded_lines),
            )


class _SemiEncodedString:

    def __init__(self, has_special_characters, semi_encoded_lines):
        self.has_special_characters = has_special_characters
        self.semi_encoded_lines = semi_encoded_lines


def lines_via_big_string_(big_s):  # (ANOTHER copy-paste of [#610].)
    import re
    return (md[0] for md in re.finditer('[^\n]*\n|[^\n]+', big_s))


def _escape_line(md, itr, line_no, listener):

    self = _ThisState()
    self.cursor = 0
    pieces = []
    line = md.string

    def step():
        span_begin, span_end = md.span()
        special_char = md[0]
        _special_char_ord = ord(special_char)
        name, is_supported, *rest = _special_chars[_special_char_ord]
        if not is_supported:
            _whine_about_special_character_not_supported(  # (Case4187)
                    span_begin, name, line, line_no, listener)
            return
        escape_expession_right_hand_side, = rest

        # add any non-special span yet to be transferred
        if self.cursor < span_begin:
            pieces.append(line[self.cursor:span_begin])

        # escape expressions always start with one of these
        pieces.append('\\')

        # then
        pieces.append(escape_expession_right_hand_side)

        self.cursor = span_end
        return _okay

    # do one "step" for this known existing matchdata
    if not step():
        return

    # for the zero or more remaining matches in the line,
    for md in itr:
        if not step():
            return

    # if the last match didn't end on the string, flush the rest
    length = len(line)
    if self.cursor != length:
        pieces.append(line[self.cursor:length])  # #here1

    return ''.join(pieces)


class _ThisState:  # #[#510.2]
    pass


# == whiners

def _whine_about_special_character_not_supported(
        pos, name, line, line_no, listener):

    _use_name = name.lower()
    _already_has = re.search(' character$', name)
    _characters = 's' if _already_has else ' characters'

    _reason = (
            f'for now, {_use_name}{_characters} are deemed '
            'not pretty enough to store.'
            )

    def structer():
        return {
                'reason': _reason,
                'position': pos,
                'line': line,
                # 'lineno': line_no,  # wrong line number
                }
    _emit_input_error(listener, structer)


def _whine_about_line_too_long(listener, line_number, line, o):

    if line_number is None:
        np = 'string'
    else:
        np = f'line {line_number} of multi-line string'

    _limit = o.paragraph_line_max_width
    _reason = f'{np} is {len(line)} characters long. cannot exceed {_limit}.'
    _emit_input_error_about_string(listener, _reason, line)


def _whine_about_too_many_lines(listener, has_more, line_number, line, o):

    _max = line_number - 1
    _more_than = ' more than' if has_more else ''
    _reason = (
            f'multi-line string cannot exceed {_max} lines '
            f'(had{_more_than} {line_number}).'
            )
    _emit_input_error_about_string(listener, _reason, line)


def _emit_input_error_about_string(listener, reason, line):
    def structer():
        return {
                'reason': reason,
                'line': line,
        }
    _emit_input_error(listener, structer)


def _emit_input_error(listener, structer):
    listener('error', 'structure', 'input_error', structer)


# ==

"""
the policy for how we encode (or don't encode) which "special characters"
is encompased in the below regex and table.

we start from the toml doc saying, "these must be escaped: U+0000 to U+001F,
U+007F.". these comprise most of the entries in the below "table". however:

👉 we don't treat newline as a special character; rather we pass them thru
because we are producing multi-line strings for all strings that have
newlines in them, so they are always represented directly.

👉 as you can see by how the "no"s outweigh the "yes"s, we explicity decline
to support most of these special characters (for now). this is towards
broad provision 1, that we exist to store data that can be human readable.

the contentious one is our declinng to support soft tabs. this could easily
change.

more at [#872] "why we implement string encoding (escaping) ourselves"
"""


_special_chars_rx = re.compile(
        '['
        '\u0000-\u0009'  # stop short of the newline, only those first 10
        '\u000B-\u001F'  # from offset 11 to offset 31
        '\u0022'  # quote
        '\\\\'    # backslash (U+005C) (yes to get it in there we need 4 for 1)
        '\u007F'  # delete
        ']'
        )


no = False
yes = True

_special_chars = {
    0:   ("Null character",                  no),        # U+0000 NUL
    1:   ("Start of Heading",                no),        # U+0001 SOH
    2:   ("Start of Text",                   no),        # U+0002 STX
    3:   ("End-of-text character",           no),        # U+0003 ETX
    4:   ("End-of-transmission character",   no),        # U+0004 EOT
    5:   ("Enquiry character",               no),        # U+0005 ENQ
    6:   ("Acknowledge character",           no),        # U+0006 ACK
    7:   ("Bell character",                  no),        # U+0007 BEL
    8:   ("Backspace",                       no),        # U+0008 BS  '\b'
    9:   ("Horizontal tab",                  no),        # U+0009 HT  '\t'
    10:  ("Line feed",                       no),        # U+000A LF  '\n'
    11:  ("Vertical tab",                    no),        # U+000B VT
    12:  ("Form feed",                       no),        # U+000C FF  '\f'
    13:  ("Carriage return",                 no),        # U+000D CR  '\r'
    14:  ("Shift Out",                       no),        # U+000E SO
    15:  ("Shift In",                        no),        # U+000F SI
    16:  ("Data Link Escape",                no),        # U+0010 DLE
    17:  ("Device Control 1",                no),        # U+0011 DC1
    18:  ("Device Control 2",                no),        # U+0012 DC2
    19:  ("Device Control 3",                no),        # U+0013 DC3
    20:  ("Device Control 4",                no),        # U+0014 DC4
    21:  ("Negative-acknowledge character",  no),        # U+0015 NAK
    22:  ("Synchronous Idle",                no),        # U+0016 SYN
    23:  ("End of Transmission Block",       no),        # U+0017 ETB
    24:  ("Cancel character",                no),        # U+0018 CAN
    25:  ("End of Medium",                   no),        # U+0019 EM
    26:  ("Substitute character",            no),        # U+001A SUB
    27:  ("Escape character",                no),        # U+001B ESC
    28:  ("File Separator",                  no),        # U+001C FS
    29:  ("Group Separator",                 no),        # U+001D GS
    30:  ("Record Separator",                no),        # U+001E RS
    31:  ("Unit Separator",                  no),        # U+001F US
    127: ("Delete",                          no),        # U+007F DEL
    # (end of the above list)
    34:  ("Quote",                          yes, '"'),   # U+0022     \"
    92:  ("Backslash",                      yes, '\\'),  # U+005C     \\
    #     any unicode character (these ones)                       \uXXXX
    #     any unicode character                                    \UXXXXXXXX
}


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_okay = True

# #born.
