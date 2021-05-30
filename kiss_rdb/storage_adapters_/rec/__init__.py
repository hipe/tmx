"""This was #born just to serve the objective of parsing schema files with

a recfiles-compatible syntax. We're targeting a subset-grammar: all schema.rec
files must parse as recfiles, but not all recfiles will parse with our
"ersatz scanner".

If we encounter a future with an actual storage adaptation for recfiles, it
seems almost certain that we can future-fit the below implementation while
preserving this "block scanner"-style interface for our one client.

This is the external thing: [GNU Recutils][1] (and this [example][2]).

Reminder: `recsel`

And so yes, at #history-B.4 we spike a not-covered prototype of collectionism

[1]: https://www.gnu.org/software/recutils/
[2]: https://www.gnu.org/software/recutils/manual/A-Little-Example.html
"""

from text_lib.magnetics.string_scanner_via_string import \
        StringScanner, pattern_via_description_and_regex_string as o


STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = False
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = True
STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS = ('.rec',)
STORAGE_ADAPTER_IS_AVAILABLE = True


def FUNCTIONSER_FOR_SINGLE_FILES():
    class fxr:  # #class-as-namespace
        PRODUCE_EDIT_FUNCTIONS_FOR_SINGLE_FILE = None

        def PRODUCE_READ_ONLY_FUNCTIONS_FOR_SINGLE_FILE():
            return _read_funcs

        PRODUCE_IDENTIFIER_FUNCTIONER = None
    return fxr


# == BEGIN #cover-me all of #history-B.4

class _read_funcs:  # #class-as-namespace

    def schema_and_entities_via_lines(lines, listener):
        return _schema_and_entities_via_lines(lines, listener)


def _schema_and_entities_via_lines(lines, listener):
    scn = ErsatzScanner(lines)
    itr = _chunks_of_fields(scn, listener)

    def entities():
        for chunk in itr:

            dct = {}
            for fld in chunk:
                k = fld.field_name
                if k in dct:
                    raise RuntimeError(f"wat do: collision: {k!r}")
                dct[k] = fld.field_value_string

            yield _MinimalIdentitylessEntity(dct)

    return None, entities()


class _MinimalIdentitylessEntity:
    def __init__(self, core_attrs):
        self.core_attributes = core_attrs


def _chunks_of_fields(scn, listener):  # #[#508.2] chunker

    cache = []

    def flush():
        ret = tuple(cache)
        cache.clear()
        return ret

    while True:
        blk = scn.next_block(listener)
        if blk.is_field_line:
            cache.append(blk)
            continue
        if blk.is_separator_block:
            if cache:
                yield flush()
            continue
        if blk.is_end_of_file:
            break

    if cache:
        yield flush()


# == END

class ErsatzScanner:

    def __init__(self, open_filehandle):
        self._lines = _LineTokenizer(open_filehandle)
        self.path = open_filehandle.name  # #here1

    def next_block(self, listener):
        if self._lines.empty:
            del self._lines
            return _END
        typ = self._lines.line_type
        if 'content_line' == typ:
            return self._finish_field(listener)

        assert 'separator_line' == typ
        return self._finish_separator_block()

    def _finish_field(self, listener):
        """
        SHAMELESSLY HACKING MULTI-LINE FIELDS
        (but we really need proper vendor parsing!)

        Interestingly, the vendor parser has to parse "field" lines
        right-to-left, because whether or not the line ends with a '\'
        determines whether to etc or to etc
        """

        tox = self._lines
        scn = tox._LINE_SCANNER_
        line = scn.peek

        # Take a snapshot of the "parser state" (line and linenumber) now,
        # for any errors that occur in creating the field. (Parsing multiline
        # field requires one line of lookahead so the line scanner is not a
        # reliable steward of these two.) If this is ugly, just pass the
        # line and line number as arguments to the requisite functions

        self.line = line
        self.lineno = tox.lineno
        tox.advance()

        if '\\' != line[-2]:  # (assume line has content)
            return _field_via_line(line, self, listener)

        # MULTI-LINE

        hax = _field_via_line(line, self, listener)
        if hax is None:
            return

        pieces = [hax.field_value_string[:-1]]  # chop trailing backslash

        while True:
            scn.advance()
            if scn.empty:
                xx("above line was continuator, now is EOF. not covering this")
            line = scn.peek
            if '\n' == line:
                xx("we don't want to support a blank line after contination "
                   "for now because we haven't needed it yet")
            if '+' == line[0]:
                xx("no support for plus sign yet (but would be trivial) "
                   "because we never needed it yet")
            if '\\' == line[-2]:
                # This line is the continuation of the above line,
                # and also it is a continuator itself
                pieces.append(line[:-2])
                continue

            # This line is the continuation of the above line but not
            # itself a continuator
            pieces.append(line[:-1])
            scn.advance()
            break

        tox._UPDATE_()  # determine line type of current line
        hax.field_value_string = ''.join(pieces)  # EEK
        return hax

    def _finish_separator_block(self):
        lines = [self._lines.line]
        while True:
            self._lines.advance()
            if self._lines.empty:
                break
            if 'separator_line' != self._lines.line_type:
                break
            lines.append(self._lines.line)
        return _SeparatorBlock(tuple(lines))


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

    scn = StringScanner(line, use_listener)

    field_name = scn.scan_required(_field_name)
    if field_name is None:
        return  # (Case1414)

    # recfiles does not allow space between field name and colon

    _did = scn.skip_required(_colon)
    if not _did:
        return  # (Case1403)

    scn.skip(_space)

    posov = scn.pos  # posov = position of start of value

    content_s = scn.scan_required(_some_content)  # (Case1403) ⏛ [#873.5]

    if content_s is None:
        return

    if False and content_s[0] in ('"', "'"):
        # allow literal quotes in values since #history-B.6
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


class _LineTokenizer:

    def __init__(self, fh):
        lib = _scnlib()
        self._scn = lib.scanner_via_iterator(fh)
        self._current_line_offset_via = lib.MUTATE_add_counter(self._scn)
        # (we use "peek" to mean "current line" yikes)
        self.line_type = None
        self._update()

    def advance(self):
        self._scn.advance()
        self._update()

    def _update(self):
        if self._scn.empty:
            del self.line_type
            return
        self.line_type = _line_type(self.line)

    _UPDATE_ = _update

    @property
    def line(self):
        return self._scn.peek

    @property
    def lineno(self):
        return self._current_line_offset_via() + 1

    @property
    def empty(self):
        return self._scn.empty

    @property
    def more(self):
        return self._scn.more

    @property
    def _LINE_SCANNER_(self):  # call UPDATE after advancing omg
        return self._scn


def _line_type(line):
    if '\n' == line:
        return 'separator_line'
    if '#' == line[0]:
        return 'separator_line'
    return 'content_line'


# ==

def _scnlib():
    from text_lib.magnetics import scanner_via as module
    return module


def xx(msg=None):
    raise RuntimeError('ohai' + ('' if msg is None else f": {msg}"))


# #history-B.5
# #history-B.4
# #born.
