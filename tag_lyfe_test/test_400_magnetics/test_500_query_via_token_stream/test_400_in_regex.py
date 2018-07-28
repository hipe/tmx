"""
introduce `in <regex>`

see the note at #coverpoint1.13 about how we want this to be more plug-inable.

significant here will be how we hackishly avoid x

:#coverpoint1.11
"""


from _init import (
        ScaryCommonCase,
        )
import unittest


class _CommonCase(unittest.TestCase):
    pass


class Case050_bad_regex__no_endthing(_CommonCase, ScaryCommonCase):

    def given_tokens(self):
        return ('#foo', 'in', '/bar')

    def test_100_fails(self):
        self.fails()

    def test_200_says_this(self):
        self.says("no ending delimiter found. expecting '/'")

    def test_300_points_at_the_one_place(self):
        #   '#foo in /bar'
        s = '------------^'
        return self.point_at_offset(len(s) - 1)


class Case062_empty_regexp(_CommonCase, ScaryCommonCase):

    def given_tokens(self):
        return ('#foo', 'in', '//')

    def test_100_fails(self):
        self.fails()

    def test_200_says_this(self):
        self.says("empty regex not allowed")

    def test_300_points_at_the_one_place(self):
        #   '#foo in //'
        s = '---------^'
        return self.point_at_offset(len(s) - 1)


class Case075_bad_regex(_CommonCase, ScaryCommonCase):

    def given_tokens(self):
        return ('#foo', 'in', '/bar[/')

    def test_100_fails(self):
        self.fails()

    def test_200_says_this(self):
        # NOTE - this language comes from the regex engine. not us."""
        self.says('unterminated character set at position 3')

    def test_300_points_at_the_one_place(self):
        return self.point_at_offset(12)
        # '#foo in /bar[/'
        # '------------^'


class Case100_good_regex(_CommonCase, ScaryCommonCase):

    def given_tokens(self):
        return ('#foo', 'in', '/^b(ar|az)$/', 'xx')

    def test_100_query_compiles(self):
        self.query_compiles()

    def test_150_unparses(self):
        self.unparses_to('#foo in /^b(ar|az)$/')

    def test_200_not_match(self):  # :#coverpoint1.11.2
        self.does_not_match_against(('#foo:barr',))

    def test_250_yes_match(self):
        self.matches_against(('#foo:baz',))


if __name__ == '__main__':
    unittest.main()

# #born.
