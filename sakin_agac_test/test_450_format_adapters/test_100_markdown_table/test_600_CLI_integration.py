# #covers: script.sync

import _init  # noqa: F401
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        memoize,
        )
import unittest


class _CommonCase(unittest.TestCase):
    """NOTE - many of these is abstraction candidates"""

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
        return self._this_line(0)

    def _second_line(self):
        return self._this_line(1)

    def _this_line(self, offset):
        return self._stderr_lines()[offset]

    def _stderr_lines(self):
        return self._end_state().stderr_lines

    # -- build end state

    def _build_end_state(self):

        _argv = self._argv()

        _stdin = self._stdin()

        stdout, stderr, end_stater = self._sout_and_serr_and_end_stater()

        _cli = _subject_script()._CLI(_stdin, stdout, stderr, _argv)

        _actual_exitstatus = _cli.execute()

        return end_stater(_actual_exitstatus)

    def _expect_this_many_on_stderr(self, num):
        return self._expect_on_X_this_many('stderr', num)

    def _expect_on_X_this_many(self, which, num):
        return _these().for_expect_on_which_this_many_under(which, num, self)

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

    def _sout_and_serr_and_end_stater(self):
        return self._expect_this_many_on_stderr(2)


class Case030_strange_option(_CommonCase):  # #coverpoint6.1.2

    def test_100_fails(self):
        self._CLI_client_results_in_failure_exitstatus()

    def test_110_SECOND_line_explains(self):
        _ = self._second_line()
        self.assertEqual(_, 'me: error: unrecognized arguments: --zazoozle\n')

    def test_120_displays_usage(self):
        self._displays_usage()

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def _argv(self):
        return ('me', '--zazoozle', 'aa', 'bb')

    def _sout_and_serr_and_end_stater(self):
        return self._expect_this_many_on_stderr(2)


class Case035_missing_requireds(_CommonCase):

    def test_100_fails(self):
        self._CLI_client_results_in_failure_exitstatus()

    def test_110_umm(self):
        _act = self._second_line()
        _exp = 'the following arguments are required: '
        'near-collection, far-collection'
        self.assertIn(_exp, _act)

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def _argv(self):
        return ('me',)

    def _sout_and_serr_and_end_stater(self):
        return self._expect_this_many_on_stderr(2)


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

    def _sout_and_serr_and_end_stater(self):
        return _these().for_recording_all_stderr_lines()

    def _argv(self):
        return ('me', '-h')


class Case050_FA_help_screen(_CommonCase):

    def test_100_succeeds(self):
        self._CLI_client_results_in_success_exitstatus()

    def test_200_stdout_lines_look_like_items__at_least_two(self):
        import re
        rx = re.compile(r'^ +[_a-z]+ \(\*\.[a-z]{2,3}\)$')  # ..
        s_a = self._end_state().first('stdout').lines
        self.assertGreaterEqual(len(s_a), 2)
        for s in s_a:
            self.assertRegex(s, rx)

    def test_300_total_number_of_format_adapters_at_end(self):
        s_a = self._end_state().last('stderr').lines
        self.assertEqual(len(s_a), 1)
        self.assertRegex(s_a[0], r'^\(\d+ total\.\)$')

    def test_400_reminder_at_begnning_about_help(self):
        _s_a = self._end_state().first('stderr').lines
        self.assertIn('FYI', _s_a[0])

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def _sout_and_serr_and_end_stater(self):
        return _these().for_flip_flopping_sectioner()

    def _argv(self):
        return ('me', '--near-format', 'help', 'xx', 'yy')


class _non_interactive_IO:  # as namespace only

    def isatty():
        return False


class _interactive_IO:  # as namespace only

    def isatty():
        return True


def _help_screen_lib():
    import script_lib.test_support.expect_help_screen as lib
    return lib


def _these():
    import script_lib.test_support.stdout_and_stderr_and_end_stater as lib
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
