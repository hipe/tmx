from modality_agnostic.test_support.common import memoize_into
import unittest


class CommonCase(unittest.TestCase):

    def expect_in_first_stderr_line(self, needle):
        assert needle in self.first_stderr_line

    def expect_in_first_stderr_line_regex(self, rxs):
        import re
        assert re.search(rxs, self.first_stderr_line)

    def expect_parse_tree_keys(self, *keys):
        act = tuple(self.end_state['parse_tree_values'].keys())
        self.assertSequenceEqual(act, keys)

    def expect_no_remaining_ARGV(self):
        argv_stack = self.end_state_argv_stack
        assert 0 == len(argv_stack)

    def expect_remaining_ARGV_head(self, token):
        argv_stack = self.end_state_argv_stack
        assert token == argv_stack[-1]

    @property
    def first_stderr_line(self):
        return self.end_state_stderr_lines[0]

    @property
    def end_state_stderr_lines(self):
        return self.end_state['stderr_lines']

    @property
    def end_state_argv_stack(self):
        return self.end_state['remaining_ARGV_stack']

    @property
    @memoize_into('_end_state')
    def end_state(self):
        return {k: v for k, v in self.build_end_state()}

    def build_end_state(self):
        seqs, lines = self.build_sequence_sexps()
        argv = ('wahoo', * self.given_argv)

        sin = interactive_terminal if self.is_interactive else noninteractive_terminal

        from script_lib.test_support.expect_STDs import \
                spy_on_write_and_lines_for as spy

        serr, serr_lines = spy(self, 'STDERR: ')
        docstring_for_help_description = "desc line 1\n\ndesc line 3\n     "

        invo = subject_module()._build_invocation(
            sin, serr, argv, seqs, lines, docstring_for_help_description)

        rc, pt = invo.returncode_or_parse_tree()
        if rc is None:
            assert not serr_lines
            yield 'parse_tree_values', pt.values
            # ..
        else:
            assert pt is None
            yield 'returncode', rc
            if serr_lines:
                yield 'stderr_lines', tuple(serr_lines)
        yield 'remaining_ARGV_stack', tuple(invo.argv_stack)

    def build_sequence_sexps(self):
        lines = tuple(self.given_usage_lines())
        func = subject_module()._sequence_via_usage_line
        return tuple(func(s) for s in lines), lines

    is_interactive = True
    do_debug = False


class Case6038_nonpositional_with_must_be_dash_constraint(CommonCase):

    def test_010_when_not_dash(self):
        self.is_interactive = False
        self.given_argv = '-file', 'some-file'
        self.expect_in_first_stderr_line("expecting '-'")
        self.expect_remaining_ARGV_head("some-file")

    def test_020_when_dash(self):
        self.is_interactive = False
        self.given_argv = '-file', 'some-file'
        self.given_argv = '-file', '-'
        dct = self.end_state['parse_tree_values']
        # this one DOES store the value
        assert '-' == dct['file']

    def test_030_when_interactive(self):
        self.is_interactive = True
        self.given_argv = '-file', 'some-file'
        self.expect_in_first_stderr_line("can't be interactive")

    def given_usage_lines(_):
        yield "usage: <some-ting> | {{prog_name}} [-file -]\n"


"""At #history-C.1 we deleted these cases from the client file
and the now gone OPEN_UPSTREAM/RESOLVE_UPSTREAM

If you run in to trouble or want better coverage, create cases that cover
the below expressions and and take them off the below list.

  - Missing required argument after '-file'
  - "With '-file -', expecting STDIN but term is interactive"
        - (alt:) whine(f'when {arg_moniker} is "-", STDIN must be pipe')
  - "'-file' primary must occur alone. Unexpected: "
  - "Can't use STDIN *and* ARGV. Unexpected: "
  - "Can't use STDIN *and* '-file PATH'. Use one or the other.\n"
        - (alt:) whine(f'when piping from STDIN, {arg_moniker} must be "-"')
"""


class Case6042_introduce_match_any(CommonCase):

    def test_010_against_more_specific_input(self):
        self.given_argv = '-file', 'zing'
        self.expect_parse_tree_keys('the_file')
        self.expect_no_remaining_ARGV()

    def test_020_against_any_other_input(self):
        self.given_argv = '-filezz', 'wazoo', 'kazoo'
        self.expect_parse_tree_keys()
        self.expect_remaining_ARGV_head('-filezz')

    def test_030_against_no_input(self):
        self.given_argv = ()
        self.expect_in_first_stderr_line_regex(r'-file\b')
        self.expect_in_first_stderr_line('[any thing..]')

    def test_040_but_what_if_partial_match(self):
        self.given_argv = ('-file',)
        self.expect_in_first_stderr_line('xpecting THE_FILE')

    def test_050_oh_dont_forget_help(self):
        self.given_argv = ('-help',)
        lines = self.end_state_stderr_lines
        assert 'usage: wahoo [any thing..]\n' == lines[0]
        assert '-file THE_FILE' in lines[1]
        assert "desc line 3\n" == lines[-1]
        assert 0 == self.end_state['returncode']

    def given_usage_lines(_):
        yield "usage: {{prog_name}} [any thing..]\n"
        yield "usage: {{prog_name}} -file THE_FILE\n"


class noninteractive_terminal:  # #class-as-namespace
    def isatty():
        return False


class interactive_terminal:  # #class-as-namespace
    def isatty():
        return True


def subject_module():
    import script_lib.via_usage_line as mod
    return mod


if '__main__' ==  __name__:
    unittest.main()

# #history-C.1
# #born
