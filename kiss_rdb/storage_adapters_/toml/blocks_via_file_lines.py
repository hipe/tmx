"""at writing the main interesting thing this module contains is only an

"actions" class that is injected into the parser.

these actions implement "block stream"

new a #birth is blocks
"""

from .identifiers_via_file_lines import (
        BaseActions_,
        table_start_line_via_line_,
        nothing, stop, okay)
from modality_agnostic.memoization import lazy


@lazy
class attribute_name_functions_:
    def __init__(self):
        self.name_gist_via_name = _build_name_gist_via_name()


def _build_name_gist_via_name():

    from kiss_rdb.magnetics_.string_scanner_via_definition import (
            Scanner,
            pattern_via_description_and_regex_string as o,
            )

    # define some reflexive regexes

    all_LC_or_UC = o(
        'all lowercase or all uppercase attribute name piece',
        r'[a-z0-9]+|[A-Z0-9]+')

    stacey_dash = o('dash', '-')

    # exactly_one_space = o('exactly one space', ' ')

    # equals_sign = o('equals sign', '=')

    # use them:

    def name_gist_via_name(attr_name_string, listener):
        # (before #history-A.1, this was how _AttributeName was built

        scn = Scanner(attr_name_string, listener)
        pieces = []
        while True:
            s = scn.scan_required(all_LC_or_UC)
            if s is None:
                return
            pieces.append(s)
            if scn.eos():
                break
            if not scn.skip_required(stacey_dash):
                return
        return ''.join(s.lower() for s in pieces)

    return name_gist_via_name


def block_stream_via_file_lines(file_lines, listener):

    from . import identifiers_via_file_lines as grammar_lib

    return grammar_lib.state_machine_.parse(
            all_lines=file_lines,
            actions_class=ActionsForCoarseBlockParse_,
            listener=listener)


class ActionsForCoarseBlockParse_(BaseActions_):
    # again, [#863] diagrams the state machine here

    def __init__(self, parse_state):
        listener = parse_state.listener

        def f(line):
            return table_start_line_via_line_(line, listener)
        self._table_start_via_line = f
        self._parse_state = parse_state

    def ready__to__table_begun(self):
        ts = self._parse_table_start()
        if ts is None:
            return stop
        self.begin_table_with_(ts)

        # (Case4100): even if there are no head lines in file, yield out
        # this empty head block so consumers can be written more simply
        return (okay, _empty_head_block)

    def ready__to__discretionary_block_1(self):
        _mhb = _AppendableHeadBlock([self._current_line()])  # eek
        self._current_appendable_head_block = _mhb

    def ready__to__done(self):
        return nothing  # (Case4096) truly empty file yields out nothing

    def discretionary_block_1__to__discretionary_block_1(self):
        self._current_appendable_head_block._append_line(self._current_line())

    def discretionary_block_1__to__table_begun(self):
        hb = self._release_head_block()
        ts = self._parse_table_start()
        if ts is None:
            return stop
        self.begin_table_with_(ts)
        return (okay, hb)

    def discretionary_block_1__to__done(self):
        return (okay, self._release_head_block())  # (Case4095) virtually empty

    def table_begun__to__inside_table(self):
        self._add_single_line_KV_to_table()

    def table_begun__to__inside_multi_line_literal(self):
        self._begin_multi_line()

    def table_begun__to__inside_multi_line_basic(self):
        self._begin_multi_line()

    def table_begun__to__table_begun(self):
        return self._release_and_begin_table_block()

    def table_begun__to__discretionary_block_2(self):
        self._begin_discretionary_block_in_table()

    def table_begun__to__done(self):
        return (okay, self._release_table_block())

    def discretionary_block_2__to__discretionary_block_2(self):
        self._add_line_to_current_discretionary_block()

    def discretionary_block_2__to__inside_table(self):
        self._add_single_line_KV_to_table()

    def discretionary_block_2__to__inside_multi_line_literal(self):
        self._begin_multi_line()

    def discretionary_block_2__to__inside_multi_line_basic(self):
        self._begin_multi_line()

    def discretionary_block_2__to__done(self):
        return (okay, self._release_table_block())

    def inside_multi_line_literal__to__inside_multi_line_literal(self):
        self._add_line_to_the_inside_of_the_multi_line()

    def inside_multi_line_literal__to__inside_table(self):
        self._end_multi_line()

    def inside_multi_line_basic__to__inside_multi_line_basic(self):
        self._add_line_to_the_inside_of_the_multi_line()

    def inside_multi_line_basic__to__inside_table(self):
        self._end_multi_line()

    def inside_table__to__inside_table(self):
        self._add_single_line_KV_to_table()

    def inside_table__to__inside_multi_line_literal(self):
        self._begin_multi_line()

    def inside_table__to__inside_multi_line_basic(self):
        self._begin_multi_line()

    def inside_table__to__table_begun(self):
        return self._release_and_begin_table_block()

    def inside_table__to__discretionary_block_3(self):
        self._begin_discretionary_block_in_table()

    def inside_table__to__done(self):
        return (okay, self._release_table_block())

    def discretionary_block_3__to__inside_table(self):
        self._add_single_line_KV_to_table()

    def discretionary_block_3__to__inside_multi_line_literal(self):
        self._begin_multi_line()

    def discretionary_block_3__to__inside_multi_line_basic(self):
        self._begin_multi_line()

    def discretionary_block_3__to__discretionary_block_3(self):
        self._add_line_to_current_discretionary_block()

    def discretionary_block_3__to__table_begun(self):
        return self._release_and_begin_table_block()

    def discretionary_block_3__to__done(self):
        return (okay, self._release_table_block())

    # -- head block

    def _release_head_block(self):
        mhb = self._current_appendable_head_block
        del(self._current_appendable_head_block)
        return mhb

    # -- table management

    def _release_and_begin_table_block(self):
        tb = self._release_table_block()
        ts = self._parse_table_start()
        if ts is None:
            return stop
        self.begin_table_with_(ts)
        return (okay, tb)

    def begin_table_with_(self, ts):
        self._current_appendable_table_block = _AppendableTableBlock(ts)

    def _parse_table_start(self):
        return self._table_start_via_line(self._current_line())

    def _release_table_block(self):
        x = self._current_appendable_table_block
        del(self._current_appendable_table_block)
        return x

    # -- multi-line

    def _begin_multi_line(self):  # (Case4127)
        _md = self._parse_state.current_matchdata  # #here1
        _mlab = _MultiLineAttributeBlock(_md)
        self._current_appendable_table_block._append_block(_mlab)

    def _add_line_to_the_inside_of_the_multi_line(self):
        self._append_tail_line_to_multiline()

    def _end_multi_line(self):
        self._append_tail_line_to_multiline()

    def _append_tail_line_to_multiline(self):
        self._current_appendable_table_block._tail_block()._append_tail_line(
                self._parse_state.line)

    # -- single line KV

    def _add_single_line_KV_to_table(self):
        _md = self._parse_state.current_matchdata  # #here1
        _ab = _SingleLineAttributeBlock(_md)
        self._current_appendable_table_block._append_block(_ab)

    # -- comm

    def _begin_discretionary_block_in_table(self):
        _db = AppendableDiscretionaryBlock_(self._current_line())
        self._current_appendable_table_block._append_block(_db)

    def _add_line_to_current_discretionary_block(self):
        _ = self._current_line()
        self._current_appendable_table_block._tail_block()._append_line(_)

    # -- support

    def _current_line(self):
        return self._parse_state.line


class _AppendableHeadBlock:

    def __init__(self, eek):
        self._head_block_lines = eek  # #testpoint

    def _append_line(self, x):
        self._head_block_lines.append(x)

    def to_line_stream(self):
        return self._head_block_lines  # while it works

    hello_head_block__ = True  # [#008.D]


_empty_head_block = _AppendableHeadBlock(())


class _AppendableTableBlock:

    def __init__(self, ts):
        self._table_start_line_object = ts  # #testpoint
        self._body_blocks = []  # #testpoint

    def append_multi_line_attribute_block_via_lines__(self, attr_s, se_lines):
        _attr_blk = _multi_line_attribute_block_via(attr_s, se_lines)
        self._append_block(_attr_blk)

    def _append_block(self, x):
        self._body_blocks.append(x)

    def to_mutable_document_entity_(self, listener):
        from .mutable_document_entity_via_table_start_line import MDE_via_TSLO
        mde = MDE_via_TSLO(self._table_start_line_object)
        for blk in self.to_body_block_stream_as_table_block_():
            _ok = mde.append_body_block(blk, listener)
            if not _ok:
                return
        return mde

    @property
    def identifier_string(self):
        return self._table_start_line_object.identifier_string

    @property
    def table_type(self):  # #NO
        return self._table_start_line_object.table_type

    # == "THE STORAGE ADAPTER ENTITY INTERFACE" (experimental)

    @property
    def identifier(self):
        return self._table_start_line_object.identifier_for_storage_adapter()

    @property
    def core_attributes_dictionary_as_storage_adapter_entity(self):
        _ = self.to_dictionary_two_deep_as_storage_adapter_entity()
        return _['core_attributes']

    def to_dictionary_two_deep_as_storage_adapter_entity(self):
        from .entity_via_identifier_and_file_lines import (
                dictionary_two_deep_via_entity_line_stream_)
        return dictionary_two_deep_via_entity_line_stream_(self)

    # == END

    def to_line_stream(self):
        yield self._table_start_line_object.line
        for blk in self._body_blocks:  # (Case4278)
            for line in blk.to_line_stream():
                yield line

    def to_body_block_stream_as_table_block_(self):
        return self._body_blocks

    def _tail_block(self):
        return self._body_blocks[-1]


class _multi_line_attribute_block_via:  # ..

    def __init__(self, attr_s, semi_encoded_lines):

        assert(len(semi_encoded_lines))

        self.attribute_name_string = attr_s

        *all_but_last_line, last_line = semi_encoded_lines

        def f():
            yield f'{attr_s} = """\n'
            # (always only ever literal not basic. we don't want the delimiters
            # flip-flopping based on content (while it is multi-line).)

            for line in all_but_last_line:
                yield line

            if last_line[-1] == "\n":  # ICK/MEH
                yield last_line
                yield '"""\n'
            else:
                # (Case4261) - currently never allowed
                assert(False)
                yield f'{last_line}"""\n'

        self._lines = tuple(f())

    def to_line_stream(self):
        return self._lines

    is_attribute_block = True  # (Case6075)


class _MultiLineAttributeBlock:

    def __init__(self, matchdata):
        self._matchdata = matchdata
        self._tail_lines = []

    def _append_tail_line(self, x):
        self._tail_lines.append(x)

    def to_line_stream(self):
        yield self._matchdata.string
        for line in self._tail_lines:
            yield line

    def which_quote___(self):
        return self._matchdata[2]

    def last_line__(self):
        return self._tail_lines[-1]

    @property
    def attribute_name_string(self):
        return self._matchdata[1]

    is_attribute_block = True
    is_multi_line_attribute_block = True


class _SingleLineAttributeBlock:

    def __init__(self, matchdata):
        self._matchdata = matchdata

    def to_line_stream(self):
        yield self.line

    @property
    def attribute_name_string(self):
        return self._matchdata[1]

    @property
    def position_of_start_of_value(self):
        return self._matchdata.end(0)

    @property
    def line(self):
        return self._matchdata.string

    is_discretionary_block = False
    is_attribute_block = True
    is_multi_line_attribute_block = False


class AppendableDiscretionaryBlock_:

    def __init__(self, first_line):
        self.discretionary_block_lines = [first_line]

    def _append_line(self, line):
        self.discretionary_block_lines.append(line)

    def to_line_stream(self):
        return self.discretionary_block_lines  # meh

    is_attribute_block = False
    is_discretionary_block = True


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


# #history-A.2: mutable document entity breaks out
# #history-A.1: massive rewrite to accomodate multi-line
# #born.
