"""This was #born just to serve the objective of parsing schema files with

a recfiles-compatible syntax. We're targeting a subset-grammar: all schema.rec
files must parse as recfiles, but not all recfiles will parse with our
"ersatz scanner".

If we encounter a future with an actual storage adaptation for recfiles, it
seems almost certain that we can future-fit the below implementation while
preserving this "block scanner"-style interface for our one client.
"""

from kiss_rdb.magnetics_.string_scanner_via_definition import (
        Scanner,
        pattern_via_description_and_regex_string as o)


STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = False
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = True
STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS = ('.rec',)
STORAGE_ADAPTER_IS_AVAILABLE = True


def RESOLVE_SINGLE_FILE_BASED_COLLECTION_AS_STORAGE_ADAPTER(**kwargs):
    raise Exception('write me')  # [#876] cover me


class ErsatzScanner:

    def __init__(self, open_filehandle):
        toks = _tokenize_lines(open_filehandle)
        self._lineno_via = next(toks)
        self._line_via = next(toks)
        self._tokens = toks
        self.path = open_filehandle.name  # as parser_state
        self._has_on_deck = False

    def next_block(self, listener):

        which, line = self.__next_which_and_line()

        if 'content' == which:
            return _field_via_line(line, self, listener)

        if 'separator' == which:
            block = [line]
            for which, line in self._tokens:
                if 'separator' == which:
                    block.append(line)
                    continue
                if 'content' == which:
                    pass
                else:
                    assert('end_of_line_stream' == which)
                    which = 'closed'
                self._has_on_deck = True
                self._on_deck = (which, line)
                break
            return _SeparatorBlock(tuple(block))

        if 'end_of_line_stream' == which:
            self._close()
        else:
            assert('closed' == which)
        return _END

    def __next_which_and_line(self):
        if self._has_on_deck:
            self._has_on_deck = False
            which, line = self._on_deck
            self._on_deck = None
        else:
            which, line = next(self._tokens)
        return which, line

    def _close(self):
        self._tokens = None

    # -- as `parser_state`

    @property
    def lineno(self):
        return self._lineno_via()

    @property
    def line(self):
        return self._line_via()


def _field_via_line(line, parse_state, listener):

    def use_listener(*a):
        # add these two more elements of context on parse error
        *chan, pay = a
        chan = tuple(chan)
        assert(chan == ('error', 'structure', 'input_error'))
        dct = pay()
        dct['lineno'] = parse_state.lineno
        dct['path'] = parse_state.path
        listener(*chan, lambda: dct)

    # we black-box reverse-engineer a TINY part of recfiles

    scn = Scanner(line, use_listener)

    field_name = scn.scan_required(_field_name)
    if field_name is None:
        return  # (Case1414)

    # recfiles does not allow space between field name and colon

    _did = scn.skip_required(_colon)
    if not _did:
        return  # (Case1403)

    scn.skip(_space)

    posov = scn.pos  # posov = position of start of value

    content_s = scn.scan_required(_some_content)  # (Case1403) ⏛ [#867.Y]

    if content_s is None:
        return

    if content_s[0] in ('"', "'"):
        raise Exception(  # #not-covered
            "Can we please just not bother with quotes ever? "
            "It seems they may neve be necessary for us in these files "
            f"({repr(content_s)}")

    return _Field(field_name, content_s, posov)


_field_name = o('field name', r'[a-zA-Z][_a-zA-Z0-9]*')
# (real recsel doesn't allow multbyte in first char, or dashes anywhere)

_colon = o('colon', ':')

_space = o('space', '[ ]+')

_some_content = o('some content', r'[^\n]+')


class _Field:
    # property names are derived from names used in /usr/local/include/rec.h
    # however, we have inflected the names further with local conventions

    def __init__(self, nn, vv, posov):
        self.field_name = nn
        self.field_value_string = vv
        self.position_of_start_of_value = posov

    position_of_start_of_field_name = 0  # ..
    is_separator_block = False
    is_field_line = True
    is_end_of_file = False


class _SeparatorBlock:
    def __init__(self, block):
        self.lines = block
    is_separator_block = True
    is_field_line = False
    is_end_of_file = False


class _END:  # #as-namespace-only
    is_separator_block = False
    is_field_line = False
    is_end_of_file = True


def _tokenize_lines(lines):

    def lineno_future():
        return lineno
    lineno = 0
    yield lineno_future

    def line_future():
        return line
    line = None
    yield line_future

    for line in lines:
        lineno += 1
        if '\n' == line:
            yield 'separator', line
            continue
        if '#' == line[0]:
            yield 'separator', line
            continue
        yield 'content', line

    line = None
    yield 'end_of_line_stream', None

# #born.
