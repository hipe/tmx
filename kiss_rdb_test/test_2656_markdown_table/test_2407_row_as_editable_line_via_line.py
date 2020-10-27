"""
keep in mind the caveats: don't get attached because:
  - we are doing it wrong: we should use existing markdown parsers
  - we are doing it wrong: we should use a parser generator like ragel
  - this is just a proof-of-concept to be thrown away later

keeping all that ☝️ in mind,

for our purposes, parsing a markdown table is "easy":

here's our pseudo grammar:

    markdown_table: markdown_row_as_line+;

    markdown_row_as_line: markdown_cel+ '\n'

    markdown_cel: '|' [^\n|]*

really, that's it. there are higher-level concerns like:

  - validating that the number of cels is right on each row
  - all our magic crazy stuff we will do

but really, for now this gets us through the night. abstraction is essential.


## DOM thing

another fun essential thing here is that we're making a
"row as editable line". let's break down what this means:

    - "row as line": this means the structure _is_ a row (a business
      object) but can _look like_ a line.

    - "editable line": this means we decompose into a DOM-like tree..
      our DOM tree's each branch node um..


## note on efficiency

as-is this may not be appropriate for read-only traversals of the table
(for example searching for a record, or searching for several records).
however as is hinted at in one place below, there may be a way that we
can dynamically decompose..
"""

from modality_agnostic.test_support.common import \
        lazify_method_safely
import unittest


class CommonCase(unittest.TestCase):

    def _number_of_cels_is(self, d):
        _row = self.case().row
        self.assertEqual(_row.cell_count, d)

    def _has_endcap_yes_or_no(self, yn):
        _row = self.case().row
        _yn = _row.has_endcap
        self.assertEqual(_yn, yn)

    def _recomposes(self):
        case = self.case()
        _expected = case.original_string
        _actual = case.row.to_line()
        self.assertEqual(_expected, _actual)

    def _cell(self, offset):
        case = self.case()
        return case.row.cell_at_offset(offset)

    do_debug = False


def given_input_string(f):  # #decorator #[#510.6]
    def build_value():
        return _CaseState(f(None))
    return lazify_method_safely(build_value)


class Case2397_some_failures(CommonCase):

    def test_010_loads(self):
        self.assertIsNotNone(subject_function())

    def test_020_pipe_at_beginning_is_required(self):
        _msg = _failure_message_via_line(self, '😂\n')
        self.assertEqual("expecting '|' had '😂' at beginning of line", _msg)

    def test_030_newline_at_ending_is_required(self):
        _msg = _failure_message_via_line(self, '|')
        self.assertEqual(r"expecting '\n' at end of line", _msg)


class Case2401_one_cel_with_nothing_YES_ENDCAP(CommonCase):

    def test_010_number_of_cels_looks_right(self):
        self._number_of_cels_is(1)

    def test_020_recomposes_good(self):
        self._recomposes()

    def test_030_first_content_fellow_says_out(self):
        self.assertEqual(self._cell(0).value_string, '')

    def test_040_row_says_YES_endcap(self):
        self._has_endcap_yes_or_no(True)

    @given_input_string
    def case(self):
        return '||\n'


class Case2405_only_one_pipe(CommonCase):

    def test_010_number_of_cels_IS_ZERO(self):
        self._number_of_cels_is(0)

    def test_020_recomposes_good(self):
        self._recomposes()

    def test_040_row_says_YES_endcap(self):
        self._has_endcap_yes_or_no(True)

    @given_input_string
    def case(self):
        return '|\n'


# Case2407  # #midpoint


class Case2409_minimal_no_endcap(CommonCase):

    def test_010_number_of_cels_looks_right(self):
        self._number_of_cels_is(1)

    def test_020_recomposes_good(self):
        self._recomposes()

    def test_030_first_content_fellow_says_out(self):
        self.assertEqual(self._cell(0).value_string, 'x')

    def test_040_row_says_NO_endcap(self):
        self._has_endcap_yes_or_no(False)

    @given_input_string
    def case(self):
        return '|x\n'


class Case2413_typical_guy(CommonCase):

    def test_010_number_of_cels_looks_right(self):
        self._number_of_cels_is(3)

    def test_020_recomposes_good(self):
        self._recomposes()

    def test_030_a_content_fellow(self):
        self.assertEqual(self._cell(0).value_string, r'<a name=123></a>[\[#123\]]')  # noqa: E501

    def test_040_row_says_NO_endcap(self):
        self._has_endcap_yes_or_no(False)

    @given_input_string
    def case(self):
        return (r'|<a name=123></a>[\[#123\]] |       | using the TO_DO stack' + '\n')  # noqa: E501


# == Assertion Support

def _failure_message_via_line(tc, upstream_s):
    import modality_agnostic.test_support.common as em
    listener, emissions = em.listener_and_emissions_for(tc, limit=1)
    x = subject_function()(line=upstream_s, listener=listener)
    assert(x is None)
    emi, = emissions
    assert(emi.channel == ('error', 'expression'))
    line1, = emi.payloader()
    return line1


# == Ad-Hoc Models

class _CaseState:
    def __init__(self, s):
        self.row = subject_function()(s, listener=None)
        self.original_string = s


# == These

def subject_function():
    from kiss_rdb_test.markdown_storage_adapter import row_AST_via_line as func
    return func


if __name__ == '__main__':
    unittest.main()

# #born.
