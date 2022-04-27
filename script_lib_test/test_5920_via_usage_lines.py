# see [#608.18] for development of our seven foundational term types

import unittest

class UsageLineCase(unittest.TestCase):
    def parse_parse(self):
        itr = subject_module()._parse_usage_line(self.given_usage_line())
        syntax_sexp = tuple(itr)

        expected_heads_tail = (f := self.expected_heads_tail) and f()
        if expected_heads_tail is not None:
            act = tuple(term[0] for term in syntax_sexp[1:])
            self.assertSequenceEqual(act, expected_heads_tail)

        def test_first_or_last_term(f, offset):
            if not f:
                return
            actual_sequence = syntax_sexp[offset]

            # If it takes arguments, assume it does its own testing
            from inspect import signature
            params = signature(f).parameters
            if len(params):
                return f(actual_sequence)

            # Since it takes no arguments, assume it produces the target seq
            expected_sequence = f()
            self.assertSequenceEqual(actual_sequence, expected_sequence)

        test_first_or_last_term(self.expected_first_term, 0)
        test_first_or_last_term(self.expected_last_term, -1)

        return syntax_sexp

    expected_first_term = expected_last_term = expected_heads_tail = None


class ParseTermCase(unittest.TestCase):
    def expect_parses(self):
        act_sx, act_end = parse_this_one_term(self.given_string, 3)
        exp_end = len(self.given_string) - 4  # " zzz"
        self.assertEqual(act_sx[0], self.expected_nonterminal)
        # assert act_sx[0] == self.expected_nonterminal
        assert act_end == exp_end
        # print(f"\n\nfor now IGNORING: {act_sx[1:]!r}\n\n")
        return act_sx


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


class Case5917_02_NonpositionalLookingLiteral(ParseTermCase):
    def test_010_ok(self):
        sx = self.expect_parses()

        dct = {sx[i][0]: sx[i][1] for i in range(3, len(sx))}
        assert 2 == len(dct)

        # No storage name but name function
        assert sx[1] is None
        surface = dct.pop('familiar_name_function')()
        assert '-file' == surface

        # value normalizer says do not store
        assert dct.pop('value_normalizer')('-file') is None
        assert not dct

    given_string = 'xxx -file yyy'
    expected_nonterminal = 'required_positional'


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


class Case5922_stop_parsing(ParseTermCase):
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


class Case5940_enter_noninteractive(UsageLineCase):

    def test_010_work(self):
        self.parse_parse()

    def given_usage_line(self):
        return "usage: <anything-like-this> | {{prog_name}} [-file -]\n"

    def expected_first_term(_):
        return 'for_interactive', False

    def expected_last_term(self, sx):
        exp = 'optional_nonpositional', '-file', '-'
        self.assertSequenceEqual(exp, sx[:3])
        dct = {sx[i][0]: sx[i][1:] for i in range(3, len(sx))}
        f, = dct.pop('value_constraint')
        assert f('-') is None
        assert f('') is not None
        assert 0 == len(dct.pop('can_accept_dash_as_value'))
        assert not dct


class Case5942_noninteractive_this_way(UsageLineCase):  # sister: Case5278

    def test_010_work(self):
        syntax_sx = self.parse_parse()
        term_sx = syntax_sx[-1]
        assert 'required_positional' == term_sx[0]

        # This term has no "familiar name" to assert "do not store"
        assert term_sx[1] is None  # the familiar name (no storage)

        # But it has many properties..
        props = {}
        for i in range(2, len(term_sx)):
            prop = term_sx[i]
            if 1 == len(prop):
                props[prop[0]] = True
            else:
                k, v = prop
                props[k] = v

        # It turns on this special meta-flag to tell the parser single dash ok
        yn = props.pop('can_accept_dash_as_value')
        assert yn is True

        # It has a value constraint to assert that it only matches '-'
        func = props.pop('value_constraint')
        assert func('-') is None
        assert func('x') is not None

        # It has a value normalizer to override storing
        func = props.pop('value_normalizer')
        res = func(token='-')
        assert res is None

        # It has a name function so it can describe the formal in messages
        func = props.pop('familiar_name_function')
        assert '-' == func()

        assert not props

    def given_usage_line(self):
        return "usage: <produce-sexp> | {{prog_name}} -\n"

    def expected_first_term(_):
        return 'for_interactive', False


class Case5950_stop_at_beginning(UsageLineCase):

    def test_010_work(self):
        syntax_sx = self.parse_parse()
        assert 2 == len(syntax_sx)
        assert syntax_sx[1][0] == 'stop_parsing'

    def given_usage_line(self):
        return "usage: {{prog_name}} [this matches anything..]\n"


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
