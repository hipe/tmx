from kiss_rdb_test.common_initial_state import functions_for
from kiss_rdb_test import storage_adapter_canon
from modality_agnostic.memoization import \
        dangerous_memoize_in_child_classes, lazy
import unittest


canon = storage_adapter_canon.produce_agent()


class CommonCase(unittest.TestCase):

    @dangerous_memoize_in_child_classes('_ES', 'build_end_state')
    def end_state(self):
        pass

    def build_end_state(self):
        return self.canon_case.build_end_state(self)

    def subject_collection(self):
        return stateless_collection()

    identifier_via_primitive = storage_adapter_canon.identifier_via_string
    do_debug = False


class Case4788_retrieve_OK(CommonCase):

    def test_100_entity_is_retrieved_and_looks_ok(self):
        self.canon_case.confirm_entity_is_retrieved_and_looks_ok(self)

    def end_state(self):  # NOTE  not memoized
        return self.canon_case.build_end_state(self)

    def given_identifier_string(self):
        return 'B9H'

    @property
    def canon_case(self):
        return canon.case_of_retrieve_OK


class Case4791_traverse_IDs(CommonCase):

    def test_100_everything(self):
        _ = canon.case_of_traverse_IDs_from_non_empty_collection
        _.confirm_all_IDs_in_any_order_no_repeats(self)


# Case4794 - traverse entities  # #midpoint


class Case4797_entity_not_found_because_identifier_too_deep(CommonCase):

    def test_100_result_is_none(self):
        self.canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self.canon_case.confirm_emitted_accordingly(self)

    def test_600_message_(self):
        sct = self.end_state()['payloader_CAUTION_HOT']()
        _expect = "can't retrieve because identifier '23YZ' "\
                  "has wrong number of digits (needed 3, had 4)"
        self.assertEqual(sct['reason_tail'], _expect)

    def given_identifier_string(self):
        return '23YZ'

    @property
    def canon_case(self):
        return canon.case_of_entity_not_found_because_identifier_too_deep


class Case4800_entity_not_found_because_no_file(CommonCase):

    def test_100_result_is_none(self):
        self.canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self.canon_case.confirm_emitted_accordingly(self)

    def test_600_message_(self):
        sct = self.end_state()['payloader_CAUTION_HOT']()
        _expect = "'CAN' (No such file or directory)"  # message is e.strerror
        self.assertEqual(sct['reason_tail'], _expect)

    def given_identifier_string(self):
        return 'CAN'

    @property
    def canon_case(self):
        return canon.case_of_entity_not_found


class Case4803_entity_not_found_in_file(CommonCase):

    def test_100_result_is_none(self):
        self.canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self.canon_case.confirm_emitted_accordingly(self)

    def test_600_message_(self):
        sct = self.end_state()['payloader_CAUTION_HOT']()
        _expect = "'B7J' (3 entities in file)"  # entity not found:
        self.assertEqual(sct['reason_tail'], _expect)

    def given_identifier_string(self):
        return 'B7J'

    @property
    def canon_case(self):
        return canon.case_of_entity_not_found


# == collection resolution is more boring, so down here


# Case4806 collection not found
# is hard to test for reasons hard to explain:
# testing a corrupted directory-based collection is out of scope
# support for single-file collections is out of scope
# as such, to even setup such a case is impractical or impossible


class Case4809_non_empty_collection_found(CommonCase):

    def test_100_result_is_not_none(self):
        canon.case_of_non_empty_collection_found.confirm_collection_is_not_none(self)  # noqa: E501

    def subject_collection(self):
        listener = _debugging_listener
        # listener = None

        from kiss_rdb import collectionerer
        return collectionerer().collection_via_path(
                collection_path=_main_dir(),
                format_name=None,
                listener=listener)


@lazy
def stateless_collection():
    return _stateless_collection_via_directory(_main_dir())


@lazy
def _main_dir():
    return fixture_directory_for('050-canon-main')


def _stateless_collection_via_directory(dir_path):
    from kiss_rdb.storage_adapters_.eno import \
            _stateless_collection_implementation_via_directory
    return _stateless_collection_implementation_via_directory(dir_path)


def _debugging_listener(*args):
    from modality_agnostic.test_support import structured_emission
    structured_emission.debugging_listener()(*args)


fixture_directory_for = functions_for('eno').fixture_directory_for


if __name__ == '__main__':
    unittest.main()

# #born.
