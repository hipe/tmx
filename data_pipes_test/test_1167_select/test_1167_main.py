from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_child_classes
import unittest


class CommonCase(unittest.TestCase):

    @property
    @shared_subj_in_child_classes
    def end_state(self):
        from script_lib.test_support.expect_STDs import \
            build_end_state_passively_for as func
        return func(self)

    def given_stdin(_):
        pass

    def given_argv(self):
        return 'ohai mami', 'select', * self.given_argv_tail()

    def given_CLI(_):
        from data_pipes.cli import _CLI as func
        return func

    do_debug = False


class Case0044_select_help(CommonCase):

    def test_050_executes(self):
        self.assertEqual(self.end_state.exitcode, 0)

    def test_100_this_string_is_in_first_line_of_description(self):
        act = self.end_state.lines[2]
        self.assertIn('sorta like the SQL command', act)

    def given_argv_tail(self):
        return '--help',


if __name__ == '__main__':
    unittest.main()

# #extracted
