from data_pipes_test.common_initial_state import (
        build_end_state_commonly,
        markdown_fixture,
        executable_fixture)
from modality_agnostic.memoization import dangerous_memoize as shared_subject
from modality_agnostic.test_support.structured_emission import (
        listener_and_emission_objecter_for)
import unittest


class _CommonCase(unittest.TestCase):

    # -- assertion support

    def _outputs_no_lines(self):
        _lines = self._end_state().outputted_lines
        self.assertEqual(len(_lines), 0)

    def _emission(self, name):
        return self._end_state().actual_emission_index.actual_emission_via_name(name)  # noqa: E501

    def _fail_against(self, s):
        listener, emissioner = listener_and_emission_objecter_for(self)
        coll = _build_collection(s, _yes_cheat, listener)
        assert(coll is None)
        em = emissioner()
        msgs = em.to_raw_lines()
        msg, = msgs  # assertion
        return msg

    _build_end_state = build_end_state_commonly


class Case1302_this_path_fails_because_absolute_path_too_crazy(_CommonCase):

    def test_100_fails(self):
        _msg = self._fail_against('/egads/ohai.py')
        self.assertRegex(_msg, r'\babsolute path outside of ecosystem\b')


class Case1305_this_one_file_fails_because_invalid_chars_in_name(_CommonCase):

    def test_100_fails(self):
        _path = executable_fixture('no-ent.py')
        _msg = self._fail_against(_path)
        self.assertRegex(_msg, "\\bcharacter we don't like[^a-zA-Z]+-")


class Case1308_here_is_a_low_level_doo_hah(_CommonCase):
    # at #history-A.2 imported this from a whole other dedicated file

    def test_100_runs(self):
        self.assertIsNotNone(self._state())

    def test_200_skipped_the_header_record(self):
        _ = [pair[0] for pair in self._state()]
        self.assertEqual(_, ['four', 'seven'])

    @shared_subject
    def _state(self):
        flat = []

        listener = None  # or throwing listener
        _path = executable_fixture('exe_130_edit_add.py')

        from data_pipes.format_adapters.producer_script import (
                producer_script_module_via_path)

        ps = producer_script_module_via_path(_path, listener)

        def recv_far_stream(normal_far_st):
            _one = next(normal_far_st)
            flat.append(_one)
            _two = next(normal_far_st)
            flat.append(_two)
            for no_see in normal_far_st:
                raise Exception('no')

        assert(ps.stream_for_sync_is_alphabetized_by_key_for_sync)

        with ps.open_traversal_stream(listener) as dcts:
            recv_far_stream(ps.stream_for_sync_via_stream(dcts))

        return flat


class Case1311_RUMSKALLA:

    def test_100_rumspringa(self):
        _path = _chimi_churri_far_path()

        # from script_lib import filesystem_functions as rsx

        _coll = _build_collection(_path, _no_cheat)

        ps = _coll.COLLECTION_IMPLEMENTATION.PRODUCER_SCRIPT_MODULE

        self.assertTrue(ps.stream_for_sync_is_alphabetized_by_key_for_sync)

        listener = None

        with ps.open_traversal_stream(listener) as dcts:
            dcts = tuple(dcts)  # see it all now

        tups = tuple(ps.stream_for_sync_via_stream(dcts))
        tup, = tups  # assertion
        key_for_sync, dct = tup

        self.assertEqual(dct, {'choo cha': 'foo fa'})
        self.assertEqual(key_for_sync, 'foo fa')


class Case1314DP_filenames_must_look_a_way(_CommonCase):

    def test_100_outputs_no_lines(self):
        self._outputs_no_lines()

    def test_110_says(self):
        _ = self._emission('first_error').to_string()
        self.assertRegex(_, r"^character we don't like \('-'\) in path stem: ")

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def expect_emissions(self):
        yield 'error', 'expression', 'as', 'first_error'

    def given(self):
        # NOTE the dash in the below filename
        return {
                'producer_script_path': executable_fixture('chimi-churry.py'),
                'near_collection': _same_near_collection(),
                }


class Case1315_file_not_found(_CommonCase):

    def test_100_raises_this_happenstance_exception(self):
        def f():
            self._build_end_state()
        _rx = r"^No module named 'script.no_such_script_one'"
        self.assertRaisesRegex(ModuleNotFoundError, _rx, f)

    def expect_emissions(self):
        return iter(())

    def given(self):
        return {
                'producer_script_path': 'script/no_such_script_one.py',
                'near_collection': _same_near_collection(),
                }


# Case1317 was "no metadata row", archived #history-A.1


class Case1319DP_bad_natural_key(_CommonCase):

    def test_100_raises_this_happenstance_exception(self):
        def f():
            self._build_end_state()
        _rx = r"^'choo cha'$"  # it asks for a prototype for this field
        self.assertRaisesRegex(KeyError, _rx, f)

    def expect_emissions(self):
        return iter(())

    def given(self):
        return {
                'producer_script_path': _chimi_churri_far_path(),
                'near_collection': _same_near_collection(),
                }


class Case1320DP_extra_cel(_CommonCase):
    """(may be partially or wholly redundant with (Case0110DP))
    (may be #overloaded. is first coverage of an oblique thing.)
    """

    def test_100_raises_this_happenstance_exception(self):
        def f():
            self._build_end_state()
        _rx = r"'ziff_davis'"
        self.assertRaisesRegex(KeyError, _rx, f)

    def expect_emissions(self):
        return iter(())

    def given(self):
        _ = executable_fixture('exe_110_extra_cel.py')
        return {
                'producer_script_path': _,
                'near_collection': _same_near_collection(),
                }


class Case1322DP_RUM(_CommonCase):

    def test_100_RUM(self):
        _ = self._build_end_state()
        act = _.outputted_lines
        self.assertEqual(len(act), 5)
        self.assertEqual(act[-2], '|thing B|y\n')

    def expect_emissions(self):
        return iter(())

    def given(self):
        return {
                'producer_script_path': executable_fixture('exe_120_endcap_yes_no.py'),  # noqa: E501
                'near_collection': markdown_fixture('0110-endcap-yes-no.md'),
                }


def _chimi_churri_far_path():
    return executable_fixture('exe_100_bad_natural_key.py')


def _same_near_collection():
    """NOTE - this is horrible "lookahead" to need to rely on this other FA

    to test our own. but meh.
    """

    return markdown_fixture('0080-cel-underflow.md')


def _build_collection(path, yes_no, listener=None):
    _kwargs = {'format_name': 'producer-script'} if yes_no else {}
    from kiss_rdb import collection_via_collection_path
    return collection_via_collection_path(path, listener, **_kwargs)


_yes_cheat = True
_no_cheat = False


if __name__ == '__main__':
    unittest.main()

# #history-A.2 turned tests to cases, absorbed another file
# #history-A.1
# #born.
