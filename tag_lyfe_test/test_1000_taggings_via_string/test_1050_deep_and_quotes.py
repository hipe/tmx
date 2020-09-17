"""
the salient features of the grammar demonstrated here:

  - double-quoted strings as name components (with one escape sequence)
  - same as non-tail nodes
"""

from tag_lyfe_test.tagging import TaggingCommonCasePlusMemoization as ThisCase
import unittest


class CommonCase(unittest.TestCase):

    def _name_component(self):
        return self._the_tagging().root_node.child._name_component

    def _the_tagging(self):
        return self.end_state[0].tagging


class Case1020_minimal_name_value(CommonCase, ThisCase):

    def given_string(self):
        return '#foo:bar'

    def test_100_shadow(self):
        self.expect_shadow('TTTTTTTT')


class Case1030_oh_boy_quotes(CommonCase, ThisCase):

    def given_string(self):
        return 'foo:(#bar:"wow" neat)'

    def test_050_the_surface_string_has_the_quotes(self):
        _act = self._name_component()._surface_string()
        self.assertEqual('"wow"', _act)

    def test_075_the_deep_string_has_no_quotes(self):
        _act = self._name_component()._deep_string()
        self.assertEqual('wow', _act)

    def test_100_expect_shadow(self):
        self.expect_shadow('sssssTTTTTTTTTTssssss')


class Case1040_double_quotes_can_escape_and_be_parent(CommonCase, ThisCase):

    def given_string(self):
        return '#foo:"mom\'s spaghetti: i \\"love\\" it":77'

    def test_050_the_surface_string_has_the_quotes_and_escapes(self):
        _exp = '"mom\'s spaghetti: i \\"love\\" it"'
        _act = self._name_component()._surface_string()
        self.assertEqual(_act, _exp)

    def test_075_the_deep_string_has_no_quotes(self):
        _exp = 'mom\'s spaghetti: i "love" it'
        _act = self._name_component()._deep_string()
        self.assertEqual(_act, _exp)

    def test_085_the_whole_tagging_rebuilds(self):
        _exp = '#foo:"mom\'s spaghetti: i \\"love\\" it":77'
        _act = self._the_tagging().to_string()
        self.assertEqual(_act, _exp)


if __name__ == '__main__':
    unittest.main()

# #born.
