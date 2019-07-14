# #covers: [isomorphic asset file]
from data_pipes_test.common_initial_state import (
        build_end_state_commonly,
        markdown_fixture,
        executable_fixture)
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        lazy)
from modality_agnostic.test_support.structured_emission import (
        minimal_listener_spy)
import unittest


class _CommonCase(unittest.TestCase):

    # -- assertion support

    def _outputs_no_lines(self):
        _lines = self._end_state().outputted_lines
        self.assertEqual(len(_lines), 0)

    def _emission(self, name):
        return self._end_state().actual_emission_index.actual_emission_via_name(name)  # noqa: E501

    def _fail_against(self, s):

        msgs, listener = minimal_listener_spy()

        _cr = _build_collection_reference(s)

        cm = _cr.open_sync_request(
                cached_document_path=None,
                datastore_resources=None,
                listener=listener)
        assert(not cm)
        msg, = msgs  # assertion
        return msg

    _build_end_state = build_end_state_commonly


class Case1312(_CommonCase):

    def test_010_format_adapter_loads(self):
        self.assertIsNotNone(_subject_format_adapter())

    def test_100_collection_reference_builds(self):
        _cr = _build_collection_reference('//Any-PATH at all 100.xx')
        self.assertIsNotNone(_cr)

    def test_210_this_one_file_fails_because_absolute_path_too_crazy(self):
        _msg = self._fail_against('/egads/ohai.py')
        self.assertRegex(_msg, r'\babsolute path outside of ecosystem\b')

    def test_220_this_one_file_fails_because_invalid_chars_in_name(self):
        _path = executable_fixture('no-ent.py')
        _msg = self._fail_against(_path)
        self.assertRegex(_msg, "\\bcharacter we don't like[^a-zA-Z]+-")

    def test_500_RUMSKALLA(self):
        _path = _chimi_churri_far_path()
        _cref = _build_collection_reference(_path)
        # from script_lib import filesystem_functions as rsx
        rsx = "you don't need filesystem resources yet"
        _cm = _cref.open_sync_request(
                cached_document_path=None,
                datastore_resources=rsx,
                listener=__file__)
        with _cm as sync_response:
            sync_params = sync_response.release_traversal_parameters()
            dict_stream = sync_response.release_dictionary_stream()
        self.assertEqual(sync_params.natural_key_field_name, 'xyzz 01')
        these = [x for x in dict_stream]
        self.assertEqual(len(these), 1)
        self.assertEqual(these[0], {'choo cha': 'foo fa'})


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
                'near_collection': _same_near_collection(),
                'far_collection': executable_fixture('chimi-churry.py'),
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
                'near_collection': _same_near_collection(),
                'far_collection': 'script/no_such_script_one.py',
                }


class Case1317_no_metadata_row(_CommonCase):

    def test_100_raises_this_happenstance_exception(self):
        def f():
            self._build_end_state()
        _rx = r"\bunexpected keyword argument 'choovo chavo'"
        self.assertRaisesRegex(TypeError, _rx, f)

    def expect_emissions(self):
        return iter(())

    def given(self):
        return {
                'near_collection': _same_near_collection(),
                'far_collection': executable_fixture('exe_080_no_metadata.py'),
                }


class Case1319_bad_human_key(_CommonCase):

    def test_100_raises_this_happenstance_exception(self):
        def f():
            self._build_end_state()
        _rx = r"^'xyzz 01'$"
        self.assertRaisesRegex(KeyError, _rx, f)

    def expect_emissions(self):
        return iter(())

    def given(self):
        return {
                'near_collection': _same_near_collection(),
                'far_collection': _chimi_churri_far_path()
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
                'near_collection': _same_near_collection(),
                'far_collection': _,
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
                'near_collection': markdown_fixture('0110-endcap-yes-no.md'),
                'far_collection': executable_fixture('exe_120_endcap_yes_no.py'),  # noqa: E501
                }


def _chimi_churri_far_path():
    return executable_fixture('exe_100_bad_natural_key.py')


def _same_near_collection():
    """NOTE - this is horrible "lookahead" to need to rely on this other FA

    to test our own. but meh.
    """

    return markdown_fixture('0080-cel-underflow.md')


def _build_collection_reference(string):
    return _subject_format_adapter().FORMAT_ADAPTER.collection_reference_via_string(string)  # noqa: E501


@lazy
def _subject_format_adapter():
    import data_pipes.format_adapters.json_script as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
