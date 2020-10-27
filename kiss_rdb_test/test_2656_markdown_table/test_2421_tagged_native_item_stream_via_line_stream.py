from kiss_rdb_test.common_initial_state import functions_for
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

    def _expect_all_normal_transitions(self):
        self._expect_these_transitions(_all_possible_transitions)

    def _expect_these_transitions(self, these):
        act = tuple((tup[0] for tup in self.end_state.STATE_AND_COUNTS))
        self.assertEqual(act, these)

    def _expect_this_many_head_and_tail_lines(self, hl, tl):
        self._expect_this_many('head_line', hl)
        self._expect_this_many('other_line', tl)

    def _expect_this_many_rows(self, n):
        self._expect_this_many('business_row_AST', n)

    def _expect_this_many(self, k, n):
        act = self.end_state.COUNT_VIA_STATE[k]
        self.assertEqual(act, n)

    @property
    @shared_subj_in_children
    def end_state(self):
        return self.build_end_state()

    def build_end_state_expecting_failure(self):
        fixture_file = self.fixture_file()
        listener, emissions = em.listener_and_emissions_for(self)
        tuples = _common_execute(fixture_file, listener)
        emi, = emissions
        msgs = emi.to_messages()
        return _EndState(tuples, msgs)

    def build_end_state_expecting_success(self):
        fixture_file = self.fixture_file()
        tuples = _common_execute(fixture_file, 'listener03')
        return _EndState(tuples)

    def fixture_file(self):
        x = self.given_markdown()
        # FOR NOW
        assert isinstance(x, str)
        assert '\n' not in x
        return x

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
        return self.build_end_state_expecting_failure()

    def given_markdown(_):
        return '0090-cel-overflow.md'


# Case2421  #midpoint


class Case2422_minimal_working(CommonCase):

    def test_010_succeeds(self):
        self._succeeds()

    def test_020_transitioned_as_expected(self):
        self._expect_all_normal_transitions()

    def test_030_expect_head_and_tail_lines_came_thru(self):
        self._expect_this_many_head_and_tail_lines(3, 4)

    def test_040_expect_all_the_rows_came_thru(self):
        self._expect_this_many_rows(2)

    def build_end_state(self):
        return self.build_end_state_expecting_success()

    def given_markdown(_):
        return '0100-hello.md'


def _common_execute(fixture_file, listener):
    tagged_row_ASTs_or_lines_via = subject_function()
    path = fixture_path(fixture_file)
    with open(path) as lines:
        return tuple(tagged_row_ASTs_or_lines_via(lines, listener))


class _EndState:
    def __init__(self, tuples, error_messages=None):
        if error_messages is None:
            self.did_succeed = True
            self.tuples = tuples
            _calculate_state_statistics(self, tuples)
        else:
            self.did_succeed = False
            self.error_messages = tuple(error_messages)


def _calculate_state_statistics(wat, tuples):
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

    wat.STATE_AND_COUNTS = tuple(result_tuples)
    wat.COUNT_VIA_STATE = {k: v for (k, v) in result_tuples}


_all_possible_transitions = (
        'beginning_of_file',
        'head_line',
        'table_schema_line_ONE_of_two',
        'table_schema_line_TWO_of_two',
        'business_row_AST',
        'other_line',
        'end_of_file')


def subject_function():
    from kiss_rdb_test.markdown_storage_adapter import \
            tagged_row_ASTs_or_lines_via_lines as function
    return function


if __name__ == '__main__':
    unittest.main()

# #history-A.1: remove "too few cels"
# #born.
