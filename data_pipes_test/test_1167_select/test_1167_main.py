from data_pipes_test.cli_support import CLI_Case
import unittest


class CommonCase(CLI_Case, unittest.TestCase):

    def given_argv(self):
        return '[me]', 'select', * self.given_argv_tail()

    do_debug = False


class Case1167_select_help(CommonCase):

    def test_050_exits_with_success_returncode(self):
        self.expect_success_returncode()

    def test_100_this_string_is_in_first_line_of_description(self):
        act = self.end_state.lines[2]
        self.assertIn('sorta like the SQL command', act)

    def given_argv_tail(self):
        return '--help',


class Case1169_minimally_illustrative(CommonCase):

    def test_050_return_code_is_good(self):
        self.expect_success_returncode()

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
