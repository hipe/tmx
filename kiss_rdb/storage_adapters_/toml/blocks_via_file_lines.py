"""at writing the main interesting thing this module contains is only an

"actions" class that is injected into the parser.

these actions implement "block stream"

new a #birth is blocks
"""


from .identifiers_via_file_lines import (
        BaseActions_,
        table_start_line_via_line_,
        nothing, stop, okay,
        )
from modality_agnostic.memoization import memoize


def _MDE_via_ATB(table_block, listener):

    mde = MDE_via_TSLO_(table_block._table_start_line_object)

    for blk in table_block.to_body_block_stream_as_table_block_():
        _ok = mde.append_body_block(blk, listener)
        if not _ok:
            return
    return mde


class _MutableDocumentEntity:
    """
    we follow the double responsibility principle:

    1) expose a mutable list API that the operations can layer on top of.
    the operations are concerned with things like ensuring that the lines
    adjacent to edited lines are not comments. we do not effectuate such
    assurances here but we make them possible with the API we expose.

    2) gist API. help prevent gist collisions, with procurement.
    """

    def __init__(self, table_start_line_object):

        from . import doubly_linked_list_functions as _
        self._LL = _.build_new_doubly_linked_list()  # #testpoint (attr name)

        self._table_start_line_object = table_start_line_object  # #testpoint
        self._IID_via_gist = {}
        self._ = None

    # -- write

    def delete_attribute_body_block_via_gist__(self, gist):
        _iid = self._IID_via_gist[gist]  # (Case405_375)
        self._delete_block_via_iid(_iid)

    def _delete_block_via_iid(self, iid):  # #testpoint

        blk = self._LL.delete_item(iid)
        if _yes_gist(blk):
            # (or keep two dictionaries)
            for gist, this_iid in self._IID_via_gist.items():
                if iid == this_iid:
                    found_gist = gist
                    break
            self._IID_via_gist.pop(found_gist)
        return blk

    def replace_attribute_block__(self, blk):
        _gist = self._gist_no_check(blk)
        _iid = self._IID_via_gist[_gist]
        return self._LL.replace_item(_iid, blk)

    def insert_body_block(self, blk, iid):

        yes = _yes_gist(blk)
        if yes:
            gist = self._gist_yes_check(blk)

        new_iid = self._LL.insert_item_before_item(blk, iid)

        if yes:
            self._IID_via_gist[gist] = new_iid

        return new_iid

    def append_body_block(self, blk, listener=None):

        yes = _yes_gist(blk)
        if yes:
            gist = self._gist_yes_check(blk, listener)
            if gist is None:
                return

        iid = self._LL.append_item(blk)

        if yes:
            self._IID_via_gist[gist] = iid

        return okay

    def _gist_yes_check(self, attr_blk, listener=None):

        gist = self._gist_no_check(attr_blk, listener)
        if gist is None:
            return

        if gist in self._IID_via_gist:
            assert(listener)
            _item = self._LL.item_via_IID(self._IID_via_gist[gist])
            _whine_about_collision(  # (Case402_060)
                    listener=listener,
                    new_name=attr_blk.attribute_name_string,
                    existing_name=_item.attribute_name_string,
                    )
            return

        return gist

    def _gist_no_check(self, attr_blk, listener=None):

        if self._ is None:  # OCD meh
            self._ = attribute_name_functions_().name_gist_via_name

        return self._(attr_blk.attribute_name_string, listener)

    # -- read

    def to_line_stream(self):
        yield self._table_start_line_object.line
        for blk in self.to_body_block_stream_as_MDE_():
            for line in blk.to_line_stream():
                yield line

    def to_body_block_stream_as_MDE_(self):
        for blk in self._LL.to_item_stream():
            yield blk

    def any_block_via_gist__(self, gist):
        if gist in self._IID_via_gist:
            return self._LL.item_via_IID(self._IID_via_gist[gist])


def _yes_gist(blk):
    if blk.is_attribute_block:
        return True
    if blk.is_discretionary_block:
        return False
    assert(False)


MDE_via_TSLO_ = _MutableDocumentEntity


@memoize
def attribute_name_functions_():
    from .string_scanner_via_definition import (
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

    class these:  # #as-namespace-only
        pass

    setattr(these, 'name_gist_via_name', name_gist_via_name)  # really?
    return these


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

        # (Case229): even if there are no head lines in file, yield out
        # this empty head block so consumers can be written more simply
        return (okay, _empty_head_block)

    def ready__to__discretionary_block_1(self):
        _mhb = _AppendableHeadBlock([self._current_line()])  # eek
        self._current_appendable_head_block = _mhb

    def ready__to__done(self):
        return nothing  # (Case186) truly empty file yields out nothing

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
        return (okay, self._release_head_block())  # (Case171) virt. empty file

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

    def _begin_multi_line(self):  # (Case296)
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
        return self._head_block_lines  # hwile it works


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
        return _MDE_via_ATB(self, listener)

    # == BEGIN ..
    @property
    def identifier_string(self):
        return self._table_start_line_object.identifier_string

    @property
    def table_type(self):
        return self._table_start_line_object.table_type
    # == END

    def to_line_stream(self):
        yield self._table_start_line_object.line
        for blk in self._body_blocks:  # (Case441)
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
                # (Case407_180) - currently never allowed
                assert(False)
                yield f'{last_line}"""\n'

        self._lines = tuple(f())

    def to_line_stream(self):
        return self._lines

    is_attribute_block = True  # (Case831)


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


# == WHINERS

def _whine_about_collision(listener, new_name, existing_name):
    def structer():
        return {
                'reason': (
                    f'new name {repr(new_name)} too similar to '
                    f'existing name {repr(existing_name)}'),
                'expecting': 'available name',
                }
    listener('error', 'structure', 'input_error', structer)


# ==

def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


# #history-A.1: massive rewrite to accomodate multi-line
# #born.
