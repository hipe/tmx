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
        from kiss_rdb.storage_adapters import rec as mod
        return mod

    do_debug = False
    is_dry = False


class Case2871_wrong_extension(CommonCase):

    def test_100_error_type(self):
        self.expect_only_one_emission_which_is_error_of_type(
            'bad_collection_name')

    def test_200_message(self):
        msg = self.error_message
        assert "should end in '.rec'" in msg
        assert 'imaginary.fooz' in msg

    coll_path_tail = 'fixture-directories', 'imaginary.fooz'


class Case2875_already_exists(CommonCase):

    def test_100_error_type(self):
        self.expect_only_one_emission_which_is_error_of_type(
                'cannot_create_collection')

    def test_200_message(self):
        msg1, msg2 = self.the_only_emission.to_messages()
        assert "Can't create collection" in msg1
        import re
        re.search('\\bFile exists:.+from-documentation\\.rec', msg2) or \
                self.fail()

    coll_path_tail = ('fixture-directories', '2969-rec',
      '0100-example-from-documentation.rec')


class Case2879_lets_party(CommonCase):

    def test_010_success_channel(self):
        act = self.the_focus_emission.channel
        self.assertSequenceEqual(('info', 'expression', 'wrote_file'), act)

    def test_020_success_result_is_none_for_now(self):
        assert self.end_state.result is None

    def test_030_emission_says(self):
        msg, = self.the_focus_emission.to_messages()
        assert 'created new recfile collection: wazoozle poozle' == msg

    def test_040_writes_look_right(self):
        writes = self.end_state.writes
        assert 5 < len(writes)
        import re
        assert re.search(r'\bAuto-generated on \d\d\d\d-\d\d-\d\d\.', writes[0])

    @property
    def the_focus_emission(self):
        return self.the_only_emission

    @property
    def additional_invocation_options(self):
        dct = {}

        # == BEGIN this is too much DRY

        def use_open(path, mode):
            assert 'x' == mode
            return Annoying()

        writes = []
        use_open.writes = writes  # #here1 (big hack)

        class Annoying:
            def write(self, data):
                if test_context.do_debug:
                    print(f"WRITE: {data!r}")
                writes.append(data)
                return len(data)

            def __enter__(self, *_):
                pass

            def __exit__(self, *_):
                pass

            name = 'wazoozle poozle'

        test_context = self

        # == END
        dct['opn'] = use_open
        return dct

    def finish_end_state(self, end_state_dct, addtl_opts_dct):
        end_state_dct['writes'] = addtl_opts_dct['opn'].writes  # #here1

    end_state_field_names = 'result', 'emissions', 'writes'
    coll_path_tail = ('no-see-just-dry.rec',)


if __name__ == '__main__':
    unittest_main()

# #born
