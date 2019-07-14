import _init  # noqa: F401
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        lazy)
import unittest


class _CommonCase(unittest.TestCase):
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

    def __init__(self, test_name):
        self.do_debug = False
        super().__init__(test_name)

    # -- assertions

    def _in_usage_expect_interesting_tail(self, tail_s):
        import re
        _s = self._section_index()['usage'].styled_content_string
        _match = re.search('^usage: ohai my-command \\[-h\\] (.+)$', _s)
        _act = _match[1]
        self.assertEqual(tail_s, _act)

    def _in_details_expect_optionals(self, *s_a):
        oai = self._optional_args_index()
        self._same_expect(oai, s_a)

    def _in_details_expect_positionals(self, *s_a):
        _act = self._section_index()
        _pai = _lib().positional_args_index_via_section_index(_act)
        self._same_expect(_pai, s_a)

    def _same_expect(self, xai, s_a):
        _exp = frozenset(s_a)
        _act = frozenset(xai.keys())
        self.assertEqual(_exp, _act)

    def _help_screen_renders(self):
        _chunks = self._chunks()
        self.assertIsNot(0, len(_chunks[0]))

    # -- builders

    def _build_optional_args_index(self):
        _act = self._section_index()
        oai = _lib().optional_args_index_via_section_index(_act)
        del oai['--help']  # tacit assertion that it exists, as well as norm
        return oai

    def _section_index_via_chunks(self):
        return _lib().section_index_via_chunks(self._chunks())

    def _chunks_via_work(self):
        return _lib().help_screen_chunks_via_test_case(self)


# (each "category N" below is from the list at [#502])

class Case010_category_4_required_field(_CommonCase):

    def test_010_help_screen_renders(self):
        self._help_screen_renders()

    def test_020_in_details_appears_as_positionals(self):
        self._in_details_expect_positionals('foo-bar', 'biff-baz')

    def test_030_these_to_positionals_in_usage(self):
        self._in_usage_expect_interesting_tail('foo-bar biff-baz')

    @shared_subject
    def _section_index(self):
        return self._section_index_via_chunks()

    @shared_subject
    def _chunks(self):
        return self._chunks_via_work()

    def command_module_(self):
        return _command_modules().two_crude_function_parameters_by_function()


class Case020_category_1_flag(_CommonCase):

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
        return self._section_index_via_chunks()

    @shared_subject
    def _chunks(self):
        return self._chunks_via_work()

    def command_module_(self):
        return _command_modules().category_1_flag_minimal()


class Case030_category_2_optional_field_NOTE(_CommonCase):
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
        self._in_usage_expect_interesting_tail('[--opto-fieldo FIELDO]')

    @property
    @shared_subject
    def _this_one_parsed_option_detail(self):
        _oai = self._build_optional_args_index()
        return _oai['--opto-fieldo']

    @shared_subject
    def _optional_args_index(self):
        return self._build_optional_args_index()
        _act = self._section_index()
        oai = _lib().optional_args_index_via_section_index(_act)
        del oai['--help']  # tacit assertion that it exists, as well as norm

    @shared_subject
    def _section_index(self):
        return self._section_index_via_chunks()

    @shared_subject
    def _chunks(self):
        return self._chunks_via_work()

    def command_module_(self):
        return _command_modules().category_2_optional_field_minimal()


class Case040_category_3_optional_list(_CommonCase):

    def test_010_help_screen_renders(self):
        self._help_screen_renders()

    def test_020_in_details_appears_as_positionals(self):
        self._in_details_expect_positionals('listo-boyo', 'wingo-wanno')

    def test_030_usage_tail_is_this(self):
        _exp = '[listo-boyo [listo-boyo ...]] wingo-wanno'
        self._in_usage_expect_interesting_tail(_exp)

    @shared_subject
    def _section_index(self):
        return self._section_index_via_chunks()

    @shared_subject
    def _chunks(self):
        return self._chunks_via_work()

    def command_module_(self):
        return _command_modules().category_3_optional_list_minimal()


class Case050_category_5_required_list(_CommonCase):

    def test_010_help_screen_renders(self):
        self._help_screen_renders()

    def test_020_in_details_appears_as_positional(self):
        self._in_details_expect_positionals('reqo-listo')

    def test_030_usage_tail_is_this(self):
        self._in_usage_expect_interesting_tail('reqo-listo [reqo-listo ...]')

    @shared_subject
    def _section_index(self):
        return self._section_index_via_chunks()

    @shared_subject
    def _chunks(self):
        return self._chunks_via_work()

    def command_module_(self):
        return _command_modules().category_5_required_list_minimal()


@lazy
def _lib():
    import script_lib.test_support.expect_help_screen as x
    return x


@lazy
def _command_modules():
    from modality_agnostic.test_support.parameters_canon import (
            command_modules as x,
            )
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
