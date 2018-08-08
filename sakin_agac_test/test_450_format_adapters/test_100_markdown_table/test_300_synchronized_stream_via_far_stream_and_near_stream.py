# #covers: sakin_agac.format_adapters.markdown_table.magnetics.prototype_row_via_example_row_and_schema_index  # noqa: E501

from _init import (
        fixture_file_path,
        pop_property,
        )
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        memoize,
        )
import sakin_agac_test.test_450_format_adapters.test_100_markdown_table._common as co  # noqa: E501
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


class Case010_far_field_names_have_to_be_subset_of_near_field_names(_CommonCase):  # noqa: E501

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_it_just_throws_a_key_error(self):  # #coverpoint1.1
        e = None
        try:
            _case_010_section_list()
        except KeyError as e_:
            e = e_
        self.assertEqual(str(e), "'chalupa fupa'")


class Case100_adds_only(_CommonCase):

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
        .#open [#410.U]:
        this test (although small in codesize) is overloaded. if you
        refactor this test, consider breaking it up to test these separately:

          - that original widths are respected when possible #coverpoint1.2
          - that blank cels also get padded appropriately #coverpoint1.3
          - what happens with content overflow #coverpoint1.4
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
        # because those are #coverpoint4.1 #coverpoint4.2

    def test_070_tail_lines_count(self):
        self._tail_lines_this_many(4)

    @shared_subject
    def _sections_index(self):
        return _sections_index_via(self._section_list())

    def _section_list(self):
        return _case_100_section_list()


class Case200_MERGE(_CommonCase):

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
        # but this bumps into #coverpoint4.4 which is at writing not covered

    @shared_subject
    def _sections_index(self):
        return _sections_index_via(self._section_list())

    def _section_list(self):
        return _case_200_section_list()


class Case317_in_this_case_mono_value_does_NOT_update(_CommonCase):
    """
    .#coverpoint1.5: IF all of:
      - the far record only has one field (name-value pair)
        (which is to say it only has the human-key field) :#here1
      - other things are "normal"

    THEN: the syncing gets short-circuited at a certain place
    """

    def test_100(self):
        _sects = self._sections_index()
        _act_line = _sects['business_object_row'].items[1].to_line()
        self.assertEqual(_act_line, '| zub | x2\n')  # NOTE not example format

    @shared_subject
    def _sections_index(self):
        _far = (
                {
                    '_is_sync_meta_data': True,
                    'natural_key_field_name': 'col_a',
                    },
                {
                    'col_a': 'zub',
                    },
                )

        _near = (
                '|Col A|Col B|\n',
                '|-----|-----|\n',
                '|  zib  |   x1   |\n',
                '| zub | x2\n',
                )

        return _sections_index_via(_section_list_via(_far, _near))


class Case350_sync_keyerser(_CommonCase):  # #coverpoint1.6

    def test_100_the_NOT_updated_business_cel_stays_as_is(self):
        self.assertEqual(self._cel_strings()[2], '| six')

    def test_200_the_YES_updated_business_cel_has_the_example_width(self):
        """(#coverpoint4.2 (align left) is also exhibited)"""
        self.assertEqual(self._cel_strings()[1], '|  5')

    def test_300_crucially_the_human_key_IS_updated(self):
        self.assertEqual(self._cel_strings()[0], '|  FOUR  ')

    @shared_subject
    def _cel_strings(self):
        _row = self._this_one_business_object_row()
        return tuple(_row.cel_at_offset(i).to_string() for i in range(0, 3))

    @shared_subject
    def _sections_index(self):

        schema_row = {x: k for x, k in _same_schema_row.items()}
        schema_row['sync_keyerser'] = _same_sync_keyerser()

        _far = (
                schema_row,
                {
                    'field_name_one': '  FOUR  ',
                    'field_2': '5',
                },
                )

        return _sections_index_via(
                _section_list_via(_far, _same_markdown_file))


class Case383_in_this_case_mono_value_does_YES_update(_CommonCase):
    """
    .#coverpoint1.7: (integration of the last 2 coverpoints) IF all of:
      - the far record only has one field (name-value pair)
        (assume it's a human-key field)
      - the sync_keyerser doo-hah exists

    THEN: yes do the record-level sync (update)
    """

    def test_100(self):
        """
        for the first result cel:
        NOTE because a column B field wasn't in the far record, that cel
        did not get updated with the example record formatting for that cel.

        for the second result cel:
        you see #coverpoint4.4 no alignment specified gets align left.
        """

        _row = self._this_one_business_object_row()
        self.assertEqual(_row.to_line(), '|ZUB  | x2\n')

    @shared_subject
    def _sections_index(self):
        _far = (
                {
                    '_is_sync_meta_data': True,
                    'natural_key_field_name': 'col_a',
                    'sync_keyerser': _same_sync_keyerser(),
                    },
                {
                    'col_a': 'ZUB',
                    },
                )
        _near = (
                '|Col A|Col B|\n',
                '|-----|-----|\n',
                '| zib |   x1   |\n',
                '| zub | x2\n',
                )
        return _sections_index_via(_section_list_via(_far, _near))


def _case_010_section_list():
        _dicts = (
                _same_schema_row,
                {
                    'field_name_one': 'adonga zebronga',
                    'chalupa fupa': 'zack braff',
                    'propecia alameda': 'ohai kauaii',
                },
                )
        return _section_list_via(_dicts, _same_markdown_file)


@memoize
def _case_100_section_list():
        _dicts = (
                _same_schema_row,
                {
                    'field_name_one': '3A',
                    'cha_cha': 'choo choo',
                },
                )
        return _section_list_via(_dicts, _same_markdown_file)


@memoize
def _case_200_section_list():
        _dicts = (
                _same_schema_row,
                {
                    'field_name_one': 'four',
                    'field_2': '5',
                },
                )
        return _section_list_via(_dicts, _same_markdown_file)


_same_schema_row = {
        '_is_sync_meta_data': True,
        'natural_key_field_name': 'field_name_one',
        }

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


def _section_list_via(dicts, mixed_far):

    far_format_adapter = _this_one_format_adapter().FORMAT_ADAPTER

    _sess = far_format_adapter._open_sync_request(
            mixed_collection_identifier=dicts,
            modality_resources=None,
            listener=None,
            )

    with _sess as sync_request:
        x = __build_section_list_via_these(
                sync_request, far_format_adapter, mixed_far)  # noqa: E501

    return x


def __build_section_list_via_these(sync_request, far_format_adapter, mixed_far):  # noqa: E501

    my_sync = _subject_module()

    listener = 'listener1'

    sp = sync_request.release_sync_parameters()

    _far_stream = sync_request.release_dictionary_stream()

    _nkfn = sp.natural_key_field_name

    _sync_keyerser = sp.sync_keyerser

    del(sp)

    if isinstance(mixed_far, str):
        use_mixed_far = fixture_file_path(mixed_far)
    else:
        use_mixed_far = mixed_far

    _f = my_sync.sibling_('tagged_native_item_stream_via_line_stream')
    _near_tagged_items = _f(use_mixed_far, listener)

    _HOLY_SHNAPPS = my_sync(
            # the streams:
            far_native_stream=_far_stream,
            near_tagged_items=_near_tagged_items,

            # the sync parameters:
            natural_key_field_name=_nkfn,
            farstream_format_adapter=far_format_adapter,

            # pseudo-optional stuff:
            far_traversal_is_ordered=None,  # not until #coverpoint99
            sync_keyerser=_sync_keyerser,

            listener=listener,
            )

    import sakin_agac.magnetics.result_via_tagged_stream_and_processor as lib

    return lib(_HOLY_SHNAPPS, _MyCustomProcessor())


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
        return pop_property(self, '_sections')

    # --

    def _move(self, typ):
        self._close_section(typ)
        self._init_section_items()

    def _init_section_items(self):
        self._current_section_items = []

    def _close_section(self, typ):
        _x_a = tuple(pop_property(self, '_current_section_items'))
        _section = _Section(typ, _x_a)
        self._sections.append(_section)

    def _same(self, x):
        self._current_section_items.append(x)


@memoize
def _same_sync_keyerser():
    return (
        'sakin_agac_test.test_450_format_adapters.'
        'test_100_markdown_table.'
        'test_300_synchronized_stream_via_far_stream_and_near_stream.'
        'Chimmy_Chamosa_001'
        )


def Chimmy_Chamosa_001(near_f, far_f):
    """
    the file added at #history-A.1 explains our excitement and misgivings
    about the facility that employs this function as an example.
    """

    def use_near(felo):
        k = near_f(felo)
        return same(k)

    def use_far(felo):
        k = far_f(felo)
        return same(k)

    def same(k):
        return '«%s»' % k.strip().upper()

    return use_near, use_far


def _natural_key_via_object(x):
    raise Exception('where')


def _this_one_format_adapter():
    import sakin_agac_test.format_adapters.in_memory_dictionaries as x
    return x


class _Section:
    def __init__(self, typ, items):
        self.count = len(items)
        self.type = typ
        self.items = items


@memoize
def _subject_module():
    return co.sub_magnetic('synchronized_stream_via_far_stream_and_near_stream')  # noqa: E501


if __name__ == '__main__':
    unittest.main()

# #history-A.2: default algorithm changed to interfolding and row order changed
# #history-A.1: as referenced
# #born.
