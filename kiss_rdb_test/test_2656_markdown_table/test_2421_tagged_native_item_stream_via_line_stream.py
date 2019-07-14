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


def lazyer(snapshotter):  # [#510.6] experiment
    def decorator(test_context_method):

        # when the test context requests the snapshot..
        def memoized_snapshot(ignore_test_context):  # (ignore else dangerous)
            return lazy_valuer()  # ..dereference this memoized value

        # build the memoized value (once) by passing 1 function into another
        def build_snapshot():
            return snapshotter(test_context_method)
        lazy_valuer = lazy(build_snapshot)

        return memoized_snapshot
    return decorator


@lazyer
def failure_snapshot(f):
        fixture_file = f(None)
        a, listener = minimal_listener_spy()
        tuples = _common_execute(fixture_file, listener)
        return _Snapshot(tuples, a)


@lazyer
def success_snapshot(f):  # local decorator
        fixture_file = f(None)
        tuples = _common_execute(fixture_file, 'listener03')
        return _Snapshot(tuples)


class Case2420_fail_too_many_rows(_CommonCase):

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


# Case2421  #midpoint


class Case2422_minimal_working(_CommonCase):

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
    _path = fixture_path(fixture_file)
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

    self = _BlankState()
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


class _BlankState:  # #[#510.2]
    pass


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
