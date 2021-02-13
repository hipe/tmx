from modality_agnostic.test_support.common import \
        listener_and_emissions_for, \
        dangerous_memoize_in_child_classes as shared_subject_in_child_classes
from unittest import TestCase as unittest_TestCase, main as unittest_main
from collections import namedtuple
import re


class CommonCase(unittest_TestCase):

    def expect_expected_complaint_lines(self):
        es = self.build_end_state()  # ..
        assert es.result is None
        exp = tuple(self.expected_complaint_lines())
        emi, = es.emissions
        act = tuple(emi.to_messages())

        # For now, we'll assume that whenever the number of expected lines
        # is shorter than the number of actual lines, then we're simply
        # disinterested in covering those extra actual lines

        if len(exp) < len(act):
            act = act[:(len(exp)+1)]

        # Support special expectation extension: regex iff this..

        if 1 == len(exp) and hasattr(exp[0], 'match'):
            # (note that we would have truncated more than one actuals above)
            return self.assertRegex(act[0], exp[0])

        self.assertSequenceEqual(act, exp)

    def expect_expected_query_tree(self):
        es = self.end_state
        assert not es.emissions
        matcher = es.result
        act = tuple(matcher.to_ASCII_tree_lines())
        exp = tuple(self.expected_query_tree())
        self.assertSequenceEqual(act, exp)

    def expect_not_matches(self, *strings):
        m = self.matcher
        assert new_way_match(m, strings) is None

    def expect_matches(self, *strings):
        m = self.matcher
        mds = new_way_match(m, strings)
        assert mds
        return mds

    @property
    def matcher(self):
        return self.end_state.result

    @property
    @shared_subject_in_child_classes
    def end_state(self):
        return self.build_end_state()

    def build_end_state(self):
        listener, emissions = listener_and_emissions_for(self)
        from tag_lyfe.magnetics.query_via_token_stream import \
            EXPERIMENTAL_NEW_WAY as func
        res = func(self.given_tokens(), listener)
        return EndState(tuple(emissions), res)

    do_debug = False


class Case1070_now_error_messages_are_as_detailed_as_we_want_them(CommonCase):

    def test_010_complain_like_this(self):
        self.expect_expected_complaint_lines()

    def expected_complaint_lines(_):
        yield re.compile(r"""^Can't parse token '#bar' from after\b.+\bExpecting AND or OR\.$""")  # noqa: E501

    def given_tokens(_):
        return '#foo', '#bar'


class Case1074_look_at_this_beautiful_freaking_query_tree(CommonCase):

    def test_010_tree_looks_good(self):
        self.expect_expected_query_tree()

    def test_020_matches_when_all_tings_are_in_one_string(self):
        self.expect_matches('so #foo and #bar', 'chummy')
        self.expect_matches('chimmy chummy', '#baz and #foo!')
        self.expect_not_matches('chumbus', 'wumbus #fooz #bazz')

    def test_030_matches_when_tings_are_spread_across_strings(self):
        self.expect_matches('#ting1 #baz', 'nothing', 'top secret(#foo:yup)')
        self.expect_not_matches('#ting1 #baz', 'nothing', 'top secr(#foo_)')

    def expected_query_tree(_):
        yield "AND\n"
        yield "├──#foo\n"
        yield "└──OR\n"
        yield "  ├──#bar\n"
        yield "  └──#baz\n"

    def given_tokens(_):
        return '#foo', 'and', '(', '#bar', 'or', '#baz', ')'


class Case1078_one_tag(CommonCase):

    def test_010_tree_looks_good(self):
        self.expect_expected_query_tree()

    def test_020_matches_when_all_tings_are_in_one_string(self):
        self.expect_matches('yes', 'wahoo #foo-bar:hello', 'yup')
        self.expect_not_matches('yes', 'wahoo ##foo-bar:hello', 'yup')

    def expected_query_tree(_):
        yield "#foo-bar\n"

    def given_tokens(_):
        return ('#foo-bar',)


def new_way_match(matcher, strings):
    return matcher.matchdatas_against_strings(strings)


EndState = namedtuple('EndState', ('emissions', 'result'))


if __name__ == '__main__':
    unittest_main()

# #born
