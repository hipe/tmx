"""
At #history-A.1 we sunsetted the legacy CLI but we're keeping this "canon"
that tested it for now.

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

from script_lib.test_support.CLI_canon import \
        THESE_TWO_CHILDREN_CLI_METHODS, CLI_Canon_Assertion_Methods
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_children
import unittest
import re


class CommonCase(CLI_Canon_Assertion_Methods, unittest.TestCase):

    # -- assertion

    def last_line_invites_to(self, program_name):
        # (at #history-A.1 we lost the gross behavior)
        # (at #history-B.2 we regained it, and we think it's beautiful)
        def pcs():
            yield '(?:see|use)[ ][\'"]', re.escape(program_name)
            yield '[ ]-(h|-help)',
        rxs = ''.join(s for row in pcs() for s in row)
        rx = re.compile(rxs, re.IGNORECASE)
        self.assertRegex(self.last_line, rx)

    # -- setup hook-outs common to all/most cases in this file

    def given_children_CLI_functions(self):
        return THESE_TWO_CHILDREN_CLI_METHODS()

    long_program_name = '/fake-fs/foo/bar/ohai-mami'

    # -- setup support

    @property  # away one day
    @shared_subj_in_children
    def end_state(self):
        return self.build_end_state_using_line_expectations()

    do_debug = False


class Case5643_no_args(CommonCase):  # classically case 0

    def test_020_fails(self):
        self.invocation_fails()

    def test_030_invocation_results_in_this_exitstatus(self):
        self.invocation_results_in_this_exitstatus(6)

    def test_050_first_line_says_expecting_sub_command(self):
        rx = re.compile(r'\bexpecting <?(?:sub-)?command', re.IGNORECASE)
        self.assertRegex(self.first_line, rx)

    def test_060_an_invitation_happened(self):
        rx = re.compile(r'\bfor help\b', re.IGNORECASE)
        self.assertRegex(self.last_line, rx)

    def expected_lines(_):
        yield 'STDERR'
        yield 'zero_or_one', 'STDERR'

    def given_argv_tail(self):
        return ()


class Case5647_strange_subparser_name(CommonCase):  # classically case 1.1

    def test_020_invokes(self):
        self.invokes()

    def test_030_invocation_results_in_failure(self):
        self.invocation_fails()

    def test_040_invocation_has_particular_exitstatus(self):
        self.invocation_results_in_this_exitstatus(9)

    def test_060_main_line_says_this(self):
        rxs = 'Unrecognized (?:sub-)?command [\'"]fhqwhgads'
        # (splay gone at #history-B.2. invite to help (splays) is sufficient)
        self.assertRegex(self.first_line, re.compile(rxs, re.IGNORECASE))

    def test_070_second_line_says_invite(self):
        self.last_line_invites_to('ohai-mami')

    def expected_lines(_):
        yield 'STDERR'
        yield 'zero_or_one', 'STDERR'

    def given_argv_tail(self):
        return ('fhqwhgads',)


# Case5650  # #midpoint


class Case5653_strange_option(CommonCase):  # classically case 1.2

    def test_020_invokes(self):
        self.invokes()

    def test_030_invocation_results_in_failure(self):
        self.invocation_fails()

    def test_040_invocation_has_particular_exitstatus(self):
        self.invocation_results_in_this_exitstatus(17)

    def test_060_main_line_says_this(self):
        rx = re.compile('Unrecognized option: [\'"]?-x[\'"]?', re.IGNORECASE)
        self.assertRegex(self.first_line, rx)

    def test_070_second_line_says_invite(self):
        self.last_line_invites_to('ohai-mami')

    def expected_lines(_):
        yield 'STDERR'
        yield 'zero_or_one', 'STDERR'

    def given_argv_tail(self):
        return ('-x', '--another', '--etc')


class Case5656_good_sub_command(CommonCase):  # classically case 1.3

    def test_010_invokes(self):
        self.invokes()

    def test_020_user_thing_writes(self):
        _exp = "hello from 'ohai-mami foo-bar'. args: ['foobie-1', 'foob-2']\n"
        _act = self.first_line
        self.assertEqual(_act, _exp)

    def test_results_in_user_exitstatus(self):
        self.invocation_results_in_this_exitstatus(4321)

    def expected_lines(_):
        yield 'STDOUT'

    def given_argv_tail(self):
        return ('foo-bar', 'foobie-1', 'foob-2')


if __name__ == '__main__':
    unittest.main()


"""
Here's an imaginary guide to error codes, constructed similarly to canon cases

`4` is a bad luck number in China, so we use it as the startingpoint for our
magically meaningful error codes. For no particular reason but this, we leave
`1`, `2` and `3` alone. Furthermore we don't expect to have occasion to emit
`4`'s either because the underlying premise is that every error is of a
specific kind.

We progress forward with error codes as if to ask what we are most likely
to encounter first with "random typing" (or narratively similar). So: What we
think is most likely to happen is you leave the input buffer blank when
there's at least one required positional:

As it works out, there are *three* kinds requireds you can miss:
- Regular positional missing, `5`
- Required plural positional missing, `6`
- Required "optional" missing, `7` (Case5495)

(`7` is a good luck number in the west, and the idea of a required optional
is pretty absurd on its face; so make of that what you will.)

On the other end of this is when there's an extra positional argument, `8`.

Then what we expect is most likely is a positional argument with an
unrecognized value (in whatever sense; say, for a child command). So we use
`9` for that, and `10` for the related case of fuzzy matching resulting in
ambiguity.

Then what we expect is most likely to happen is an unrecognized option.
At writing we have 10 ways you can fail with options (unrec long, long
doesn't take argument, equals with no content after it, long missing arg,
long arg looks like option, ball of options issue, unrec short, short
missing arg, short arg looks like option, missing required "option".)
So that's 11 thru 20, inclusive.
"""

# #history-B.2
# #history-A.1
# #born.
