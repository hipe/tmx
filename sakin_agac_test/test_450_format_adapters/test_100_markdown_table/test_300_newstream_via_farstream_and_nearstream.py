# #covers: sakin_agac.format_adapters.markdown_table.magnetics.newstream_via_farstream_and_nearstream  # noqa: E501

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
        self._etc('takashi', num)

    def _etc(self, typ, num):
        _d = self._second_index()
        _act = _d[typ]
        self.assertEqual(_act, num)


class Case010_far_field_names_have_to_be_subset_of_near_field_names(_CommonCase):  # noqa: E501

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module())

    # NOTE - THIS WILL ALL CHANGE WHEN SYNC IS REAL (look at the case name)

    def test_020_head_lines_count(self):
        self._head_lines_this_many(3)

    def test_030_schema(self):
        self._schema_lines_OK()

    def test_040_main_lines(self):
        self._main_lines_this_many(3)

    def test_050_tail_lines_count(self):
        self._tail_lines_this_many(4)

    @shared_subject
    def _second_index(self):
        return _build_second_index(self._thing_one())

    @shared_subject
    def _thing_one(self):
        _native_objects = (
                {
                    '_is_sync_meta_data': True,
                    'natural_key_field_name': 'field_name_one',
                },
                {
                    'field_name_one': 'adonga zebronga',
                    'chalupa fupa': 'zack braff',
                    'propecia alameda': 'ohai kauaii',
                },
                )

        _markdown_file = '0100-hello.md'
        return _THIS_THING(_native_objects, _markdown_file)


def _build_second_index(list_thing):
    """in a separate pass, ensure that sections (runs) don't repeat"""

    dct = {}
    for (typ, num) in list_thing:
        if typ in dct:
            raise Exception('collision')
        dct[typ] = num
    return dct


def _THIS_THING(native_objects, markdown_file):

    far_format_adapter = _this_one_format_adapter().FORMAT_ADAPTER

    sync_request = far_format_adapter.sync_request_via_native_stream(iter(native_objects))  # noqa: E501

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
    return _wat


class _MyCustomProcessor:

    def __init__(self):
        self._this_list = []

    def move_from__BEGIN__to__head_line(self):
        self._current_count = 0

    def head_line(self, x):
        self._same()

    def move_from__head_line__to__table_schema_line_one_of_two(self):
        self._move('head_line')

    def table_schema_line_one_of_two(self, x):
        self._same()

    def move_from__table_schema_line_one_of_two__to__table_schema_line_two_of_two(self):  # noqa: E501
        self._move('table_schema_line_one_of_two')

    def table_schema_line_two_of_two(self, x):
        self._same()

    def move_from__table_schema_line_two_of_two__to__takashi(self):
        self._move('table_schema_line_two_of_two')

    def takashi(self, x):
        self._same()

    def move_from__takashi__to__tail_line(self):
        self._move('takashi')

    def tail_line(self, x):
        self._same()

    def move_from__tail_line__to__END(self):
        self._move('tail_line')
        return release(self, '_this_list')

    def _move(self, typ):
        self._this_list.append((typ, self._current_count))
        self._current_count = 0

    def _same(self):
        self._current_count += 1


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
