import _common_state  # noqa: F401
from kiss_rdb_test import structured_emission
from modality_agnostic.memoization import dangerous_memoize as shared_subject
import unittest


class _CommonCase(unittest.TestCase):

    # (at #tombstone-A.1 we removed the "expression" counterparts.)

    def expecting_any_of_these_common_things(self):
        o = self.emitted_elements()
        _ = ('blank line', 'comment line', 'section line')
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

        def listener(*args):
            nonlocal count
            count += 1
            if 1 < count:
                raise Exception('more than one emission')
            *chan, payloader = args
            self.assertEqual(chan, ['error', shape, 'input_error'])
            receive_payloader(payloader)

        count = 0
        itr = self._run_non_validating_ID_traversal(listener)
        for x in itr:
            self.fail()
        self.assertEqual(count, 1)

    def run_non_validating_ID_traversal_expecting_success(self):

        listener = structured_emission.debugging_listener() if False else None
        # set the above to true if it's failing and trying to emit, to debug
        itr = self._run_non_validating_ID_traversal(listener)
        x_a = []
        for x in itr:
            x_a.append(x)
        return tuple(x_a)

    def _run_non_validating_ID_traversal(self, listener):
        _all_lines = self.given_lines()
        return _subject_module()._traverse_IDs_without_validating(_all_lines, listener)  # noqa: E501

    def given_lines(self):
        raise Exception('ha ha')


class Case100_truly_blank_file(_CommonCase):
    """
    necessary discussion:

    rather than have an ad-hoc hard-coded check for the various circumstances
    of state that are true for when a file with no lines is what "caused" the
    input error, we can generalize the expression so we have less code but the
    code is more powerful.

    a file with no lines now triggers the error in this way: we are in the
    "start" state and the special "end of stream" token is received. there is
    no state transition out that state for that token.

    this is a better way to implement the behavior because it's more general
    general implementation that can still effect the target behavior (+ or -).

    so for example you can more easily design a grammar that accomodates
    empty input simply by rearranging your state machine.

      - the changes discussed here happened in #tombstone-A.1
      - this tombstone buried the production "no lines in input", which
        is very CLI-ready production but had to go for reasons
      - now this is more structured but more opaque: to determine that
        there were no lines in file, you have to detect both:
          - that the end was reached AND
          - that the current line is 0 (not a line)
    """

    def test_100_it_says_that_you_DID_reach_EOS(self):
        self.you_can_see_that_EOS_was_reached()

    def test_200_IFF_a_first_line_is_never_parsed__these_two_things(self):
        self.line_number_but_not_position(0)

    def test_300_new_in_this_case__expecting_any_of__an_array(self):
        self.expecting_any_of_these_common_things()

    @shared_subject
    def emitted_elements(self):
        return self.run_expecting_structured_input_error()

    def given_lines(self):
        return ()


class Case115_sneak_oxford_join_coverage_into_here(_CommonCase):

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


class Case120_early_end_of_non_empty_file(_CommonCase):

    # lost a message production at #tombstone-A.1:
    # 'file has no sections (so no entities)'

    def test_100_you_can_see_that_EOS_was_reached(self):
        self.you_can_see_that_EOS_was_reached()

    def test_200_parse_state_still_holds_the_LAST_line_parsed(self):
        self.line_number_but_not_position(2)

    def test_300_the_expecting_message_hints_at_syntax__whats_required(self):
        self.expecting_any_of_these_common_things()

    @shared_subject
    def emitted_elements(self):
        return self.run_expecting_structured_input_error()

    def given_lines(self):
        return ('# comment line\n', '# comment line 2\n')


class Case130_an_ordinary_looking_line(_CommonCase):

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


class Case210_not_quite_section_line(_CommonCase):

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


class Case220_section_but_no_dots(_CommonCase):

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


class Case240_wrong_keyword_for_third_component(_CommonCase):

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


class Case250_too_many_components(_CommonCase):

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


class Case310_non_validated_ID_traversal_one(_CommonCase):

    def test_100_everything(self):
        _ = self.run_non_validating_ID_traversal_expecting_success()
        self.assertEqual(_, (('0O1L', 'attributes'),))

    def given_lines(self):
        return ('[item.0O1L.attributes]\n',)


class Case320_non_validated_ID_traversal_two(_CommonCase):

    # this is invalid (meta must come before attributes for the same thing)
    # but the point is we aren't validating that at this level.

    def test_100_everything(self):
        _ = self.run_non_validating_ID_traversal_expecting_success()
        self.assertEqual(_, (('B', 'attributes'), ('B', 'meta')))

    def given_lines(self):
        return ('[item.B.attributes]\n', '[item.B.meta]\n')


def _subject_module():
    from kiss_rdb.magnetics_ import identifiers_via_file_lines as _
    return _


if __name__ == '__main__':
    unittest.main()

# #tombstone-A.1: as referenced
# #born.
