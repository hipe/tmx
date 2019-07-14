"""
#covers: sakin_agac.format_adapters.markdown_table.magnetics.prototype_row_via_example_row_and_schema_index  # noqa: E501

this file's founding objective was for a regression to cover the unforseen
edge case of having irregular use of endcaps. what we set out to test
initially was that a record merge does not add an endcap under some certain
circumstances.

along the way this evolved to cover also our alignment and other formatting
behavior (#history-A.1).
"""

from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject)
import unittest


class _CommonCase(unittest.TestCase):

    def _there_is_NO_endcap_after(self):
        row = self._row_after()
        self.assertEqual(row.has_endcap, False)
        line = row.to_line()
        self.assertEqual(line[-1], '\n')
        self.assertNotEqual(line[-2], '|')

    def _there_is_YES_endcap_after(self):
        row = self._row_after()
        self.assertEqual(row.has_endcap, True)
        line = row.to_line()
        self.assertEqual(line[-1], '\n')
        self.assertEqual(line[-2], '|')

    def _the_two_cel_byteses(self):
        row = self._row_after()
        return tuple(row.cel_at_offset(offset).to_string() for offset in (0, 1))  # noqa: E501

    def _content_string_after(self):
        return self._cel_after().content_string()

    def _cel_after(self):
        return self._row_after().cel_at_offset(self._offset_of_interest())

    def _row_after(self):
        return self._state().row_after

    def _offset_of_interest(self):
        return 1


class Case2478KR_example_row_HAS_endcap_and_before_line_does_NOT(_CommonCase):

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_the_content_string_gets_updated(self):
        self.assertEqual(self._content_string_after(), 'X2')

    def test_030_there_is_NO_endcap_after(self):
        self._there_is_NO_endcap_after()

    def test_040_things_are_aligned_all_the_way_right(self):
        """
        as touched on near other mentions of the coverpoint mentioned in the
        setup, note what is happening at writing: notwithstanding the
        endcappiness being preserved, the updated characterspans have:
          - the widths as proscribed in the example row
          - the alignments as proscribed in the second schema row

        note that the "coddling" (the padding-by-whitespace on either side,
        separately) is lossed-away; both that of the before row and that of
        the example row. this is probably not what we want but we are covering
        it to prove it (as existing behavior) and to track it. :#here1
        """

        str1, str2 = self._the_two_cel_byteses()
        self.assertEqual(str1, '|                x1')
        self.assertEqual(str2, '|          X2')

    @shared_subject
    def _state(self):
        return self._build_state_commonly()

    def far_name_value_pairs(self):
        return (('ohai_im_natty_key', 'x1'), ('celo', 'X2'))

    def near_row_before(self):  # NOTE *no* endcap
        return _row_via_line('| x1  | x2  \n')

    def example_row(self):  # NOTE *yes* encap
        return _row_via_line('|   eggsie xamply  |   foo fah  |\n')

    def schema_plus(self):
        return _schema_plus_via_two_lines(
            "|Ohai I'm Natty Key|Celo|\n",
            '|--:|--:|\n',  # no colon, yes colon means right  ##here2
            nkfn='ohai_im_natty_key',
            )


class Case2479KR_example_row_does_NOT_have_endcap_and_before_line_DOES(_CommonCase):  # noqa: E501 #midpoint

    def test_020_the_content_string_gets_updated(self):
        self.assertEqual(self._content_string_after(), 'Y3')

    def test_030_there_is_YES_endcap_after(self):
        self._there_is_YES_endcap_after()

    def test_040_things_are_aligned_all_the_way_left(self):
        """
        (if this fails, or change is desired, see exactly #here1)
        """

        str1, str2 = self._the_two_cel_byteses()
        self.assertEqual(str1, '|y1                ')
        self.assertEqual(str2, '|Y3          ')

    @shared_subject
    def _state(self):
        return self._build_state_commonly()

    def far_name_value_pairs(self):
        return (('hallo_im_natty_key', 'y1'), ('zig', 'Y3'))

    def near_row_before(self):  # NOTE *yes* endcap
        return _row_via_line('| y1  | y2  |\n')

    def example_row(self):  # NOTE *yes* encap
        return _row_via_line('|   eggsie xamply  |   foo fah  |\n')

    def schema_plus(self):
        return _schema_plus_via_two_lines(
            "|Hallo I'm Natty Key|Zig|\n",
            '|:--|:--|\n',  # yes colon, no colon means left  ##here2
            nkfn='hallo_im_natty_key',
            )


class Case2480KR_change_human_key_only_OK(_CommonCase):
    """
    it used to be a thing to short-circuit the record-merge (and leave the
    "before" record alone) if there was nothing but the human key in the
    far "record". but this was based off the assumption that there would be
    no reason to update the "before" human key with the "after" one. with
    the introduction of fuzzy-matching human keys (#history-A.1) this changed.
    (there might be such short-circuiting still happening, but the decision
    is pushed up to a higher level.) (at writing, yes there is.)
    """

    def test_020_the_content_string_gets_updated(self):
        self.assertEqual(self._content_string_after(), 'Z1')

    def test_040_things_are_aligned_some_kind_of_center(self):
        """
        (if this fails, or change is desired, see exactly #here1)

        NOTE also: when an odd number of spare space, the extra one is on RT
        """

        str1 = self._row_after().cel_at_offset(0).to_string()
        self.assertEqual(str1, '|        Z1         ')

    @shared_subject
    def _state(self):
        return self._build_state_commonly()

    def far_name_value_pairs(self):
        return (('oi_im_natty', 'Z1'),)

    def near_row_before(self):
        return _row_via_line('| z1  |\n')

    def example_row(self):
        return _row_via_line('|    eggsie xamply  |\n')

    def schema_plus(self):
        return _schema_plus_via_two_lines(
            "|Oi I'm Natty|\n",
            '|:--:|\n',  # yes colon yes colon means center  ##here2
            nkfn='oi_im_natty',
            )

    def _offset_of_interest(self):
        return 0


# (Case2481KR) (no alignment specified) is ricocheted off of elsewhere.)


def _build_state_commonly(tc):

    sp = tc.schema_plus()
    _eg_row = tc.example_row()
    _near_row_before = tc.near_row_before()
    _far_pairs = tc.far_name_value_pairs()

    _proto = _subject_module()(
            natural_key_field_name=sp.nkfn,
            example_row=_eg_row,
            complete_schema=sp.complete_schema,
            )

    liner = _proto.new_row_via_far_pairs_and_near_row_DOM__(
            _far_pairs, _near_row_before)

    class _State:
        def __init__(self, _1, _2):
            self.line_after = _1
            self.row_after = _2

    _line_after = liner.to_line()
    return _State(_line_after, liner)


_CommonCase._build_state_commonly = _build_state_commonly


class _schema_plus_via_two_lines:

    def __init__(self, line1, line2, nkfn):
        from kiss_rdb.storage_adapters_.markdown_table.magnetics_ import (
            schema_index_via_schema_row as _)
        _tup = _.row_two_function_and_liner_via_row_one_line(
                line1, 'listener01')
        f1, row1 = _tup
        assert(row1.to_line() == line1)  # not SUT. just checking

        f2, row2 = f1(line2)
        assert(row2.to_line() == line2)  # not SUT. just checking

        self.complete_schema = f2()
        self.nkfn = nkfn


def _row_via_line(line):
    from kiss_rdb.storage_adapters_.markdown_table.magnetics_ import (
        row_as_editable_line_via_line as _)
    _row = _(line, listener=None)
    return _row


def _subject_module():
    from kiss_rdb.storage_adapters_.markdown_table.magnetics_ import (
        prototype_row_via_example_row_and_schema_index as mod)
    return mod


if __name__ == '__main__':
    unittest.main()

# #history-A.1: as referenced
# #born.
