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

    def build_end_state_expecting_failure(self):
        return canon.build_end_state_expecting_failure_via(self)

    def resolve_collection(self, listener):
        from kiss_rdb.storage_adapters_ import markdown_table as lib
        path = self.given_path()
        if path is None:
            opened = self.given_pretend_file()
            use_path = opened.path
        else:
            opened = None
            use_path = path
        _coll_ID = StubCollectionIdentity(use_path)
        return lib._resolve_collection_via_file(opened, _coll_ID, listener)

    def given_path(self):
        pass



class Case2510_collection_not_found(CommonCase):

    def test_100_result_is_none(self):
        self.canon_case.confirm_result_is_none(self)

    def test_200_channel_looks_right(self):
        self.canon_case.confirm_channel_looks_right(self)

    def test_300_expression_looks_right(self):
        self.canon_case.confirm_expression_looks_right(self)

    @shared_subject
    def end_state(self):
        return self.build_end_state_expecting_failure()

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
        return self.build_end_state_expecting_failure()

    def given_path(self):
        return md_fixture_path('2515-has-no-table.md')

    @property
    def canon_case(self):
        return canon.case_of_collection_not_found


class Case2516_file_has_multiple_tables(CommonCase):

    def test_100_result_is_none(self):
        self._canon_case.confirm_result_is_none(self)

    def test_200_channel_looks_right(self):
        self._canon_case.confirm_channel_looks_right(self)

    def test_300_expression_looks_right(self):
        self._canon_case.confirm_expression_looks_right(self)
        reason = reason_via_end_state(self.end_state())
        needle = ': found 3 markdown tables, for now can only have one - '
        self.assertIn(needle, reason)

    @shared_subject
    def end_state(self):
        return self.build_end_state_expecting_failure()

    def given_pretend_file(self):
        return pretend_file_via_path_and_big_string(
            'pretend-file/2516-multiple-tables.md',
            """
            # .
            |aa|bb|cc|
            |---|---|---

            ## 2

            |dd|ee|ff|
            |---|---|---
            |

            # .
            |gg|hh|ii|
            |---|---|---
            |
            |

            """)

    @property
    def canon_case(self):
        return canon.case_of_collection_not_found


class Case2519_empty_collection_found(CommonCase):

    def test_100_result_is_not_none(self):
        _canon_case = canon.case_of_empty_collection_found
        _canon_case.confirm_collection_is_not_none(self)

    def subject_collection(self):
        return self.resolve_collection(None)

    def given_pretend_file(self):
        lines = unindent_with_dot_hack(
            """
            .

            (blank line above)
            |aa|bb|cc|
            |---|---|---
            """)
        pretend_path = 'pretend-file/2519-empty-collection.md'
        return pretend_file_via_path_and_lines(pretend_path, lines)


class Case2522_non_empty_collection_found(CommonCase):

    def test_100_result_is_not_none(self):
        canon_case = canon.case_of_non_empty_collection_found
        canon_case.confirm_collection_is_not_none(self)

    def given_collection(self):
        return self.resolve_collection(None)

    def given_pretend_file(self):
        return pretend_file_via_path_and_big_string(
            'pretend-file/2522-non-empty-collection.md',
            """
            |aa|bb|cc|
            |---|---|---
            |
            """)


reason_via_end_state = canon.reason_via_end_state


if __name__ == '__main__':
    unittest.main()

# #born.
