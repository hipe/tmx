# #covers: sakin_agac.format_adapters.markdown_table.magnetics.tagged_native_item_stream_via_line_stream  # noqa: E501

from _init import (
        fixture_file_path,
        minimal_listener_spy,
        )
from modality_agnostic.memoization import (
import sakin_agac_test.test_450_format_adapters.test_100_markdown_table._common as co  # noqa: E501
        lazy)
import unittest


class _CommonCase(unittest.TestCase):

    def _fails(self):
        self._expect_did_succeed(False)

    def _succeeds(self):
        self._expect_did_succeed(True)

    def _expect_did_succeed(self, yn):
        _act = self.snapshot().did_succeed
        self.assertEqual(_act, yn)

    def _failed_talking_bout(self, s):
        act_s_a = self.snapshot().error_messages
        self.assertEqual(act_s_a, (s,))

    def _expect_all_normal_transitions(self):
        self._expect_these_transitions(_all_possible_transitions)

    def _expect_these_transitions(self, these):
        _act = tuple((tup[0] for tup in self.snapshot().STATE_AND_COUNTS))
        self.assertEqual(_act, these)

    def _expect_this_many_head_and_tail_lines(self, hl, tl):
        self._expect_this_many('head_line', hl)
        self._expect_this_many('tail_line', tl)

    def _expect_this_many_rows(self, n):
        self._expect_this_many('business_object_row', n)

    def _expect_this_many(self, k, n):
        _act = self.snapshot().COUNT_VIA_STATE[k]
        self.assertEqual(_act, n)


def failure_snapshot(f):  # local decorator

    def g(ignore_self):
        return mutable_f()

    def mutable_f():
        fixture_file = f(None)
        a, listener = minimal_listener_spy()
        tuples = _common_execute(fixture_file, listener)

        def final_f():
            return x
        x = _Snapshot(tuples, a)
        nonlocal mutable_f
        mutable_f = final_f
        return mutable_f()

    return g


def success_snapshot(f):  # local decorator

    def g(ignore_self):
        return mutable_f()

    def mutable_f():
        fixture_file = f(None)
        tuples = _common_execute(fixture_file, 'listener03')

        def final_f():
            return x
        x = _Snapshot(tuples)
        nonlocal mutable_f
        mutable_f = final_f
        return mutable_f()

    return g


class Case020_fail_too_many_rows(_CommonCase):  # #coverpoint3.1

    def test_005_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_010_fails(self):
        self._fails()

    def test_020_talkin_bout_etc(self):
        # #overloaded-test
        _exp = 'row cannot have more cels than the schema row has. (had 5, needed 3.)'  # noqa: E501
        self._failed_talking_bout(_exp)

    @failure_snapshot
    def snapshot(self):
        return '0090-cel-overflow.md'


class Case030_minimal_working(_CommonCase):

    def test_010_succeeds(self):
        self._succeeds()

    def test_020_transitioned_as_expected(self):
        self._expect_all_normal_transitions()

    def test_030_expect_head_and_tail_lines_came_thru(self):
        self._expect_this_many_head_and_tail_lines(3, 4)

    def test_040_expect_all_the_rows_came_thru(self):
        self._expect_this_many_rows(2)

    @success_snapshot
    def snapshot(self):
        return '0100-hello.md'


def _common_execute(fixture_file, listener):

    _magnetic = _subject_module().OPEN_TAGGED_DOC_LINE_ITEM_STREAM
    _path = fixture_file_path(fixture_file)
    _cm = _magnetic(upstream_path=_path, listener=listener)
    tuples = []
    with _cm as itr:
        for tup in itr:
            tuples.append(tup)
    return tuple(tuples)


class _Snapshot:

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

    def increment_count():
        raise Exception('no see')

    def change_state(state):

        nonlocal increment_count

        def increment_count():
            nonlocal curr_count
            curr_count += 1

        _do_change_state(state)
        nonlocal change_state
        change_state = _change_state_normally

    def _change_state_normally(state):
        result_tuples.append((curr_state, curr_count))
        _do_change_state(state)

    def _do_change_state(state):
        nonlocal curr_count
        curr_count = 1
        nonlocal curr_state
        curr_state = state

    curr_count = None
    curr_state = None
    result_tuples = []

    for tup in tuples:
        very_curr_state = tup[0]
        if curr_state == very_curr_state:
            increment_count()
        else:
            change_state(very_curr_state)

    change_state(None)

    wat.STATE_AND_COUNTS = tuple(result_tuples)
    wat.COUNT_VIA_STATE = {k: v for (k, v) in result_tuples}


_all_possible_transitions = (
        'head_line',
        'table_schema_line_one_of_two',
        'table_schema_line_two_of_two',
        'business_object_row',
        'tail_line',
        )


def _subject_module():
    return co.sub_magnetic('tagged_native_item_stream_via_line_stream')


if __name__ == '__main__':
    unittest.main()

# #history-A.1: remove "too few cels"
# #born.
