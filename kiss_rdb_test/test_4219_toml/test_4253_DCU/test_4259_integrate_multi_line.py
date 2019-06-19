from kiss_rdb_test.CUD import (
        expect_big_success,
        emission_payload_expecting_error_given_edit_tuples,
        )
from modality_agnostic.memoization import dangerous_memoize as shared_subject
import unittest


"""
Cover what happens when multi-line strings are passed (for CREATE and UPDATE).

Nominally that is our scope, but note that a previous test module tests
aganst *non* mult-line strings;
which fires up the string encoder, which primarily exists only to process
multi-line strings -- even strings that are not multi-line strings undergo
validation closely related to multi-line processing (because the
"business schema" decides what dimensions of string are allowable for all
kinds of strings..) Anyway this separation of multi-line strings from non
is more a logical separation than a practical one.

Orthogonal to canon.
"""


class _CommonCase(unittest.TestCase):

    expect_big_success = expect_big_success

    def expect_input_error(self):
        return emission_payload_expecting_error_given_edit_tuples(
                self, 'input_error')


class Case4257_simplifed_typical(_CommonCase):

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


class Case4258_empty_string(_CommonCase):

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


class Case4259_one_line_special_char(_CommonCase):  # #midpoint

    def test_100_stores_as_one_line_not_multi_line(self):
        self.expect_big_success()

    def expect_entity_body_lines(self):
        return """
        aa-aa = \"\\\" 👈 a quote\"
        """

    def given_request_tuples(self):
        return (('create', 'aa-aa', '" 👈 a quote'),)

    def given_entity_body_lines(self):
        return ''


class Case4260_multiple_lines_and_special_chars(_CommonCase):

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


class Case4261_no_newline_on_final_line(_CommonCase):

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
