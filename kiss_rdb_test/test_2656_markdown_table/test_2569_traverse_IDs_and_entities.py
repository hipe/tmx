from kiss_rdb_test._common_state import (
        pretend_file_via_path_and_big_string,
        )
from kiss_rdb_test import storage_adapter_canon
from modality_agnostic.memoization import dangerous_memoize as shared_subject
import unittest


# traverse ID's: [2535 (2552) 2569)
# traverse all entities: [2569 (2587) 2604)


# py -c 'beg=2535;end=2569;jump=(end-beg)/3; print(tuple(round(beg + (jump*i)) for i in range(1, 3)))'  # noqa: E501
# (2546, 2558)


canon = storage_adapter_canon.produce_agent()


_CommonCase = unittest.TestCase


class Case2535_traverse_whole_collection_as_IDs(_CommonCase):

    def test_100_all_IDs_are_there_in_any_order_none_repeated(self):
        _ = canon.case_of_traverse_IDs_from_non_empty_collection
        _.confirm_all_IDs_in_any_order_no_repeats(self)

    def subject_collection(self):
        return _build_same_collection_anew_BUT_FOR_IDs()


class Case2558_traverse_empty_collection_as_IDs(_CommonCase):

    def test_100_results_in_empty_stream(self):
        _ = canon.case_of_traverse_IDs_from_empty_collection
        _.confirm_results_in_empty_stream(self)

    def subject_collection(self):
        return _build_empty_collection()


class Case2587_traverse_whole_collection_as_entities(_CommonCase):

    def test_100_all_IDs_are_there_in_any_order_none_repeated(self):
        _traverse_ents().confirm_all_IDs_in_any_order_no_repeats(self)

    def test_200_an_entity_from_the_middle_knows_one_of_its_fields(self):
        _traverse_ents().confirm_particular_entity_knows_one_of_its_field(self)

    def test_300_featherweighting_isnt_biting(self):
        _traverse_ents().confirm_featherweighting_isnt_biting(self)

    @shared_subject
    def flattened_collection_for_traversal_case(self):
        return canon.build_flattened_collection_for_traversal_case(self)

    def subject_collection(self):
        return _build_same_collection_anew_BUT_FOR_FIELDS()


def _traverse_ents():
    return canon.case_of_traverse_all_entities


def _build_same_collection_anew_BUT_FOR_FIELDS():
    return _build_collection_via_path_and_big_string(
        'pretend-file/2536-for-ID-traversal.md',
        """
        | i De nTi Fier zz | thing 1  | thing-2 | Thing_A |thing-B|
        |---|---|---
        | B9H  |     |     |  hi i'm B9H   | hey i'm B9H |
        | B8H | hi i'm B8H | hey i'm B8H
        | 2HJ
        | B9G
        | B9J
        | B7E
        | B7F
        | B7G | hi G | hey G |
        """)

    # hi-G hi-J


def _build_same_collection_anew_BUT_FOR_IDs():
    return _build_collection_via_path_and_big_string(
        'pretend-file/2536-for-ID-traversal.md',
        """
        xx
        xxxyy
        | i De nTi Fier zz | thing-1  | thing-2 |
        |---|---|---
        | B8H
        | 2HJ|xx|yy|zz|aa|bb|
        | B9G
        | B9H
        | B9J
        | B7E
        | B7F
        | B7G
        """)


def _build_empty_collection():

    return _build_collection_via_path_and_big_string(
        'pretend-file/2519-empty-collection.md',  # #copy-paste
        """
        hello

        ## hi

        |aa|bb|cc|
        |---|---|---

        goodbye
        """)


def _build_collection_via_path_and_big_string(path, big_string):
    pfile = pretend_file_via_path_and_big_string(path, big_string)
    from kiss_rdb.storage_adapters_ import markdown_table as lib
    return lib.resolve_collection_via_file(pfile, pfile.path, None)


if __name__ == '__main__':
    unittest.main()

# #born.
