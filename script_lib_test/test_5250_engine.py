# See [#608.18] for an in-depth explanation of what is covered here.
# (at #history-C.1 we moved a really long comment from here to there.)

from script_lib_test import engine_support
import unittest


class CommonCase(engine_support.CommonCase, unittest.TestCase):

    def expect_value_sequence(self, these):
        pt = self.expect_success()
        act = pt.values.get(self.parse_tree_focus_value)
        if these is None:
            assert act is None
            return
        self.assertSequenceEqual(act, these)


class Case5230_empty_grammar_against_no_tokens(CommonCase):

    def test_010_ohai(self):
        self.expect_success()

    argv_tail = ()


class Case5234_empty_grammar_against_one_non_option_looking_token(CommonCase):

    def test_010_ohai(self):
        self.expect_early_stop('unexpected_extra_argument')

    argv_tail = ('foo',)


class Case5238_empty_grammar_against_one_option_looking_token(CommonCase):

    def test_010_ohai(self):
        self.expect_early_stop('unrecognized_option')

    argv_tail = ('--strange',)


class Case5242_strange_short(CommonCase):

    def test_010_ohai(self):
        self.expect_early_stop('unrecognized_short')

    argv_tail = ('-xfoobie',)


class Case5246_long_help(CommonCase):

    def test_010_ohai(self):
        self.expect_early_stop('display_help')

    argv_tail = ('--help',)


class Case5250_short_help(CommonCase):

    def test_010_ohai(self):
        self.expect_early_stop('display_help')

    argv_tail = ('-h',)


class Case5254_impatient(CommonCase):

    def test_010_fail_to_get_first_subcommand(self):
        self.argv_tail = 'aa', 'bb', 'cc'
        self.expect_early_stop('expecting_subcommand', 'wing')

    def test_020_fail_to_get_second_subcommand(self):
        self.argv_tail = 'wing', 'bb', 'cc'
        self.expect_early_stop('expecting_subcommand', 'chun')

    def test_030_fail_to_get_required_positional(self):
        self.argv_tail = 'wing', 'chun'
        self.expect_early_stop('expecting_required_positional', 'ARG1')

    def test_040_too_many_actual_positionals(self):
        self.argv_tail = 'wing', 'chun', 'arg1_x', 'arg2_y', 'arg3_z', 'arg4_no'
        self.expect_early_stop('unexpected_extra_argument')

    def test_050_big_ball_candy_crush(self):
        self.argv_tail = 'wing', 'chun', '--verbo', 'a1', '-vfzig.txt', 'a2'
        pt = self.expect_success()
        self.assertSequenceEqual(('wing', 'chun'), pt.subcommands)
        dct = pt.values
        val = dct.pop
        assert val('arg1') == 'a1'
        assert val('arg2') == 'a2'
        assert val('verbose') is True
        assert val('file') == 'zig.txt'
        assert not dct

    def test_060_but_ruin_it_at_end(self):
        self.argv_tail = 'wing', 'chun', '--verbo', 'a1', '-vfz.txt', 'a2', '-x'
        self.expect_early_stop('unrecognized_short')

    nonpositionals = '--verbose', '--file=FILE'
    positionals = 'ARG1', '[ARG2]', '[ARG3]'
    subcommands = ('subcommand', 'wing'), ('subcommand', 'chun')
    terminal_is_interactive = False
    formal_is_for_interactive = False


class Case5258_introduce_subcommands(CommonCase):

    def test_010_tell_me_expecting(self):
        self.argv_tail = ()
        self.expect_early_stop('expecting_required_positional', '"zingbar"')

    def test_020_tell_me_wrong(self):
        self.argv_tail = ('zongbar',)
        self.expect_early_stop('expecting_subcommand', 'zingbar')

    def test_030_tell_me_expecting_second_MULTIPLE(self):
        self.argv_tail = ('zingbar',)
        self.expect_early_stop('expecting_required_positional', ('"tazo"', '"wazo"'))

    def test_040_tell_me_wrong_second_MULTIPLE(self):
        self.argv_tail = ('zingbar', 'fizo')
        self.expect_early_stop('expecting_subcommand', ('tazo', 'wazo'))

    def test_050_tell_me_RIGHT(self):
        self.argv_tail = ('zingbar', 'tazo')
        pt = self.expect_success()
        self.assertSequenceEqual(('zingbar', 'tazo'), pt.subcommands)

    def build_first_sequence(self):  # (up here for historic reasons only)
        return build_sequence(
            for_interactive=True,
            subcommands=(('subcommand','zingbar'), ('subcommand', 'tazo')),
            nonpositionals=None,
            positionals=None)

    def build_second_sequence(self):
        return build_sequence(
            for_interactive=True,
            subcommands=(('subcommand', 'zingbar'), ('subcommand','wazo')),
            nonpositionals=None,
            positionals=None)


class Case5262_introduce_interactive_vs_not(CommonCase):

    def test_010_term_is_interactive_and_argv_is_nothing(self):
        self.terminal_is_interactive = True
        self.argv_tail = ()
        self.expect_success()

    def test_020_term_is_noninteractive_and_argv_is_nothing(self):
        self.terminal_is_interactive = False
        self.argv_tail = ()
        self.expect_success()

    def test_030_term_is_interactive_and_file_is_dash(self):
        self.terminal_is_interactive = True
        self.argv_tail = '-file', '-'
        self.expect_early_stop('cannot_be_dash')

    def test_040_term_is_interactive_and_file_is_not_dash(self):
        self.terminal_is_interactive = True
        self.argv_tail = '-file', 'foo.txt'
        self.expect_success()

    def test_050_term_is_noninteractive_and_file_is_dash(self):
        self.terminal_is_interactive = False
        self.argv_tail = '-file', '-'
        self.expect_success()

    def test_060_term_is_noniteractive_and_file_is_not_dash(self):
        self.terminal_is_interactive = False
        self.argv_tail = '-file', 'foo.txt'
        self.expect_early_stop('must_be_dash_FOR_EXAMPLE')

    def build_first_sequence(self):  # (up here for historic reasons only)
        return build_sequence(
            for_interactive=True,
            nonpositionals=('-file FILE',))

    def build_second_sequence(self):
        return build_sequence(
            for_interactive=False,
            nonpositionals=('-file -',))


class Case5266_introduce_optional_glob(CommonCase):

    def test_005_none(self):
        self.argv_tail = ()
        self.expect_value_sequence(None)

    def test_010_one(self):
        same = ('val1',)
        self.argv_tail = same
        self.expect_value_sequence(same)

    def test_020_two(self):
        same = 'val1', 'val2'
        self.argv_tail = same
        self.expect_value_sequence(same)

    def test_030_three(self):
        same = 'val1 val2 val3'.split()
        self.argv_tail = same
        self.expect_value_sequence(same)

    positionals = ('[TING [TING [..]]]',)
    parse_tree_focus_value = 'ting'


class Case5270_introduce_required_glob(CommonCase):

    def test_005_none(self):
        self.argv_tail = ()
        self.expect_early_stop('expecting_required_positional', 'TING')

    def test_010_one(self):
        same = ('val1',)
        self.argv_tail = same
        self.expect_value_sequence(same)

    def test_020_two(self):
        same = 'val1', 'val2'
        self.argv_tail = same
        self.expect_value_sequence(same)

    def test_030_three(self):
        same = 'val1 val2 val3'.split()
        self.argv_tail = same
        self.expect_value_sequence(same)

    positionals = ('TING [TING [..]]',)
    parse_tree_focus_value = 'ting'


class Case5274_introduce_stops(CommonCase):

    def test_010_what(self):
        self.argv_tail = 'val1', 'no-parse-1', 'no-parse-2'
        pt = self.expect_success()
        assert 'val1' == pt.values.pop('arg1')
        assert not pt.values
        stack = self.argv_stack
        assert 'val1' == stack.pop()  # not so in frontend integration
        assert 'no-parse-1' == stack.pop()
        assert 'no-parse-2' == stack.pop()
        assert not stack

    positionals = ('ARG1', '[stop ..]')


class Case5278_literal_dash_as_positional(CommonCase):  # sister: Case5952

    def test_010_stores_nothing(self):
        """ it must be so because we can't derive a name from the term """
        self.argv_tail = ('-',)
        pt = self.expect_success()
        assert 0 == len(pt.values)

    def test_020_whines_about_expecting(self):
        self.argv_tail = ()
        wat = self.expect_early_stop('expecting_required_positional', '-')

    positionals = ('-',)
    formal_is_for_interactive = True


build_sequence = engine_support.build_sequence


if '__main__' ==  __name__:
    unittest.main()

# #history-C.1
# #born
