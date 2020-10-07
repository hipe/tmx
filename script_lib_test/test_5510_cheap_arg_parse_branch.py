from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_child_classes, \
        dangerous_memoize as shared_subject
import unittest


class CommonCase(unittest.TestCase):

    def __init__(self, *a):
        self._is_first_debug = True
        super().__init__(*a)

    # -- assertions

    def expect_first_line_ignorecase(self, exp):
        self.expect_ignorecase(self.first_line, exp)

    def expect_ignorecase(self, act, rxs):
        import re
        self.assertRegex(act, re.compile(rxs, re.IGNORECASE))

    def expect_exitstatus_for_failure(self):
        es = self.end_state.exitstatus
        self.assertIsInstance(es, int)
        self.assertNotEqual(es, 0)

    def expect_exitstatus_for_success(self):
        self.expect_this_exitstatus(0)

    def expect_this_exitstatus(self, exp_es):
        es = self.end_state.exitstatus
        self.assertEqual(es, exp_es)

    def section(self, label_content):
        return self.help_screen.section_via_key(label_content)

    def invites_shallowly(self):
        exp = '\\b(?:see|use) [\'"]mu-mi -(?:h|-help)[\'"]'
        self.expect_ignorecase(self.last_line, exp)

    @property
    def first_line(self):
        return self.line_at_offset(0)

    @property
    def last_line(self):
        return self.line_at_offset(-1)

    def line_at_offset(self, offset):
        which = self.which_std
        if 'stderr' == which:
            attr = 'stderr_lines'
        else:
            assert 'stdout' == which
            attr = 'stdout_lines'
        return getattr(self.end_state, attr)[offset]

    # -- building end state

    @property
    @shared_subj_in_child_classes
    def help_screen(self):
        lines = self.end_state.stderr_lines
        from script_lib.test_support.expect_help_screen \
            import parse_help_screen as func
        return func(lines)

    @property
    @shared_subj_in_child_classes
    def end_state(self):
        argv = ('/fake-fs/frik/frak/mu-mi', *self.given_argv_tail())
        _cx = self.given_CLI_functions()

        if 'stderr' == self.which_std:
            stdout_is_expected = False
            stderr_is_expected = True
        else:
            assert('stdout' == self.which_std)
            stdout_is_expected = True
            stderr_is_expected = False

        stdout_lineser, spy_sout = self.build_IO_spy(
                stdout_is_expected, 'DEBUG STDOUT: ')

        stderr_lineser, spy_serr = self.build_IO_spy(
                stderr_is_expected, 'DEBUG STDERR: ')

        _mod = subject_module()
        es = _mod.cheap_arg_parse_branch(None, spy_sout, spy_serr, argv, _cx)
        return EndState(es, stdout_lineser(), stderr_lineser())

    def build_IO_spy(self, yes_no, msg):
        if yes_no:
            return self.build_IO_recorder(msg)
        return lambda: None, None

    def build_IO_recorder(self, dbg_msg_head):
        from script_lib.test_support.expect_STDs import \
            spy_on_write_and_lines_for as func
        spy_IO, lines = func(self, dbg_msg_head)
        return lambda: tuple(lines), spy_IO

    def given_CLI_functions(self):
        yield ('foo-bar', lambda: the_CLI_function_called_foo_bar)
        yield ('biff-baz', lambda: the_CLI_function_called_biff_baz)

    do_debug = False
    which_std = 'stderr'


class Case5498_no_args_says_expecting_sub_command(CommonCase):

    def test_010_expect_fails(self):
        self.expect_exitstatus_for_failure()

    def test_020_first_line_complains(self):
        exp = r'\bexpecting <(?:sub-)?command>'
        self.expect_ignorecase(self.first_line, exp)

    def test_030_last_line_invites(self):
        self.invites_shallowly()

    def given_argv_tail(self):
        return ()


class Case5501_strange_arg_might_splay(CommonCase):

    def test_010_expect_fails(self):
        self.expect_exitstatus_for_failure()

    def test_020_expresses_reasons(self):
        exp = "Unrecognized (?:sub-)?command ['\"]strange-commando['\"]"
        self.expect_first_line_ignorecase(exp)

    # splay gone at #history-B.2

    def given_argv_tail(self):
        return ('strange-commando',)


class Case5504_strange_opt_complains_from_the_root(CommonCase):

    def test_010_expect_fails(self):
        self.expect_exitstatus_for_failure()

    def test_020_first_line_expresses_reason(self):
        self.expect_first_line_ignorecase("unrecognized option: '-x'")

    def test_030_last_line_invites(self):
        self.invites_shallowly()

    def given_argv_tail(self):
        return ('-x',)


class Case5507_requesting_help_shows_special_branch_screen_CRAZY(CommonCase):
    # (this is a nice, pretty general splay-out of the main datapoints
    # we want all branchy help screens to have.)

    def test_010_expect_succeeds(self):
        self.expect_exitstatus_for_success()

    def test_020_the_first_usage_line_looks_different(self):
        self.assertEqual(self.first_line, _first_line_of_help_screen)

    # #history-B.2 no more asserting a description section (placeholder anyway)

    def test_040_theres_just_the_usual_help_option(self):
        exp = '^[ ]*-h,?[ ]+--help[ ]{2,}(?:show )?this screen\\b'
        act = self.section('options').lines[1]
        self.expect_ignorecase(act, exp)

    def test_050_all_the_subcommands_are_listed(self):
        one, two = (row[0] for row in self.this_table)
        self.assertEqual(one, 'foo-bar')
        self.assertEqual(two, 'biff-baz')

    def test_060_the_subcommand_with_a_description_shows_the_description(self):
        exp = "I'm this kid out here foo bar"
        act = self.this_table[0][1]
        self.assertEqual(act, exp)

    def test_070_the_subcommand_with_no_desc_gets_placeholder(self):
        exp = "(the 'biff-baz' command)"  # #here1. simplified at #history-B.2
        act = self.this_table[1][1]
        self.assertEqual(act, exp)

    @shared_subject
    def this_table(self):
        def split(line):
            here = line.rindex('  ')
            return line[0:here].strip(), line[here+2:-1]  # _eol
        sect = self.section('commands')
        return tuple(split(line) for line in sect.to_body_lines())

    def given_argv_tail(self):
        return ('-h',)


class Case5510_we_can_reach_a_subcommand_that_takes_no_args(CommonCase):  # noqa: E501 #midpoint

    def test_010_expect_succeeds(self):
        self.expect_this_exitstatus(987)

    def given_argv_tail(self):
        return ('foo-bar',)

    which_std = 'stdout'


class Case5513_passing_strange_option_to_child_command_gets_thru(CommonCase):

    def test_010_expect_succeeds(self):
        self.expect_exitstatus_for_failure()

    def given_argv_tail(self):
        return ('foo-bar', '-x')


class Case5516_passing_option_intended_for_child_reaches_child(CommonCase):

    def test_010_expect_succeeds(self):
        self.expect_this_exitstatus(876)

    def given_argv_tail(self):
        return ('biff-baz', '-x')

    which_std = 'stdout'


class Case5519_help_of_child_works(CommonCase):

    def test_010_expect_succeeds(self):
        self.expect_exitstatus_for_success()

    def given_argv_tail(self):
        return ('biff-baz', '-h')


class Case5522_you_cant_do_help_of_child_this_way(CommonCase):

    def test_020_it_shows_the_shallower_help_screen(self):
        self.assertEqual(self.first_line, _first_line_of_help_screen)

    def build_end_state(self):  # EXPERIMENT

        # Build a write spy like we normally do but stop at one line
        def receivers_and_state():
            yield lib.build_write_receiver_for_debugging('DBG: ', lambda: self.do_debug)  # noqa: E501
            recv, lines = lib.build_write_receiver_for_recording_and_lines()
            yield recv
            recv, stop = lib.build_write_receiver_for_stopping(1)
            yield recv
            yield stop, lines
        import script_lib.test_support.expect_STDs as lib
        stop, lines = (recvs := list(receivers_and_state())).pop()
        serr = lib.spy_on_write_via_receivers(recvs)

        argv = '/fake-fs/frik/frak/mu-mi', *self.given_argv_tail()
        cx = self.given_CLI_functions()
        mod = subject_module()
        try:
            mod.cheap_arg_parse_branch(None, None, serr, argv, cx)
            raise RuntimeError('no see')
        except stop:
            pass
        return EndState(None, None, tuple(lines))

    def given_argv_tail(self):
        return ('-h', 'biff-baz')

    which_std = 'stderr'


def the_CLI_function_called_biff_baz(sin, sout, serr, argv, enver):
    # no description per #here1

    formals = (
        ('-x', '--xx-yy', 'yes we take this option'),
        ('-h', '--help', 'no see'))

    def do_CLI(sin, sout, serr, yes_x, _rscr):
        """i'm just a kid, named Biff Baz"""

        sout.write(f"you said {'YES' if yes_x else 'NO'}\n")
        return 876

    func = subject_function_terminal_form()
    return func(do_CLI, sin, sout, serr, argv, formals)


def the_CLI_function_called_foo_bar(sin, sout, serr, argv, enver):
    "I'm this kid out here foo bar"

    def do_CLI(sin, sout, serr, _rscr):
        """i am the function called 'foo-bar' (no see since #history-B.2)"""

        sout.write("hello i am foo bar.\n")
        return 987

    func = subject_function_terminal_form()
    return func(do_CLI, sin, sout, serr, argv, ())


class EndState:
    def __init__(self, es, sout_lines, serr_lines):
        self.stdout_lines = sout_lines
        self.stderr_lines = serr_lines
        self.exitstatus = es


def subject_function_terminal_form():
    return subject_module().cheap_arg_parse


def subject_module():
    from script_lib import cheap_arg_parse as module
    return module


_first_line_of_help_screen = "usage: mu-mi [-h] <command> [..]\n"  # _eol


if __name__ == '__main__':
    unittest.main()

# #history-B.2
# #born.
