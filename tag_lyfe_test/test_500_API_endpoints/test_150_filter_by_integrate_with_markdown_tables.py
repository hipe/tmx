"""
.:#coverpoint1.5.1

to pose a markdown-table based collection as a producer for a filter-by,
it raises an issue endemic to markdown tables that is not encountered in
bespoke producers: with markdown tables it's not easy to add arbitrary data
to its (otherwise purely inferred) collection metadata item.

because the added work would damper normal operation, we aren't going to
parse every cel of every row looking for tags. rather, we want a priori
knowledge of which fields (columns (cels)) to be looking for tags in.

we accomplish this thru [#418.2] another "example row" hack (or if you
prefer, [#418.3] "heuristic templating").

but more broadly, this sprung forth the idea of "intention" which we put
to use and give coverage here.
"""


from _init import (
        fixture_file_path,
        )
from tag_lyfe_test.API_integration import (
        MemoizyCommonCase as _ThisCase,
        query_which_is_no_see,
        query_via_tokens,
        simplify_emission_line,
        )
import unittest


_CommonCase = unittest.TestCase


class Case050_hashtag_heuristic_required(_CommonCase, _ThisCase):
    # :#coverpointTL.1.5.1.1

    def test_100_fails(self):
        self.fails()

    def test_200_first_line_says_blick(self):
        _exp = 'your example row needs at least one cel with a hashtag in it.'
        _ = self.first_line()
        self.assertEqual(_, _exp)

    def test_210_second_line_says_bleck(self):
        _ = self.second_line()
        self.assertEqual(_, "(had: 'x0', 'x1', 'x2')")

    def given_query(self):
        return query_which_is_no_see()

    def given_collection_identifier(self):
        return fixture_file_path_from_sibling('0115-stream-me.md')


class Case100_minimal_intro(_CommonCase, _ThisCase):
    # :#coverpointTL.1.5.1.2

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_expect_match(self):
        self.expect_matches_items('item 1', 'item 3')

    def test_300_says_this(self):
        _ = self.assume_exactly_one_emission_and_of_that_exactly_one_line()
        _ = simplify_emission_line(_)
        self.assertEqual(_, '2 matches of 4 items seen')

    def given_query(self):
        return query_via_tokens('#blue')

    def given_collection_identifier(self):
        return fixture_file_path('0110-blue-green-blue.md')
        # (table is last thing in file and that's OK)


class Case200_this_one_target(_CommonCase, _ThisCase):
    # :#coverpointTL.1.5.1.3

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_expect_match(self):
        self.expect_matches_items('#909.C')

    def test_300_says_this(self):
        _ = self.assume_exactly_one_emission_and_of_that_exactly_one_line()
        _ = simplify_emission_line(_)
        self.assertEqual(_, '1 matches of 5 items seen')

    def given_query(self):
        return query_via_tokens('#opin', 'and', '#important')

    def given_collection_identifier(self):
        return fixture_file_path('0120-ROIDMOI.md')


def fixture_file_path_from_sibling(path):  # crazy
    from sakin_agac_test._init import fixture_file_path as _
    return _(path)


if __name__ == '__main__':
    unittest.main()

# #born.
