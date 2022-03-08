"""We imagine this core file as having a lifecycle of three phases:

Phase 1: hand-written parser of a subset of the recfiles grammar
         just for parsing `schema.rec` files.
Phase 2: sub-process out to recutils executables, parse their results
Phase 3: use c-bindings

At writing (#history-B.7) we are making Phase 2. We don't want to break
the Phase 1 work: parsing the subset grammar by hand just to get schema.rec
to parse.

Ultimately we are interesting in pursuing Phase 3, but that is out of scope
for now.

In transition from Phase 1 to Phase 2, we won't know exactly what to expect
from the recutils executables in terms of its output structure; so we will
hold off at first from eliminating all redundancies between 1 & 2 until
we have the new work of Phase 2 stable & covered.

One example of this being a challenge: at #here2 we complain when our
schema.rec files have a name collision of field names within one record.
But this is perfectly allowable in native recfiles.

This is the external thing: [GNU Recutils][1] (and this [example][2]).

Reminder: `recsel`

- At #history-B.7 we sub-process out to real recsel
- At #history-B.5 we added create collection
- At #history-B.4 we spike not-yet-covered prototype of collectionism (?)

[1]: https://www.gnu.org/software/recutils/
[2]: https://www.gnu.org/software/recutils/manual/A-Little-Example.html
"""

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
                if k in dct:  # #here2
                    raise RuntimeError(f"wat do: collision: {k!r}")
                dct[k] = fld.field_value_string

            yield _MinimalIdentitylessEntity(dct)

    return None, entities()


def NATIVE_RECORDS_VIA_LINES(lines, listener):
    # NOTE this intentionally has known holes in it, holding off until etc

    # from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    # scn = func(lines)

    def from_beginning_state():
        yield if_field_line, move_to_main_state

    def from_inside_record():
        yield if_field_line, process_field_line
        yield if_blank_line, yield_record

    # == matchers

    def if_field_line():
        return not '\n' == line

    def if_blank_line():
        return '\n' == line

    # == actions

    def move_to_main_state():
        process_field_line()
        state.current_state = from_inside_record

    def process_field_line():
        pos = line.index(':')
        native_field_name = line[0:pos]
        assert ' ' == line[pos+1]  # ..
        value_but = line[pos+2:-1]
        dct = state.experimental_mutable_record_dict
        if native_field_name in dct:
            arr = dct[native_field_name]
        else:
            dct[native_field_name] = (arr := [])
        arr.append(value_but)

    def yield_record():
        dct = state.experimental_mutable_record_dict
        state.experimental_mutable_record_dict = {}
        return 'yield_this', dct

    state = yield_record  # #watch-the-world-burn
    state.current_state = from_beginning_state
    state.experimental_mutable_record_dict = {}

    lineno = 0
    for line in lines:
        lineno += 1

        found = None
        for matcher, action in state.current_state():
            yes = matcher()
            if not yes:
                continue
            found = action
            break
        if not found:
            nm = state.current_state.__name__
            xx(f"{nm}, unexpected line: {line!r}")
        opcode = found()
        if not opcode:
            continue
        directive, data = opcode
        assert 'yield_this' == directive
        yield data


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
        self._use_field_via_line = _field_via_line_function()
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
            return self._field_via_line(line, listener)

        # MULTI-LINE

        raise("Hello this needs covering/work. Look at what we were up to")

        hax = self._field_via_line(line, listener)
        if hax is None:
            return

        pieces = [hax.field_value_string[:-1]]  # chop trailing backslash

        while True:
            line = scn.peek
            scn.advance()

            if scn.empty:
                xx("above line was continuator, now is EOF. not covering this")
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

    def _field_via_line(self, line, listener):
        return self._use_field_via_line(line, self._path_and_lineno, listener)

    def _path_and_lineno(self):
        return self.path, self.lineno


def _field_via_line_function():
    memo = _field_via_line_function
    if not hasattr(memo, 'the_value'):
        memo.the_value = _build_function_called_field_via_line()
    return memo.the_value


def _build_function_called_field_via_line():

    def field_via_line(line, path_and_lineno_er, listener):
        # we black-box reverse-engineer a TINY part of recfiles

        def use_listener(*a):
            # add these two more elements of context on parse error
            *chan, pay = a
            chan = tuple(chan)
            assert chan == ('error', 'structure', 'input_error')
            dct = pay()
            path, lineno = path_and_lineno_er()
            dct['path'] = path
            dct['lineno'] = lineno
            listener(*chan, lambda: dct)

        scn = StringScanner(line, use_listener)

        # Scan a field name
        field_name = scn.scan_required(field_name_pattern)
        if field_name is None:
            return  # (Case1414)

        # Recfiles does not allow space between field name and colon
        _did = scn.skip_required(colon)
        if not _did:
            return  # (Case1403)

        scn.skip(space)
        value_start_pos = scn.pos
        content_s = scn.scan_required(some_content)  # (Case1403) ⏛ [#873.5]
        if content_s is None:
            return

        # allow literal quotes in values since #history-B.6
        return _Field(field_name, content_s, value_start_pos)

    from text_lib.magnetics.string_scanner_via_string import \
            StringScanner, pattern_via_description_and_regex_string as o

    field_name_pattern = o('field name', r'[a-zA-Z][_a-zA-Z0-9]*')
    # (real recsel doesn't allow multbyte in first char, or dashes anywhere)

    colon = o('colon', ':')
    space = o('space', '[ ]+')
    some_content = o('some content', r'[^\n]+')

    return field_via_line


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

def OPEN_PROCESS(recfile, listener):
    # (if this works, this will get abstracted so we seaparate different
    # kind of recsel (and the rest) type calls

    import subprocess as sp
    proc = sp.Popen(
        args=('recsel', recfile),
        shell=False,  # if true, the command is executed through the shell
        cwd='.',
        stdin=sp.DEVNULL,
        stdout=sp.PIPE,
        stderr=sp.PIPE,
        text=True,  # give me lines, not binary
    )

    def close_both():
        proc.stdout.close()
        proc.stderr.close()

    class ContextManager:
        def __init__(self):
            self.did_terminate = False  # here not __enter__ b.c iterator

        def __enter__(self):
            for line in proc.stdout:
                yield line

            lines = []
            maxi = 3
            did_reach_maxi = False
            for line in proc.stderr:
                if maxi == len(lines):
                    did_reach_maxi = True
                    break
                lines.append(line)

            rc = proc.wait()

            # (warnings if we don't do this)
            close_both()
            self.did_terminate = True

            rc_is_ok = 0 == rc
            if rc_is_ok and 0 == len(lines):
                return
            def lineser():
                if 0 == len(lines):
                    yield f"recsel had existatus: {rc}"
                    yield "(no messages to stderr?)"
                    return
                for line in lines:
                    yield line
                if rc_is_ok:
                    return
                yield f"(exitstatus: {rc})"
            listener('error', 'expression', 'recsel_failure', lineser)

        def __exit__(self, *_):
            if self.did_terminate:
                return
            proc.wait()
            close_both()

    return ContextManager()

# ==

def CREATE_COLLECTION(collection_path, listener, is_dry, opn=None):
    from ._create_collection import create_collection as func
    return func(collection_path, listener, is_dry, opn=opn)


# ==

def _scnlib():
    from text_lib.magnetics import scanner_via as module
    return module


def xx(msg=None):
    raise RuntimeError('ohai' + ('' if msg is None else f": {msg}"))


# #history-B.7
# #history-B.6
# #history-B.5
# #history-B.4
# #born.
