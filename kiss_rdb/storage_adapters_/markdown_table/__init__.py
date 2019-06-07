"""NOTE this was #born only to bootstrap the development of the canon
"""
import re


def resolve_collection_via_file(opened, path, listener):

    if opened is None:
        try:
            opened = open(path)
        except FileNotFoundError as e_:
            e = e_

    if opened is None:
        assert(e)
        return _whine_about_collection_not_found(listener, lambda: str(e))

    with opened as fh:
        proto_tables = _cached_proto_tables_via_filehandle(fh).execute()

    num_tables = len(proto_tables.children)

    if 0 == num_tables:
        return __whine_about_no_tables(listener, proto_tables, path)

    if 1 < num_tables:
        return __whine_about_too_many_tables(listener, proto_tables, path)

    return proto_tables.children[0]  # ..


class _MUTABLE_Cached_Table:

    def __init__(self, header_line, inner):
        self.HEADER_LINE = header_line
        self.INNER = inner
        self.ENTITY_LINES = []

    def ACCEPT_SECOND_LINE(self, x):
        self.SECOND_LINE = x

    def APPEND_ENTITY_LINE(self, line):
        self.ENTITY_LINES.append(line)

    def to_identifier_stream_as_storage_adapter_collection(self):

        self._pop_inner()  # not used

        rx = re.compile(r"""^
            \|[ ]*  # skip over the head-anchored leading pipe and any whites
            (  # capture:
                [^\|\n]*  # zero or more not-pipes
                [^\|\n]  # make sure you land on one not pipe or space
            )
            [ ]*  # skip over space between here and any next pipe
            (?:\|[^\]\n]*)*  # ZERO or more pipes then not pipes (not clever)
        $""", re.VERBOSE)

        from kiss_rdb.magnetics_.identifier_via_string import (
                identifier_via_string__ as iid_via_s)  # #todo - change name

        from kiss_rdb import THROWING_LISTENER as listener

        _itr = self._pop_entity_line_iterator()
        for line in _itr:
            md = rx.match(line)
            # ..
            yield iid_via_s(md[1], listener)

    def to_entity_stream_as_storage_adapter_collection(self):

        field_names = self._flush_normal_field_names()

        # NOW, as it is traversed, parse each row "forgivingly", assuming
        # only that the line starts with a newline

        _rx_for_entity_line_parse = re.compile(r"""^
            \|
            (.+)  # ick/meh
        $""", re.VERBOSE)

        from kiss_rdb.magnetics_.identifier_via_string import (
                identifier_via_string__ as iid_via_s)  # #todo - change name

        from kiss_rdb import THROWING_LISTENER as listener

        num_columns = len(field_names)
        num_columns_plus_one = num_columns + 1

        _itr = self._pop_entity_line_iterator()
        for line in _itr:
            md = _rx_for_entity_line_parse.match(line)
            # ..
            contents = [s.strip() for s in md[1].split('|')]
            # one "content" is the content string of one cel (maybe '')

            """
            TL;DR: a tail-anchored pipe is hard to interpret correctly.

            An undocumented provision is that you can't store blank strings,
            empty strings or the "null value"; for at least two reasons: One,
            it's an intentional trade-off to allow for more aesthetic/readable
            surface forms. Two, we don't *want* to support the distinction,
            because in practice this infects business code with the smell of
            not knowing whether you need to check for null/empty/blank for a
            given value, a smell that oftens spreads deep into the code.

            Rather, we conflate all such cases into one we call "no-value",
            and we leave it up to the client to decide how or whether to
            represent a value whose key isn't present in the entity-as-dict.

            Also for reasons, we do not require that the entity row express
            those of its contiguous cel values that are no-value and also
            anchored to the tail of the line.

            This is to say:
                |foo|bar||||||||
            is the same as:
                |foo|bar|

            `man git-log` brings up the distinction bewteen
            > "terminator" semantics and "separator" semantics.
            This distinction between these two categories becomes relevant
            here with our interpretation of the pipe ("|").

            Also we allow for an optional, decorative trailing pipe on any
            row (that's not the first or maybe second row, that is the
            "the table head"). This is to say that all these are the same:

                |foo|bar||||||||
                |foo|bar|
                |foo|bar

            Combining the two broad principles above; namely that no-value
            expressions are not required when tail-anchored, and that any
            trailing pipe might be decorative; we cannot know how many field
            values the row intends to express just by looking at it. So:
            """

            if num_columns_plus_one == len(contents) and '' == contents[-1]:
                contents.pop()  # (Case2587)
                # (but otherwise, let excessively long rows thru to error belo)

            iid = iid_via_s(contents[0], listener)  # ..

            _ = tuple((i, contents[i]) for i in range(1, len(contents)))

            _wow = {field_names[i]: s for i, s in _ if s is not ''}

            yield _RowAsEntity(iid, _wow)

    def _flush_normal_field_names(self):
        # resolve normal field names

        inner = self._pop_inner()

        def normal_field_name_of(content):
            # treat dashes, spaces, and underscores as all one unified separato
            _pieces = re.split(r'[- _]', content)
            return '-'.join(normal_piece_via_piece(piece) for piece in _pieces)

        def normal_piece_via_piece(piece):
            # lowercase the piece unless it is all caps EXPERIMENTAL
            if re.match(r'^[A-Z]+$', piece):
                return piece
            return piece.lower()

        return tuple(normal_field_name_of(s.strip()) for s in inner.split('|'))

    def _pop_inner(self):
        inner = self.INNER
        del self.INNER
        return inner

    def _pop_entity_line_iterator(self):
        itr = self.ENTITY_LINES
        del self.ENTITY_LINES
        return itr


class _RowAsEntity:

    def __init__(self, iid, yes_value_dict):
        self.identifier = iid
        self.yes_value_dictionary = yes_value_dict


# == RESOLVING THE CACHED LINES FROM A FILE


class _cached_proto_tables_via_filehandle:

    def __init__(self, fh):
        self._filehandle = fh

    def execute(self):

        fh = self._filehandle
        del self._filehandle

        self._lineno = 0
        self._last_header_line = None
        self._current_MUTABLE_proto_table = None
        self._state = self._when_ready
        self._cached_proto_tables = []

        for line in fh:
            self._lineno += 1
            self._process_line(line)

        self._state(None)
        self._step()  # :#here1

        return _CachedTableLines(
                tuple(self._cached_proto_tables), self._lineno)

    def _when_ready(self, line):
        if '\n' == line:
            return
        if line is None:
            return  # assuming #here1
        char = line[0]
        if '|' == char:
            md = _table_open_line_rx.match(line)
            if not md:
                not_covered('when line starts with pipe but is not table open')
            # self._last_header_line can be None (Case2519)
            self._step()
            self._current_MUTABLE_proto_table = _MUTABLE_Cached_Table(
                    self._last_header_line, md[1])
            self._last_header_line = None
            return self._when_after_table_open
        if '#' == char:
            self._last_header_line = line
            return
        self._last_header_line = None

    def _when_after_table_open(self, line):
        if line is None:
            not_covered('when file ends after table open but b4 metrics line')
        if '|' != line[0]:
            not_covered("whine line after table open doesn't look like metrix")
        self._current_MUTABLE_proto_table.ACCEPT_SECOND_LINE(line)
        return self._when_inside_table_body

    def _when_inside_table_body(self, line):
        if line is None:
            # end of file when inside table, no big woop if #here1 (Case2519)
            return
        char = line[0]
        if '|' == char:
            self._current_MUTABLE_proto_table.APPEND_ENTITY_LINE(line)
            return
        self._state = self._when_ready
        self._process_line(line)

    def _process_line(self, line):
        f = self._state(line)
        if f is None:
            return
        self._state = f

    def _step(self):
        if self._current_MUTABLE_proto_table is None:
            return
        self._cached_proto_tables.append(self._current_MUTABLE_proto_table)
        self._current_MUTABLE_proto_table = None


_table_open_line_rx = re.compile(r'^\|([^\|]+(?:\|[^\|]+)+)\|$')


class _CachedTableLines:

    def __init__(self, cx, num_lines):
        self.num_lines = num_lines
        self.children = cx


# == whiners

def __whine_about_too_many_tables(listener, cached_proto_tables, path):
    def reasoner():
        return (f'found {num_tables} markdown tables, '
                f'for now can only have one - {path}')
    num_tables = len(cached_proto_tables.children)
    _whine_about_collection_not_found(listener, reasoner)


def __whine_about_no_tables(listener, cached_proto_tables, path):
    def reasoner():
        return f'no markdown table found in {num_lines} lines - {path}'
    num_lines = cached_proto_tables.num_lines
    _whine_about_collection_not_found(listener, reasoner)


def _whine_about_collection_not_found(listener, reasoner):
    _emit_collection_not_found(listener, lambda: {'reason': reasoner()})


def _emit_collection_not_found(listener, structer):
    def use_structer():
        dct = structer()
        dct['reason'] = f"collection not found: {dct['reason']}"
        return dct
    listener('error', 'structure', 'collection_not_found', use_structer)


def not_covered(when):
    raise Exception(f'edge case not covered: {when}')

# #born.
