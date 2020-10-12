from kiss_rdb.test_support.intro import CommonestCase
import unittest


class CommonCase(CommonestCase, unittest.TestCase):

    def given_schema(_):
        return 'schema', 'field_name_keys', ('field_A', 'field_B')

    def given_module(_):
        return subject_module()


class Case1003_lines_via_two_entities(CommonCase):

    def test_050_loads(self):
        assert self.given_module()

    def test_100_output_lines_look_right(self):
        self.output_lines_look_right()

    def given_entities(_):
        yield {'field_A': 'A1', 'field_B': 'B1'}
        yield {'field_A': 'A2', 'field_B': 'B2'}

    def expected_lines(_):
        yield 'Field A, Field B\n'
        yield 'A1, B1\n'
        yield 'A2, B2\n'


def subject_module():
    from data_pipes.format_adapters import csv as module
    return module


if '__main__' == __name__:
    unittest.main()

# #born
