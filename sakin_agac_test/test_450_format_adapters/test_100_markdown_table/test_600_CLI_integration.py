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
        self._CLI_client_results_in_failure_or_success(False)

    def _CLI_client_results_in_success_exitstatus(self):
        self._CLI_client_results_in_failure_or_success(True)

    def _CLI_client_results_in_failure_or_success(self, expect_success):
        sta = self._end_state()
        es = sta.exitstatus
        self.assertEqual(type(es), int)  # #[#412]
        if expect_success:
            self.assertEqual(es, 0)
        else:
            self.assertNotEqual(es, 0)

    # -- assertion assist

    def _displays_usage(self):
        _lines = self._stderr_lines()
        self.assertRegex(
                _lines[0],
                r'^usage: me \[-h\] \[--near-format FORMAT\] '
                r'\[--far-format FORMAT\]\n'
                r' +near-collection far-collection$')

    def _first_line(self):
        return self._stderr_lines()[0]

    def _stderr_lines(self):
        return self._end_state().stderr_lines

    # -- build end state

    def _build_end_state(self):

        _argv = self._argv()

        _stdin = self._stdin()

        stdout, stderr, actual_lines = self._sout_and_serr_and_finisher()

        _cli = _subject_script()._CLI(_stdin, stdout, stderr, _argv)

        actual_exitstatus = _cli.execute()

        actual_sout, actual_serr = actual_lines()

        return _EndState(actual_exitstatus, actual_sout, actual_serr)

    def _sout_and_serr_and_finisher(self):

        serr_tup = self._expected_stderr_lines()

        lib = _expect_STDs()

        if True:
            if True:
                actual_serr_lines, serr_itr = serr_tup
                exp = lib.expect_stderr_lines(serr_itr)

                def f():
                    finish()
                    return (None, tuple(actual_serr_lines))

        perfo = exp.to_performance_under(self)
        finish = perfo.finish

        return perfo.stdout, perfo.stderr, f

    def _expect_this_many(self, num):

        actual_lines = []

        def f(line):
            actual_lines.append(line)

        _line_expectations = (f for _ in range(0, num))

        return actual_lines, _line_expectations

    def _stdin(self):
        return _interactive_IO


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

    def _argv(self):
        return ()

    def _expected_stderr_lines(self):
        return self._expect_this_many(2)


class Case030_strange_option(_CommonCase):  # #coverpoint6.1.2

    def test_100_fails(self):
        self._CLI_client_results_in_failure_exitstatus()

    def test_110_SECOND_line_explains(self):
        _ = self._stderr_lines()[1]
        self.assertEqual(_, 'me: error: unrecognized arguments: --zazoozle\n')

    def test_120_displays_usage(self):
        self._displays_usage()

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def _argv(self):
        return ('me', '--zazoozle', 'aa', 'bb')

    def _expected_stderr_lines(self):
        return self._expect_this_many(2)


class Case040_top_help_screen(_CommonCase):

    def test_100_succeeds(self):
        self._CLI_client_results_in_success_exitstatus()

    def test_200_something_about_usage(self):
        self._section('usage')  # exists

    def test_300_something_about_description(self):
        _sect = self._section('description')
        _first_line = _sect.children[0].styled_content_string
        self.assertIn('description: for a given particular natur', _first_line)

    def test_400_something_about_arguments(self):
        self._num_children(self._section('positional arguments'), 2)

    def test_500_something_about_options(self):
        self._num_children(self._section('optional arguments'), 3)  # -h + 1

    def _num_children(self, sect, num):
        cx = sect.children
        self.assertEqual(len(cx), 2)
        _act = len(cx[1].children)
        self.assertEqual(_act, num)

    def _section(self, key):
        return self._section_index()[key]

    @shared_subject
    def _section_index(self):
        _lines = self._end_state().stderr_lines
        return _help_screen_lib().section_index_via_chunks(_lines)

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def _sout_and_serr_and_finisher(self):

        def f():
            return None, tuple(lines)

        lines = []
        _serr = _expect_STDs().WriteOnly_IO_Proxy(lines.append)
        return None, _serr, f

    def _argv(self):
        return ('me', '-h')


class _EndState:

    def __init__(self, d, sout_line_tup, serr_line_tup):
        self.exitstatus = d
        self.STDOUT_LINES = sout_line_tup
        self.stderr_lines = serr_line_tup


class _non_interactive_IO:  # as namespace only

    def isatty():
        return False


class _interactive_IO:  # as namespace only

    def isatty():
        return True


def _help_screen_lib():
    import script_lib.test_support.expect_help_screen as lib
    return lib


def _expect_STDs():
    import script_lib.test_support.expect_STDs as lib
    return lib


@memoize
def _subject_script():
    import script.sync as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
