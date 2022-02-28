from kiss_rdb_test.common_initial_state import functions_for, unindent
import modality_agnostic.test_support.common as em
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_children
import unittest
from dataclasses import dataclass


fixture_path = functions_for('markdown').fixture_path


class CommonCase(unittest.TestCase):

    def _fails(self):
        self._expect_did_succeed(False)

    def _succeeds(self):
        self._expect_did_succeed(True)

    def _expect_did_succeed(self, yn):
        act = self.end_state.did_succeed
        self.assertEqual(act, yn)

    def _failed_talking_bout(self, s):
        act_s_a = self.end_state.error_messages
        self.assertEqual(act_s_a, (s,))

    def _expect_this_many_rows(self, n):
        self._expect_this_many('business_row_AST', n)

    @property
    @shared_subj_in_children
    def end_state(self):
        return self.build_end_state()

    def build_end_state_expecting_one_emission(self):
        lines_or_file = self.fixture_lines_or_file()
        listener, emissions = em.listener_and_emissions_for(self)
        return _build_end_state(lines_or_file, listener, emissions, 1)

    def build_end_state_expecting_no_emissions(self):
        lines_or_file = self.fixture_lines_or_file()
        listener, emissions = em.listener_and_emissions_for(self, limit=0)
        return _build_end_state(lines_or_file, listener, emissions, 0)

    def fixture_lines_or_file(self):
        func = self.given_markdown_lines
        if func:
            return 'lines_not_file', func()
        path = self.given_markdown()
        # == BEGIN some legacy-ism from before #history-B.4 idk
        assert isinstance(path, str)
        assert '\n' not in path
        return 'file_not_lines', path

    given_markdown_lines = None
    do_debug = False


class Case2420_fail_too_many_rows(CommonCase):

    def test_005_loads(self):
        self.assertIsNotNone(subject_function())

    def test_010_fails(self):
        self._fails()

    def test_020_talkin_bout_etc(self):
        # #overloaded-test
        _exp = 'row cannot have more cels than the schema row has. (had 5, needed 3.)'  # noqa: E501
        self._failed_talking_bout(_exp)

    def build_end_state(self):
        return self.build_end_state_expecting_one_emission()

    def given_markdown(_):
        return '0090-cel-overflow.md'


# Case2421  #midpoint


class Case2422_minimal_working(CommonCase):

    def test_010_succeeds(self):
        self._succeeds()

    def test_030_expect_head_and_tail_lines_came_thru(self):
        es = self.end_state
        assert 3 == len(es.leading_non_table_lines)
        assert 4 == len(es.trailing_non_table_lines)

    def test_040_expect_all_the_rows_came_thru(self):
        assert 2 == len(self.end_state.business_row_ASTs)

    def build_end_state(self):
        return self.build_end_state_expecting_no_emissions()

    def given_markdown(_):
        return '0100-hello.md'


class Case2424_table_header(CommonCase):

    def test_010_hi(self):
        es = self.end_state
        assert es.did_succeed
        act = es.complete_schema.table_header_line
        assert "# Zib Zub super table\n" == act

    def build_end_state(self):
        return self.build_end_state_expecting_no_emissions()

    def given_markdown_lines(_):
        return unindent("""
        # Zib Zub super table

        |aa|bb|cc|
        |---|---|---
        |x1|x2|x3
        |x4|x5|x6|

        """)


# Case2428_010 imagine file with no lines


class Case2428_020_file_with_no_table(CommonCase):

    def test_010_ohai(self):
        es = self.end_state
        assert not es.did_succeed
        act, = es.error_messages
        assert "no markdown table found in 2 lines" == act

    def build_end_state(self):
        return self.build_end_state_expecting_one_emission()

    def given_markdown_lines(_):
        yield "line 1\n"
        yield "line 2\n"


class Case2428_030_end_early(CommonCase):

    def test_010_is_OK(self):
        es = self.end_state
        assert es.did_succeed

    def build_end_state(self):
        return self.build_end_state_expecting_no_emissions()

    def given_markdown_lines(_):
        return unindent("""
        hello

        |aa|bb|cc|
        |---|---|---
        """)


class Case2428_040_multi_table_not_okay_normally(CommonCase):

    def test_010_not_yes(self):
        es = self.end_state
        assert not es.did_succeed
        act, = es.error_messages
        assert "for now can only have one table" == act

    def build_end_state(self):
        return self.build_end_state_expecting_one_emission()

    def given_markdown_lines(_):
        return unindent("""
        Shamonay

        # 1
        (zig zug)

        |aa|bb|cc|
        |---|---|---
        |eg|[#867.E]
        |x1|x2|x3
        |x4|x5|x6|

        ## 2
        |dd|ee|ff|
        |---|---|---
        |x|x|x
        """)


class Case2428_050_multi_table_okay_with_directives(CommonCase):

    def test_010_not_yes(self):
        es = self.end_state
        assert '## 2' in es.complete_schema.table_header_line
        assert 10 == len(es.leading_non_table_lines)
        assert 1 == len(es.business_row_ASTs)
        assert 9 == len(es.trailing_non_table_lines)

    def build_end_state(self):
        return self.build_end_state_expecting_no_emissions()

    def given_markdown_lines(_):
        return unindent("""
        Shamonay

        # 1
        (ignore this table: ohai)

        |aa|bb|cc|
        |---|---|---
        |one|two|

        ## 2
        |dd|ee|ff|
        |---|---|---
        |x1|x2|x3

        ## 3

        (ignore this table)
        |hh|ii|
        |---|---|
        |y1|y2

        yup
        """)


def _build_end_state(fh, listener, emissions, num_emis):
    typ, mixed = fh
    if 'file_not_lines' == typ:
        path = fixture_path(mixed)  # entry
        opened = open(path)
    else:
        assert 'lines_not_file' == typ
        from contextlib import nullcontext as func
        opened = func(mixed)  # iterator

    single_table_doc_scn_via_lines = subject_function()

    with opened as lines:
        dscn = single_table_doc_scn_via_lines(lines, listener)
        lines1 = tuple(dscn.release_leading_non_table_lines())
        sch = dscn.ok and dscn.release_complete_schema()
        asts = dscn.ok and tuple(dscn.release_business_row_ASTs())
        lines2 = dscn.ok and tuple(dscn.release_trailing_non_table_lines())

    msgs = None
    if 0 != num_emis:
        assert 1 == num_emis
        emi, = emissions
        msgs = tuple(emi.to_messages())

    return _EndState(
        did_succeed=dscn.ok, error_messages=msgs,
        leading_non_table_lines=lines1,
        complete_schema=sch,
        business_row_ASTs=asts,
        trailing_non_table_lines=lines2)


@dataclass
class _EndState:
    did_succeed: bool
    error_messages: tuple
    leading_non_table_lines: tuple[str]
    complete_schema: object
    business_row_ASTs: tuple[object]
    trailing_non_table_lines: tuple[str]


def lines_via_indendted_big_string(big_string):
    from re import finditer as func  # [#610]
    return (md[1] for md in func(r'^[ ]*((?:[^ ][^\n])*?\n)', big_string))


def subject_function():
    from kiss_rdb_test.markdown_storage_adapter import \
            single_table_document_scanner_via_lines as function
    return function


if __name__ == '__main__':
    unittest.main()

# #history-B.4: changed parsing to use state machine and added many cases
# #history-A.1: remove "too few cels"
# #born.
