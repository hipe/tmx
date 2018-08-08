"""
.:#coverpoint1.5

(see discussion at [#706.B] about what belongs here and what belongs elsewhere)
"""


import _init  # noqa: F401
from tag_lyfe_test.API_integration import (
        MemoizyCommonCase as _ThisCase,
        query_via_tokens,
        )
from modality_agnostic.memoization import (
        memoize,
        )
import unittest


_CommonCase = unittest.TestCase


class Case050_schema_row_missing_this_one_thing(_CommonCase, _ThisCase):

    def test_100_fails(self):
        self.fails()

    def test_200_says_only_this(self):
        self.says_only_this_regex(r'\bmust have `tag_lyfe_field_names`')

    def given_query(self):
        return _query_which_is_no_see()

    def given_collection_identifier(self):
        return (
                {
                    '_is_sync_meta_data': True,
                    'natural_key_field_name': 'xx_no_see',
                    },
                )


class Case075_no_rows_at_all(_CommonCase, _ThisCase):

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_says_only_this(self):
        _exp = '(nothing matched because collection was empty.)'
        self.says_only_this(_exp)

    def given_query(self):
        return _query_which_is_no_see()

    def given_collection_identifier(self):
        return (
                {
                    '_is_sync_meta_data': True,
                    'natural_key_field_name': 'xx_no_see',
                    'tag_lyfe_field_names': ('no_see_1', 'no_see_2'),
                    },
                )


class Case100_one_participating_column_match_one(_CommonCase, _ThisCase):

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_expect_match(self):
        self.expect_matches_items('item 1')

    def test_300_says_this(self):
        _exp = '(1 match(es) of 2 item(s) seen.)'
        self.says_this_one_line(_exp)

    def given_query_tokens(self):
        return ('#red',)

    def given_collection_identifier(self):
        return _collection_with_one_participating_column()


class Case150_one_participating_column_match_all(_CommonCase, _ThisCase):

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_expect_match(self):
        self.expect_matches_items('item 1', 'item 2')

    def test_300_says_this(self):
        _exp = '(all 2 item(s) matched.)'
        self.says_this_one_line(_exp)

    def given_query_tokens(self):
        return ('#red', 'or', '#blue')

    def given_collection_identifier(self):
        return _collection_with_one_participating_column()


@memoize
def _collection_with_one_participating_column():
    return (
            {
                '_is_sync_meta_data': True,
                'natural_key_field_name': 'xx_no_see',
                'tag_lyfe_field_names': ('bb',),
                },
            {
                'aa': 'item 1',
                'bb': 'this is #red.',
                },
            {
                'aa': 'item 2',
                'bb': 'this is #blue.',
                },
    )


@memoize
def _query_which_is_no_see():
    return query_via_tokens(('#x-no-see',))


if __name__ == '__main__':
    unittest.main()

# #extracted from a cousin test file
