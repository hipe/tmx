from kiss_rdb_test.filter_canon import \
        case_of_one_column_match_two_out_of_three, \
        case_of_empty_collection
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes
import unittest


class CommonCase(unittest.TestCase):

    @dangerous_memoize_in_child_classes('_end_state', 'build_end_state')
    def end_state():
        pass

    def build_end_state(self):
        return self.my_case.build_end_state(self)


class Case1872_one_column_match_two_out_of_three(CommonCase):

    def test_100_result(self):
        self.my_case.expect_these_two_entities(self)

    def test_200_statistics(self):
        self.my_case.expect_the_appropriate_statistics(self)

    def given_collection(self):
        return tuple(_EZ_Entity(dct) for dct in _lets_go())

    @property
    def my_case(self):
        return case_of_one_column_match_two_out_of_three


class Case1875_empty_collection(CommonCase):

    def test_100_result(self):
        self.my_case.expect_no_entities(self)

    def test_200_statistics(self):
        self.my_case.expect_the_appropriate_statistics(self)

    def given_collection(self):
        return ()

    @property
    def my_case(self):
        return case_of_empty_collection


def _lets_go():
    return (
            {
                'aa': 'ENA',
                'bb': 'this is #red.',
                },
            {
                'aa': 'ENB',
                'bb': 'this is #green.',
                },
            {
                'aa': 'ENC',
                'bb': 'this is #blue.',
                })


class _EZ_Entity:

    def __init__(self, dct):
        self._dct = dct

    @property
    def identifier_string(self):
        return self._dct['aa']

    @property
    def core_attributes_dictionary_as_storage_adapter_entity(self):
        return self._dct


if __name__ == '__main__':
    unittest.main()

# #history-A.1: rewrite
# #extracted from a cousin test file
