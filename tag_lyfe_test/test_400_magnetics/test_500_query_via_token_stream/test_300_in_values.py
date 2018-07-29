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

.:#coverpoint1.13
"""


from _init import (
        ScaryCommonCase,
        )
import unittest


_CommonCase = unittest.TestCase


class Case100(_CommonCase, ScaryCommonCase):

    def given_tokens(self):
        return ('#foo', 'in', '(', 'bar', 'baz', 'quux', ')', 'xx')

    def test_100_query_compiles(self):
        self.query_compiles()

    def test_150_unparses(self):
        self.unparses_to('#foo in ( bar baz quux )')

    def test_200_not_matches_if_the_tag_is_not_there(self):
        # :#coverpoint1.13.2
        self.does_not_match_against(('#fux',))

    def test_225_not_matches_if_the_tag_has_no_value(self):
        # :#coverpoint1.13.3
        self.does_not_match_against(('#foo',))

    def test_250_not_matches_if_the_tag_has_outside_value(self):
        # :#coverpoint1.13.4
        self.does_not_match_against(('#foo:quuxo',))

    def test_300_yes_matches_simple(self):
        # :#coverpoint1.13.5
        self.matches_against(('#foo:quux',))

    def test_325_yes_ALSO_matches_if_tagging_is_deeper_than_query(self):
        # :#coverpoint1.13.6
        self.matches_against(('#foo:quux:fizzo',))


if __name__ == '__main__':
    unittest.main()

# #born.
