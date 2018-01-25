"""cover the "magnetic" module that isomorphs with the name of this test file.

the scope of this test file is currently broad: cover all the things
involved in CLI-specific parsing of a request. this means options,
positional arguments, (what is known in platform as) sub-parsers, and
whatever else.

here's a rough skeleton we typically use to permute the core cases we
need to test. each test case has a name composed of two integers (as
"integer dot integer"). the first integer represents how many actual
elements will be in the ARGV of the test case (sort of (see #here1)).

  - case 0: zero arguments when one (or more) is expected.

  - case 1.1: the first argument is not recognized (think sub-parser)
  - case 1.2: the first term (an option-looking argument) is not recognized.
  - case 1.3: one sub-parser argument that *is* recognized.
  - case 1.4: one option-looking argument that *is* recognized.

for those cases that have them in their name, the second integer is a sort
of arbitary identifier; but as a mnemonic: the order of the cases is
vaguely based on the idea of what cases are most likely to occur by pure
chance - i.e, almost literally a monkey typing random keys on a keyboard:

typing a random word that starts with a dash ("-") is less likely to happen
to happen than not; and randomly typing a correct option or positional
argument is generally to happen than not (and in turn, probably less likely
than typing a word that ramdomly starts with a dash. (by the way: option
tokens start with dashes.)

we follow [#006.regression-order] in naming the test cases and test methods
"""

import os, sys, unittest

# boilerplate
_ = os.path
path = _.dirname(_.dirname(_.dirname(_.abspath(__file__))))
a = sys.path
if a[0] != path:
    a.insert(0, path)
# end boilerplate


from game_server_test.generic_CLI_helper import(
  CLI_CaseMethods,
  the_empty_ARGV,
  ARGV,
  PROGRAM_NAME,
  NEWLINE,
)


import game_server_test.helper as helper

shared_subject = helper.shared_subject
memoize = helper.memoize


class _CommonCase(CLI_CaseMethods, unittest.TestCase):

    # -- assertion

    def one_line_says_usage_(self):
        """insulate main body of test code from having to know ..

        that currently the usage line WEIRDLY shows up before the main line
        """
        self._this_line_says_usage('first_line')

    def _this_line_says_usage(self, attr):
        _actual_line = getattr(self.magnetic_call_, attr)
        self.assertEqual(_foo_bar_usage_line(), _actual_line)

    # -- setup hook-outs common to all/most cases in this file

    def command_stream_(self):
        return self.stream_with_two_commands_()

    # -- setup support

    def _invocation_when_two_stderr_lines_expected(self):
        return self.invocation_when_expected_(2, STDERR)


class Case0_no_args(_CommonCase):

    def test_010_subject_module_loads(self):
        self.assertIsNotNone(self.main_magnetic_())

    def test_020_magnetic_call_happens(self):
        self.magnetic_call_happens_()

    def test_050_second_line_says_usage(self):
        self._this_line_says_usage('second_line');

    def test_060_first_line_says_this(self):
        _actual_line = self.magnetic_call_.first_line
        self.assertEqual(_actual_line, 'expecting sub-command.'+NEWLINE)

    @property
    @shared_subject
    def magnetic_call_(self):
        return self._invocation_when_two_stderr_lines_expected()

    def ARGV_(self):
        return the_empty_ARGV()


class Case1_1_strange_subparser_name(_CommonCase):

    def test_020_magnetic_call_happens(self):
        self.magnetic_call_happens_()

    def test_030_magnetic_call_results_in_failure(self):
        self.magnetic_call_results_in_failure_()

    def test_040_magnetic_call_has_particular_exitstatus(self):
        self.magnetic_call_has_exitstatus_of_common_error_()

    def test_050_one_line_says_usage(self):
        self.one_line_says_usage_();

    def test_060_main_line_says_this(self):
        self.main_line_says_this_(
          "invalid choice: 'fhqwhgads' (choose from 'foo-bar', 'biff-baz')")

    @property
    @shared_subject
    def magnetic_call_(self):
        return self._invocation_when_two_stderr_lines_expected()

    @ARGV
    def ARGV_(self):
        return [ 'fhqwhgads' ]


class Case1_2_strange_option(_CommonCase):

    def test_020_magnetic_call_happens(self):
        self.magnetic_call_happens_()

    def test_030_magnetic_call_results_in_failure(self):
        self.magnetic_call_results_in_failure_()

    def test_040_magnetic_call_has_particular_exitstatus(self):
        self.magnetic_call_has_exitstatus_of_common_error_()

    def test_050_one_line_says_usage(self):
        self.one_line_says_usage_()

    def test_060_main_line_says_this(self):
        self.main_line_says_this_('unrecognized arguments: -x --another --etc')

    @property
    @shared_subject
    def magnetic_call_(self):
        return self._invocation_when_two_stderr_lines_expected()

    @ARGV
    def ARGV_(self):
        return [ '-x', '--another', '--etc' ]


class Case1_3_good_sub_command(_CommonCase):

    def test_020_magnetic_call_happens(self):
        self.magnetic_call_happens_()

    def test_050_has_command(self):
        self.assertIsNotNone(self.magnetic_call_.WIP_COMMAND)

    def test_050_has_namespace(self):
        self.assertIsNotNone(self.magnetic_call_.WIP_NAMESPACE)

    @property
    @shared_subject
    def magnetic_call_(self):
        return self.result_when_expecting_no_output_or_errput_()

    @ARGV
    def ARGV_(self):
        return [ 'foo-bar' ]

@memoize
def _foo_bar_usage_line():
  return 'usage: %s [-h] {foo-bar,biff-baz} ...%s' % (PROGRAM_NAME, NEWLINE)


STDERR = 'STDERR'


if __name__ == '__main__':
    unittest.main()

# #born.
