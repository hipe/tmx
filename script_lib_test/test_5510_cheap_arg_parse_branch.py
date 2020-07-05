from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        dangerous_memoize_in_child_classes)
import unittest


class CommonCase(unittest.TestCase):

    def __init__(self, *a):
        self._is_first_debug = True
        super().__init__(*a)

    # -- assertions

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
        return self.help_screen_section_index[label_content]

    def invites_shallowly(self):
        self.assertEqual(self.second_line_content, "see 'mu-mi --help'")

    @property
    def first_line_content(self):
        return self.line_at_offset_content(0)

    @property
    def second_line_content(self):
        return self.line_at_offset_content(1)

    def line_at_offset_content(self, offset):
        _i = ('stderr', 'stdout').index(self.which_std)
        _attr = ('stderr_lines', 'stdout_lines')[_i]
        _lines = getattr(self.end_state, _attr)
        return _lines[offset][0:-1]  # _eol

    # -- building end state

    @property
    @dangerous_memoize_in_child_classes('_HSSI', '_build_help_screen_sect_idx')
    def help_screen_section_index(self):
        pass

    def _build_help_screen_sect_idx(self):
        from script_lib.test_support.expect_help_screen import (
                section_index_via_unsanitized_strings_)
        _lines = self.end_state.stderr_lines
        return section_index_via_unsanitized_strings_(_lines)

    @property
    @dangerous_memoize_in_child_classes('_ES', 'build_end_state')
    def end_state(self):
        pass

    def build_end_state(self):
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
        from script_lib.test_support import lines_and_spy_io_for_test_context
        lines, spy_IO = lines_and_spy_io_for_test_context(self, dbg_msg_head)
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
        self.assertEqual(self.first_line_content,
                         'parameter error: expecting <sub-command>')

    def test_030_second_line_invites(self):
        self.invites_shallowly()

    def given_argv_tail(self):
        return ()


class Case5501_strange_arg_might_splay(CommonCase):

    def test_010_expect_fails(self):
        self.expect_exitstatus_for_failure()

    def test_020_expresses_reasons(self):
        self.assertEqual(self.head_and_tail[0],
                         "no sub-command for 'strange-commando'")

    def test_030_express_splay(self):
        self.assertEqual(self.head_and_tail[1],
                         "(there's 'foo-bar' and 'biff-baz')")

    @property
    @shared_subject
    def head_and_tail(self):
        return tuple(self.first_line_content.split('. '))

    def given_argv_tail(self):
        return ('strange-commando',)


class Case5504_strange_opt_complains_from_the_root(CommonCase):

    def test_010_expect_fails(self):
        self.expect_exitstatus_for_failure()

    def test_020_first_line_expresses_reason(self):
        self.assertIn("unrecognized option: '-x'", self.first_line_content)

    def test_030_second_line_invites(self):
        self.invites_shallowly()

    def given_argv_tail(self):
        return ('-x',)


class Case5507_requesting_help_shows_special_branch_screen_CRAZY(CommonCase):
    # (this is a nice, pretty general splay-out of the main datapoints
    # we want all branchy help screens to have.)

    def test_010_expect_succeeds(self):
        self.expect_exitstatus_for_success()

    def test_020_the_first_usage_line_looks_different(self):
        self.assertEqual(self.first_line_content, _first_line_of_help_screen)

    def test_030_the_description_IS_A_PLACEHOLDER(self):
        _exp = 'description: «these are the sub-commands»'
        _node = self.section('description')
        self.assertEqual(_node.styled_content_string, _exp)

    def test_040_theres_just_the_usual_help_option(self):
        _exp = '-h, --help  show this screen'
        _node = self.section('option')
        self.assertEqual(_node.children[0].styled_content_string, _exp)

    def test_050_all_the_subcommands_are_listed(self):
        one, two = (row[0] for row in self.this_table)
        self.assertEqual(one, 'foo-bar')
        self.assertEqual(two, 'biff-baz')

    def test_060_the_subcommand_with_a_description_shows_the_description(self):
        _exp = " i am the function called 'foo-bar'"  # #todo note leading spa
        _act = self.this_table[0][1]
        self.assertEqual(_act, _exp)

    def test_070_the_subcommand_with_no_desc_but_yes_arguments_uses_that(self):
        _exp = '[-x]'
        _act = self.this_table[1][1]
        self.assertEqual(_act, _exp)

    @property
    @shared_subject
    def this_table(self):
        def f(line):
            return re.match(r'([^ ]+)[ ]{2}(.+)', line).groups()
        import re
        branch = self.section('sub-commands')
        return tuple(f(ch.styled_content_string) for ch in branch.children)

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
        self.assertEqual(self.first_line_content, _first_line_of_help_screen)

    def build_end_state(self):  # EXPERIMENT
        lines = []
        # ==

        class StderrSpy:
            def __init__(self):
                self._count = 0

            def write(self, s):
                self._count += 1
                lines.append(s)
                if 1 == self._count:  # magic constant
                    raise Yuck()
                return len(s)

        class Yuck(Exception):
            pass
        # ==
        argv = ('/fake-fs/frik/frak/mu-mi', *self.given_argv_tail())
        _cx = self.given_CLI_functions()
        _mod = subject_module()
        try:
            _mod.cheap_arg_parse_branch(None, None, StderrSpy(), argv, _cx)
            raise Exception('no see')
        except Yuck:
            pass
        return EndState(None, None, tuple(lines))

    def given_argv_tail(self):
        return ('-h', 'biff-baz')

    which_std = 'stderr'


def the_CLI_function_called_biff_baz(sin, sout, serr, argv):
    from script_lib.cheap_arg_parse import cheap_arg_parse

    _formals = (('-x', '--xx-yy', 'yes we take this option'),)

    def do_CLI(mon, sin, sout, serr, yes_x):
        sout.write(f"you said {'YES' if yes_x else 'NO'}\n")
        return 876

    return cheap_arg_parse(do_CLI, sin, sout, serr, argv, _formals)


def the_CLI_function_called_foo_bar(sin, sout, serr, argv):
    from script_lib.cheap_arg_parse import cheap_arg_parse

    def do_CLI(mon, sin, sout, serr):
        """i am the function called 'foo-bar'"""

        sout.write("hello i am foo bar.\n")
        return 987

    return cheap_arg_parse(do_CLI, sin, sout, serr, argv, ())


class EndState:
    def __init__(self, es, sout_lines, serr_lines):
        self.stdout_lines = sout_lines
        self.stderr_lines = serr_lines
        self.exitstatus = es


def subject_module():
    from script_lib import cheap_arg_parse_branch
    return cheap_arg_parse_branch


_first_line_of_help_screen = "usage: mu-mi <sub-command> .."


if __name__ == '__main__':
    unittest.main()

# #born.
