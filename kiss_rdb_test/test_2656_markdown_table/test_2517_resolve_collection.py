import kiss_rdb_test.markdown_storage_adapter as msa
from kiss_rdb_test import storage_adapter_canon
from kiss_rdb_test.common_initial_state import \
        unindent_with_dot_hack, functions_for
import modality_agnostic.test_support.common as em
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject
import unittest


toml_fixture_directory_for = functions_for('toml').fixture_directory_for
md_fixture_path = functions_for('markdown').fixture_path


# [2500 (2517) 2535)


canon = storage_adapter_canon.produce_agent()


class CommonCase(unittest.TestCase):

    def build_end_state_expecting_failure(self, also=None):
        return canon.build_end_state_expecting_failure_via(self, also)

    def resolve_collection(self, listener):
        path = self.given_path()
        if path is not None:
            return msa.collection_via_real_path(path, listener)
        x = self.given_pretend_file()
        return msa.collection_via_mixed_test_resource(x, listener)

    def given_path(self):
        pass

    do_debug = False


class Case2510_collection_not_found(CommonCase):

    def test_100_result_is_none(self):
        self.canon_case.confirm_result_is_none(self)

    def test_200_channel_looks_right(self):
        self.canon_case.confirm_channel_looks_right(self)

    def test_300_expression_looks_right(self):
        self.canon_case.confirm_expression_looks_right(self)

    @shared_subject
    def end_state(self):
        return self.build_end_state_expecting_failure(traverse)

    def given_path(self):
        return toml_fixture_directory_for('000-no-ent')

    @property
    def canon_case(self):
        return canon.case_of_collection_not_found


class Case2513_file_has_no_table(CommonCase):

    def test_100_result_is_none(self):
        self.canon_case.confirm_result_is_none(self)

    def test_200_channel_looks_right(self):
        self.canon_case.confirm_channel_looks_right(self)

    def test_300_expression_looks_right(self):
        self.canon_case.confirm_expression_looks_right(self)
        reason = reason_via_end_state(self.end_state)
        self.assertIn(': no markdown table found in 7 lines', reason)

    @shared_subject
    def end_state(self):
        return self.build_end_state_expecting_failure(traverse)

    def given_path(self):
        return md_fixture_path('2515-has-no-table.md')

    @property
    def canon_case(self):
        return canon.case_of_collection_not_found


class Case2516_file_has_multiple_tables(CommonCase):
    # (in #history-B.1 change to streaming this changed to fail late)

    def test_100_items_are_produced(self):
        ents = self.end_state['result_value']
        eids = tuple(e.nonblank_identifier_primitive for e in ents)
        self.assertSequenceEqual(eids, ('x1', 'x4'))
        # self.canon_case.confirm_result_is_none(self)

    def test_200_channel_looks_right(self):
        actual = self.end_state['channel']
        expected = ('error', 'structure', 'multiple_tables')
        self.assertSequenceEqual(actual, expected)
        # self.canon_case.confirm_channel_looks_right(self)

    def test_300_expression_looks_right(self):
        reason = reason_via_end_state(self.end_state)
        needle = 'for now can only have one table'
        self.assertIn(needle, reason)
        # self.canon_case.confirm_expression_looks_right(self)

    @shared_subject
    def end_state(self):
        return self.build_end_state_expecting_failure(traverse_and_flatten)

    def given_pretend_file(self):
        return (
            'pretend-file/2516-multiple-tables.md',
            """
            # .
            |aa|bb|cc|
            |---|---|---
            |eg|[#867.5.1]
            |x1|x2|x3
            |x4|x5|x6|

            ## 2

            |dd|ee|ff|
            |---|---|---
            |x|x|x

            # .
            |gg|hh|ii|
            |---|---|---
            |x|x|x
            |x|x|x

            """)

    @property
    def canon_case(self):
        return canon.case_of_collection_not_found


class Case2519_empty_collection_found(CommonCase):

    def test_100_try_to_traverse_andd_you_get_none(self):
        coll = self.given_collection()

        # canon_case = canon.case_of_empty_collection_found
        # canon_case.confirm_collection_is_not_none(self)

        listener = em.throwing_listener
        with coll.open_entity_traversal(listener) as ents:
            for ent in ents:
                self.fail("should have been no entities")

    def given_collection(self):
        return self.resolve_collection(None)

    def given_pretend_file(self):
        lines = unindent_with_dot_hack(
            """
            .

            (blank line above)
            |aa|bb|cc|
            |---|---|---
            """)
        return 'pretend-file/2519-empty-collection.md', lines


class Case2522_non_empty_collection_found(CommonCase):

    def test_100_result_is_not_none(self):
        canon_case = canon.case_of_non_empty_collection_found
        canon_case.confirm_collection_is_not_none(self)

    def given_collection(self):
        return self.resolve_collection(None)

    def given_pretend_file(self):
        return (
            'pretend-file/2522-non-empty-collection.md',
            """
            |aa|bb|cc|
            |---|---|---
            |
            """)


def traverse_and_flatten(coll, listener):
    with open_ent_trav(coll, listener) as ents:
        return tuple(ents)


def traverse(coll, listener):
    # since getting rid of random access, we need to trip this
    with open_ent_trav(coll, listener) as ents:
        if ents is None:
            return
        for ent in ents:
            pass


def open_ent_trav(coll, listener):
    return coll.open_entity_traversal(listener)


reason_via_end_state = canon.reason_via_end_state


def xx(*_):
    raise RuntimeError('foo')


if __name__ == '__main__':
    unittest.main()

# #history-B.1
# #born.
