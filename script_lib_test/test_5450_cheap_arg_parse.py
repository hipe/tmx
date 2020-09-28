from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_children, lazy
import unittest
import re


class CommonCase(unittest.TestCase):
    do_debug = False


class ParsePosiCase(unittest.TestCase):

    @property  # ..
    @shared_subj_in_children
    def formal(self):
        moniker = self.given_string()
        return subject_function_one()((moniker, 'desc no see'))


class Case_5399_required_plural_positional(ParsePosiCase):

    def test_100_(self):
        fo = self.formal
        self.assertTrue(fo.is_plural)
        self.assertTrue(fo.is_required)

    def given_string(self):
        return '<file> [<file> [..]]'


class Case_5401_glob(ParsePosiCase):

    def test_100_(self):
        fo = self.formal
        self.assertTrue(fo.is_plural)
        self.assertFalse(fo.is_required)

    def given_string(self):
        return '[<command> [..]]'


class Case_5403_regular_positional(ParsePosiCase):

    def test_100_(self):
        fo = self.formal
        self.assertFalse(fo.is_plural)
        self.assertTrue(fo.is_required)

    def given_string(self):
        return '<arg>'


class Case_5405_you_must_keep_using_the_same_moniker(ParsePosiCase):

    def test_100_yuck(self):
        def run():
            self.formal
        errcls = subject_module().DefinitionError_
        self.assertRaisesRegex(errcls, "no support for multi.+IZZO', 'FA", run)

    def given_string(self):
        return 'FIZZO [FAZZO [..]]'

    def given_method(_):
        return 'nonterminal_parse'


class Case5414_introduce_formals_structure(CommonCase):

    def test_050_builds(self):
        self.end_state.formal_positionals

    def test_100_descriptions_which_are_required_look_like_this(self):
        a1 = self.first_option.descs
        a2 = self.second_option.descs
        a3 = self.first_argument.descs
        assert(len(a1))
        assert(len(a2))
        assert(len(a3))
        assert(isinstance(a1[0], str))
        assert(isinstance(a2[0], str))
        assert(isinstance(a3[0], str))

    def test_120_the_short_name_is_just_one_character(self):
        self.assertEqual(self.first_option.short_char, 'a')

    def test_140__the_long_name_doesnt_have_the_leading_dashes(self):
        self.assertEqual(self.first_option.long_stem, 'allo-morph')

    def test_160__currently_this_is_how_you_etc(self):
        self.assertEqual(self.first_option.arg_moniker, 'OH_HAI')

    def test_180_an_option_does_not_need_a_short_name(self):
        self.assertIsNone(self.second_option.short)

    def test_200_arg_name(self):
        self.assertEqual(self.first_argument.moniker, 'arg-num1')

    @property
    def first_option(self):
        return self.end_state.formal_options[0]

    @property
    def second_option(self):
        return self.end_state.formal_options[1]

    @property
    def first_argument(self):
        return self.end_state.formal_positionals[0]

    @property
    def end_state(self):
        return formals_one()


class ParseyCase(CommonCase):

    # -- failure assertion and set-up

    def expect_unrecognized_option(self, sw):
        self.expect_lc_reason_includes('unrecognized option', sw)

    def expect_does_not_take_an_argument(self, sw):
        self.expect_reason_with_agency('does not take an argument', sw)

    def expect_expecting_argument_for(self, sw):
        self.expect_lc_reason_includes('expecting argument for', sw)

    def expect_expecting_argument(self, farg):
        self.expect_lc_reason_includes('expecting', farg)

    def expect_unexpected_argument(self, farg):
        self.expect_lc_reason_includes('unexpected argument', farg)

    def expect_la_la_for(self, la_la, farg):
        rxs = ''.join((re.escape(la_la), " for '?", re.escape(farg)))
        self.expect_regex_case_insensitive(rxs)

    def expect_reason_with_agency(self, tail, agent):
        rxs = ''.join(("'?", re.escape(agent), "'? ", re.escape(tail)))
        self.expect_regex_case_insensitive(rxs)

    def expect_lc_reason_includes(self, head, tail):
        rxs = ''.join((re.escape(head), ":? '?", re.escape(tail), "'?"))
        self.expect_regex_case_insensitive(rxs)

    def expect_regex_case_insensitive(self, rxs):
        rx = re.compile(rxs, re.IGNORECASE)
        act = self.end_state_reason
        self.assertRegex(act, rx)

    @property
    def end_state_reason(self):
        return self.end_state_stderr_lines_and_exitstatus[0][0]

    @property
    @shared_subj_in_children
    def end_state_stderr_lines_and_exitstatus(self):
        return self.my_run(False)

    # -- success assertion and set-up

    def assert_all_none(self, x_a):
        assert(len(x_a))
        assert(not len(tuple(None for x in x_a if x is not None)))

    def expect_success(self):
        two_tups = self.my_run(True)
        self.assertIsNotNone(two_tups)
        return two_tups

    # --

    def my_run(self, do_expect_success):
        foz = self.given_formals()
        argv = self.given_args()
        from script_lib.test_support import \
            spy_on_write_and_lines_for as func
        serr, lines = func(self, 'DBG: ')
        m = self.given_method()
        vals, es = getattr(foz, m)(serr, list(reversed(argv)))
        if do_expect_success:
            self.assertIsNone(es)
            assert not len(lines)
            return foz.sparse_tuples_in_grammar_order_via_consume_values(vals)
        else:
            self.assertTrue(es)  # eek
            return tuple(lines), es

    def given_method(_):
        return 'terminal_parse'


class same(ParseyCase):

    def given_formals(self):
        return formals_one()


class Case5417_all_args_no_opts(same):

    def test_100_looks_good(self):
        opts, args = self.expect_success()
        self.assert_all_none(opts)
        self.assertSequenceEqual(args, ('AA', 'BB'))

    def given_args(self):
        return ('AA', 'BB')


class Case5421_opt_at_head(same):
    # also long with separate argument

    def test_100_looks_good(self):
        opts, args = self.expect_success()
        self.assertEqual(opts[0], 'x1')
        self.assert_all_none(opts[1:])
        self.assertSequenceEqual(args, ('AA', 'BB'))

    def given_args(self):
        return ('--allo-morph', 'x1', 'AA', 'BB')


class Case5424_not_equals(same):

    def test_100_reason(self):
        self.expect_unrecognized_option('--allo-morph?1987')

    def given_args(self):
        return ('--allo-morph?1987', 'no see')


class Case5428_opts_in_middle(same):
    # also long with equals

    def test_100_looks_good(self):
        opts, args = self.expect_success()
        self.assertSequenceEqual(args, ('AA', 'BB'))
        self.assertSequenceEqual(opts, ('x2', True))

    def given_args(self):
        return ('AA', '--allo-morph=x2', '--bu-ju', 'BB')


class Case5431_opt_at_end(same):
    # also short with tight argument

    def test_100_looks_good(self):
        opts, args = self.expect_success()
        self.assertSequenceEqual(args, ('AA', 'BB'))
        self.assertEqual(opts[0], 'x3')
        self.assert_all_none(opts[1:])

    def given_args(self):
        return ('AA', 'BB', '-ax3')


class Case5435_opts_everywhere_note_overwrite(same):
    # also short with separate argument. also clobber

    def test_100_looks_good(self):
        opts, args = self.expect_success()
        self.assertSequenceEqual(args, ('AA', 'BB'))
        self.assertSequenceEqual(opts, ('x3', True))

    def given_args(self):
        return ('--allo-morph', 'x1',
                'AA',
                '--allo-morph=x2',
                '--bu-ju',
                'BB',
                '-a', 'x3')


class Case5438_malformed_option_name(same):

    def test_100_reason(self):
        self.expect_unrecognized_option('---')

    def given_args(self):
        return ('---',)


class Case5442_an_unrecognied_long_looks_like_this(same):

    def test_100_reason(self):
        self.expect_unrecognized_option('--uh-oh')

    def given_args(self):
        return ('--bu-ju', '--uh-oh', 'no-see')


class Case5445_an_unrecognied_short_looks_like_this(same):
    # contrast to (Case5480) below unrec n jumble

    def test_100_reason(self):
        self.expect_unrecognized_option('-q')

    def given_args(self):
        return ('-q', 'no-see')


class Case5449_an_extra_positional_arg_looks_like_this(same):

    def test_100_reason(self):
        self.expect_unexpected_argument('CC')

    def given_args(self):
        return ('AA', 'BB', 'CC')


# Case5450  # #midpoint


class Case5452_an_missing_positional_arg_looks_like_this(same):
    # and positional moniker with <foo> braces

    def test_100_reason(self):
        self.expect_expecting_argument('<arg2>')

    def given_args(self):
        return ('AA',)


class Case5456_if_you_dont_pass_an_arg_taker_an_argument_it_is_sad(same):

    def test_100_reason(self):
        self.expect_expecting_argument_for('--allo-morph')

    def given_args(self):
        return ('-a',)


class Case5459_if_you_do_pass_a_flag_a_value_it_is_sad(same):

    def test_100_reason(self):
        self.expect_does_not_take_an_argument('--bu-ju')

    def given_args(self):
        return ('--bu-ju=1997', 'no see')


class Case5463_you_cant_pass_an_arg_taker_the_empty_string_after_equals(same):

    def test_100_reason(self):
        self.expect_lc_reason_includes(
            "equals sign must have content after it", '--allo-morph=')

    def given_args(self):
        return ('--allo-morph=',)


class Case5466_but_you_CAN_pass_empty_string_as_a_separate_argument(same):

    def test_100_looks_good(self):
        opts, args = self.expect_success()
        self.assertSequenceEqual(args, ('AA', 'BB'))
        self.assertSequenceEqual(opts, ('', None))

    def given_args(self):
        return ('AA', 'BB', '-a', '')


class Case5470_arg_taker_separate_arg_cant_look_like_option(same):

    def test_100_reason(self):
        self.expect_la_la_for("value looks like option", "--allo-morph")

    def given_args(self):
        return ('--allo-morph', '-x')


class Case5473_you_CAN_pass_an_option_looking_option_value_using_equals(same):

    def test_100_looks_good(self):
        opts, args = self.expect_success()
        self.assertSequenceEqual(args, ('AA', 'BB'))
        self.assertSequenceEqual(opts, ('-x', None))

    def given_args(self):
        return ('AA', 'BB', '--allo-morph=-x')


# ========

class same(ParseyCase):
    def given_formals(self):
        return formals_two()


class Case5477_you_can_expresss_multiple_flags_in_one_ball(same):
    # also, options only (no arguments)

    def test_100_reason(self):
        opts, args = self.expect_success()
        self.assertEqual(args, ())
        self.assertSequenceEqual(opts, (True, True, True, None))

    def given_args(self):
        return ('-abc',)


class Case5480_a_nonfirst_unrecognized_short_in_a_ball_has_more_info(same):
    # contrast to (Case5445) unrecognized flag at the front

    def test_100_reason(self):
        self.expect_unrecognized_option('-e')

    def given_args(self):
        return ('-abef',)


class Case5484_you_cannot_combine_flags_and_argument_takers_in_a_ball(same):

    def test_100_reason(self):
        self.expect_lc_reason_includes("ball of opts", "-b' then '-d")

    def given_args(self):
        return ('-abdx1',)


# currently_cannot_pass_option_looking_values_as_arguments:
# this is #open [#604.2] a known issue. perhaps a property of all arg parsers.
# writing a test for this would just look silly - the issue stems from a core
# assumption that perhaps all CLI's are built on.


# help meh


@lazy
def formals_two():
    return foz_via_defs((
        ('-a', '--alfalfa', 'd1'),
        ('-b', '--bubu', 'd2'),
        ('-c', '--chou-chou', 'd3'),
        ('-d', '--dingus=WEE', 'd4')), prog_namer=lambda: 'ohi')


@lazy
def formals_one():
    return foz_via_defs((
        ('-a', '--allo-morph=OH_HAI', 'desc 1A', 'desc 1B'),
        ('--bu-ju', 'desc 2'),
        ('arg-num1', 'desc 3A', 'desc 3B'),
        ('<arg2>', 'desc 4')), prog_namer=lambda: 'ohe')


# == Bridges and delegations

def foz_via_defs(definitions, **kwargs):
    return subject_module().formals_via_definitions(definitions, **kwargs)
    # #todo replacing syntax_AST_via_parameters_definition_


@lazy
def subject_function_one():
    return subject_module()._build_formal_positional_parser()


def subject_module():
    from script_lib import cheap_arg_parse as mod
    return mod


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))


if __name__ == '__main__':
    unittest.main()

# #history-B.2
# #born.
