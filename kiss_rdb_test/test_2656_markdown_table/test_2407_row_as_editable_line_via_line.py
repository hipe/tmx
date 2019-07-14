# #covers: sakin_agac.format_adapters.markdown_table.magnetics.row_as_editable_line_via_line  # noqa: E501
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

from _init import (
        sanity,
        )
import sakin_agac_test.test_450_format_adapters.test_100_markdown_table._common as co  # noqa: E501
import unittest


class _CommonCase(unittest.TestCase):

    def _number_of_cels_is(self, d):
        _row = self.case().row
        self.assertEqual(_row.cels_count, d)

    def _has_endcap_yes_or_no(self, yn):
        _row = self.case().row
        _yn = _row.has_endcap
        self.assertEqual(_yn, yn)

    def _recomposes(self):
        case = self.case()
        _expected = case.original_string
        _actual = case.row.to_string()
        self.assertEqual(_expected, _actual)

    def _cel(self, offset):
        case = self.case()
        return case.row.cel_at_offset(offset)


def given_input_string(f):  # local decorator

    def g(_ignore_self):
        return mutable_f()

    def mutable_f():
        def f3():
            return x
        x = _CaseState(f(None))
        nonlocal mutable_f
        mutable_f = f3
        return f3()

    return g


class Case005_ASSORTED_STOWAWAYS(_CommonCase):

    def test_format_adapter_loads(self):
        self.assertIsNotNone(co.subject_format_adapter())

    def test_SNEAK_IN_TEST_ABOUT_REFLECTION(self):
        count = 0
        import sakin_agac.format_adapters as x
        for mod in x.EVERY_MODULE():
            fa = mod.FORMAT_ADAPTER
            if fa is not None:
                mod.FORMAT_ADAPTER.associated_filename_globs  # it's OK if None
                count += 1
        self.assertNotEqual(0, count)


class Case010_some_failures(_CommonCase):

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_pipe_at_beginning_is_required(self):
        _msg = _failure_message_via_line('😂')
        self.assertEqual("expecting '|' had '😂' at beginning of line", _msg)

    def test_030_newline_at_ending_is_required(self):
        _msg = _failure_message_via_line('|')
        self.assertEqual(r"expecting '\n' at end of line", _msg)


class Case020_one_cel_with_nothing_YES_ENDCAP(_CommonCase):

    def test_010_number_of_cels_looks_right(self):
        self._number_of_cels_is(1)

    def test_020_recomposes_good(self):
        self._recomposes()

    def test_030_first_content_fellow_says_out(self):
        self.assertEqual(self._cel(0).content_string(), '')

    def test_040_row_says_YES_endcap(self):
        self._has_endcap_yes_or_no(True)

    @given_input_string
    def case(self):
        return '||\n'


class Case022_only_one_pipe(_CommonCase):

    def test_010_number_of_cels_IS_ZERO(self):
        self._number_of_cels_is(0)

    def test_020_recomposes_good(self):
        self._recomposes()

    def test_040_row_says_YES_endcap(self):
        self._has_endcap_yes_or_no(True)

    @given_input_string
    def case(self):
        return '|\n'


class Case024_minimal_no_endcap(_CommonCase):

    def test_010_number_of_cels_looks_right(self):
        self._number_of_cels_is(1)

    def test_020_recomposes_good(self):
        self._recomposes()

    def test_030_first_content_fellow_says_out(self):
        self.assertEqual(self._cel(0).content_string(), 'x')

    def test_040_row_says_NO_endcap(self):
        self._has_endcap_yes_or_no(False)

    @given_input_string
    def case(self):
        return '|x\n'


class Case030_typical_guy(_CommonCase):

    def test_010_number_of_cels_looks_right(self):
        self._number_of_cels_is(3)

    def test_020_recomposes_good(self):
        self._recomposes()

    def test_030_a_content_fellow(self):
        self.assertEqual(self._cel(0).content_string(), r'<a name=123></a>[\[#123\]]')  # noqa: E501

    def test_040_row_says_NO_endcap(self):
        self._has_endcap_yes_or_no(False)

    @given_input_string
    def case(self):
        return (r'|<a name=123></a>[\[#123\]] |       | using the TO_DO stack' + '\n')  # noqa: E501


def _failure_message_via_line(upstream_s):
    def listener(*chan_msg):
        def o(s):
            a.append(s)
        chan_msg[-1](o)
    a = []
    x = _subject_module()(
            upstream_line=upstream_s,
            listener=listener,
            )
    None if x is None else sanity('should be none')
    return 'EEK'.join(a)


class _CaseState:
    def __init__(self, s):
        self.row = _subject_module()(s, listener=None)
        self.original_string = s


def _subject_module():
    return co.sub_magnetic('row_as_editable_line_via_line')


if __name__ == '__main__':
    unittest.main()

# #born.
