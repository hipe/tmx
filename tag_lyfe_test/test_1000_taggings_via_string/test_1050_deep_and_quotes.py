"""
the salient features of the grammar demonstrated here:

  - double-quoted strings as name components (with one escape sequence)
  - same as non-tail nodes
"""

from tag_lyfe_test.tagging import TaggingCommonCasePlusMemoization as ThisCase
import unittest


class CommonCase(unittest.TestCase):

    def surface_string(self):
        dqs = self.double_quoted_string()
        return dqs._to_string()  # should have the quotes

    def deep_string(self):
        pcs = []
        for ch in self.double_quoted_string().alternating_pieces:
            typ = ch._type
            if 'raw_string' == typ:
                pcs.append(ch.self_which_is_string)
            else:
                'escaped_character' == typ
                pcs.append(ch.unescaped_character)
        return ''.join(pcs)

    def double_quoted_string(self):
        ch = self.subcomponents()[0]  # in (Case1040) there's >1 but we want 0
        bo = ch.body_slot
        assert 'double_quoted_string' == bo._type
        return bo

    def subcomponents(self):
        return self.the_tagging().subcomponents

    def the_tagging(self):
        return self.end_state.doc_pairs[0].tag


def pieces(cx, first, subsequent):
    yield first(cx[0])  # ..
    for i in range(1, len(cx)):
        yield subsequent(cx[i])


class Case1020_minimal_name_value(CommonCase, ThisCase):

    def given_string(self):
        return '#foo:bar'

    def test_100_shadow(self):
        self.expect_shadow('TTTTTTTT')


class Case1030_oh_boy_quotes(CommonCase, ThisCase):

    def given_string(self):
        return 'foo:(#bar:"wow" neat)'

    def test_050_the_surface_string_has_the_quotes(self):
        _act = self.surface_string()
        self.assertEqual('"wow"', _act)

    def test_075_the_deep_string_has_no_quotes(self):
        _act = self.deep_string()
        self.assertEqual('wow', _act)

    def test_100_expect_shadow(self):
        self.expect_shadow('sssssTTTTTTTTTTssssss')


class Case1040_double_quotes_can_escape_and_be_parent(CommonCase, ThisCase):

    def given_string(self):
        return '#foo:"mom\'s spaghetti: i \\"love\\" it":77'

    def test_050_the_surface_string_has_the_quotes_and_escapes(self):
        _exp = '"mom\'s spaghetti: i \\"love\\" it"'
        _act = self.surface_string()
        self.assertEqual(_act, _exp)

    def test_075_the_deep_string_has_no_quotes(self):
        _exp = 'mom\'s spaghetti: i "love" it'
        _act = self.deep_string()
        self.assertEqual(_act, _exp)

    def test_085_the_whole_tagging_rebuilds(self):
        _exp = '#foo:"mom\'s spaghetti: i \\"love\\" it":77'
        _act = self.the_tagging()._to_string()
        self.assertEqual(_act, _exp)


if __name__ == '__main__':
    unittest.main()

# #born.
