"""
.:#coverpoint1.7

(see discussion at [#706.B] about what belongs here and what belongs elsewhere)
"""


import _init  # noqa: F401
from tag_lyfe_test.CLI_integration import (
        MemoizyCommonCase as _ThisCase,
        )
from modality_agnostic.memoization import (
        memoize,
        )
import unittest


_CommonCase = unittest.TestCase


class Case025_help_screen(_CommonCase, _ThisCase):

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_hallo(self):
        only_section, = self.end_state().sections
        one_big_string, = only_section.lines
        _exp = 'filter the input rows by'
        self.assertIn(_exp, one_big_string)

    def given_query_tokens(self):
        return ()  # tricky

    def given_collection_identifier(self):
        return '--hel'  # tricky


class Case050_extra_args_after_query(_CommonCase, _ThisCase):

    def test_100_fails(self):
        self.fails()

    def test_200_says(self):
        _exp = r'\bunrecognized arguments: arg2 arg3\b'
        self.says_this_as_message_line_regex(_exp)

    def test_250_usage_line(self):
        self.expect_usage_line()

    def given_query_tokens(self):
        return ('#foo', 'arg1', 'arg2')

    def given_collection_identifier(self):
        return ('arg3')


class Case075_no_args_after_query(_CommonCase, _ThisCase):  # :#coverpoint1.7.2

    def test_100_fails(self):
        self.fails()

    def test_200_says(self):
        _exp = 'expecting query or <collection-identifier>\n'
        self.says_only_this(_exp)

    def given_query_tokens(self):
        return ()

    def given_collection_identifier(self):
        return None


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

# #history-A.1: exodus of some tests to the API endpoint suite
# #born.
