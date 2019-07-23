from modality_agnostic.memoization import (
    dangerous_memoize_in_child_classes,
    lazy)
import unittest


CommonCase = unittest.TestCase


class Case5414_AST(CommonCase):

    def test_100_descriptions_which_are_required_look_like_this(self):
        a1 = self.first_option.description_lines
        a2 = self.second_option.description_lines
        a3 = self.first_argument.description_lines
        assert(len(a1))
        assert(len(a2))
        assert(len(a3))
        assert(isinstance(a1[0], str))
        assert(isinstance(a2[0], str))
        assert(isinstance(a3[0], str))

    def test_120_the_short_name_is_just_one_character(self):
        self.assertEqual(self.first_option.short_name, 'a')

    def test_140__the_long_name_doesnt_have_the_leading_dashes(self):
        self.assertEqual(self.first_option.long_name, 'allo-morph')

    def test_160__currently_this_is_how_you_etc(self):
        self.assertEqual(self.first_option.meta_var, 'OH_HAI')

    def test_180_an_option_does_not_need_a_short_name(self):
        self.assertIsNone(self.second_option.short_name)

    def test_200_arg_name(self):
        self.assertEqual(self.first_argument.name, 'arg-num1')

    @property
    def first_option(self):
        return self.end_state()[0][0]

    @property
    def second_option(self):
        return self.end_state()[0][1]

    @property
    def first_argument(self):
        return self.end_state()[1][0]

    def end_state(self):
        return grammar_one()


class ParseyCase(CommonCase):

    # -- failure assertion and set-up

    def expect_option_with_long_name(self, s):
        _ = self.flush_end_state_payload()['option'].long_name
        self.assertEqual(_, s)

    def expect_token_and_position(self, tok, pos):
        dct = self.flush_end_state_payload()
        self.assertEqual(dct['token'], tok)
        self.assertEqual(dct['token_position'], pos)

    def expect_token(self, tok):
        dct = self.flush_end_state_payload()
        self.assertEqual(dct['token'], tok)

    def expect_channel_tail(self, channel_tail):
        self.expect_channel_two_tail('parameter_error', channel_tail)

    def expect_channel_two_tail(self, error_category, error_case):
        self.assertSequenceEqual(
                self.end_state_error_channel(),
                ('error', 'structure', error_category, error_case))

    def end_state_error_channel(self):
        channel, structurer = self.failure_end_state()
        return channel

    def flush_end_state_payload(self):
        channel, structurer = self.failure_end_state()
        return structurer()

    @dangerous_memoize_in_child_classes('fail_ES', 'build_failure_end_state')
    def failure_end_state():
        pass

    def build_failure_end_state(self):
        channel, structurer = self.expect_failure()
        return channel, structurer

    def expect_failure(self):
        from modality_agnostic.test_support.structured_emission import (
                one_and_none)
        channel, payloader = one_and_none(self, self.my_run)
        # meh .. in progress
        return channel, payloader

    # -- success assertion and set-up

    def assert_all_none(self, x_a):
        assert(len(x_a))
        assert(not len(tuple(None for x in x_a if x is not None)))

    def expect_success(self):
        two_tups = self.my_run(None)
        self.assertIsNotNone(two_tups)
        return two_tups

    # --

    def my_run(self, listener):
        token_scn = parse_lib().TokenScanner(self.given_args())
        CLI_function = self.given_CLI()
        return CLI_function(token_scn, listener)


class same(ParseyCase):
    def given_CLI(self):
        return CLI_one()


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

    def test_100_channel(self):
        self.expect_channel_tail('expecting_equals_sign')

    def test_200_payload(self):
        self.expect_token_and_position('--allo-morph?1987', 12)

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

    def test_100_channel(self):
        self.expect_channel_tail('malformed_option_name')

    def test_200_payload(self):
        self.expect_token_and_position('---', 2)

    def given_args(self):
        return ('---',)


class Case5442_an_unrecognied_long_looks_like_this(same):

    def test_100_channel(self):
        self.expect_channel_tail('unrecognized_option')

    def test_200_payload(self):
        self.expect_token('--uh-oh')

    def given_args(self):
        return ('--bu-ju', '--uh-oh', 'no-see')


class Case5445_an_unrecognied_short_looks_like_this(same):
    # contrast to (Case5480) below unrec n jumble

    def test_100_channel(self):
        self.expect_channel_tail('unrecognized_option')

    def test_200_payload(self):
        self.expect_token('-q')

    def given_args(self):
        return ('-q', 'no-see')


class Case5449_an_extra_positional_arg_looks_like_this(same):

    def test_100_channel(self):
        self.expect_channel_tail('unexpected_argument')

    def test_200_payload(self):
        self.expect_token('CC')

    def given_args(self):
        return ('AA', 'BB', 'CC')


# #midpoint


class Case5452_an_missing_positional_arg_looks_like_this(same):

    def test_100_channel(self):
        self.expect_channel_tail('expecting')

    def test_200_payload(self):
        _arg = self.flush_end_state_payload()['argument']
        self.assertEqual(_arg.name, 'arg2')

    def given_args(self):
        return ('AA',)


class Case5456_if_you_dont_pass_an_arg_taker_an_argument_it_is_sad(same):

    def test_100_channel(self):
        self.expect_channel_tail('option_requires_argument')

    def test_200_payload(self):
        self.expect_option_with_long_name('allo-morph')

    def given_args(self):
        return ('-a',)


class Case5459_if_you_do_pass_a_flag_a_value_it_is_sad(same):

    def test_100_channel(self):
        self.expect_channel_tail('flag_option_must_have_nothing_after_it')

    def test_200_payload(self):
        self.expect_token_and_position('--bu-ju?1997', 7)

    def given_args(self):
        return ('--bu-ju?1997', 'no see')


class Case5463_you_cant_pass_an_arg_taker_the_empty_string_after_equals(same):

    def test_100_channel(self):  # ..
        self.expect_channel_tail('equals_sign_must_have_content_after_it')

    def test_200_payload(self):
        self.expect_token_and_position('--allo-morph=', len('--allo-morph='))

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

    def test_100_channel(self):
        self.expect_channel_tail('option_value_looks_like_option')

    def test_200_payload(self):
        dct = self.flush_end_state_payload()
        self.assertEqual(dct['token'], '-x')
        self.assertEqual(dct['option'].long_name, 'allo-morph')

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
    def given_CLI(self):
        return CLI_two()


class Case5477_you_can_expresss_multiple_flags_in_one_ball(same):
    # also, options only (no arguments)

    def test_100_looks_good(self):
        opts, args = self.expect_success()
        self.assertEqual(args, ())
        self.assertSequenceEqual(opts, (True, True, True, None))

    def given_args(self):
        return ('-abc',)


class Case5480_a_nonfirst_unrecognized_short_in_a_ball_has_more_info(same):
    # contrast to (Case5445) unrecognized flag at the front

    def test_100_channel(self):
        self.expect_channel_tail('unrecognized_option')

    def test_200_payload(self):
        self.expect_token_and_position('-abef', 3)

    def given_args(self):
        return ('-abef',)


class Case5484_you_cannot_combine_flags_and_argument_takers_in_a_ball(same):

    def test_100_channel(self):
        self.expect_channel_tail(
                'cannot_mix_flags_and_optional_parameters_in_one_token')

    def test_200_payload(self):
        self.expect_token_and_position('-abdx1', 3)

    def given_args(self):
        return ('-abdx1',)


# Case5487 currently_cannot_pass_option_looking_values_as_arguments:
# this is #open [#604.2] a known issue. perhaps a property of all arg parsers.
# writing a test for this would just look silly - the issue stems from a core
# assumption that perhaps all CLI's are built on.


# help meh


@lazy
def CLI_two():
    return CLI_via(AST_via((
        ('-a', '--alfalfa', 'd1'),
        ('-b', '--bubu', 'd2'),
        ('-c', '--chou-chou', 'd3'),
        ('-d', '--dingus=WEE', 'd4'))))


@lazy
def CLI_one():
    return CLI_via(grammar_one())


@lazy
def grammar_one():
    return AST_via((
        ('-a', '--allo-morph=OH_HAI', 'desc 1A', 'desc 1B'),
        ('--bu-ju', 'desc 2'),
        ('arg-num1', 'desc 3A', 'desc 3B'),
        ('arg2', 'desc 4')))


def CLI_via(syntax_AST):
    return subject_module()._CLI_parser_function_via_syntax_AST(syntax_AST)


def AST_via(tups):
    return subject_module()._syntax_AST_via_parameters_definition(tups)


def parse_lib():
    from script_lib.magnetics import parser_via_grammar as parse_lib
    return parse_lib


def subject_module():
    from script_lib.magnetics import (
            argument_parser_index_via_stderr_and_command_stream as mod)
    return mod


if __name__ == '__main__':
    unittest.main()

# #born.
