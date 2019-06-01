import _init  # noqa: F401
import doctest
import unittest


def load_tests(loader, tests, ignore):  # (this is a unittest API hook-in)
    tests.addTests(doctest.DocTestSuite(_subject_module()))
    # `oxford_join` hi.
    return tests


_CommonCase = unittest.TestCase


class Case180_oxford_join_variant_B(_CommonCase):

    # (at #tombstone-A.1 we severed this production but still want it)

    def test_000_zero_items_OK(self):
        self.expect((), 'nothing')

    def test_010_one_item_OK(self):
        self.expect(('hi there',), 'hi there')

    def test_020_two_items_OK(self):
        self.expect(('eenie', 'meenie'), 'eenie or meenie')

    def test_030_three_items_OK(self):
        self.expect(('A', 'B', 'C'), 'A, B or C')

    def test_040_four_items_OK(self):
        self.expect(('A', 'B', 'C', 'D'), 'A, B, C or D')

    def expect(self, given_tuple, expected_string):
        from modality_agnostic.magnetics.rotating_buffer_via_positional_functions import (  # noqa: E501
                oxford_OR)
        _actual = oxford_OR(given_tuple)
        self.assertEqual(_actual, expected_string)


def _subject_module():
    import modality_agnostic.magnetics.rotating_buffer_via_positional_functions as _  # noqa: E501
    return _


if __name__ == '__main__':
    unittest.main()

# #abstracted
