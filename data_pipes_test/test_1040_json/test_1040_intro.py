from kiss_rdb.test_support.intro import CommonestCase
import unittest


class CommonCase(CommonestCase, unittest.TestCase):

    def given_schema(_):
        return 'schema', 'field_name_keys', ('field_A', 'field_B')

    def given_module(_):
        return subject_module()


class Case1040_lines_via_two_entities(CommonCase):

    def test_050_loads(self):
        assert self.given_module()

    def test_100_output_lines_look_right(self):
        self.expect_expected_lines_given_entities()

    def given_entities(_):
        yield {'field_A': 'A1', 'field_B': 'B1'}
        yield {'field_A': 'A2', 'field_B': 'B2'}

    def expected_lines(_):
        yield '[{\n'
        yield '  "field_A": "A1",\n'
        yield '  "field_B": "B1"\n'
        yield '},\n'
        yield '{\n'
        yield '  "field_A": "A2",\n'
        yield '  "field_B": "B2"\n'
        yield '}]\n'


class CaseNNNN_two_entities_via_lines(CommonCase):

    def test_100_schema_looks_right(self):
        self.expect_expected_schema_field_name_keys()

    def test_200_result_entities_look_right(self):
        self.expect_expected_entities_given_lines()

    def given_lines(_):
        yield '[{\n'
        yield '  "field_A": "A1",\n'
        yield '  "field_B": "B1"\n'
        yield '},\n'
        yield '{\n'
        yield '  "field_A": "A2",\n'
        yield '  "field_B": "B2"\n'
        yield '}]\n'

    def expected_field_name_keys(_):
        return 'field_A', 'field_B'

    def expected_entities(_):
        yield {'field_A': 'A1', 'field_B': 'B1'}
        yield {'field_A': 'A2', 'field_B': 'B2'}


def subject_module():
    from data_pipes.format_adapters import json as module
    return module


if '__main__' == __name__:
    unittest.main()

# #born
