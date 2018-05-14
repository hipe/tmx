# #covers: sakin_agac.format_adapters.markdown_table.magnetics.newstream_via_farstream_and_nearstream  # noqa: E501
# #covers: sakin_agac.format_adapters.markdown_table.magnetics.prototype_row_via_example_row_and_schema_index  # noqa: E501

from _init import (
        fixture_file_path,
        release,
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

    def _etc(self, typ, num):
        _d = self._second_index()
        _act = _d[typ].count
        self.assertEqual(_act, num)

    def _interesting_section(self):
        return self._second_index()['business_object_row']


class Case010_far_field_names_have_to_be_subset_of_near_field_names(_CommonCase):  # noqa: E501

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_it_just_throws_a_key_error(self):  # #coverpoint1.1
        e = None
        try:
            _case_010_first_index()
        except KeyError as e_:
            e = e_
        self.assertEqual(str(e), "'chalupa fupa'")


class Case100_adds_only(_CommonCase):

    def test_002_does_not_fail(self):
        self.assertIsNotNone(self._first_index())

    def test_020_head_lines_count(self):
        self._head_lines_this_many(3)

    def test_030_schema(self):
        self._schema_lines_OK()

    def test_040_main_lines_count(self):
        self._main_lines_this_many(3)

    def test_050_the_original_two_occur_first(self):

        items = self._interesting_section().items

        _line_one = items[0].to_line()
        _line_two = items[1].to_line()

        self.assertEqual(_line_one, "|one|two|three\n")
        self.assertEqual(_line_two, "| four | five | six\n")

    def test_060_the_new_one_was_added(self):
        """
        TODO: this test (although small in codesize) is overloaded. if you
        refactor this test, consider breaking it up to test these separately:

          - that original widths are respected when possible #coverpoint1.2
          - that blank cels also get padded appropriately #coverpoint1.3
          - what happens with content overflow #coverpoint1.4
          - align left #coverpoint1.5
          - align center #coverpoint1.6 (not actually covered in this test)
          - align right #coverpoint1.7
        """

        items = self._interesting_section().items

        _line_three = items[2].to_line()

        self.assertEqual(_line_three, "|3A |   |choo choo\n")

    def test_070_tail_lines_count(self):
        self._tail_lines_this_many(4)

    @shared_subject
    def _second_index(self):
        return _build_second_index(self._first_index())

    def _first_index(self):
        return _case_100_first_index()


class Case200_MERGE(_CommonCase):

    def test_010_does_not_fail(self):
        self.assertIsNotNone(self._first_index())

    def test_020_wee(self):
        items = self._interesting_section().items
        self.assertEqual(len(items), 2)
        _OMG_WOW = items[1].to_line()
        self.assertEqual(_OMG_WOW, '| four |  5| six\n')

    @shared_subject
    def _second_index(self):
        return _build_second_index(self._first_index())

    def _first_index(self):
        return _case_200_first_index()


def _case_010_first_index():
        _native_objects = (
                _same_schema_row,
                {
                    'field_name_one': 'adonga zebronga',
                    'chalupa fupa': 'zack braff',
                    'propecia alameda': 'ohai kauaii',
                },
                )
        return _build_first_index(_native_objects, _same_markdown_file)


@memoize
def _case_100_first_index():
        _native_objects = (
                _same_schema_row,
                {
                    'field_name_one': '3A',
                    'cha_cha': 'choo choo',
                },
                )
        return _build_first_index(_native_objects, _same_markdown_file)


@memoize
def _case_200_first_index():
        _native_objects = (
                _same_schema_row,
                {
                    'field_name_one': 'four',
                    'field_2': '5',
                },
                )
        return _build_first_index(_native_objects, _same_markdown_file)


_same_schema_row = {
        '_is_sync_meta_data': True,
        'natural_key_field_name': 'field_name_one',
        }

_same_markdown_file = '0100-hello.md'


def _build_second_index(first_index):
    """in a separate pass, ensure that sections (runs) don't repeat"""

    dct = {}
    for section in first_index:
        typ = section.type
        if typ in dct:
            raise Exception('collision')
        dct[typ] = section
    return dct


def _build_first_index(native_objects, markdown_file):

    far_format_adapter = _this_one_format_adapter().FORMAT_ADAPTER

    _sess = far_format_adapter.session_for_sync_request_(
            mixed_collection_identifier=native_objects,
            modality_resources=None,
            listener=None,
            )

    with _sess as sync_request:
        x = __build_first_index_via_these(sync_request, far_format_adapter, markdown_file)  # noqa: E501

    return x


def __build_first_index_via_these(sync_request, far_format_adapter, markdown_file):  # noqa: E501

    _sync_params = sync_request.release_sync_parameters()

    _item_stream = sync_request.release_item_stream()

    _nkfn = _sync_params.natural_key_field_name

    _HOLY_SHNAPPS = _subject_module()(
            # the streams:
            farstream_items=_item_stream,
            nearstream_path=fixture_file_path(markdown_file),

            # the sync parameters:
            natural_key_field_name=_nkfn,
            farstream_format_adapter=far_format_adapter,
            )

    import sakin_agac.magnetics.result_via_tagged_stream_and_processor as lib

    _wat = lib(_HOLY_SHNAPPS, _MyCustomProcessor())
    return _wat  # #todo


class _MyCustomProcessor:

    def __init__(self):
        self._sections = []

    def move_from__BEGIN__to__head_line(self):
        self._init_section_items()

    def head_line(self, x):
        self._same(x)

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

    def move_from__tail_line__to__END(self):
        self._close_section('tail_line')
        return release(self, '_sections')

    # --

    def _move(self, typ):
        self._close_section(typ)
        self._init_section_items()

    def _init_section_items(self):
        self._current_section_items = []

    def _close_section(self, typ):
        _x_a = tuple(release(self, '_current_section_items'))
        _section = _Section(typ, _x_a)
        self._sections.append(_section)

    def _same(self, x):
        self._current_section_items.append(x)


class _Section:
    def __init__(self, typ, items):
        self.count = len(items)
        self.type = typ
        self.items = items


def _natural_key_via_object(x):
    raise Exception('where')


def _this_one_format_adapter():
    import sakin_agac_test.format_adapters.in_memory_dictionaries as x
    return x


@memoize
def _subject_module():
    return co.sub_magnetic('newstream_via_farstream_and_nearstream')


if __name__ == '__main__':
    unittest.main()

# #born.
