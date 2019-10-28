"""
At #history-A.1 #todo



  - case 0: zero arguments when one (or more) is expected.

  - case 1.1: the first argument is not recognized (think sub-parser)
  - case 1.2: the first term (an option-looking argument) is not recognized.
  - case 1.3: one sub-parser argument that *is* recognized.
  - case 1.4: one option-looking argument that *is* recognized.

typing a random word that starts with a dash ("-") is less likely to happen
to happen than not; and randomly typing a correct option or positional
argument is generally to happen than not (and in turn, probably less likely
than typing a word that ramdomly starts with a dash. (by the way: option
tokens start with dashes.)
"""

from script_lib.test_support.CLI_canon import (
        THESE_TWO_CHILDREN_CLI_METHODS,
        CLI_Canon_Case_Methods)
from modality_agnostic.memoization import dangerous_memoize as shared_subject
# lazy ^
import unittest


class _CommonCase(CLI_Canon_Case_Methods, unittest.TestCase):

    # -- assertion

    def second_line_invites_to(self, program_name):
        # (at #history-A.1 we lost the gross behavior)
        _exp = f"see '{program_name} --help'\n"
        self.assertEqual(self.second_line, _exp)

    # -- setup hook-outs common to all/most cases in this file

    def given_children_CLI_functions(self):
        return THESE_TWO_CHILDREN_CLI_METHODS()

    long_program_name = '/fake-fs/foo/bar/ohai-mami'

    # -- setup support

    do_debug = False


class Case5643_no_args(_CommonCase):  # classically case 0

    def test_010_subject_module_loads(self):
        from script_lib import cheap_arg_parse_branch
        self.assertIsNotNone(cheap_arg_parse_branch)

    def test_020_fails(self):
        self.invocation_fails()

    def test_030_invocation_results_in_this_exitstatus(self):
        self.invocation_results_in_this_exitstatus(457)

    def test_050_first_line_says_expecting_sub_command(self):
        _exp = 'parameter error: expecting <sub-command>\n'
        self.assertEqual(self.first_line, _exp)

    def test_060_second_line_says_invite(self):
        self.assertEqual(self.second_line[0:4], 'see ')

    @property
    @shared_subject
    def end_state(self):
        return self.invoke_expecting(line_count=2, which='STDERR')

    def given_argv_tail(self):
        return ()


class Case5647_strange_subparser_name(_CommonCase):  # classically case 1.1

    def test_020_invokes(self):
        self.invokes()

    def test_030_invocation_results_in_failure(self):
        self.invocation_fails()

    def test_040_invocation_has_particular_exitstatus(self):
        self.invocation_results_in_this_exitstatus(1)

    def test_060_main_line_says_this(self):
        import re
        md = re.match(r'([^(]+) \(([^)]+)\)$', self.first_line)
        head, tail = md.groups()
        self.assertEqual(head, "no sub-command for 'fhqwhgads'.")
        self.assertEqual(tail, "there's 'foo-bar' and 'biff-baz'")

    def test_070_second_line_says_invite(self):
        self.second_line_invites_to('ohai-mami')

    @property
    @shared_subject
    def end_state(self):
        return self.invoke_expecting(line_count=2, which='STDERR')

    def given_argv_tail(self):
        return ('fhqwhgads',)


# Case5650  # #midpoint


class Case5653_strange_option(_CommonCase):  # classically case 1.2

    def test_020_invokes(self):
        self.invokes()

    def test_030_invocation_results_in_failure(self):
        self.invocation_fails()

    def test_040_invocation_has_particular_exitstatus(self):
        self.invocation_results_in_this_exitstatus(457)

    def test_060_main_line_says_this(self):
        self.assertIn("unrecognized option: '-x'", self.first_line)

    def test_070_second_line_says_invite(self):
        self.second_line_invites_to('ohai-mami')

    @property
    @shared_subject
    def end_state(self):
        return self.invoke_expecting(line_count=2, which='STDERR')

    def given_argv_tail(self):
        return ('-x', '--another', '--etc')


class Case5656_good_sub_command(_CommonCase):  # classically case 1.3

    def test_010_invokes(self):
        self.invokes()

    def test_020_user_thing_writes(self):
        _exp = "hello from 'ohai-mami foo-bar'. args: ['foobie-1', 'foob-2']\n"
        _act = self.first_line
        self.assertEqual(_act, _exp)

    def test_results_in_user_exitstatus(self):
        self.invocation_results_in_this_exitstatus(4321)

    @property
    @shared_subject
    def end_state(self):
        return self.invoke_expecting(line_count=1, which='STDOUT')

    def given_argv_tail(self):
        return ('foo-bar', 'foobie-1', 'foob-2')


if __name__ == '__main__':
    unittest.main()

# #history-A.1
# #born.
