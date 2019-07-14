from kiss_rdb_test.common_initial_state import (
        pretend_file_via_path_and_big_string,
        PretendFile,
        unindent_with_dot_hack,
        functions_for)
from kiss_rdb_test import storage_adapter_canon
from modality_agnostic.memoization import dangerous_memoize as shared_subject
import unittest


toml_fixture_directory_for = functions_for('toml').fixture_directory_for
md_fixture_path = functions_for('markdown').fixture_path


# [2500 (2517) 2535)


canon = storage_adapter_canon.produce_agent()


class _CommonCase(unittest.TestCase):

    def build_end_state_expecting_failure(self):
        from modality_agnostic.test_support import structured_emission as se_lib  # noqa: E501
        listener, emissioner = se_lib.listener_and_emissioner_for(self)
        x = self.resolve_collection(listener)
        chan, payloader = emissioner()
        sct = payloader()  # make it not hot
        return {
                'result_value': x,
                'channel': chan,
                'payloader_CAUTION_HOT': lambda: sct,
                }
        # eventually #open [#867.J] re-redund this

    def resolve_collection(self, listener):
        from kiss_rdb.storage_adapters_ import markdown_table as lib
        path = self.given_path()
        if path is None:
            opened = self.given_pretend_file()
            use_path = opened.path
        else:
            opened = None
            use_path = path
        return lib._resolve_collection_via_file(opened, use_path, listener)

    def given_path(self):
        pass


class Case2510_collection_not_found(_CommonCase):

    def test_100_result_is_none(self):
        self._canon_case.confirm_result_is_none(self)

    def test_200_channel_looks_right(self):
        self._canon_case.confirm_channel_looks_right(self)

    def test_300_expression_looks_right(self):
        self._canon_case.confirm_expression_looks_right(self)

    @shared_subject
    def end_state(self):
        return self.build_end_state_expecting_failure()

    def given_path(self):
        return toml_fixture_directory_for('000-no-ent')

    @property
    def _canon_case(self):
        return canon.case_of_collection_not_found


class Case2513_file_has_no_table(_CommonCase):

    def test_100_result_is_none(self):
        self._canon_case.confirm_result_is_none(self)

    def test_200_channel_looks_right(self):
        self._canon_case.confirm_channel_looks_right(self)

    def test_300_expression_looks_right(self):
        self._canon_case.confirm_expression_looks_right(self)
        reason = reason_via_end_state(self.end_state())
        self.assertIn(': no markdown table found in 7 lines - ', reason)

    @shared_subject
    def end_state(self):
        return self.build_end_state_expecting_failure()

    def given_path(self):
        return md_fixture_path('2515-has-no-table.md')

    @property
    def _canon_case(self):
        return canon.case_of_collection_not_found


class Case2516_file_has_multiple_tables(_CommonCase):

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
    def _canon_case(self):
        return canon.case_of_collection_not_found


class Case2519_empty_collection_found(_CommonCase):

    def test_100_result_is_not_none(self):
        _canon_case = canon.case_of_empty_collection_found
        _canon_case.confirm_collection_is_not_none(self)

    def subject_collection(self):
        return self.resolve_collection(None)

    def given_pretend_file(self):
        _lines = unindent_with_dot_hack(
            """
            .

            (blank line above)
            |aa|bb|cc|
            |---|---|---
            """)
        return PretendFile(
            _lines,
            'pretend-file/2519-empty-collection.md')


class Case2522_non_empty_collection_found(_CommonCase):

    def test_100_result_is_not_none(self):
        _canon_case = canon.case_of_non_empty_collection_found
        _canon_case.confirm_collection_is_not_none(self)

    def subject_collection(self):
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