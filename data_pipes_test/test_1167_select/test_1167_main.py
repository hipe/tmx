from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_child_classes
import unittest


class CommonCase(unittest.TestCase):

    # Assertion support

    def exits_with_success_exitcode(self):
        self.assertEqual(self.end_state.exitcode, 0)

    def expect_expected_output_lines(self):
        self.expect_expected_lines('stdout', 'expected_output_lines')

    def expect_expected_errput_lines(self):
        self.expect_expected_lines('stderr', 'expected_errput_lines')

    def expect_expected_lines(self, which, attr):
        es = self.end_state
        act_lines = es.only_line_run(which).lines
        exp_lines = tuple(getattr(self, attr)())
        self.assertSequenceEqual(act_lines, exp_lines)

    # Performance

    @property
    @shared_subj_in_child_classes
    def end_state(self):
        from script_lib.test_support.expect_STDs import \
            build_end_state_passively_for as func
        return func(self)

    def given_CLI(_):
        from data_pipes.cli import _CLI as func
        return func

    def given_stdin(self):
        itr = self.given_input_lines()
        if itr is None:
            return
        from kiss_rdb_test.filesystem_spy import mock_filehandle as func
        return func(itr, '<stdin>')

    def given_input_lines(_):
        pass

    def given_argv(self):
        return 'ohai mami', 'select', * self.given_argv_tail()

    def expected_output_lines(_):
        pass

    def expected_errput_lines(_):
        pass

    do_debug = False


class Case1167_select_help(CommonCase):

    def test_050_exits_with_success_exitcode(self):
        self.exits_with_success_exitcode()

    def test_100_this_string_is_in_first_line_of_description(self):
        act = self.end_state.lines[2]
        self.assertIn('sorta like the SQL command', act)

    def given_argv_tail(self):
        return '--help',


class Case1169_minimally_illustrative(CommonCase):

    def test_050_return_code_is_good(self):
        self.assertEqual(self.end_state.exitcode, 0)

    def test_100_outputs_only_the_matched_entities(self):
        self.expect_expected_output_lines()

    def test_200_errpost_this_friendly_message(self):
        self.expect_expected_errput_lines()

    def expected_errput_lines(self):
        yield '`select` saw 2 entit{y|ies}\n'

    def expected_output_lines(self):
        yield '[{\n'
        yield '  "tha_flavor": "chocolate"\n'
        yield '},\n'
        yield '{\n'
        yield '  "tha_flavor": "vanilla"\n'
        yield '}]\n'

    def given_input_lines(self):
        yield '[{\n'
        yield '  "tha_flavor": "chocolate",\n'
        yield '  "cost": "$1/scoop"\n'
        yield '},\n'
        yield '{\n'
        yield '  "tha_flavor": "vanilla",\n'
        yield '  "cost": "$0.75/scoop"\n'
        yield '}]\n'

    def given_argv_tail(self):
        return '-', 'tha_flavor'


if __name__ == '__main__':
    unittest.main()

# #extracted
