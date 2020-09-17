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


class JumbleCase(unittest.TestCase):

    def expect_lines(self, *expected_lines):
        actual_lines = (''.join(row) for row in self.build_actual_rows())
        actual_lines = tuple(actual_lines)
        self.assertSequenceEqual(actual_lines, expected_lines)

    def expect_table(self, *expected):
        expected_stack = list(reversed(expected))
        for actual_pieces in self.build_actual_rows():
            expected_pieces = expected_stack.pop()
            self.assertSequenceEqual(expected_pieces, actual_pieces)
        self.assertEqual(len(expected_stack), 0)

    def build_actual_rows(self):
        return _subject_module().piece_rows_via_jumble(self.given_jumble())


class Case5180_jumble_titlecased_token_starts_a_new_sentence(JumbleCase):

    def test_100(self):
        self.expect_table(('One', ' ', 'love', '.'), ('One heart',))

    def given_jumble(self):
        yield 'One', 'love'
        yield 'One heart'  # NOTE this is a string not a tuple. this is to spec


class Case5181_jumble_colon_normally_adds_space_after(JumbleCase):

    def test_100(self):
        self.expect_table(('Look', ':', ' ', 'neato', ' ', 'skeeto'))

    def given_jumble(self):
        yield 'Look', ':', 'neato', 'skeeto'


class Case5182_jumble_colon_is_hacked_for_path_colon_lineno(JumbleCase):

    def test_100(self):
        self.expect_table(('Ohai some-file.pz', ':', '182'))

    def given_jumble(self):
        yield 'Ohai some-file.pz', ':', 182


class Case5185_jumble_quotes_hug_the_content(JumbleCase):

    def test_100(self):
        self.expect_lines('She said my room looked "somewhat clean".', 'Wow')

    def given_jumble(self):
        yield 'She said my room looked', '"', 'somewhat', 'clean', '"', 'Wow'


class Case5188_jumble_experimental_parenthesis_hack(JumbleCase):

    def test_100(self):
        self.expect_lines("When will 2020 end?", "(if ever)")

    def given_jumble(self):
        yield "When will 2020 end", "?", "if", "ever"


class Case5192_jumble_target_case(JumbleCase):

    def test_100(self):
        self.expect_lines(
            "Unrecognized attribute: 'thing_C'.",
            'This field does not appear in "table uno".',
            "Did you mean 'thing_B', 'thing_2' or 'hi_G'?",
            "(in some-file/123-abc.mx:345)")

    def given_jumble(self):
        yield 'Unrecognized attribute', ": 'thing_C'"
        yield 'This', 'field', 'does', 'not appear in'
        yield '"', 'table uno', '"'
        yield 'Did you mean', "'thing_B', 'thing_2' or 'hi_G'", '?'
        yield 'in', 'some-file/123-abc.mx', ':', 345


@lazy
def wrapper_two():
    return _subject_module().rotating_bufferer(
            lambda c: f'u:{c}',  # u = uninteresting
            lambda c: f'stl:{c}',  # stl = final
            lambda c: f'l:{c}',  # l = last
            lambda: 'nada')


@lazy
def wrapper_one():
    return _subject_module().rotating_bufferer(
            lambda c: f'nf:{c}',  # nf = non-final
            lambda c: f'f:{c}',  # f = final
            None)  # when empty


def _subject_module():
    import modality_agnostic.magnetics.rotating_buffer_via_positional_functions as _  # noqa: E501
    return _


if __name__ == '__main__':
    unittest.main()

# #abstracted
