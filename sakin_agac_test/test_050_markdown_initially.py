from sakin_agac_test.common_initial_state import (
        executable_fixture)
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject)
import unittest


# Case001SA is used to reference this whole file


class _CommonCase(unittest.TestCase):  # #[#459.F]

    # -- assertions & assistance

    def _same_business_lines(self):
        act = self.table_lines()
        self.assertIn('boo bah', act[-2])
        self.assertIn('choo chah', act[-1])
        self.assertEqual(len(act), 5)

    def fails(self):
        self.assertNotEqual(self._validated_exitstatus(), 0)

    def succeeds(self):
        self.assertEqual(self._validated_exitstatus(), 0)

    def _validated_exitstatus(self):
        _es = self.end_state()
        es = _es.exitstatus
        self.assertIsInstance(es, int)
        return es

    def invites(self):
        _exp = "see 'ohai-mami --help'\n"
        self.assertEqual(self.last_stderr_line(), _exp)

    def first_stderr_line(self):
        return self._stderr_line(0)

    def last_stderr_line(self):
        return self._stderr_line(-1)

    def _stderr_line(self, offset):
        return self.end_state().first_line_run('stderr').lines[offset]

    def build_end_state(self):
        # sout, serr, end_stater = _this_one_lib().for_DEBUGGING()
        sout, serr, end_stater = _this_one_lib().three_for_line_runner()

        _stdin = self.stdin()

        _tail = self.argv_tail()
        _use_argv = ('ohai-mami', *_tail)

        from kiss_rdb.storage_adapters_.markdown_table.magnetics_ import (
                markdown_via_json_stream as subject_script)

        _es = subject_script._CLI(_stdin, sout, serr, _use_argv)

        _state = end_stater(_es)
        return _state

    def stdin_that_is_NOT_interactive(self):
        return _this_one_lib().MINIMAL_NON_INTERACTIVE_IO

    def stdin_that_IS_interactive(self):
        return _this_one_lib().MINIMAL_INTERACTIVE_IO


class Case010SA_help(_CommonCase):

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_content(self):
        lines = self.end_state().first_line_run('stderr').lines
        self.assertIn('usage: ', lines[0])
        self.assertAlmostEqual(len(lines), 10, delta=2)

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def stdin(self):
        return self.stdin_that_IS_interactive()  # be jerks

    def argv_tail(self):
        return ('--help',)


class Case020SA_no_args(_CommonCase):

    def test_100_fails(self):
        self.fails()

    def test_200_whines(self):
        _exp = 'parameter error: expecting <script>\n'
        self.assertEqual(self.first_stderr_line(), _exp)

    def test_300_invites(self):
        self.invites()

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def stdin(self):
        return self.stdin_that_IS_interactive()  # be jerks

    def argv_tail(self):
        return ()


class Case030SA_args_and_stdin(_CommonCase):

    def test_100_fails(self):
        self.fails()

    def test_200_content(self):
        _exp = 'parameter error: when piping from STDIN, <script> must be "-"\n'  # noqa: E501
        self.assertEqual(self.first_stderr_line(), _exp)

    def test_300_invites(self):
        self.invites()

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def stdin(self):
        return self.stdin_that_is_NOT_interactive()

    def argv_tail(self):
        return ('no-see',)


class Case040SA_too_many_args(_CommonCase):

    def test_100_fails(self):
        self.fails()

    def test_200_content(self):
        _exp = "parameter error: unrecognized option: '--fing-foo'\n"
        self.assertEqual(self.first_stderr_line(), _exp)

    def test_300_invites(self):
        self.invites()

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def stdin(self):
        return self.stdin_that_IS_interactive()

    def argv_tail(self):
        return ('no-see', '--fing-foo', 'da-da')


class Case050SA_one_arg_which_is_stdin(_CommonCase):

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_header_row_and_second_one(self):
        act = self.table_lines()
        self.assertRegex(act[0], r'^\| [A-Z][a-z]+ .+ \|$')
        self.assertRegex(act[1], r'^(?:\|[-:]-+:?)+\|$')

    def test_220_business_object_rows_got_alphabetized(self):
        self._same_business_lines()

    @shared_subject
    def table_lines(self):
        return self.end_state().first_line_run('stdout').lines

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def stdin(self):
        return _this_one_lib().STDERR_CRAZYTOWN(
                '{ "header_level": 1 }\n',
                '{ "lesson": "[choo chah](foo fa)" }\n',
                '{ "lesson": "[boo bah](loo la)" }\n',
                )

    def argv_tail(self):
        return ('-',)


class Case060SA_one_arg_which_is_token(_CommonCase):

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_same_business_lines(self):
        self._same_business_lines()

    @shared_subject
    def table_lines(self):
        return self.end_state().first_line_run('stdout').lines

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def stdin(self):
        return self.stdin_that_IS_interactive()

    def argv_tail(self):
        return (executable_fixture('exe_140_khong_micro.py'),)


def _this_one_lib():
    import script_lib.test_support.stdout_and_stderr_and_end_stater as lib
    return lib


if __name__ == '__main__':
    unittest.main()

# #history-A.1: when interfolding became the main algorithm, order changed
# #born.
