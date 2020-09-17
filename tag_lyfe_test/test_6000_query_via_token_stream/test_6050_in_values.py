"""
introduce `in ( foo bar baz )`

Discussion: this is the first grammatical element that we imagine as a
"plugin". the biggest obstacle to fully realizing a plugin architecture here
is how non-trivial it would be to have features integrate into the grammar
in a modular way (especially the upcoming regexes..). later or never for that.

oh but the point: we would move this test to a dedicated node (folder) just
for such extensions at such time; but as long as extensions are't really
supported formally; we'll keep this test in the same line as the others for
consistency and regression aesthetics.
"""

from tag_lyfe_test.query import ScaryCommonCase
import unittest


class CommonCase(unittest.TestCase):


# Case6020 is below

# Case6030 is below


class Case6040(CommonCase, ScaryCommonCase):  # #midpoint

    def given_tokens(self):
        return ('#foo', 'in', '(', 'bar', 'baz', 'quux', ')', 'xx')

    def test_100_query_compiles(self):
        self.query_compiles()

    def test_150_unparses(self):
        self.unparses_to('#foo in ( bar baz quux )')

    def test_200_not_matches_if_the_tag_is_not_there(self):  # :(Case6020)
        self.does_not_match_against(('#fux',))

    def test_225_not_matches_if_the_tag_has_no_value(self):  # :(Case6030)
        self.does_not_match_against(('#foo',))

    def test_250_not_matches_if_the_tag_has_outside_value(self):  # :(Case6040)
        self.does_not_match_against(('#foo:quuxo',))

    def test_300_yes_matches_simple(self):  # :(Case6050)
        self.matches_against(('#foo:quux',))

    def test_325_yes_ALSO_matches_if_tagging_is_deeper_than_query(self):
        # :(Case6060)
        self.matches_against(('#foo:quux:fizzo',))


# Case6050 is above

# Case6060 is above


if __name__ == '__main__':
    unittest.main()

# #history-A.1: no more coverpoints
# #born.
