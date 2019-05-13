from _common_state import (
        unindent,
        )
from kiss_rdb_test import structured_emission as se_lib
from modality_agnostic.memoization import dangerous_memoize as shared_subject
import unittest


class _CommonCase(unittest.TestCase):

    # (at #tombstone-A.1 we removed the "expression" counterparts.)

    def expecting_any_of_these_common_things(self):
        o = self.emitted_elements()
        _ = (
                'blank line or comment line',
                'table start line',
                'end of input',
                )
        self.assertEqual(o['expecting_any_of'], _)

    def line_number_but_not_position(self, lineno):
        o = self.emitted_elements()
        self.assertFalse('position' in o)
        self.assertEqual(o['lineno'], lineno)

    def line_number_and_position(self, lineno, position):
        o = self.emitted_elements()
        self.assertEqual(o['lineno'], lineno)
        self.assertEqual(o['position'], position)

    def some_line_number_and_line(self):
        o = self.emitted_elements()
        self.assertIsNotNone(o['lineno'])
        self.assertIsNotNone(o['line'])

    def you_can_see_that_EOS_was_NOT_reached(self):
        self.assertFalse(self._did_reach_EOS())

    def you_can_see_that_EOS_was_reached(self):
        self.assertTrue(self._did_reach_EOS())

    def _did_reach_EOS(self):
        return self.emitted_elements()['did_reach_end_of_stream']

    def run_expecting_structured_input_error(self):

        def recv_payloader(payloader):
            nonlocal freeform_metadata
            freeform_metadata = payloader()
        freeform_metadata = None

        self._run_expecting_input_error('structure', recv_payloader)
        return freeform_metadata

    def _run_expecting_input_error(self, shape, receive_payloader):

        def receive_emission(chan, payloader):
            self.assertEqual(chan, ('error', shape, 'input_error'))
            receive_payloader(payloader)

        listener, ran = se_lib.one_and_done(receive_emission, self)

        itr = self._run_non_validating_ID_traversal(listener)

        for x in itr:
            self.fail()

        ran()

    def run_non_validating_ID_traversal_expecting_success(self):

        listener = se_lib.debugging_listener() if False else None
        # set the above to true if it's failing and trying to emit, to debug
        itr = self._run_non_validating_ID_traversal(listener)
        x_a = []
        for tsl in itr:
            x_a.append((tsl.identifier_string, tsl.table_type))
        return tuple(x_a)

    def _run_non_validating_ID_traversal(self, listener):
        _all_lines = self.given_lines()
        return _subject_module().table_start_line_stream_via_file_lines_(_all_lines, listener)  # noqa: E501

    def given_lines(self):
        raise Exception('ha ha')


class Case055_truly_blank_file_produces_empty_stream(_CommonCase):
    """
    (language production for "no lines in input" in #tombstone-A.1)
    """

    def test_100_all(self):
        _ = self.run_non_validating_ID_traversal_expecting_success()
        self.assertSequenceEqual(_, ())

    def given_lines(self):
        return ()


class Case065_sneak_oxford_join_coverage_into_here(_CommonCase):

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
        from kiss_rdb.magnetics_.state_machine_via_definition import (
                oxford_OR as subject,
                )

        _actual = subject(given_tuple)
        self.assertEqual(_actual, expected_string)


class Case075_effectively_empty_file_produces_empty_stream(_CommonCase):

    # lost a message production at #tombstone-A.1:
    # 'file has no sections (so no entities)'

    def test_100_all(self):
        _ = self.run_non_validating_ID_traversal_expecting_success()
        self.assertSequenceEqual(_, ())

    def given_lines(self):
        return ('# comment line\n', '# comment line 2\n')


class Case085_an_ordinary_looking_line(_CommonCase):

    def test_100_you_can_see_that_EOS_was_NOT_reached(self):
        self.you_can_see_that_EOS_was_NOT_reached()

    def test_200_says_expecting_these_same_common_things(self):
        self.expecting_any_of_these_common_things()

    def test_300_line_number_and_line_but_NOT_position(self):
        self.line_number_but_not_position(3)
        self.assertEqual(self.emitted_elements()['line'], 'Huh ZAH!\n')

    @shared_subject
    def emitted_elements(self):
        return self.run_expecting_structured_input_error()

    def given_lines(self):
        return ('# comment line\n', '\n', 'Huh ZAH!\n')


class Case095_not_quite_section_line(_CommonCase):

    def test_100_says_this_one_ad_hoc_description_of_expecting(self):
        o = self.emitted_elements()
        self.assertEqual(o['expecting'], 'close brace and end of line')

    def test_200_you_can_see_that_EOS_was_NOT_reached(self):
        self.you_can_see_that_EOS_was_NOT_reached()

    def test_300_you_have_the_line_number_and_position(self):
        self.line_number_and_position(3, 4)

    def test_400_the_module_has_this_ASCII_art_function(self):

        # at #tombstone-A.1 we severed this behavior from "production"
        # but we know we will want it again later at CLI integration

        from kiss_rdb.magnetics_.string_scanner_via_definition import (
                two_lines_of_ascii_art_via_position_and_line_USE_ME as subject,
                )
        _all_these = self.emitted_elements()
        _itr = subject(**_all_these)  # this is really clever by the way
        last_lines = list(_itr)
        _1 = "    '[fun time…'"
        _2 = "     ----^"
        self.assertEqual(last_lines, [_1, _2])

    @shared_subject
    def emitted_elements(self):
        return self.run_expecting_structured_input_error()

    def given_lines(self):
        return ('# comment line\n', '\n', '[fun time]\n')


class Case105_section_but_no_dots(_CommonCase):

    def test_100_our_first_structured_emisson(self):
        o = self.emitted_elements()
        self.assertEqual(o['expecting'], 'keyword "item"')

    def test_200_points_right_at_the_first_letter(self):
        o = self.emitted_elements()
        self.assertEqual(o['position'], 1)

    def test_300_correct_line_number_and_line(self):
        o = self.emitted_elements()
        self.assertEqual(o['lineno'], 1)
        self.assertEqual(o['line'], '[woot]\n')

    @shared_subject
    def emitted_elements(self):
        return self.run_expecting_structured_input_error()

    def given_lines(self):
        return ('[woot]\n',)


class Case115_wrong_keyword_for_third_component(_CommonCase):

    def test_100_expecting(self):
        o = self.emitted_elements()
        self.assertEqual(o['expecting'], 'keyword "attributes" or "meta"')

    def test_200_points_right_at_the_first_letter_of_the_keyword(self):
        o = self.emitted_elements()
        pos = o['position']
        self.assertEqual(pos, 11)
        self.assertEqual(o['line'][pos:pos+4], 'attr')

    def test_300_some_line_number_and_line(self):
        self.some_line_number_and_line()

    @shared_subject
    def emitted_elements(self):
        return self.run_expecting_structured_input_error()

    def given_lines(self):
        return ('[item.0O1L.attribute]\n',)


class Case125_too_many_components(_CommonCase):

    def test_100_structured_emission(self):
        o = self.emitted_elements()
        self.assertEqual(o['expecting'], "']'")

    def test_200_points_right_at_the_exta_dot(self):
        o = self.emitted_elements()
        pos = o['position']
        self.assertEqual(pos, 21)
        self.assertEqual(o['line'][pos], '.')

    def test_300_some_line_number_and_line(self):
        self.some_line_number_and_line()

    @shared_subject
    def emitted_elements(self):
        return self.run_expecting_structured_input_error()

    def given_lines(self):
        return ('[item.0O1L.attributes.huzzah]\n',)


class Case135_non_validated_ID_traversal_one(_CommonCase):

    def test_100_everything(self):
        _ = self.run_non_validating_ID_traversal_expecting_success()
        self.assertEqual(_, (('0O1L', 'attributes'),))

    def given_lines(self):
        return ('[item.0O1L.attributes]\n',)


class Case145_non_validated_ID_traversal_two(_CommonCase):

    # this is invalid (meta must come before attributes for the same thing)
    # but the point is we aren't validating that at this level.

    def test_100_everything(self):
        _ = self.run_non_validating_ID_traversal_expecting_success()
        self.assertEqual(_, (('B', 'attributes'), ('B', 'meta')))

    def given_lines(self):
        return ('[item.B.attributes]\n', '[item.B.meta]\n')


class Case150_first_touch_of_multi_line(_CommonCase):  # #mutli-line-case

    def test_100_EVERYTHING(self):
        _actual = self.run_non_validating_ID_traversal_expecting_success()
        _expect = (
                ('2K9', 'attributes'),
                ('2KA', 'attributes'))
        self.assertSequenceEqual(_actual, _expect)

    def given_lines(self):

        # DISCUSSION: below migh be too much, but it's exactly what we had
        # in a file when we made it a file, and it's representative & useful
        # this way

        return unindent('''
            [item.2K9.attributes]
            ting = """
            [item.ABC.attributes]
            """
            tang = 'tong'

            [item.2KA.attributes]
            thing = "x"

            # #born.
            ''')


def _subject_module():
    from kiss_rdb.magnetics_ import identifiers_via_file_lines as _
    return _


if __name__ == '__main__':
    unittest.main()

# #tombstone-A.2: blank files become OK,remove discussion of how great SM's are
# #tombstone-A.1: as referenced
# #born.
