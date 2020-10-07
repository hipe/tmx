from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_child_classes
import unittest


class CommonCase(unittest.TestCase):
    """you might think that some of these should be pushed up to the..

    test helper library for help screens (and you might be right) but for
    now we are holding off on making a monolithic test case superclass,
    opting instead to stitch-in to only the needed facilities from there
    on an as-needed basis, with the justification that by cherry-picking
    in this way:

      - we can decrease coupling (why should the test helper library require
        in-depth, opaque knowledge of what methods we implement? vice-versa?)

      - we can improve clarity (because functions as opposed to methods show
        all their parameters in the call).
    """

    # -- assertions

    def in_usage_expect_interesting_tail(self, tail):
        import re
        line = self.help_screen['usage'].head_line
        md = re.match(r'^usage: ohai-mumo my-command \[-h\](?: (.+))?$', line)
        self.assertEqual(tail, md[1])

    def _in_details_expect_optionals(self, *s_a):
        act_oi = self.option_index
        self._same_expect(act_oi, s_a)

    def _in_details_expect_positionals(self, *s_a):
        act_pai = self.help_screen.to_positional_index()
        self._same_expect(act_pai, s_a)

    def _same_expect(self, xai, s_a):
        _exp = frozenset(s_a)
        _act = frozenset(xai.keys())
        self.assertEqual(_exp, _act)

    def _help_screen_renders(self):
        lines = self.end_state_lines
        self.assertIsNot(0, len(lines))

    # -- builders

    @property
    @shared_subj_in_child_classes
    def option_index(self):
        oi = self.help_screen.to_option_index()
        oi.pop('--help')  # tact assertion. cleans up logic elsewhere
        return oi

    @property
    @shared_subj_in_child_classes
    def help_screen(self):
        lines = self.end_state_lines
        func = EHS().parse_help_screen
        return func(lines)

    @property
    @shared_subj_in_child_classes
    def end_state_lines(self):

        # moved here from a library file at #history-A.1.
        # will DRY with sibling file and maybe push back up maybe later.
        # right now scope is just to green this file

        from script_lib.test_support.expect_STDs import \
            spy_on_write_and_lines_for as func
        spy_IO, lines = func(self, 'DEBUG: ')

        argv = '/fake-fs/xx/yy/ohai-mumo', 'my-command', '--help'

        from script_lib.magnetics.CLI_formal_parameters_via_formal_parameters \
            import CLI_function_via_command_module
        _command_module = self.given_command_module()
        _CLI_function = CLI_function_via_command_module(_command_module)

        cx_CLI_funcs = (('my-command', lambda: _CLI_function),)

        from script_lib.cheap_arg_parse import cheap_arg_parse_branch as func
        es = func(None, None, spy_IO, argv=argv, cx=cx_CLI_funcs)

        self.assertEqual(0, es)
        return tuple(lines)

    do_debug = False


# (each "category N" below is from the list at [#502])

class Case5844_category_4_required_field(CommonCase):

    def test_010_help_screen_renders(self):
        self._help_screen_renders()

    def test_020_in_details_appears_as_positionals(self):
        self._in_details_expect_positionals('foo-bar', 'biff-baz')

    def test_030_these_to_positionals_in_usage(self):
        self.in_usage_expect_interesting_tail('foo-bar biff-baz')

    def given_command_module(self):
        return command_modules().two_crude_function_parameters_by_function


class Case5847_category_1_flag(CommonCase):

    def test_010_help_screen_renders(self):
        self._help_screen_renders()

    def test_020_in_details_appears_as_optional(self):
        self._in_details_expect_optionals('--this-flag')

    def test_030_usage_tail_is_this(self):
        self.in_usage_expect_interesting_tail('[--this-flag]')

    def given_command_module(self):
        return command_modules().category_1_flag_minimal


class Case5850_category_2_optional_field_NOTE(CommonCase):
    """NOTE - there is a #aesthetic-hueristic vaporware here that has

    yet to be specified (in this project). it's something like this: an
    optional field can be promoted to a positional argument under certain
    gestalt states. (probably something like: no category 3, no category 5,
    and there's a clear reason to chose one cat 2 over any other cat 2 for
    such a promotion; i.e only when there's only one cat 2.) meh for now.
    """

    def test_010_help_screen_renders(self):
        self._help_screen_renders()

    def test_020_in_details_appears_as_OPTIONAL(self):
        self.assertIsNotNone(self._this_one_parsed_option_detail)

    def test_025_in_details_the_optional_field_names_its_parameter_sensically(self):  # noqa: E501
        _guy = self._this_one_parsed_option_detail
        self.assertEqual('FIELDO', _guy.args_tail_of_long)

    def test_027_in_details_the_optional_does_not_automatically_get_a_short_switch(self):  # noqa: E501
        _guy = self._this_one_parsed_option_detail
        self.assertIsNone(_guy.main_short_switch)

    def test_030_usage_tail_is_this(self):
        self.in_usage_expect_interesting_tail('[--opto-fieldo=X]')

    @property
    def _this_one_parsed_option_detail(self):
        return self.option_index['--opto-fieldo']

    def given_command_module(self):
        return command_modules().category_2_optional_field_minimal


class Case5853_category_3_optional_list(CommonCase):

    def test_010_help_screen_renders(self):
        self._help_screen_renders()

    def test_020_in_details_appears_as_positionals(self):
        self._in_details_expect_positionals('listo-boyo', 'wingo-wanno')

    def test_030_usage_tail_is_this(self):
        exp = 'wingo-wanno [listo-boyo […]]'
        self.in_usage_expect_interesting_tail(exp)

    def given_command_module(self):
        return command_modules().category_3_optional_list_minimal


class Case5856_category_5_required_list(CommonCase):

    def test_010_help_screen_renders(self):
        self._help_screen_renders()

    def test_020_in_details_appears_as_positional(self):
        self._in_details_expect_positionals('reqo-listo')

    def test_030_usage_tail_is_this(self):
        self.in_usage_expect_interesting_tail('reqo-listo [reqo-listo […]]')

    def given_command_module(self):
        return command_modules().category_5_required_list_minimal


def EHS():
    from script_lib.test_support import expect_help_screen
    return expect_help_screen


def command_modules():
    from modality_agnostic.test_support.parameters_canon import \
        command_modules as module
    return module


if __name__ == '__main__':
    unittest.main()

# #history-A.1
# #born.
