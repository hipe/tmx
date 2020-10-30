from kiss_rdb_test import storage_adapter_canon
from kiss_rdb_test.common_initial_state import \
        end_state_named_tuple, functions_for, spy_on_write_and_lines_for
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_child_classes,\
        dangerous_memoize as shared_subject, lazy
import unittest


canon = storage_adapter_canon.produce_agent()


def load_tests(loader, tests, ignore):  # (this is a unittest API hook-in)
    module = import_toolkit_module()
    from doctest import DocTestSuite as func
    suite = func(module)
    tests.addTests(suite)
    return tests  # (necessary (return our argument))


class CommonCase(unittest.TestCase):

    @property
    @shared_subject_in_child_classes
    def end_state(self):
        return self.canon_case.build_end_state(self)

    def given_collection(self):
        return stateless_collection()

    do_debug = False


class Case4788_retrieve_OK(CommonCase):

    def test_100_entity_is_retrieved_and_looks_ok(self):
        self.canon_case.confirm_entity_is_retrieved_and_looks_ok(self)

    @property
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


class Case4794_traverse_whole_document_tree_for_debugging(CommonCase):
    # SKRRRT

    def test_050_toolkit_module_loads(self):
        assert self.subject_module.HELLO_I_AM_ENO_TOOLKIT_
        # (we don't trust that the above method will stay a property)

    def test_075_werk_werk_werk(self):
        es = self.end_state
        assert 0 == es.returncode

    def test_100_every_line_looks_like_this(self):
        exp = set("""
            ATTRIBUTE END_OF_FILE ENTITY IDENTITY_LINE
            LINE PASS_THRU_BLOCK PATH WS
        """.split())
        act = self.custom_index.line_types
        self.assertEqual(act, exp)

    def test_200_every_line_looks_like_this(self):
        act = self.custom_index.indents
        exp = set((0, 2, 4, 6))
        self.assertEqual(act, exp)

    @shared_subject
    @end_state_named_tuple('indents', 'line_types')
    def custom_index(self):
        indents, line_types = set(), set()
        import re
        lines = self.end_state.output_lines
        for line in lines:
            md = re.match(r'([ ]*)([A-Z]+(?:[ ][A-Z]+)*)(?::|[ ]\(|$)', line)
            if not md:
                raise RuntimeError(f"oops - {line!r}")
            ws, header = md.groups()
            indents.add(len(ws))
            line_types.add(header.replace(' ', '_'))
        return indents, line_types

    @shared_subject
    @end_state_named_tuple('returncode', 'output_lines')
    def end_state(self):
        sout, sout_lines = spy_on_write_and_lines_for(self, 'DBG SOUT: ')
        coll = stateless_collection()
        func = self.subject_module._the_main_experiment
        rc = func(sout, None, coll)
        return rc, tuple(sout_lines)

    @shared_subject
    def subject_module(self):
        return import_toolkit_module()


class Case4797_entity_not_found_because_identifier_too_deep(CommonCase):

    def test_100_result_is_none(self):
        self.canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self.canon_case.confirm_emitted_accordingly(self)

    def test_600_message_(self):
        sct = self.end_state['payloader']()
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
        sct = self.end_state['payloader']()
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
        sct = self.end_state['payloader']()
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

    def given_collection(self):
        coll_path = main_dir()

        listener = None
        if self.do_debug:
            listener = import_debugging_listener()

        from kiss_rdb import collectionerer
        return collectionerer().collection_via_path(
                collection_path=coll_path,
                format_name=None,
                listener=listener)


# == Fixture collections, directories & fixture loading support

@lazy
def stateless_collection():
    coll_path = main_dir()
    return coll_via_path(coll_path)


@lazy
def main_dir():
    return fixture_directory_for('050-canon-main')


def coll_via_path(coll_path):
    from kiss_rdb_test.eno_support import coll_via_path as func
    return func(coll_path)


fixture_directory_for = functions_for('eno').fixture_directory_for


# == Subject modules & similar

def import_toolkit_module():
    from kiss_rdb_test.eno_support import import_sub_module as func
    return func('toolkit')


# == Dispatchers

def import_debugging_listener():
    from modality_agnostic.test_support.common import \
        debugging_listener as funcer
    return funcer()


if __name__ == '__main__':
    unittest.main()

# #born.
