from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_child_classes
import unittest


class CommonCase(unittest.TestCase):  # #[#459.F] CLI integ tests have redundan

    # == Assert Exitcode (assertions then readers)

    def expect_failure_exitcode(self):
        self.assertNotEqual(self.exitcode_checked(), 0)

    def expect_success_exitcode(self):
        self.assertEqual(self.exitcode_checked(), 0)

    def exitcode_checked(self):
        act = self.end_state.exitcode
        self.assertIsInstance(act, int)
        return act

    # == High-Level Custom Assertions

    def expect_choo_cha_boo_bah(self):  # NOTE not alphabetized (unlike before)
        act = self.end_state_file_table.table_lines
        self.assertIn('choo chah', act[-2])
        self.assertIn('boo bah', act[-1])
        self.assertEqual(len(act), 4)

    def invites(self):
        # _exp = "see 'ohai-mami --help'\n"
        # _exp = "Try 'ohai-mami convert-collection --help' for help.\n"
        exp = 'Use "ohai mami convert-collection -h" for help'
        self.assertIn(exp, self.last_stderr_line())

    @property
    @shared_subject_in_child_classes
    def end_state_file_table(self):
        itr = iter(self.stdout_lines)
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

    # == Assert Output Lines

    def expect_expected_output_lines(self):
        actual_lines = self.stdout_lines
        expected_lines = tuple(self.expected_output_lines())
        self.assertSequenceEqual(actual_lines, expected_lines)

    # == Read End State Lines

    @property
    def reason_stderr_line(self):
        return self.last_stderr_line()  # click ick/meh

    def first_stderr_line(self):
        return self.stderr_lines[0]

    def last_stderr_line(self):
        return self.stderr_lines[-1]

    @property
    def stdout_lines(self):
        return self.end_state.stdout_lines

    @property
    def stderr_lines(self):
        return self.end_state.stderr_lines

    # == Build End State

    @property
    @shared_subject_in_child_classes
    def end_state(self):
        # (before #history-B.3 this was the UGLIEST support code for click)

        from script_lib.test_support.expect_STDs import \
            build_end_state_passively_for as func

        return func(self)

    # == Givens (defaults & convenience readers)

    def stdin_that_is_NOT_interactive(self):
        return 'FAKE_STDIN_NON_INTERACTIVE'

    def stdin_that_IS_interactive(self):
        return 'FAKE_STDIN_INTERACTIVE'

    def given_argv(self):
        return 'ohai mami', 'convert-collection', *self.given_argv_tail()

    def given_CLI(_):
        from data_pipes.cli import _CLI as func
        return func

    do_debug = False


class Case1050_help(CommonCase):

    def test_100_succeeds(self):
        self.expect_success_exitcode()

    def test_200_content(self):
        lines = self.end_state.first_line_run('stderr').lines
        self.assertIn('usage: ', lines[0])
        self.assertAlmostEqual(len(lines), 18, delta=5)

    def given_stdin(self):
        return self.stdin_that_IS_interactive()  # be jerks

    def given_argv_tail(self):
        return ('--help',)


class Case1053_no_args(CommonCase):

    def test_100_fails(self):
        self.expect_failure_exitcode()

    def test_200_whines(self):
        exp = "Expecting FROM_COLLECTION"
        self.assertIn(exp, self.reason_stderr_line)

    def test_300_invites(self):
        self.invites()

    def given_stdin(self):
        return self.stdin_that_IS_interactive()  # be jerks

    def given_argv_tail(self):
        return ()


class Case1056_args_and_stdin(CommonCase):

    def test_100_fails(self):
        self.expect_failure_exitcode()

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

    def given_argv_tail(self):
        return ('no-see-1', 'no-see-2')


class Case1059_too_many_args(CommonCase):

    def test_100_fails(self):
        self.expect_failure_exitcode()

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

    def given_argv_tail(self):
        return ('no-see', '--fing-foo', 'da-da')


class Case1062DP_one_arg_which_is_stdin(CommonCase):  # #midpoint

    def test_100_succeeds(self):
        self.expect_success_exitcode()

    def test_200_header_row_and_second_one(self):
        act = self.end_state_file_table.table_lines
        self.assertRegex(act[0], r'^\| [A-Z][a-z]+ \|$')
        self.assertRegex(act[1], r'^(?:\|[-:]-+:?)+\|$')

    def test_220_business_object_rows_are_NOT_alpahbetized(self):
        self.expect_choo_cha_boo_bah()

    def test_300_head_lines(self):
        _act = self.end_state_file_table.head_lines
        self.assertIn('i am your collection', _act[1])

    def test_400_tail_lines(self):
        _act = self.end_state_file_table.tail_lines
        self.assertIn('#born', _act[-1])

    def given_stdin(self):
        return (
                # '{ "header_level": 1 }\n',  # #history-A.2
                '{ "lesson": "[choo chah](foo fa)" }\n',
                '{ "lesson": "[boo bah](loo la)" }\n')

    def given_argv_tail(self):
        return ('-', '--from-format', 'producer-script',
                '-', '--to-format', 'markdown-table')


class Case1065_one_arg_which_is_token(CommonCase):

    def test_100_succeeds(self):
        self.expect_success_exitcode()

    def test_200_same_business_lines(self):
        self.expect_choo_cha_boo_bah()

    def given_stdin(self):
        return self.stdin_that_IS_interactive()

    def given_argv_tail(self):
        from data_pipes_test.common_initial_state import \
            executable_fixture as func
        producer_script = func('exe_140_khong_micro.py')
        return producer_script, '-', '--to-format', 'markdown-table'


class Case1068DP_convert_from_CSV_to_json(CommonCase):

    def test_100_succeeds(self):
        self.expect_success_exitcode()

    def test_200_outputs_correctly(self):
        self.expect_expected_output_lines()

    def given_argv_tail(self):
        return '-f', 'csv', '-', '-'  # json is default format

    def given_stdin(self):
        yield 'Field A, Field B\n'
        yield 'ting 1, ting 2\n'
        yield 'ting 3, ting 4\n'

    def expected_output_lines(_):
        yield '[{\n'
        yield '  "field_A": "ting 1",\n'
        yield '  "field_B": "ting 2"\n'
        yield '},\n'
        yield '{\n'
        yield '  "field_A": "ting 3",\n'
        yield '  "field_B": "ting 4"\n'
        yield '}]\n'


class Case1071_convert_from_json_to_CSV(CommonCase):

    def test_100_succeeds(self):
        self.expect_success_exitcode()

    def test_200_outputs_correctly(self):
        self.expect_expected_output_lines()

    def given_argv_tail(self):
        return '-f', 'json', '-', '-t', 'csv', '-'

    def given_stdin(self):
        yield '[{\n'
        yield '  "field_A": "ting 1",\n'
        yield '  "field_B": "ting 2"\n'
        yield '},\n'
        yield '{\n'
        yield '  "field_A": "ting 3",\n'
        yield '  "field_B": "ting 4"\n'
        yield '}]\n'

    def expected_output_lines(_):
        yield 'Field A, Field B\n'
        yield 'ting 1, ting 2\n'
        yield 'ting 3, ting 4\n'


if __name__ == '__main__':
    unittest.main()

# #history-B.4 begin magnetic cloud transition
# #history-B.3 get rid of the ugliest click related code ever
# #history-B.2
# #history-A.3: moved here from another subproject
# #history-A.2 implementation moved to kiss (convert collection)
# #history-A.1: when interfolding became the main algorithm, order changed
# #born.
