"""
querying for "values":

  - `#foo:bar` is a query that searches for taggings of `#foo:bar`.

  - in the above example, the surface representation of the query is the
    same as that of the tagging; but don't assume this holds for all queries
    and all of their matching taggings. (we're leaving some room here.)

  - currently a more general query will match a more specific tagging:

    if the query is for example `#food:fruit` and the item is tagged with
    `#food:fruit:tomato`, then yes this is a match; a tomato is (in this
    taxonomy) a fruit. i.e:

        #food:fruit:tomato ∈ #food:fruit

    (:#coverpoint1.16.3)

  - but the reverse is not true. a more specific query will not match a
    more generally tagged item. a query for `#car:ford:f-series` will not
    match an item simply tagged with `#car`. (yes you could take a fuzzy
    guess that the item might match but we aren't doing fuzzy matching yet :P)
    (:#coverpoint1.16.2)

  - note we have gotten this far without having the queries and taggings
    (variously) model "name-value pairs". one perspective is that it's sort
    of a Shrödinger's choice: a query that looks like a name-value pair can
    be searching for a tagging that *is* a name-value pair or, alternatetly,
    it can match that head-anchored segment of a deeper tagging.

    but a perhaps more insightful take is that for taggings and queries
    alike there are no name-value pairs per se: but rather there are only
    deep nodes and terminal nodes. (this simplified view will leak as an
    abstraction near [#707.E] when we flesh out quoted string values and
    related. or maybe it won't)
"""

from tag_lyfe_test.query import ScaryCommonCase
import unittest


_CommonCase = unittest.TestCase


class Case100_two_deep(_CommonCase, ScaryCommonCase):

    def given_tokens(self):
        return ('#foo:bar', 'xx')

    def test_100_query_compiles(self):
        self.query_compiles()

    def test_150_unparses(self):
        self.unparses_to('#foo:bar')

    def test_200_against_shallower_does_not_match(self):
        self.does_not_match_against(('#foo',))

    def test_217_against_deep_but_first_component_not_match(self):
        self.does_not_match_against(('#fiz:bar',))

    def test_225_against_near_does_not_match(self):
        self.does_not_match_against(('#foo:barr',))

    def test_250_against_same_matches(self):
        self.matches_against(('#foo:bar',))

    def test_275_against_more_specific_matches(self):  # #coverpoint1.16.3
        self.matches_against(('#foo:bar:baz',))


class Case200_three_deep(_CommonCase, ScaryCommonCase):

    def given_tokens(self):
        return ('#foo:bar:baz', 'xx')

    def test_100_query_compiles(self):
        self.query_compiles()

    def test_150_unparses(self):
        self.unparses_to('#foo:bar:baz')

    def test_200_against_shallower_does_not_match(self):
        self.does_not_match_against(('#foo:bar',))

    def test_225_against_near_does_not_match(self):
        self.does_not_match_against(('#foo:bar:bazz',))

    def test_250_against_same_matches(self):
        self.matches_against(('#foo:bar:baz',))

    def test_275_against_more_specific_matches(self):
        self.matches_against(('#foo:bar:baz:boffo',))


if __name__ == '__main__':
    unittest.main()

# #born.
