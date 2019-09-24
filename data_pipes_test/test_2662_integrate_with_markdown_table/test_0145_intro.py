from kiss_rdb_test.common_initial_state import (
        publicly_shared_fixture_file)
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        lazy)
import unittest


class _CommonCase(unittest.TestCase):

    def _schema_lines_OK(self):
        self._etc('table_schema_line_one_of_two', 1)
        self._etc('table_schema_line_two_of_two', 1)

    def _head_lines_this_many(self, num):
        self._etc('head_line', num)

    def _tail_lines_this_many(self, num):
        self._etc('tail_line', num)

    def _main_lines_this_many(self, num):
        self._etc('business_object_row', num)

    def _items(self):
        return self._interesting_section().items

    def _etc(self, typ, num):
        _d = self._sections_index()
        _act = _d[typ].count
        self.assertEqual(_act, num)

    def _this_one_business_object_row(self):
        return self._interesting_section().items[1]

    def _interesting_section(self):
        return self._sections_index()['business_object_row']


class Case0110DP_far_field_names_have_to_be_subset_of_near_field_names(_CommonCase):  # noqa: E501

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_it_just_throws_a_key_error(self):
        e = None
        try:
            _case_010_section_list()
        except KeyError as e_:
            e = e_
        self.assertEqual(str(e), "'chalupa fupa'")


class Case0130DP_adds_only(_CommonCase):

    def test_002_does_not_fail(self):
        self.assertIsNotNone(self._section_list())

    def test_020_head_lines_count(self):
        self._head_lines_this_many(3)

    def test_030_schema(self):
        self._schema_lines_OK()

    def test_040_main_lines_count(self):
        self._main_lines_this_many(3)

    def test_050_the_first_and_last_items_are_as_in_the_original(self):

        items = self._items()

        _line_one = items[0].to_line()
        _line_two = items[-1].to_line()

        self.assertEqual(_line_one, "|one|two|three|\n")
        self.assertEqual(_line_two, "| four | five | six\n")

    def test_060_the_new_one_was_added(self):
        """
        .#open [#459.J]:
        this test (although small in codesize) is overloaded. if you
        refactor this test, consider breaking it up to test these separately:

          - that original widths are respected when possible (Case0120DP)
          - that blank cels also get padded appropriately (Case0130DP)
          - what happens with content overflow (Case0140DP)
        """

        items = self._items()
        row = items[1]
        cel0 = row.cel_at_offset(0)
        cel1 = row.cel_at_offset(1)
        cel2 = row.cel_at_offset(2)

        self.assertEqual(cel0.content_string(), '3A')
        self.assertEqual(cel1.to_string(), '|   ')
        self.assertEqual(cel2.to_string(), '|choo choo')

        self.assertEqual(row.has_endcap, True)

        # we are avoiding testing the details of alignment
        # self.assertEqual(_actual_line, "|3A |   |choo choo|\n")
        # because those are (Case2478KR) (Case2479KR)

    def test_070_tail_lines_count(self):
        self._tail_lines_this_many(4)

    @shared_subject
    def _sections_index(self):
        return _sections_index_via(self._section_list())

    def _section_list(self):
        return _case_100_section_list()


class Case0140DP_MERGE(_CommonCase):

    def test_010_does_not_fail(self):
        self.assertIsNotNone(self._section_list())

    def test_020_the_after_content_is_right(self):
        items = self._items()
        self.assertEqual(len(items), 2)
        row = items[1]
        t = tuple(row.cel_at_offset(i).content_string() for i in range(0, 3))

        self.assertEqual(t[0], 'four')
        self.assertEqual(t[1], '5')
        self.assertEqual(t[2], 'six')
        self.assertEqual(row.has_endcap, False)
        # avoid testing alignments here, but:
        # self.assertEqual(_after_line, '| four |  5| six\n')
        # this touches on alignment not specified (Case2481KR)

    @shared_subject
    def _sections_index(self):
        return _sections_index_via(self._section_list())

    def _section_list(self):
        return _case_200_section_list()


class Case0150DP_in_this_case_mono_value_does_NOT_update(_CommonCase):
    # short-circuit out of entity sync because reasons [#458.7]
    # (note that intentionally weird formatting is maintained)

    def test_100(self):
        _sects = self._sections_index()
        _act_line = _sects['business_object_row'].items[1].to_line()
        self.assertEqual(_act_line, '|   zub | x2\n')  # not the example format

    @shared_subject
    def _sections_index(self):
        _entity_dictionaries = ({'col_a': 'zub'},)
        _near = (
                '|Col A|Col B|\n',
                '|-----|-----|\n',
                '|  zib  |   x1   |\n',
                '|   zub | x2\n',
                )
        return _sections_index_via(_section_list_via(
                _entity_dictionaries, _near))


class Case0160DP_custom_keyer_for_syncing(_CommonCase):

    def test_100_the_NOT_updated_business_cel_stays_as_is(self):
        self.assertEqual(self._cel_strings()[2], '| six')

    def test_200_the_YES_updated_business_cel_has_the_example_width(self):
        # (Case2479KR) (align left) is also exhibited
        self.assertEqual(self._cel_strings()[1], '|  5')

    def test_300_crucially_the_human_key_IS_updated(self):
        self.assertEqual(self._cel_strings()[0], '|  FOUR  ')

    @shared_subject
    def _cel_strings(self):
        _row = self._this_one_business_object_row()
        return tuple(_row.cel_at_offset(i).to_string() for i in range(0, 3))

    @shared_subject
    def _sections_index(self):
        _entity_dictionaries = (
                {
                    'field_name_one': '  FOUR  ',
                    'field_2': '5',
                },
                )
        return _sections_index_via(_section_list_via(
                _entity_dictionaries, _same_markdown_file,
                near_keyerer=_same_near_keyerer()))


class Case0170DP_in_this_case_mono_value_does_YES_update(_CommonCase):
    # [#458.7] when natural keys are different, take the far value

    def test_100(self):
        """
        The example row is untouched.

        The second row is the row of interest. For its first cel:
        There was a match given the sync keys (both are "zub"), but the
        natural keys are different ("ZuB" vs "zUb"). The far value clobbers
        the near value and formatting from the example row is applied.

        It's doing the crazy, now un-desired behavior of ASCII-formatting
        cel values to match the alignment specified in the format line
        (which defaults to align-left) and using the ASCII fixed-width of
        the example cel (maybe??) (Case2481KR).

        for the second result cel:
        NOTE because a column B field wasn't in the far record, that cel
        did not get updated with the example record formatting for that cel.
        """

        _row = self._this_one_business_object_row()
        self.assertEqual(_row.to_line(), '|zUb   | x2\n')

    @shared_subject
    def _sections_index(self):
        _entity_dictionaries = ({'col_a': 'zUb'},)
        _near = (
                '|Col A|Col B|\n',
                '|-----|-----|\n',
                '| zib  |   x1   |\n',
                '|      ZuB   | x2\n',
                )
        return _sections_index_via(_section_list_via(
                _entity_dictionaries, _near,
                near_keyerer=_same_near_keyerer()))


def _case_010_section_list():
    _entity_dictionaries = (
                {
                    'field_name_one': 'adonga zebronga',
                    'chalupa fupa': 'zack braff',
                    'propecia alameda': 'ohai kauaii',
                },
                )
    return _section_list_via(_entity_dictionaries, _same_markdown_file)


@lazy
def _case_100_section_list():
    _entity_dictionaries = (
                {
                    'field_name_one': '3A',
                    'cha_cha': 'choo choo',
                },
                )
    return _section_list_via(_entity_dictionaries, _same_markdown_file)


@lazy
def _case_200_section_list():
    _entity_dictionaries = (
                {
                    'field_name_one': 'four',
                    'field_2': '5',
                },
                )
    return _section_list_via(_entity_dictionaries, _same_markdown_file)


_same_markdown_file = '0100-hello.md'


def _sections_index_via(section_list):
    """in a separate pass, ensure that sections (runs) don't repeat"""

    dct = {}
    for section in section_list:
        typ = section.type
        if typ in dct:
            raise Exception('collision')
        dct[typ] = section
    return dct


def _section_list_via(sorted_far_dcts, mixed_near, near_keyerer=None):
    # :[#459.2]: an exemplary implementation of sync
    # (rewritten at #history-A.4 to be less crazy)

    assert(isinstance(sorted_far_dcts, tuple))  # #[#022]

    from modality_agnostic import listening
    listener = listening.throwing_listener

    # --

    dcts = iter(sorted_far_dcts)
    first_dct = next(dcts)  # ..

    if True:
        key = next(iter(first_dct.keys()))

        def far_key_via(dct):
            return _simplify_and_add_guillemets(dct[key])

        def stream_for_sync_via_stream():  # (not exactly this but like this)
            yield (far_key_via(first_dct), first_dct)
            for dct in dcts:
                yield (far_key_via(dct), dct)

        normal_far_stream = stream_for_sync_via_stream()

    # --

    if isinstance(mixed_near, str):
        near_path_or_lines = publicly_shared_fixture_file(mixed_near)
    else:
        assert(isinstance(mixed_near, tuple))
        assert(isinstance(mixed_near[0], str))
        near_path_or_lines = mixed_near

    from kiss_rdb.storage_adapters_.markdown_table.magnetics_.tagged_native_item_stream_via_line_stream import (  # noqa: E501
        OPEN_TAGGED_DOC_LINE_ITEM_STREAM)

    opened_near = OPEN_TAGGED_DOC_LINE_ITEM_STREAM(near_path_or_lines, listener)  # noqa: E501

    # --

    if near_keyerer is None:
        near_keyerer = Chimmy_Chamosa_001_near
    else:
        assert(isinstance(near_keyerer, str))
        from data_pipes.magnetics import function_via_function_identifier
        near_keyerer = function_via_function_identifier(near_keyerer, listener)
        assert(near_keyerer)

    # --

    from kiss_rdb.storage_adapters_.markdown_table.magnetics_.synchronized_stream_via_far_stream_and_near_stream import (  # noqa: E501
        OPEN_NEWSTREAM_VIA)

    from data_pipes.magnetics.result_via_tagged_stream_and_processor import (
            result_via_tagged_stream_and_processor as section_list_via)
    # at writing this is the only place we call this ^

    with opened_near as document_section_ASTs:
        opened_new = OPEN_NEWSTREAM_VIA(
                normal_far_stream=normal_far_stream,
                near_tagged_items=document_section_ASTs,
                near_keyerer=near_keyerer,
                listener=listener)
        # ..
        with opened_new as AST_nodes:
            _pcsr = _MyCustomProcessor()
            _section_list = section_list_via(AST_nodes, _pcsr)

    return _section_list


class _MyCustomProcessor:

    def __init__(self):
        self._sections = []

    def move_from__BEGIN__to__head_line(self):
        self._init_section_items()

    def head_line(self, x):
        self._same(x)

    def move_from__BEGIN__to__table_schema_line_one_of_two(self):
        self._init_section_items()
        self._move('head_line')

    def move_from__head_line__to__table_schema_line_one_of_two(self):
        self._move('head_line')

    def table_schema_line_one_of_two(self, x):
        self._same(x)

    def move_from__table_schema_line_one_of_two__to__table_schema_line_two_of_two(self):  # noqa: E501
        self._move('table_schema_line_one_of_two')

    def table_schema_line_two_of_two(self, x):
        self._same(x)

    def move_from__table_schema_line_two_of_two__to__business_object_row(self):
        self._move('table_schema_line_two_of_two')

    def business_object_row(self, x):
        self._same(x)

    def move_from__business_object_row__to__tail_line(self):
        self._move('business_object_row')

    def tail_line(self, x):
        self._same(x)

    def move_from__business_object_row__to__END(self):
        self._close_section('business_object_row')
        return self._close()

    def move_from__tail_line__to__END(self):
        self._close_section('tail_line')
        return self._close()

    def _close(self):
        sections = self._sections
        del self._sections
        return tuple(sections)

    # --

    def _move(self, typ):
        self._close_section(typ)
        self._init_section_items()

    def _init_section_items(self):
        self._current_section_items = []

    def _close_section(self, typ):
        items = self._current_section_items
        del self._current_section_items
        _section = _Section(typ, items)
        self._sections.append(_section)

    def _same(self, x):
        self._current_section_items.append(x)


@lazy
def _same_near_keyerer():
    # really nasty, but OK while it works: load this selfsame test file
    # *as* a moudule, to see if we can reach the function using this identifier

    from os import path as os_path
    o = __file__.split(os_path.sep)
    _mod_name = '.'.join((o[-3], o[-2], os_path.splitext(o[-1])[0]))
    return f'{_mod_name}.Chimmy_Chamosa_001_near'  # (in this file)


def Chimmy_Chamosa_001_near(key_via_row_DOM_normally, complete_schema, listen):
    """at #history-A.3 this changed, symmetry broke"""

    def key_via_row_DOM(row_DOM):
        _k = key_via_row_DOM_normally(row_DOM)
        return _simplify_and_add_guillemets(_k)

    return key_via_row_DOM


def _simplify_and_add_guillemets(k):
    return f'«{k.strip().upper()}»'


class _Section:
    def __init__(self, typ, items):
        self.count = len(items)
        self.type = typ
        self.items = items


def _subject_module():
    from kiss_rdb.storage_adapters_.markdown_table.magnetics_ import (
        synchronized_stream_via_far_stream_and_near_stream as mod)
    return mod


if __name__ == '__main__':
    unittest.main()

# #history-A.4: no more sync-side item-mapping
# #history-A.3: broke symmetry between near and far keyerer
# #history-A.2: default algorithm changed to interfolding and row order changed
# #born.
