from modality_agnostic.memoization import (
    dangerous_memoize as shared_subject)
import unittest


class CommonCase(unittest.TestCase):

    def build_result_lines(self):
        given = _Given()
        self.given(given.initialize)
        from script_lib.magnetics.via_words import (
                fixed_shape_word_wrapperer as word_wrapperer)
        ww = word_wrapperer(
                row_max_widths=given.row_max_widths,
                ellipsis_string=given.ellipsis_string)
        return _ResultLines(ww(big_string=given.big_string))


class Case3735_when_end_of_line_hits_mid_word(CommonCase):

    def test_100_it_wraps_to_the_next_line(self):
        o = self.result_lines
        self.assertEqual(o.first_line.index('One Two'), 0)
        self.assertEqual(o.second_line.index('Three'), 0)

    def test_200_the_result_lines_are_NOT_padded_with_trailing_spaces(self):
        o = self.result_lines
        self.assertNotIn('Two ', o.first_line)
        self.assertNotIn('Three ', o.second_line)

    def test_300_the_result_lines_are_NOT_newline_terminated(self):
        o = self.result_lines
        self.assertNotEqual(o.first_line[-1], '\n')
        self.assertNotEqual(o.second_line[-1], '\n')

    @shared_subject
    def result_lines(self):
        return self.build_result_lines()

    def given(self, given):
        given(
                big_string='One Two Three',
                row_max_widths=(9, 9),
                )


class Case3738_when_it_lands_right_on_the_money(CommonCase):

    def test_100_ok(self):
        o = self.build_result_lines()
        self.assertSequenceEqual(o.lines, ('Aaa B Ccc',))
        return o

    def given(self, given):
        given(
                big_string='Aaa B Ccc',
                row_max_widths=(9,),
                )


class Case3742_when_a_leftmost_word_would_put_you_over(CommonCase):

    def test_100_it_gets_to_break_the_constraint(self):
        o = self.build_result_lines()
        self.assertSequenceEqual(o.lines, ('Aaa', 'Bbbbbb', 'Ccc'))

    def given(self, given):
        given(
                big_string='Aaa Bbbbbb Ccc',
                row_max_widths=(5, 5, 5),
                )


class Case3745_ellipsis_when_room(CommonCase):

    def test_100_appends(self):
        o = self.build_result_lines()
        self.assertSequenceEqual(o.lines, ('Aa Bb', 'C D..'))

    def given(self, given):
        given(
                big_string='Aa Bb C D Ee Fff NO_SEE',
                row_max_widths=(6, 5),
                ellipsis_string='..',
                )


class Case3748_ellipsis_when_replace(CommonCase):

    def test_100_replaces_while_breaking_constraint_because_lazy(self):
        o = self.build_result_lines()
        self.assertSequenceEqual(o.lines, ('Aa Bb', 'C...'))

    def given(self, given):
        given(
                big_string='Aa Bb C D Ee',
                row_max_widths=(6, 3),
                ellipsis_string='...',
                )


# Case3750  # #midpoint


class Case3751_no_room_and_only_one_item_on_last_line(CommonCase):

    def test_100_drops_last_line_and_append(self):
        o = self.build_result_lines()
        self.assertSequenceEqual(o.lines, ('Aa Bb...',))

    def given(self, given):
        given(
                big_string='Aa Bb CCC NO_SEE',
                row_max_widths=(8, 3),
                ellipsis_string='...',
                )


class Case3754_no_room_on_second_to_last(CommonCase):

    def test_100_drops_last_line_and_replace(self):
        o = self.build_result_lines()
        self.assertSequenceEqual(o.lines, ('Aa..',))

    def given(self, given):
        given(
                big_string='Aa Bb CCC NO_SEE',
                row_max_widths=(6, 3),
                ellipsis_string='..',
                )


class Case3757_last_resort(CommonCase):

    def test_100_makes_some_line_violate_the_constraint(self):
        o = self.build_result_lines()
        self.assertSequenceEqual(o.lines, ('Aaaaa', 'Bbbbb…'))

    def given(self, given):
        given(
                big_string='Aaaaa Bbbbb C',
                row_max_widths=(5, 5),
                ellipsis_string='…',
                )


class Case3760_empty_string(CommonCase):

    def test_100_WAT(self):
            o = self.build_result_lines()
            self.assertSequenceEqual(o.lines, ())

    def given(self, given):
        given(
                big_string='',
                row_max_widths=(1, 2, 3),
                )


# == support

class _Given:

    def __init__(self):
        self._mutex = None

    def initialize(self, big_string, row_max_widths, ellipsis_string=None):
        del self._mutex
        self.big_string = big_string
        self.row_max_widths = row_max_widths
        self.ellipsis_string = ellipsis_string


class _ResultLines:

    def __init__(self, itr):
        tup = tuple(itr)
        length = len(tup)
        rang = range(0, length)
        self._states = ['_read_initially' for _ in rang]
        self._values = [None for _ in rang]
        self._structured_lines = tup
        self.num_lines = length

    @property
    def first_line(self):
        return self.line_at_offset(0)

    @property
    def second_line(self):
        return self.line_at_offset(1)

    @property
    def third_line(self):
        return self.line_at_offset(2)

    @property
    def lines(self):
        return tuple(self.line_at_offset(i) for i in range(0, self.num_lines))

    def line_at_offset(self, offset):
        _method = self._states[offset]
        return getattr(self, _method)(offset)

    def _read_initially(self, offset):
        self._states[offset] = '_read_subsequently'
        self._values[offset] = self._structured_lines[offset].to_string()
        return self.line_at_offset(offset)

    def _read_subsequently(self, offset):
        return self._values[offset]


if __name__ == '__main__':
    unittest.main()

# #born.
