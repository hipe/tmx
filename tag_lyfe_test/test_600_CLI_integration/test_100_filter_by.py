"""
.:#coverpoint1.7
"""


from _init import (
        memoize,
        )
from tag_lyfe_test.CLI_integration import (
        MemoizyCommonCase as _ThisCase,
        )
import unittest


_CommonCase = unittest.TestCase


# test help screen
# test no args after query
# test extra args after query


class Case050_schema_row_missing_this_one_thing(_CommonCase, _ThisCase):

    def test_100_fails(self):
        self.fails()

    def test_200_says_only_this(self):
        self.says_only_this_regex(r'\bmust have `tag_lyfe_field_names`')

    def given_query_tokens(self):
        return ('#x-no-see',)

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
        _exp = '(nothing matched because collection was empty.)\n'
        self.says_only_this(_exp)

    def given_query_tokens(self):
        return ('#x-no-see',)

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
        _exp = '(1 match(es) of 2 item(s) seen.)\n'
        self.says_this_one_line(_exp)

    def given_query_tokens(self):
        return ('#red',)

    def given_collection_identifier(self):
        return _collection_with_one_participating_column()


class Case100_one_participating_column_match_all(_CommonCase, _ThisCase):

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_expect_match(self):
        self.expect_matches_items('item 1', 'item 2')

    def test_300_says_this(self):
        _exp = '(all 2 item(s) matched.)\n'
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


if __name__ == '__main__':
    unittest.main()

# #born.
