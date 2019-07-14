"""
introduce `in <range>`

see the note at #coverpoint1.13 about how we want this to be more plug-inable.

see towards the end of the file of smatterings of not implemeted things

we might never use this feature, but it's an OCD contact exercise

:#coverpoint1.12
"""

from tag_lyfe_test.query import ScaryCommonCase
import unittest


_CommonCase = unittest.TestCase


class Case050_bad_range(_CommonCase, ScaryCommonCase):

    def given_tokens(self):
        return ('#foo', 'in', '13..12')

    def test_100_fails(self):
        self.fails()

    def test_200_says_this(self):
        self.says('end must be greater than beginning (13 is not less than 12)')  # noqa: E501

    def test_300_points_at_the_one_place(self):
        return self.point_at_word('13..12')


class Case100_good_range(_CommonCase, ScaryCommonCase):

    def given_tokens(self):
        return ('#foo', 'in', '12..14', 'xx')

    def test_100_query_compiles(self):
        self.query_compiles()

    def test_150_unparses(self):
        self.unparses_to('#foo in 12..14')

    def test_200_not_a_number(self):  # :#coverpoint1.12.2
        self.does_not_match_against(('#foo:bar',))

    def test_210_a_number_plus_alpha(self):
        self.does_not_match_against(('#foo:13gen',))

    def test_220_under(self):  # :#coverpoint1.12.3
        self.does_not_match_against(('#foo:11',))

    def test_230_at_lower_boundary(self):
        self.matches_against(('#foo:12',))

    def test_240_inside(self):
        self.matches_against(('#foo:13',))

    def test_250_at_upper_boundary(self):
        self.matches_against(('#foo:14',))

    def test_260_above(self):  # :#coverpoint1.12.4
        self.does_not_match_against(('#foo:15',))


class Case200_float(_CommonCase, ScaryCommonCase):  # :#coverpoint1.12.5

    def given_tokens(self):
        return ('#foo', 'in', '12.5..13.7')

    def test_120_against_float(self):
        self.matches_against(('#foo:12.5',))

    def test_130_against_int(self):
        self.matches_against(('#foo:13',))

    def test_220_under(self):
        self.does_not_match_against(('#foo:12.4',))

    def test_230_at_lower_boundary(self):
        self.matches_against(('#foo:12.5',))

    def test_240_inside(self):
        self.matches_against(('#foo:12.6',))

    def test_250_at_upper_boundary(self):
        self.matches_against(('#foo:13.7',))

    def test_260_above(self):
        self.does_not_match_against(('#foo:13.8',))


# negatives

# unbounded lower

# unbounded upper

# exclusive (not inclusive) for end


if __name__ == '__main__':
    unittest.main()

# #born.
