from modality_agnostic.test_support.common import \
        listener_and_emissions_for, \
        dangerous_memoize_in_child_classes as shared_subject
from unittest import TestCase as unittest_TestCase, main as unittest_main


class CommonCase(unittest_TestCase):

    # run-time assertions

    def expect_expected_error_type(self):
        exp = self.expected_error_type
        assert exp == self.the_only_emission.channel[2]

    # getters for participants in assertions

    @property
    def error_message(self):
        msg, = self.the_only_emission.to_messages()
        return msg

    @property
    def the_only_emission(self):
        emis, res = self.end_state_emissions_and_result
        assert not res
        emi, = emis
        return emi

    @property
    @shared_subject
    def end_state_emissions_and_result(self):
        coll_path = self.build_collection_path()
        listener, emis = listener_and_emissions_for(self, limit=4)
        sa = self.build_storage_adapter()
        res = sa.CREATE_COLLECTION(coll_path, listener, is_dry=True)
        return tuple(emis), res

    def build_collection_path(self):
        from kiss_rdb_test.common_initial_state import top_test_dir
        from os.path import join as path_join
        return path_join(top_test_dir(), * self.dir_path_tail)

    def build_storage_adapter(self):  # could be lazy
        from kiss_rdb.storage_adapters_ import eno as sa_mod
        from kiss_rdb.magnetics_.collection_via_path import \
            _StorageAdapter as SA_class
        return SA_class(sa_mod, 'eno')

    do_debug = False


class Case4852_050_collection_is_in_dir_too_deep(CommonCase):

    def test_100_error_type(self):
        self.expect_expected_error_type()

    def test_200_message(self):
        msg = self.error_message
        assert 'directory must exist' in msg
        assert '/000-no-ent' == msg[-11:]

    dir_path_tail = 'fixture-directories', '000-no-ent', 'dir-not-exist'
    expected_error_type = 'cannot_create_collection'


class Case4852_075_collection_dir_already_exists_or_is_nonempty(CommonCase):

    def test_100_error_type(self):
        self.expect_expected_error_type()

    def test_200_message(self):
        msg = self.error_message
        assert 'directory cannot already exist' in msg
        assert '/050-canon-main' == msg[-15:]

    dir_path_tail = 'fixture-directories', '4844-eno', '050-canon-main'
    expected_error_type = 'cannot_create_collection'


class Case4852_100_lets_party(CommonCase):

    def test_010_IDK(self):
        emis, res = self.end_state_emissions_and_result
        assert '000-no-ent' == res.mixed_collection_identifier
        uniq = []
        for s in (emi.channel[2] for emi in emis):  # #[#508.2] chunker
            if (0 == len(uniq) or uniq[-1] != s):
                uniq.append(s)
        self.assertSequenceEqual(uniq, ('dry_run', 'from_patchfile'))

    dir_path_tail = 'fixture-directories', '000-no-ent'


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))


if __name__ == '__main__':
    unittest_main()

# #born
