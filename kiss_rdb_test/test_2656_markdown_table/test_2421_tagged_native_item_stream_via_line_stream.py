from kiss_rdb_test.common_initial_state import functions_for, unindent
import modality_agnostic.test_support.common as em
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_children
import unittest


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
        tuples = _common_execute(lines_or_file, listener)
        emi, = emissions
        msgs = emi.to_messages()
        return _EndState(tuples, msgs)

    def build_end_state_expecting_no_emissions(self):
        lines_or_file = self.fixture_lines_or_file()
        listener, _ = em.listener_and_emissions_for(self, limit=0)
        tuples = _common_execute(lines_or_file, listener)
        return _EndState(tuples)

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

    def test_020_transitioned_as_expected(self):
        es = self.end_state
        act = tuple(sx[0] for sx in es.contiguous_sexp_type_and_counts)
        exp = 'non_table_line', 'complete_schema', \
              'business_row_AST', 'non_table_line'
        self.assertSequenceEqual(act, exp)

    def test_030_expect_head_and_tail_lines_came_thru(self):
        _1, _, _, _2 = self.end_state.contiguous_sexp_type_and_counts
        assert _1[1] == 3
        assert _2[1] == 4

    def test_040_expect_all_the_rows_came_thru(self):
        act = self.end_state.count_via_sexp_type['business_row_AST']
        assert act == 2

    def build_end_state(self):
        return self.build_end_state_expecting_no_emissions()

    def given_markdown(_):
        return '0100-hello.md'


class Case2424_table_header(CommonCase):

    def test_010_hi(self):
        es = self.end_state
        assert es.did_succeed
        typ, *rest = es.tuples[2]
        assert 'complete_schema' == typ
        sch, = rest
        act = sch.table_cstack_[-1]['table_header_line']  # eek
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
        |eg|[#867.5.1]
        |x1|x2|x3
        |x4|x5|x6|

        ## 2
        |dd|ee|ff|
        |---|---|---
        |x|x|x
        """)


class Case2428_050_multi_table_okay_with_directives(CommonCase):

    def test_010_not_yes(self):
        current_type = None
        counts = []
        for sx in self.end_state.tuples:
            typ = sx[0]
            if current_type != typ:
                counts.append([typ, 0])
                current_type = typ
            counts[-1][1] += 1

        exp = ['non_table_line', 10], ['complete_schema', 1], \
              ['business_row_AST', 1], ['non_table_line', 9]

        self.assertSequenceEqual(counts, exp)

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


def _common_execute(lines_or_file, listener):

    typ = lines_or_file[0]
    if 'file_not_lines' == typ:
        entry, = lines_or_file[1:]
        path = fixture_path(entry)
        opened = open(path)
    else:
        assert 'lines_not_file' == typ
        itr, = lines_or_file[1:]
        from contextlib import nullcontext as func
        opened = func(itr)

    tagged_row_ASTs_or_lines_via = subject_function()
    with opened as lines:
        return tuple(tagged_row_ASTs_or_lines_via(lines, listener))


class _EndState:
    def __init__(self, tuples, error_messages=None):
        if error_messages is not None:
            self.error_messages = tuple(error_messages)
            self.did_succeed = False
            return
        for k, x in _calculate_state_statistics(tuples):
            setattr(self, k, x)
        self.tuples = tuples
        self.did_succeed = True


def _calculate_state_statistics(tuples):
    """answer questions about state transitions.

    questions like:
      - what was the order in which the states were visited?
      - how many elements were produced in each state?

    infallible.
    """

    class statistics:  # #class-as-namespace
        pass
    self = statistics

    self._change_state = None
    self._current_count = None
    self._current_state = None
    result_tuples = []

    def increment_count_initially():
        raise Exception('no see')

    self._increment_count = increment_count_initially

    def change_state_initially(state):
        self._increment_count = increment_count_normally
        do_change_state(state)
        self._change_state = change_state_normally

    self._change_state = change_state_initially

    def increment_count_normally():
        self._current_count += 1

    def change_state_normally(state):
        result_tuples.append((self._current_state, self._current_count))
        do_change_state(state)

    def do_change_state(state):
        self._current_count = 1
        self._current_state = state

    for tup in tuples:
        state = tup[0]
        if self._current_state == state:
            self._increment_count()
        else:
            self._change_state(state)

    self._change_state(None)

    yield 'contiguous_sexp_type_and_counts', tuple(result_tuples)
    yield 'count_via_sexp_type', {k: v for (k, v) in result_tuples}


def lines_via_indendted_big_string(big_string):
    from re import finditer as func  # [#610]
    return (md[1] for md in func(r'^[ ]*((?:[^ ][^\n])*?\n)', big_string))


def subject_function():
    from kiss_rdb_test.markdown_storage_adapter import \
            tagged_row_ASTs_or_lines_via_lines as function
    return function


if __name__ == '__main__':
    unittest.main()

# #history-B.4: changed parsing to use state machine and added many cases
# #history-A.1: remove "too few cels"
# #born.
