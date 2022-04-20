# see [#608.18] for development of our seven foundational term types

import unittest

class UsageLineCase(unittest.TestCase):
    def parse_parse(self):
        itr = subject_module()._parse_usage_line(self.given_usage_line())
        syntax_sexp = tuple(itr)

        def same(f):
            return f and f()

        expected_first_term = same(self.expected_first_term)
        expected_last_term = same(self.expected_last_term)
        expected_heads_tail = same(self.expected_heads_tail)

        if expected_heads_tail is not None:
            act = tuple(term[0] for term in syntax_sexp[1:])
            self.assertSequenceEqual(act, expected_heads_tail)

        if expected_first_term is not None:
            self.assertSequenceEqual(syntax_sexp[0], expected_first_term)

        if expected_last_term is not None:
            self.assertSequenceEqual(syntax_sexp[-1], expected_last_term)

    expected_first_term = expected_last_term = expected_heads_tail = None


class ParseTermCase(unittest.TestCase):
    def expect_parses(self):
        act_sx, act_end = parse_this_one_term(self.given_string, 3)
        exp_end = len(self.given_string) - 4  # " zzz"
        self.assertEqual(act_sx[0], self.expected_nonterminal)
        # assert act_sx[0] == self.expected_nonterminal
        assert act_end == exp_end
        # print(f"\n\nfor now IGNORING: {act_sx[1:]!r}\n\n")


class Case5911_RP(ParseTermCase):  # required positional
    def test_010_ok(self):
        self.expect_parses()

    given_string = 'xxx ARG_ONE_1 zzz'
    expected_nonterminal = 'required_positional'


class Case5912_SC(ParseTermCase):  # subcommand
    def test_010_ok(self):
        self.expect_parses()

    given_string = 'xxx foo-bar zzz'
    expected_nonterminal = 'subcommand'


class Case5913_OP(ParseTermCase):  # optional positional
    def test_010_ok(self):
        self.expect_parses()

    given_string = 'xxx [ARG1] zzz'
    expected_nonterminal = 'nested_optional_positionals'  # for now


class Case5914_FD(ParseTermCase):  # flag (double dash)
    def test_010_ok(self):
        self.expect_parses()

    given_string = 'xxx [--ziff-davis] yyy'
    expected_nonterminal = 'flag'


class Case5915_FS(ParseTermCase):  # flag (single dash)
    def test_010_ok(self):
        self.expect_parses()

    given_string = 'xxx [-ziff-davis] yyy'
    expected_nonterminal = 'flag'


class Case5916_ONPD(ParseTermCase):  # optional nonpositional (double dash)
    def test_010_ok(self):
        self.expect_parses()

    given_string = 'xxx [--ziff-davis=DING] yyy'
    expected_nonterminal = 'optional_nonpositional'


class Case5917_ONPS(ParseTermCase):  # optional nonpositional (single dash)
    def test_010_ok(self):
        self.expect_parses()

    given_string = 'xxx [-ziff-davis=DING] yyy'
    expected_nonterminal = 'optional_nonpositional'


class Case5918_OG(ParseTermCase):  # optional glob
    def test_010_ok(self):
        self.expect_parses()

    given_string = 'xxx [ARG [ARG [..]]] yyy'
    expected_nonterminal = 'optional_glob'


class Case5919_RG(ParseTermCase):  # required glob
    def test_010_ok(self):
        self.expect_parses()

    given_string = 'xxx ARG [ARG [..]] yyy'
    expected_nonterminal = 'required_glob'


class Case5920_nested_optional_positionals(ParseTermCase):  # optional position
    def test_010_ok(self):
        self.expect_parses()

    given_string = 'xxx [BARG [FARG [HARG]]] yyy'
    expected_nonterminal = 'nested_optional_positionals'


class Case5922_stop_parsing(ParseTermCase):  # optional position
    def test_010_ok(self):
        self.expect_parses()

    given_string = 'xxx [any-thing you want ..] yyy'
    expected_nonterminal = 'stop_parsing'


class Case5928_no_parameters(UsageLineCase):

    def test_010_work(self):
        self.parse_parse()

    def given_usage_line(self):
        return "usage: {{prog_name}}\n"

    def expected_heads_tail(_):
        return ()


class Case5932_one_optional_nonpositional(UsageLineCase):

    def test_010_work(self):
        self.parse_parse()

    def given_usage_line(self):
        return "usage: {{prog_name}} [-file=FILE]\n"

    def expected_last_term(_):
        return 'optional_nonpositional', '-file', 'FILE'


class Case5936_this_cute_thing(UsageLineCase):

    def test_010_work(self):
        self.parse_parse()

    def given_usage_line(self):
        return "usage: {{prog_name}} ARG1 [ARG2]\n"

    def expected_heads_tail(_):
        return 'required_positional', 'optional_positional'


class Case5940_enter_noninteractive(UsageLineCase):

    def test_010_work(self):
        self.parse_parse()

    def given_usage_line(self):
        return "usage: <anything-like-this> | {{prog_name}} [-file -]\n"

    def expected_first_term(_):
        return 'for_interactive', False

    def expected_last_term(_):
        return 'optional_nonpositional', '-file', '-'


class Case5948_subcommand_and_nonpos_and_pos(UsageLineCase):

    def test_010_work(self):
        self.parse_parse()

    def given_usage_line(_):
        return "usage: {{prog_name}} generate [-i] [--preview] COLLECTION_PATH\n"

    def expected_heads_tail(_):
        return 'subcommand', 'flag', 'flag', 'required_positional'


def parse_this_one_term(string, cursor):
    memo = parse_this_one_term
    if memo.value is None:
        memo.value = subject_module()._build_term_matcher()
    return memo.value(string, cursor)


parse_this_one_term.value = None


def subject_module():
    import script_lib.via_usage_line as mod
    return mod


if '__main__' ==  __name__:
    unittest.main()

# #born
