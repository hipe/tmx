# #covers: script.sync

import _init  # noqa: F401
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        memoize,
        )
import unittest


class _CommonCase(unittest.TestCase):
    """NOTE - all of this is abstraction candidates"""

    # -- assertions

    def _CLI_client_results_in_failure_exitstatus(self):
        self._CLI_client_results_in_success_or_failure(False)

    def _CLI_client_results_in_success_or_failure(self, expect_success):
        sta = self._end_state()
        es = sta.exitstatus
        self.assertEqual(type(es), int)  # #[#412]
        if expect_success:
            self.assertEqual(es, 0)
        else:
            self.assertNotEqual(es, 0)

    # -- assertion assist

    def _first_line(self):
        return self._end_state().lines[0]

    # -- build end state

    def _build_end_state(self):

        import script_lib.test_support.expect_STDs as lib

        actual_lines, itr = self._expected_stderr_lines()

        _exp = lib.expect_stderr_lines(itr)

        perfo = _exp.to_performance_under(self)

        _stdin = self._stdin()

        _cli = _subject_script()._CLI(_stdin, perfo.stdout, perfo.stderr, ())

        actual_exitstatus = _cli.execute()

        return _EndState(actual_exitstatus, tuple(actual_lines))

    def _expect_this_many(self, num):

        actual_lines = []

        def f(line):
            actual_lines.append(line)

        _line_expectations = (f for _ in range(0, num))

        return actual_lines, _line_expectations


class Case010_basics(_CommonCase):

    def test_100_subject_script_loads(self):
        self.assertIsNotNone(_subject_script())


class Case020_must_be_interactive(_CommonCase):

    def test_100_CLI_client_results_in_failure_exitstatus(self):
        self._CLI_client_results_in_failure_exitstatus()

    def test_110_first_line_explains(self):
        self.assertEqual(self._first_line(), 'cannot yet read from STDIN.\n')

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def _stdin(self):
        return _non_interactive_IO

    def _expected_stderr_lines(self):
        return self._expect_this_many(2)


class _EndState:

    def __init__(self, d, s_a):
        self.exitstatus = d
        self.lines = s_a


class _non_interactive_IO:  # as namespace only

    def isatty():
        return False


@memoize
def _subject_script():
    import script.sync as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
