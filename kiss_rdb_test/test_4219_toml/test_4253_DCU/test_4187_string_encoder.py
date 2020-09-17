from kiss_rdb_test.common_initial_state import unindent
import modality_agnostic.test_support.common as ts
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject, lazy
import unittest


"""The string encoder's responsibility is to take an input string and decide

whether and how it will be represented in storage. This involves decisions
like whether a string should be represented as multi-line or not, whether it
has characters that need escaping (and if so what kind of surface string
should be used), and whether the string's content exceeds our "threshold of
simplicity" (to coin a term).

This scope of conern is orthogonal to canon compliance, being at a lower level.
"""


class CommonCase(unittest.TestCase):

    # -- assertion

    def whines_talkinbout(self, expected_reason):
        _actual = self.expect_input_error_structure_reason()
        self.assertEqual(_actual, expected_reason)

    # -- assertion support

    def message_head(self):
        head, tail = self.message_head_and_tail
        return head

    def message_tail(self):
        head, tail = self.message_head_and_tail
        return tail

    def message_head_and_tail_commonly(self):
        actual = self.expect_input_error_structure_reason()
        first = actual.index('. ')
        _head = actual[0:(first + 1)]
        _tail = actual[(first + 2):]
        return _head, _tail

    def expect_had_no_special_characters(self):
        self.assertEqual(self._has_special_chars(), False)

    def expect_had_special_characters(self):
        self.assertEqual(self._has_special_chars(), True)

    def _has_special_chars(self):
        return self.encoding_plan.has_special_characters

    def expect_encodes_as_multi_line_string(self):
        self.assertGreaterEqual(self._number_of_lines(), 2)

    def expect_encodes_as_single_line_string(self):
        self.assertEqual(self._number_of_lines(), 1)

    def _number_of_lines(self):
        return len(self.semi_encoded_lines())

    def semi_encoded_lines(self):
        return self.encoding_plan.semi_encoded_lines

    # -- execution & direct derivatives

    def expect_input_error_structure_reason(self):
        sct = self.expect_input_error_structure()
        self.assertIsInstance(sct.pop('line'), str)
        res = sct.pop('reason')
        self.assertEqual(len(sct), 0)
        return res

    def expect_input_error_structure(self):
        listener, emissions = ts.listener_and_emissions_for(self, limit=1)
        self.assertIsNone(self.execute(listener))
        emi, = emissions
        chan = emi.channel
        self.assertSequenceEqual(chan, ('error', 'structure', 'input_error'))
        return emi.payloader()

    def build_encoding_plan_expecting_success(self):
        x = self.execute()
        self.assertIsNotNone(x)
        return x

    def execute(self, listener=None):
        _big_s = self.given_big_string()
        return _common_subject().encode(_big_s, listener)

    do_debug = False


class Case4181_basics(CommonCase):

    def test_100_this_library_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_200_this_thing(self):
        self.assertIsNotNone(_common_subject())


class Case4182_empty_string(CommonCase):

    def test_100_no_lines(self):
        _ = self.semi_encoded_lines()
        self.assertSequenceEqual(_, ())

    def test_200_had_no_special_characters(self):
        self.expect_had_no_special_characters()

    @shared_subject
    def encoding_plan(self):
        return self.build_encoding_plan_expecting_success()

    def given_big_string(self):
        return ''


class Case4183_first_line_too_long(CommonCase):

    def test_100(self):
        self.whines_talkinbout(
                f'string is 90 characters long. cannot exceed {_limit}.')

    def given_big_string(self):
        return _ninety_character_long_string


class Case4184_non_first_line_too_long(CommonCase):

    def test_100(self):
        self.assertEqual(
                self.message_head(),
                'line 2 of multi-line string is 91 characters long.')

    def test_200(self):
        self.assertEqual(
                self.message_tail(),
                f'cannot exceed {_limit}.')

    @shared_subject
    def message_head_and_tail(self):
        return self.message_head_and_tail_commonly()

    def given_big_string(self):
        def these():
            yield 'xx\n'
            yield f'{_ninety_character_long_string}\n'
            yield 'no see\n'

        return ''.join(these())


class Case4185_too_many_lines(CommonCase):

    def test_100(self):
        self.whines_talkinbout(
                'multi-line string cannot exceed 3 lines (had 4).')

    def given_big_string(self):
        return ''.join(unindent("""
                aa
                bb
                cc
                dd
                """))


class Case4187_character_to_avoid_for_now(CommonCase):  # #midpoint

    def test_100(self):
        _expect = (
                'for now, horizontal tab characters are deemed '
                'not pretty enough to store.')
        o = self.error_structure
        self.assertEqual(o['reason'], _expect)

    def test_200_has_position(self):
        o = self.error_structure
        self.assertEqual(o['position'], 2)
        self.assertEqual(o['line'][-1], '\n')  # sneak this in

    @shared_subject
    def error_structure(self):
        return self.expect_input_error_structure()

    def given_big_string(self):
        return 'abc\n12\t3\n'


class Case4188_things_to_escape_but_only_one_line(CommonCase):

    def test_100_things_were_escaped(self):
        _ = self.semi_encoded_lines()
        self.assertSequenceEqual(_, (r'aa \"\\t\" cc',))

    def test_200_had_special_characters(self):
        self.expect_had_special_characters()

    @shared_subject
    def encoding_plan(self):
        return self.build_encoding_plan_expecting_success()

    def given_big_string(self):
        return 'aa "\\t" cc'  # not a real tab character


class Case4189_a_shorter_line_encodes_for_single_line(CommonCase):

    def test_100(self):
        o = self.build_encoding_plan_expecting_success()
        self.assertEqual(len(o.semi_encoded_lines), 1)
        self.assertEqual(o.has_special_characters, False)

    def given_big_string(self):
        return 'one.......ten.......twenty....thirty....fourty....fifty..'


class Case4190_a_long_but_not_too_long_line(CommonCase):

    def test_100_one_line(self):
        self.expect_encodes_as_single_line_string()

    def test_200_no_special_chars(self):
        self.expect_had_no_special_characters()

    def test_300_is_pass_thru(self):
        line, = self.semi_encoded_lines()
        self.assertEqual(line, _seventy_nine_chars)

    @shared_subject
    def encoding_plan(self):
        return self.build_encoding_plan_expecting_success()

    def given_big_string(self):
        return _seventy_nine_chars


class Case4191_typical_simplified(CommonCase):

    def test_100_mutli_line(self):
        self.expect_encodes_as_multi_line_string()

    def test_200_no_special_chars(self):
        self.expect_had_no_special_characters()

    def test_300_file_bytes_look_good(self):
        _actual = self.semi_encoded_lines()
        _expected = ("line 1\n", "line 2\n", "line 3\n")
        self.assertSequenceEqual(_actual, _expected)

    @shared_subject
    def encoding_plan(self):
        return self.build_encoding_plan_expecting_success()

    def given_big_string(self):
        return "line 1\nline 2\nline 3\n"


class Case4193_no_trailing_newline(CommonCase):

    def test_300_didnt_add_newline(self):
        _actual = self.semi_encoded_lines()
        _expected = ("line 1\n", "line 2\n", "line 3")
        self.assertSequenceEqual(_actual, _expected)

    @shared_subject
    def encoding_plan(self):
        return self.build_encoding_plan_expecting_success()

    def given_big_string(self):
        return "line 1\nline 2\nline 3"


@lazy
def _common_subject():
    return _subject_module().string_encoder_via_definition(
            smaller_string_max_length=_small_limit,
            paragraph_line_max_width=_limit,
            max_paragraph_lines=3)


_ninety_character_long_string = (
    'one.......'
    'ten.......'
    'twenty....'
    'thirty....'
    'fourty....'
    'fifty.....'
    'sixty.....'
    'seventy...'
    'eighty....')  # this string is 90 chars long


_seventy_nine_chars = (
    'one.......ten.......twenty....thirty....'
    'fourty....fifty.....sixty.....seventy..')


_small_limit = 57
_limit = 79


def _subject_module():
    from kiss_rdb.storage_adapters_.toml import (
            string_encoder_via_definition as _)
    return _


if __name__ == '__main__':
    unittest.main()

# #born.
