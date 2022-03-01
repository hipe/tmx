from kiss_rdb_test.common_initial_state import CreateCollectionCaseMethods
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject
from unittest import TestCase as unittest_TestCase, main as unittest_main


class CommonCase(CreateCollectionCaseMethods, unittest_TestCase):
    @property
    @shared_subject
    def end_state(self):
        return self.build_end_state()

    @property
    def storage_adapter_module(self):
        from kiss_rdb.storage_adapters_ import eno as mod
        return mod

    do_debug = False
    is_dry = False


class Case4852_050_collection_is_in_dir_too_deep(CommonCase):

    def test_100_error_type(self):
        self.expect_only_one_emission_which_is_error_of_type(
            'cannot_create_collection')

    def test_200_message(self):
        msg = self.error_message
        assert 'directory must exist' in msg
        assert '/000-no-ent' == msg[-11:]

    coll_path_tail = 'fixture-directories', '000-no-ent', 'dir-not-exist'


class Case4852_075_collection_dir_already_exists_or_is_nonempty(CommonCase):

    def test_100_error_type(self):
        self.expect_only_one_emission_which_is_error_of_type(
            'cannot_create_collection')

    def test_200_message(self):
        msg = self.error_message
        assert 'directory cannot already exist' in msg
        assert '/050-canon-main' == msg[-15:]

    coll_path_tail = 'fixture-directories', '4844-eno', '050-canon-main'


class Case4852_100_lets_party(CommonCase):

    def test_010_IDK(self):
        es = self.end_state
        emis, res = es.emissions, es.result
        assert '000-no-ent' == res.mixed_collection_identifier
        uniq = []
        for s in (emi.channel[2] for emi in emis):  # #[#508.2] chunker
            if (0 == len(uniq) or uniq[-1] != s):
                uniq.append(s)
        self.assertSequenceEqual(uniq, ('dry_run', 'from_patchfile'))

    is_dry = True
    coll_path_tail = 'fixture-directories', '000-no-ent'


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))


if __name__ == '__main__':
    unittest_main()

# #born
