from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        dangerous_memoize_in_child_classes)
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

    def _in_usage_expect_interesting_tail(self, tail_s):
        import re
        node = self._section_index()['usage']
        _use_node = node if node.is_terminal else node.children[0]
        _s = _use_node.styled_content_string
        _match = re.search('^usage: ohai-mumo my-command (.+)$', _s)
        _act = _match[1]
        self.assertEqual(tail_s, _act)

    def _in_details_expect_optionals(self, *s_a):
        oai = self._optional_args_index()
        self._same_expect(oai, s_a)

    def _in_details_expect_positionals(self, *s_a):
        _act = self._section_index()
        _pai = EHS().positional_args_index_via_section_index(_act)
        self._same_expect(_pai, s_a)

    def _same_expect(self, xai, s_a):
        _exp = frozenset(s_a)
        _act = frozenset(xai.keys())
        self.assertEqual(_exp, _act)

    def _help_screen_renders(self):
        _lines = self.end_state_lines()
        self.assertIsNot(0, len(_lines[0]))

    # -- builders

    def _build_optional_args_index(self):
        _act = self._section_index()
        oai = EHS().optional_args_index_via_section_index(_act)
        del oai['--help']  # tacit assertion that it exists, as well as norm
        return oai

    def build_section_index(self):
        return EHS().section_index_via_lines(self.end_state_lines())

    @dangerous_memoize_in_child_classes('_END_STATE_LINES', 'build_lines')
    def end_state_lines(self):
        pass

    def build_lines(self):

        # moved here from a library file at #history-A.1.
        # will DRY with sibling file and maybe push back up maybe later.
        # right now scope is just to green this file

        from script_lib.test_support import lines_and_spy_io_for_test_context
        lines, spy_IO = lines_and_spy_io_for_test_context(self, 'DEBUG: ')

        _argv = ('/fake-fs/xx/yy/ohai-mumo', 'my-command', '--help')

        from script_lib.magnetics.CLI_formal_parameters_via_formal_parameters import (  # noqa: E501
                CLI_function_via_command_module)
        _command_module = self.given_command_module()
        _CLI_function = CLI_function_via_command_module(_command_module)

        _cx_CLI_funcs = (('my-command', lambda: _CLI_function),)

        from script_lib.cheap_arg_parse_branch import cheap_arg_parse_branch
        es = cheap_arg_parse_branch(
                stdin=None, stdout=None, stderr=spy_IO, argv=_argv,
                children_CLI_functions=_cx_CLI_funcs)

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
        self._in_usage_expect_interesting_tail('foo-bar biff-baz')

    @shared_subject
    def _section_index(self):
        return self.build_section_index()

    def given_command_module(self):
        return command_modules().two_crude_function_parameters_by_function


class Case5847_category_1_flag(CommonCase):

    def test_010_help_screen_renders(self):
        self._help_screen_renders()

    def test_020_in_details_appears_as_optional(self):
        self._in_details_expect_optionals('--this-flag')

    def test_030_usage_tail_is_this(self):
        self._in_usage_expect_interesting_tail('[--this-flag]')

    # NOTE no memoization
    def _optional_args_index(self):
        return self._build_optional_args_index()

    @shared_subject
    def _section_index(self):
        return self.build_section_index()

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
        self._in_usage_expect_interesting_tail('[--opto-fieldo=FIELDO]')

    @property
    @shared_subject
    def _this_one_parsed_option_detail(self):
        _oai = self._build_optional_args_index()
        return _oai['--opto-fieldo']

    @shared_subject
    def _optional_args_index(self):
        return self._build_optional_args_index()
        _act = self._section_index()
        oai = EHS().optional_args_index_via_section_index(_act)
        del oai['--help']  # tacit assertion that it exists, as well as norm

    @shared_subject
    def _section_index(self):
        return self.build_section_index()

    def given_command_module(self):
        return command_modules().category_2_optional_field_minimal


class Case5853_category_3_optional_list(CommonCase):

    def test_010_help_screen_renders(self):
        self._help_screen_renders()

    def test_020_in_details_appears_as_positionals(self):
        self._in_details_expect_positionals('listo-boyo', 'wingo-wanno')

    def test_030_usage_tail_is_this(self):
        _exp = 'wingo-wanno [listo-boyo [listo-boyo …]]'
        self._in_usage_expect_interesting_tail(_exp)

    @shared_subject
    def _section_index(self):
        return self.build_section_index()

    def given_command_module(self):
        return command_modules().category_3_optional_list_minimal


class Case5856_category_5_required_list(CommonCase):

    def test_010_help_screen_renders(self):
        self._help_screen_renders()

    def test_020_in_details_appears_as_positional(self):
        self._in_details_expect_positionals('reqo-listo')

    def test_030_usage_tail_is_this(self):
        self._in_usage_expect_interesting_tail('reqo-listo [reqo-listo …]')

    @shared_subject
    def _section_index(self):
        return self.build_section_index()

    def given_command_module(self):
        return command_modules().category_5_required_list_minimal


def EHS():
    from script_lib.test_support import expect_help_screen
    return expect_help_screen


def command_modules():
    from modality_agnostic.test_support.parameters_canon import (
            command_modules)
    return command_modules


if __name__ == '__main__':
    unittest.main()

# #history-A.1
# #born.
