from modality_agnostic.memoization import lazy
import unittest


class CommonCase(unittest.TestCase):

    # -- assertions

    def expect_sequence_equals_recursive(self, ast, exp):
        from script_lib.test_support import assert_sequence_equals_recursive
        return assert_sequence_equals_recursive(ast, exp, self)

    # -- create end state

    def run_expecting_failure(self, error_case_name):
        import modality_agnostic.test_support.common as em
        listener, emissions = em.listener_and_emissions_for(self, limit=1)
        x = self._do_run(listener, self.given_tokens())
        self.assertIsNone(x)
        emi, = emissions
        channel, payloader = (emi.channel, emi.payloader)
        expect = ('error', 'structure', 'parse_error', error_case_name)
        self.assertSequenceEqual(expect, channel)
        return channel, payloader

    def run_expecting_success(self):
        return self.run_expecting_success_against(self.given_tokens())

    def run_expecting_success_against(self, tokens):
        from modality_agnostic import listening
        listener = listening.throwing_listener
        return self._do_run(listener, tokens)

    def _do_run(self, listener, tokens):  # can't call it `run` b.c unittest
        _scn = subject_module().TokenScanner(tokens)
        _grammar = self.given_grammar()
        return _grammar.parse(_scn, listener)

    do_debug = False


class against_grammar_A(CommonCase):

    def given_grammar(self):
        return just_the_letter_A()


class Case2595_matching_matches(against_grammar_A):

    def test_050_grammar_loads(self):
        self.assertIsNotNone(self.given_grammar())

    def test_100_parses(self):
        ast = self.run_expecting_success()
        self.assertSequenceEqual(ast, ('A',))

    def given_tokens(self):
        return ('A',)


class Case2598_not_matches_not_matches(against_grammar_A):

    def test_100_channel(self):
        self.run_expecting_failure('unrecognized_input')

    def given_tokens(self):
        return ('B',)


class Case2611_too_many_is_too_many(against_grammar_A):

    def test_100_channel(self):
        self.run_expecting_failure('extra_input')

    def given_tokens(self):
        return ('A', 'B')


class Case2614_none_is_too_few(against_grammar_A):

    def test_100_channel(self):
        self.run_expecting_failure('missing_required')

    def given_tokens(self):
        return ()


class against_grammar_B(CommonCase):

    def given_grammar(self):
        return grammar_B_thing_ding()


class Case2617_no_optional(against_grammar_B):

    def test_100_parses(self):
        ast = self.run_expecting_success()
        self.assertSequenceEqual(ast, (None, '--foo-bar'))

    def given_tokens(self):
        return ('--foo-bar',)


class Case2620_yes_optional(against_grammar_B):  # #midpoint

    def test_100_parses(self):
        ast = self.run_expecting_success()
        self.assertSequenceEqual(ast, ('-x', '--foo-bar'))

    def given_tokens(self):
        return ('-x', '--foo-bar')


class Case2623_too_many_optionals(against_grammar_B):

    def test_100_channel(self):
        self.run_expecting_failure('unrecognized_input')

    def given_tokens(self):
        return ('-x', '-x', '--foo-bar')


class against_grammar_C(CommonCase):

    def given_grammar(self):
        return grammar_C_plurality_intro()


class Case2626_introduce_plural_grammar(against_grammar_C):

    def test_100_parses(self):
        ast = self.run_expecting_success()
        self.assertSequenceEqual(ast, (('A', 'A'),))

    def given_tokens(self):
        return ('A', 'A')


class Case2629_introduce_sub_expressions(CommonCase):

    def test_010_parses(self):
        ast = self.run_expecting_success()
        _exp = ('A', (('B', 'C'), ('B', 'C')))
        self.expect_sequence_equals_recursive(ast, _exp)

    def given_tokens(self):
        return ('A', 'B', 'C', 'B', 'C')

    def given_grammar(self):
        return grammar_D1_subexpression_intro_NOT_MEMOIZED()


class Case2632_optional_glob_with_none_is_none_not_empty_list(CommonCase):

    def test_010_parses(self):

        _given_tokens = ('A',)
        ast = self.run_expecting_success_against(_given_tokens)
        _exp = ('A', None)  # NOTE second term is `None` not `()`
        self.expect_sequence_equals_recursive(ast, _exp)

        # curb check (tests similar input structure to previous case)
        _given_tokens = ('A', 'B', 'C')
        ast = self.run_expecting_success_against(_given_tokens)
        _exp = ('A', (('B', 'C'),))
        self.expect_sequence_equals_recursive(ast, _exp)

    def given_grammar(self):
        return grammar_D2_optional_list()


# stop: Case3735


@lazy
def grammar_D2_optional_list():
    return build_grammar(
            'one', 'A',
            'zero or more', '(', 'one', 'B', 'one', 'C', ')')


def grammar_D1_subexpression_intro_NOT_MEMOIZED():
    return build_grammar(
            'zero or one', 'A',
            'one or more', '(', 'one', 'B', 'one', 'C', ')')


@lazy
def grammar_C_plurality_intro():
    return build_grammar('one or more', 'A')


@lazy
def grammar_B_thing_ding():
    return build_grammar('any', 'short', 'one', 'long')


@lazy
def just_the_letter_A():
    return build_grammar('one', 'A')


def build_grammar(*tokens):
    return subject_module().parser_via_grammar_and_symbol_table(
            tokens, symbol_table())


@lazy
def symbol_table():
    return {
            'A': lambda: build_minimal_parser('A'),
            'B': lambda: build_minimal_parser('B'),
            'C': lambda: build_minimal_parser('C'),
            'long': lambda: build_minimal_parser('--foo-bar'),
            'short': lambda: build_minimal_parser('-x'),
            }


class build_minimal_parser:

    def __init__(self, string):
        self._string = string

    def match_by_peek_as_subparser(self, tox):
        return self._string == tox.peek

    def parse_as_subparser(self, tox, listener):
        tox.advance()
        return (self._string,)


def subject_module():
    from script_lib.magnetics import parser_via_grammar as mod
    return mod


if __name__ == '__main__':
    unittest.main()

# #born
