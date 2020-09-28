"""
this file's founding objective was for a regression to cover the unforseen
edge case of having irregular use of endcaps. what we set out to test
initially was that a record merge does not add an endcap under some certain
circumstances.

along the way this evolved to cover also our alignment and other formatting
behavior (#history-A.1).
"""

import kiss_rdb_test.markdown_storage_adapter as msa
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes_2 as shared_subj_in_children, \
        dangerous_memoize as shared_subject
import unittest


class CommonCase(unittest.TestCase):

    def expect_NO_endcap_after(self):
        row = self.end_state_row
        self.assertEqual(row.has_endcap, False)
        line = row.to_line()
        self.assertEqual(line[-1], '\n')
        self.assertNotEqual(line[-2], '|')

    def expect_YES_endcap_after(self):
        row = self.end_state_row
        self.assertEqual(row.has_endcap, True)
        line = row.to_line()
        self.assertEqual(line[-1], '\n')
        self.assertEqual(line[-2], '|')

    def the_two_end_state_content_strings(self):
        two = normalize_row(self.end_state_row)
        assert 2 == len(two)
        return two

    @property
    def end_state_content_string(self):
        offset = self.given_offset_of_interest()
        return self.end_state_row.cell_at_offset(offset).value_string

    @property
    def end_state_row(self):
        return self.end_state.row_after

    @property
    @shared_subj_in_children
    def end_state(self):
        return self.build_end_state_commonly()

    def given_offset_of_interest(self):
        return 1


class Case2475_parse_line_fully(CommonCase):

    def test_010_empty_row(self):
        line = "|\n"
        actual = PLF_against(line)
        self.PLF_looks_like(actual, 1, False)
        ps, vs = PLF_content_and_value_at(line, actual, 0)
        assert '' == vs
        assert vs == ps

    def test_015_empty_row_plus_endcap(self):
        line = "||\n"
        actual = PLF_against(line)
        self.PLF_looks_like(actual, 1, True)
        ps, vs = PLF_content_and_value_at(line, actual, 0)
        assert '' == vs
        assert vs == ps

    def test_020_some_content(self):
        line = "|a\n"
        actual = PLF_against(line)
        self.PLF_looks_like(actual, 1, False)
        ps, vs = PLF_content_and_value_at(line, actual, 0)
        assert 'a' == vs
        assert vs == ps

    def test_025_some_content_plus_endcap(self):
        line = "|a|\n"
        actual = PLF_against(line)
        self.PLF_looks_like(actual, 1, True)
        ps, vs = PLF_content_and_value_at(line, actual, 0)
        assert 'a' == vs
        assert vs == ps

    def test_030_two_cells_no_encap(self):
        line = "|a|bc\n"
        actual = PLF_against(line)
        self.PLF_looks_like(actual, 2, False)
        ps, vs = PLF_content_and_value_at(line, actual, 0)
        assert 'a' == vs
        assert vs == ps
        ps, vs = PLF_content_and_value_at(line, actual, 1)
        assert 'bc' == vs
        assert vs == ps

    def test_035_enter_padding(self):
        line = "| abc  \n"
        actual = PLF_against(line)
        self.PLF_looks_like(actual, 1, False)
        ps, vs = PLF_content_and_value_at(line, actual, 0)
        assert 'abc' == vs
        assert ' abc  ' == ps

    def test_040_enter_escape(self):
        line = "|pipe:\\|\n"
        actual = PLF_against(line)
        self.PLF_looks_like(actual, 1, False)
        ps, vs = PLF_content_and_value_at(line, actual, 0)
        assert 'pipe:\\|' == vs  # ..
        assert vs == ps

    def PLF_looks_like(self, actual, count, has_endcap):
        self.assertEqual(len(actual) - 1, count)
        expected = 'has_endcap' if has_endcap else 'no_endcap'
        self.assertEqual(actual[-1][1], expected)


def PLF_content_and_value_at(line, sexp, offset):
    cel = sexp[offset]
    typ, psx, vsx = cel
    assert 'complete_cell' == typ
    typ, p_begin, p_end = psx
    assert 'padded_span' == typ
    typ, v_begin, v_end = vsx
    assert 'value_span' == typ
    return line[p_begin:p_end], line[v_begin:v_end]


def PLF_against(line):
    from kiss_rdb.storage_adapters_.markdown_table\
        ._prototype_row_via_example_row_and_complete_schema import \
        _complete_sexp_via_line as func
    return tuple(func(line))


class Case2478KR_example_row_HAS_endcap_and_before_line_does_NOT(CommonCase):

    def test_010_loads(self):
        self.assertIsNotNone(subject_function())

    def test_020_the_content_string_gets_updated(self):
        self.assertEqual(self.end_state_content_string, 'X2')

    def test_030_there_is_NO_endcap_after(self):
        self.expect_NO_endcap_after()

    def test_040_things_are_aligned_all_the_way_right(self):
        """
        A lot going on here:
          - encappiness of existing row preserved (not pictured)
          - the widths as proscribed in the example row
          - the alignments as proscribed in the second schema row
          - the counterpart cell paddings from the example row
        """

        str1, str2 = self.the_two_end_state_content_strings()
        self.assertEqual(str1, '|            x1   ')  # 17 (3)
        self.assertEqual(str2, '|        X2  ')  # 12 (2)

    def given_schema(_):
        yield 'natural_key_field_name', 'ohai_im_natty_key'
        yield "|Ohai I'm Natty Key|Celo|\n"
        yield '|--:|--:|\n'  # no colon, yes colon means right  #here2

    def given_example_row(_):
        return '|     seventeen   |    twelve  |\n'  # 3, 2 *yes* endcap

    def given_near_row_before(_):
        return '| x1  | x2   \n'  # *no* endcap

    def given_far_name_value_pairs(_):
        yield 'ohai_im_natty_key', 'x1'
        yield 'celo', 'X2'


class Case2479KR_example_row_does_NOT_have_endcap_and_before_line_DOES(CommonCase):  # noqa: E501 #midpoint

    def test_020_the_content_string_gets_updated(self):
        self.assertEqual(self.end_state_content_string, 'Y3')

    def test_030_there_is_YES_endcap_after(self):
        self.expect_YES_endcap_after()

    def test_040_things_are_aligned_all_the_way_left(self):
        str1, str2 = self.the_two_end_state_content_strings()
        self.assertEqual(str1, '|   y1             ')  # (3) 18
        self.assertEqual(str2, '|  Y3        ')        # (2) 12

    def given_schema(_):
        yield 'natural_key_field_name', 'hallo_im_natty_key'
        yield "|Hallo I'm Natty Key|Zig|\n"
        yield '|:--|:--|\n'  # yes colon, no colon means left  #here2

    def given_example_row(_):
        return '|   eggsie xamply  |  foo fah   |\n'  # 18, 12 *yes* endcap

    def given_near_row_before(_):
        return '| y1  | y2  |\n'  # *yes* endcap

    def given_far_name_value_pairs(_):
        yield 'hallo_im_natty_key', 'y1'
        yield 'zig', 'Y3'


class Case2480KR_change_natural_key_only_OK(CommonCase):
    """
    It used to be a thing to short-circuit the record-merge (and leave the
    "before" record alone) if there was nothing but the natural key in the
    far "record". But this has changed (at #history-A.1):

    Now, "sync keys" are not necessarily "natural keys". So just because
    a near and far entity are matched up using a sync key, does not mean that
    their natural keys are the same.

    Now (still), we short-circuit when the far entity is only length one
    and the natural keys are the same.

    (all of this is tracked with [#458.7].)
    """

    def test_020_the_content_string_gets_updated(self):
        self.assertEqual(self.end_state_content_string, 'Z1')

    def test_040_things_are_aligned_some_kind_of_center(self):
        # A lot happens: the example row is 19 wide. The argument value is 2
        # wide. We want it centered, which means we want the same amount of
        # filler space on each side. But we have an odd number (17) of filler
        # spaces to use. If we put 8 spaces on each side, we have one left
        # over we didn't use and it breaks fixed-width alignment. Which side
        # we put the extra space on is determined by the spacing in the example
        # cell (if it's at all lopsided). Otherwise we align slightly left.

        str1 = normalize_row(self.end_state_row)[0]
        self.assertEqual(str1, '|         Z1        ')  # (9) 19 (8)

    def given_schema(_):
        yield 'natural_key_field_name', 'oi_im_natty'
        yield "|Oi I'm Natty|\n"
        yield '|:--:|\n'  # yes colon yes colon means center  #here2

    def given_example_row(_):
        return '|    eggsie xamply  |\n'  # (4) 19 (2)

    def given_near_row_before(_):
        return '| z1  |\n'

    def given_far_name_value_pairs(self):
        yield 'oi_im_natty', 'Z1'

    def given_offset_of_interest(self):
        return 0


# (Case2481KR) (no alignment specified) is ricocheted off of elsewhere.)


class Case2482_update_against_no_endcap_with_blank_strings(CommonCase):

    def test_100_the_inside_cel_shrink_to_zero_width(self):
        cel1, cel2, *_ = self.normal_cels
        self.assertEqual(cel2, '|')
        assert cel1, '| [#123 '

    def test_200_it_is_as_if_the_rightmost_cel_never_existed(self):
        self.assertEqual(len(self.normal_cels), 2)
        # redundantly but for clarity, assert the whole expected line
        end_line = self.end_state_row.to_line()
        self.assertEqual(end_line, self.expected_end_line())

    @shared_subject
    def normal_cels(self):
        return normalize_row(self.end_state_row)

    def given_schema(_):
        yield 'natural_key_field_name', 'identito'
        yield '| identito | main_tag | body |\n'
        yield '|---|---|---|\n'

    def given_example_row(_):
        return '| eg | eg2 | eg3\n'  # no trailing ws

    def given_near_row_before(_):
        return '| [#123] | #tagg | change me\n'  # no trailing ws

    def given_far_name_value_pairs(self):
        yield 'identito', '[#123]'
        yield 'main_tag', ''  # empty string
        yield 'body', ''  # empty string

    def expected_end_line(_):
        return '| [#123] ||\n'


def build_end_state_commonly(tc):
    itr = tc.given_schema()
    kwargs = {k: v for k, v in (next(itr),)}
    line1, line2 = itr
    sp = complete_schema_plus_via(line1, line2, **kwargs)
    eg_row = row_via_line(tc.given_example_row())
    row_before = row_via_line(tc.given_near_row_before())
    far_pairs = tuple((k, v) for k, v in tc.given_far_name_value_pairs())

    _, updated_row_via = subject_function()(eg_row, sp.complete_schema)
    row = updated_row_via(far_pairs, row_before, msa.throwing_listener)

    class end_state:  # #class-as-namespace
        line_after = row.to_line()
        row_after = row
    return end_state


CommonCase.build_end_state_commonly = build_end_state_commonly


class complete_schema_plus_via:

    def __init__(self, line1, line2, natural_key_field_name):
        row1, row2 = (row_via_line(line) for line in (line1, line2))
        self.complete_schema = complete_schema_via(row1, row2)
        self.nkfn = natural_key_field_name


def normalize_row(row):
    import re
    line = row.to_line()
    pieces = re.split(r'(?<=.)(?=\|)', line)  # #[#873.24]

    # Chop off the newline (assert it is there)
    assert '\n' == pieces[-1][-1]
    pieces[-1] = pieces[-1][0:-1]

    # If there's an endcap, normalize that away (for now)
    if '|' == pieces[-1]:
        pieces.pop()

    return tuple(pieces)


# ==

def complete_schema_via(row1, row2):
    return msa.complete_schema_via_row_ASTs(row1, row2)


def row_via_line(line):
    return msa.row_AST_via_line(line, msa.throwing_listener)


# ==

def subject_function():
    from kiss_rdb.storage_adapters_.markdown_table\
            ._prototype_row_via_example_row_and_complete_schema \
            import BUILD_CREATE_AND_UPDATE_FUNCTIONS_ as func
    return func


if __name__ == '__main__':
    unittest.main()

# #history-A.1: as referenced
# #born.
