"""
introduce parenthesized group

.:#coverpoint1.10
"""


import _init  # noqa: F401
from tag_lyfe_test.query import (
        ScaryCommonCase,
        )
import unittest


_CommonCase = unittest.TestCase


class Case100(_CommonCase, ScaryCommonCase):

    def given_tokens(self):
        return ('#foo', 'and', '(', '#bar', 'or', '#baz', ')', 'xx')

    def test_100_query_compiles(self):
        self.query_compiles()

    def test_150_unparses(self):
        self.unparses_to('#foo and ( #bar or #baz )')

    def test_200_no(self):
        self.does_not_match_against(('#baf', '#foo'))

    def test_300_yes(self):
        self.matches_against(('#baz', '#foo'))


if __name__ == '__main__':
    unittest.main()

# #born.
