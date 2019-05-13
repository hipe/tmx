import _common_state  # noqa: F401
from kiss_rdb_test import CUD as CUD_support
from modality_agnostic.memoization import dangerous_memoize as shared_subject
import unittest


"""
DISCUSSION: immediately previous to this test module is the test module
for CUD of entity attributes. those cases employ the C and U of string
attributes, which fires up the string encoder, which essentially exists
to process #multi-line strings. even strings that are not multi-line undergo
validation closely related to multi-line processing (because the
"business schema" decides what dimensions of string are allowable for all
kinds of strngs..") anyway this separation of m.l strings from non-line
strings is more a conceptual separation than anything else.
"""


class _CommonCase(CUD_support.CUD_BIG_SUCCESS_METHODS, unittest.TestCase):
    pass


class Case407_100_simplifed_typical(_CommonCase):

    def test_100_everything(self):
        self.expect_big_success()

    def expect_entity_body_lines(self):
        return """
        aa-aa = 1
        bb-bb = \"\"\"
        line 1
        line 2
        \"\"\"
        cc-cc = 3
        """

    def given_request_tuples(self):
        return (('update', 'bb-bb', "line 1\nline 2\n"),)

    def given_entity_body_lines(self):
        return """
        aa-aa = 1
        bb-bb = 2
        cc-cc = 3
        """


class Case407_120_empty_string(_CommonCase):

    def test_100_reason(self):
        self.assertIn('not allowed generally', self.error_structure['reason'])

    def test_200_attr_name_and_bad_attr_value(self):
        o = self.error_structure
        self.assertEqual(o['attribute_name'], 'aa-aa')
        self.assertEqual(o['unsanitized_attribute_value'], '')

    def test_300_suggestion(self):
        _actual = self.error_structure['suggestion_sentence_phrase']
        self.assertIn('maybe ', _actual)

    @property
    @shared_subject
    def error_structure(self):
        return self.expect_input_error()

    def given_request_tuples(self):
        return (('create', 'aa-aa', ''),)

    def given_entity_body_lines(self):
        return ''


class Case407_140_one_line_special_char(_CommonCase):

    def test_100_stores_as_one_line_not_multi_line(self):
        self.expect_big_success()

    def expect_entity_body_lines(self):
        return """
        aa-aa = \"\\\" <- a quote\"
        """

    def given_request_tuples(self):
        return (('create', 'aa-aa', '" <- a quote'),)  # #todo point left

    def given_entity_body_lines(self):
        return ''


class Case407_160_multiple_lines_and_special_chars(_CommonCase):

    def test_100_everything(self):
        self.expect_big_success()

    def expect_entity_body_lines(self):
        return """
        aa-aa = 1
        bb-bb = \"\"\"
        line 1
        a quote: \\\"
        \"\"\"
        cc-cc = 3
        """

    def given_request_tuples(self):
        return (('update', 'bb-bb', "line 1\na quote: \"\n"),)

    def given_entity_body_lines(self):
        return """
        aa-aa = 1
        bb-bb = "only one line"
        cc-cc = 3
        """


class Case407_180_no_newline_on_final_line(_CommonCase):

    def test_100_reason(self):
        self.assertIn('must have a newline', self.error_structure['reason'])

    def test_200_attr_name_and_bad_attr_value(self):
        o = self.error_structure
        self.assertEqual(o['attribute_name'], 'aa-aa')
        self.assertEqual(o['unsanitized_attribute_value'], 'line 1\nline 2')

    @property
    @shared_subject
    def error_structure(self):
        return self.expect_input_error()

    def given_request_tuples(self):
        return (('create', 'aa-aa', "line 1\nline 2"),)

    def given_entity_body_lines(self):
        return ''


if __name__ == '__main__':
    unittest.main()

# #born.
