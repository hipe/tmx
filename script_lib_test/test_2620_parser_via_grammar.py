from modality_agnostic.memoization import lazy
import unittest


class _CommonCase(unittest.TestCase):

    def run_expecting_failure(self, error_case_name):
        # ..
        from modality_agnostic.test_support.structured_emission import (
                one_and_none)
        channel, payloader = one_and_none(self, self.my_run)
        # ..
        expect = ('error', 'structure', 'parse_error', error_case_name)
        self.assertSequenceEqual(expect, channel)
        return channel, payloader

    def run_expecting_success(self):
        from modality_agnostic import listening
        listener = listening.throwing_listener
        return self.my_run(listener)

    def my_run(self, listener):  # NOTE you can't call it `run` because unittst
        _tokens = self.given_tokens()
        _scn = subject_module().TokenScanner(_tokens)
        _grammar = self.given_grammar()
        return _grammar.parse(_scn, listener)


class against_grammar_A(_CommonCase):

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


class against_grammar_B(_CommonCase):

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


class against_grammar_C(_CommonCase):

    def given_grammar(self):
        return grammar_C_plurality_intro()


class Case2626_introduce_plural_grammar(against_grammar_C):

    def test_100_parses(self):
        ast = self.run_expecting_success()
        self.assertSequenceEqual(ast, (('A', 'A'),))

    def given_tokens(self):
        return ('A', 'A')


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
