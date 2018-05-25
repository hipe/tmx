# #covers: sakin_agac.format_adapters.markdown_table.magnetics.prototype_row_via_example_row_and_schema_index  # noqa: E501

import _init  # noqa: F401
from modality_agnostic.memoization import (
        memoize,
        )
import sakin_agac_test.test_450_format_adapters.test_100_markdown_table._common as co  # noqa: E501
import unittest


class _CommonCase(unittest.TestCase):
    pass


class Case010_hello(_CommonCase):

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_giant_RUMSKALLA(self):
        """NOTE - this is a regression to cover the unforseen edge case of

        having irregular use of endcaps - what we are testing is that a
        merge (within a single row) does not add an endcap.
        """

        # #coverpoint4.1 - no colon - yes colon
        # #coverpoint4.2 - yes colon - no colon

        _line1 = "|Ohai I'm Natty Key|Cel|\n"
        _line2 = '|--:|:--|\n'
        _line3 = '| thing ding one | thing ding two |\n'
        line4 = '| choo cha       | fa faaa\n'  # NOTE no endcap

        # -- resolve the schema

        _ = co.sub_magnetic('schema_index_via_schema_row')
        x = _.row_two_function_and_liner_via_row_one_line(_line1, 'listener01')
        f1, row1 = x
        row1.to_line  # (we're not testing that it works here, just that it is)
        f2, row2 = f1(_line2)
        _act = row2.to_line()
        self.assertEqual(_act, _line2)
        _complete_schema = f2()

        # -- resolve the row prototype

        row_via = co.sub_magnetic('row_as_editable_line_via_line')
        _eg_row = row_via(_line3, None)

        _proto = _subject_module()(
                natural_key_field_name='ohai_im_natty_key',
                example_row=_eg_row,
                complete_schema=_complete_schema,
                )

        # -- do the merge, assert endcap was not added

        _pairs = (('ohai_im_natty_key', 'thing ding one'),)

        _subj_row = row_via(line4, None)
        _wat = _proto.MERGE(_pairs, _subj_row)

        _actual = _wat.to_string()

        self.assertEqual(_actual, line4)


@memoize
def _subject_module():
    return co.sub_magnetic('prototype_row_via_example_row_and_schema_index')


if __name__ == '__main__':
    unittest.main()

# #born.
