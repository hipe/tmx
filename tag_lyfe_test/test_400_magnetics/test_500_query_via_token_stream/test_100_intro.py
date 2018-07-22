"""
## objectives, requirements and provisions (all subject to change)

broadly, our high-level objectives are to suss-out our main big unknowns:

  - can we stop at garbage? like, can we have greedy parsing with no
    '$' endpoint marker in the grammar? and then..

  - if yes above, after this parse can we reliably see "the rest" of the
    input stream (ARGV tokens) for our more traditional argv parsing?

  - how are we going to integrate error expressions with column traces with
    exceptions thrown from the generated parser etc?

  - is this null byte hack really going to work? (more below at #here1)


experimental new provisions:

  - stack countdown number as testpoint identifier (see [#704.B])
"""


from _init import (
        ScaryCommonCase,
        )
from modality_agnostic.memoization import (
        memoize,
        )
import unittest


class _CommonCase(unittest.TestCase):

    def _la_la(self, left, right):
        return f"can't change from '{left}' to '{right}' at the same level (use parens)"  # noqa: E501


class Case100_cant_switch_from_AND_to_OR(_CommonCase, ScaryCommonCase):

    def test_050_hi(self):
        self.assertIsNotNone(_subject_magnetic())

    def given_tokens(self):
        return ('#one', 'and', '#two', 'or', '#three', 'xx')

    def test_100_fails(self):
        self.fails()

    def test_200_says_this(self):
        return self.says(self._la_la('and', 'or'))

    def test_300_points_at_this_word(self):
        return self.point_at('or')


class Case200_cant_switch_from_OR_to_AND(_CommonCase, ScaryCommonCase):

    def given_tokens(self):
        return ('#one', 'or', '#two', 'and', '#three', 'xx')

    def test_100_fails(self):
        self.fails()

    def test_200_says_this(self):
        return self.says(self._la_la('or', 'and'))

    def test_300_points_at_this_word(self):
        return self.point_at('and')


class Case300_minimal_OR(_CommonCase, ScaryCommonCase):

    def given_tokens(self):
        return ('#one', 'or', '#two')

    def test_100_query_compiles(self):
        self.query_compiles()

    def test_200_against_other_tag_does_not_match(self):
        self.does_not_match_against(('#tres',))

    def test_300_against_one_tag_matches(self):
        self.matches_against(('#two',))


class Case400_minimal_AND(_CommonCase, ScaryCommonCase):

    def given_tokens(self):
        return ('#one', 'and', '#two')

    def test_100_query_compiles(self):
        self.query_compiles()

    def test_200_against_one_tag_does_not_match(self):
        self.does_not_match_against(('#one',))

    def test_200_against_both_tags_matches(self):
        self.matches_against(('#one', '#two'))

    def test_300_against_both_tags_and_another_matches(self):
        self.matches_against(('#one', '#tres', '#two'))


class Case500_lone_tag(_CommonCase, ScaryCommonCase):

    def given_tokens(self):
        return ('#one',)

    def test_100_query_compiles(self):
        self.query_compiles()

    def test_100_against_not_this_does_not_match(self):
        self.does_not_match_against(('#tres',))

    def test_200_against_yes_this_does_match(self):
        self.matches_against(('#one',))

    def test_300_against_this_and_others_mathes(self):
        self.matches_against(('#tres', '#one'))


@memoize
def _subject_magnetic():
    import tag_lyfe as x  # NOTE
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
