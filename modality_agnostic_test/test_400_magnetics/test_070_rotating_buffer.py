import _init  # noqa: F401
from modality_agnostic.memoization import lazy
import doctest
import unittest


def load_tests(loader, tests, ignore):  # (this is a unittest API hook-in)
    tests.addTests(doctest.DocTestSuite(_subject_module()))
    # `oxford_join` hi.
    return tests


class _WrapperCase(unittest.TestCase):

    def do_test(self):
        _wrapper = self.given_wrapper()
        _argument = iter(self.given())
        _itr = _wrapper(_argument)
        _actual = tuple(_itr)
        _expected = self.expect()
        self.assertSequenceEqual(_actual, _expected)


class _WrapperTwoCase(_WrapperCase):

    def given_wrapper(self):
        return wrapper_two()


class _WrapperOneCase(_WrapperCase):

    def given_wrapper(self):
        return wrapper_one()


class Case5129_typical(_WrapperTwoCase):

    def test(self):
        self.do_test()

    def expect(self):
        return ('u:A', 'u:B', 'u:C', 'u:D', 'u:E', 'stl:F', 'l:G')

    def given(self):
        return ('A', 'B', 'C', 'D', 'E', 'F', 'G')


class Case5135_three(_WrapperTwoCase):

    def test(self):
        self.do_test()

    def expect(self):
        return ('u:A', 'stl:B', 'l:C')

    def given(self):
        return ('A', 'B', 'C')


class Case5141_two(_WrapperTwoCase):

    def test(self):
        self.do_test()

    def expect(self):
        return ('stl:A', 'l:B')

    def given(self):
        return ('A', 'B')


class Case5147_one(_WrapperTwoCase):

    def test(self):
        self.do_test()

    def expect(self):
        return ('l:A',)

    def given(self):
        return ('A',)


class Case5153_two(_WrapperOneCase):

    def test(self):
        self.do_test()

    def expect(self):
        return ('nf:A', 'f:B')

    def given(self):
        return ('A', 'B')


class Case5159_one(_WrapperOneCase):

    def test(self):
        self.do_test()

    def expect(self):
        return ('f:A',)

    def given(self):
        return ('A',)


class Case5165_zero_when_no_callback(_WrapperOneCase):

    def test(self):
        self.do_test()

    def expect(self):
        return ()

    def given(self):
        return ()


class Case5171_zero_when_yes_callback(_WrapperTwoCase):

    def test(self):
        self.do_test()

    def expect(self):
        return ('nada',)

    def given(self):
        return ()


class Case5177_oxford_join_hand_written_unit_test(unittest.TestCase):

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
        _actual = oxford_OR(iter(given_tuple))
        self.assertEqual(_actual, expected_string)


@lazy
def wrapper_two():
    return _subject_module().rotating_bufferer(
            lambda c: f'u:{c}',  # u = uninteresting
            lambda c: f'stl:{c}',  # stl = final
            lambda c: f'l:{c}',  # l = last
            lambda: 'nada'
            )


@lazy
def wrapper_one():
    return _subject_module().rotating_bufferer(
            lambda c: f'nf:{c}',  # nf = non-final
            lambda c: f'f:{c}',  # f = final
            None,  # when empty
            )


def _subject_module():
    import modality_agnostic.magnetics.rotating_buffer_via_positional_functions as _  # noqa: E501
    return _


if __name__ == '__main__':
    unittest.main()

# #abstracted
