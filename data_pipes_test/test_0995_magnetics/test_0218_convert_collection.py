from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_child_classes
import unittest


class CommonCase(unittest.TestCase):  # #[#459.F] CLI integ tests have redundan

    # -- assertions & assistance

    def _same_business_lines(self):  # NOTE not alphabetized (unlike before)
        act = self.outputted_file_lines.table_lines
        self.assertIn('choo chah', act[-2])
        self.assertIn('boo bah', act[-1])
        self.assertEqual(len(act), 4)

    def fails(self):
        self.assertNotEqual(self._validated_exitstatus(), 0)

    def succeeds(self):
        self.assertEqual(self._validated_exitstatus(), 0)

    def _validated_exitstatus(self):
        _es = self.end_state
        ec = _es.exitcode
        self.assertIsInstance(ec, int)
        return ec

    def invites(self):
        # _exp = "see 'ohai-mami --help'\n"
        # _exp = "Try 'ohai-mami convert-collection --help' for help.\n"
        exp = 'Use "ohai mami convert-collection -h" for help'
        self.assertIn(exp, self.last_stderr_line())

    @property
    def reason_stderr_line(self):
        return self.last_stderr_line()  # click ick/meh

    def first_stderr_line(self):
        return self.stderr_lines[0]

    def last_stderr_line(self):
        return self.stderr_lines[-1]

    @property
    def stderr_lines(self):
        return self._lines('stderr')

    def _lines(self, stdout_or_stderr):
        return self.end_state.first_line_run(stdout_or_stderr).lines

    @property
    @shared_subject_in_child_classes
    def outputted_file_lines(self):

        itr = iter(self.end_state.first_line_run('stdout').lines)
        line = next(itr)
        head_lines = []
        if '---' == line[0:3]:
            while True:
                head_lines.append(line)
                line = next(itr)
                if '---' == line[0:3]:
                    head_lines.append(line)
                    break

        table_title_line = None

        for line in itr:
            if '\n' == line:
                continue
            if '#' != line[0]:
                break
            table_title_line = line
            for line in itr:
                if '\n' == line:
                    continue
                break
            break

        assert '|' == line[0]
        table_lines = []
        while True:
            table_lines.append(line)
            line = next(itr)
            if '|' != line[0]:
                break

        while '\n' == line:
            line = next(itr)

        _1, _2, _3 = head_lines, table_title_line, table_lines

        class OutputtedFileLines:  # #class-as-namespace
            head_lines = tuple(_1)
            table_title_line = _2
            table_lines = tuple(_3)
            tail_lines = (line, *itr)

        return OutputtedFileLines

    @property
    @shared_subject_in_child_classes
    def end_state(self):
        # (before #history-B.3 this was the UGLIEST support code for click)

        from script_lib.test_support.expect_STDs import \
            build_end_state_passively_for as func

        return func(self)

    def stdin_that_is_NOT_interactive(self):
        return 'FAKE_STDIN_NON_INTERACTIVE'

    def stdin_that_IS_interactive(self):
        return 'FAKE_STDIN_INTERACTIVE'

    def given_argv(self):
        return 'ohai mami', 'convert-collection', *self.argv_tail()

    def given_CLI(_):
        from data_pipes.cli import _CLI as func
        return func

    do_debug = False


class Case010_help(CommonCase):

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_content(self):
        lines = self.end_state.first_line_run('stderr').lines
        self.assertIn('usage: ', lines[0])
        self.assertAlmostEqual(len(lines), 18, delta=2)

    def given_stdin(self):
        return self.stdin_that_IS_interactive()  # be jerks

    def argv_tail(self):
        return ('--help',)


class Case020_no_args(CommonCase):

    def test_100_fails(self):
        self.fails()

    def test_200_whines(self):
        exp = "Expecting FROM_COLLECTION"
        self.assertIn(exp, self.reason_stderr_line)

    def test_300_invites(self):
        self.invites()

    def given_stdin(self):
        return self.stdin_that_IS_interactive()  # be jerks

    def argv_tail(self):
        return ()


class Case030_args_and_stdin(CommonCase):

    def test_100_fails(self):
        self.fails()

    def test_200_content(self):
        # exp = 'parameter error: when piping from STDIN, <script> must be "-"
        exp = "STDIN cannot be a pipe unless FROM_COLLECTION is '-'\n"
        act = self.first_stderr_line()
        self.assertEqual(act, exp)

    def test_300_invites(self):
        # broke at #history-A.2
        self.assertEqual(len(self.stderr_lines), 1)
        # self.invites()

    def given_stdin(self):
        return self.stdin_that_is_NOT_interactive()

    def argv_tail(self):
        return ('no-see-1', 'no-see-2')


class Case040_too_many_args(CommonCase):

    def test_100_fails(self):
        self.fails()

    def test_200_content(self):
        act = self.reason_stderr_line
        # exp = "parameter error: unrecognized option: '--fing-foo'\n"
        # exp = "Error: no such option: --fing-foo\n"
        exp = "Unrecognized option '--fing-foo'"
        self.assertIn(exp, act)

    def test_300_invites(self):
        self.invites()

    def given_stdin(self):
        return self.stdin_that_IS_interactive()

    def argv_tail(self):
        return ('no-see', '--fing-foo', 'da-da')


class Case050SA_one_arg_which_is_stdin(CommonCase):  # #midpoint

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_header_row_and_second_one(self):
        act = self.outputted_file_lines.table_lines
        self.assertRegex(act[0], r'^\| [A-Z][a-z]+ \|$')
        self.assertRegex(act[1], r'^(?:\|[-:]-+:?)+\|$')

    def test_220_business_object_rows_are_NOT_alpahbetized(self):
        self._same_business_lines()

    def test_300_head_lines(self):
        _act = self.outputted_file_lines.head_lines
        self.assertIn('i am your collection', _act[1])

    def test_400_tail_lines(self):
        _act = self.outputted_file_lines.tail_lines
        self.assertIn('#born', _act[-1])

    def given_stdin(self):
        return STUB_STDIN(
                # '{ "header_level": 1 }\n',  # #history-A.2
                '{ "lesson": "[choo chah](foo fa)" }\n',
                '{ "lesson": "[boo bah](loo la)" }\n')

    def argv_tail(self):
        return ('-', '--from-format', 'producer-script',
                '-', '--to-format', 'markdown-table')


class Case060_one_arg_which_is_token(CommonCase):

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_same_business_lines(self):
        self._same_business_lines()

    def given_stdin(self):
        return self.stdin_that_IS_interactive()

    def argv_tail(self):
        from kiss_rdb_test import fixture_executables as mod
        these = mod.__path__._path
        fixtures_dir, = tuple(set(these))  # sometimes there's 2 idk
        from os.path import join
        producer_script = join(fixtures_dir, 'exe_140_khong_micro.py')
        return producer_script, '-', '--to-format', 'markdown-table'


class STUB_STDIN:  # :[#605.4]

    def __init__(self, *lines):
        self._lines = lines

    def isatty(self):
        return False

    def __iter__(self):
        return iter(self._lines)

    def fileno(_):  # #provision [#608.15]: implement this correctly
        return 0

    mode = 'r'


if __name__ == '__main__':
    unittest.main()

# #history-B.3 get rid of the ugliest click related code ever
# #history-B.2
# #history-A.3: moved here from another subproject
# #history-A.2 implementation moved to kiss (convert collection)
# #history-A.1: when interfolding became the main algorithm, order changed
# #born.
