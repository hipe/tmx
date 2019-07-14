# #covers: [isomorphic asset file]

from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        lazy)
import unittest

fixture_executable_path = ts.fixture_executable_path
fixture_file_path = ts.fixture_file_path


class _CommonCase(unittest.TestCase):

    # -- assertion support

    def _outputs_no_lines(self):
        _lines = self._end_state().outputted_lines
        self.assertEqual(len(_lines), 0)

    def _emission(self, name):
        return self._end_state().actual_emission_index.actual_emission_via_name(name)  # noqa: E501

    def _fail_against(self, s):

        msgs, listener = ts.minimal_listener_spy()

        _cr = _build_collection_reference(s)

        cm = _cr.open_sync_request(
                cached_document_path=None,
                datastore_resources=None,
                listener=listener)
        assert(not cm)
        msg, = msgs  # assertion
        return msg


    _build_end_state = ts.build_end_state_commonly


class Case100(_CommonCase):

    def test_010_format_adapter_loads(self):
        self.assertIsNotNone(_subject_format_adapter())

    def test_100_collection_reference_builds(self):
        _cr = _build_collection_reference('//Any-PATH at all 100.xx')
        self.assertIsNotNone(_cr)

    def test_210_this_one_file_fails_because_absolute_path_too_crazy(self):
        _msg = self._fail_against('/egads/ohai.py')
        self.assertRegex(_msg, r'\babsolute path outside of ecosystem\b')

    def test_220_this_one_file_fails_because_invalid_chars_in_name(self):
        _path = ts.fixture_file_path('no-ent.py')
        _msg = self._fail_against(_path)
        self.assertRegex(_msg, "\\bcharacter we don't like[^a-zA-Z]+-")

    def test_500_RUMSKALLA(self):  # :#coverpoint7.6

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


class Case250_filenames_must_look_a_way(_CommonCase):  # #coverpoint7.1

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
        return {
                'near_collection': _same_near_collection(),
                'far_collection': fixture_file_path('chimi-churry.py'),  # NOTE - dash  # noqa: E501
                }


class Case260_file_not_found(_CommonCase):

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


class Case270_no_metadata_row(_CommonCase):  # #coverpoint7.2

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
                'far_collection': fixture_executable_path('exe_080_no_metadata.py'),  # noqa: E501
                }


class Case280_bad_human_key(_CommonCase):  # :#coverpoint7.3

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


class Case290_extra_cel(_CommonCase):  # #coverpoint7.4
    """(may be partially or wholly redundant with #coverpoint1.1)
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
        _ = fixture_executable_path('exe_110_extra_cel.py')
        return {
                'near_collection': _same_near_collection(),
                'far_collection': _,
                }


class Case300_RUM(_CommonCase):  # #coverpoint7.5
    """(RUM)"""

    def test_100_RUM(self):
        _ = self._build_end_state()
        act = _.outputted_lines
        self.assertEqual(len(act), 5)
        self.assertEqual(act[-2], '|thing B|y\n')

    def expect_emissions(self):
        return iter(())

    def given(self):
        return {
                'near_collection': fixture_file_path('0110-endcap-yes-no.md'),
                'far_collection': fixture_executable_path('exe_120_endcap_yes_no.py'),  # noqa: E501
                }


def _chimi_churri_far_path():
    return fixture_executable_path('exe_100_bad_natural_key.py')


def _same_near_collection():
    """NOTE - this is horrible "lookahead" to need to rely on this other FA

    to test our own. but meh.
    """

    return fixture_file_path('0080-cel-underflow.md')


def _build_collection_reference(string):
    return _subject_format_adapter().FORMAT_ADAPTER.collection_reference_via_string(string)  # noqa: E501


@lazy
def _subject_format_adapter():
    import sakin_agac.format_adapters.json_script as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
