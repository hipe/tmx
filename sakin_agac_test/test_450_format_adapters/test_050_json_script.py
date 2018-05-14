# #covers: [isomorphic asset file]

import _init as ts  # "test support"
from sakin_agac import (
        sanity,
        )
from modality_agnostic.memoization import (
        memoize,
        )
import unittest


class _CommonCase(unittest.TestCase):

    def _fail_against(self, s):

        msgs, listener = ts.minimal_listener_spy()

        _cr = _build_collection_reference(s)
        _sess = _cr.session_for_sync_request(None, listener)
        with _sess as doo_hah:
            None if doo_hah is None else sanity()

        None if 1 == len(msgs) else sanity()
        return msgs[0]


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
        self.assertRegex(_msg, "\\bcharacter we don't like: '-'")

    def test_500_RUMSKALLA(self):

        _path = ts.fixture_executable_path('100_chimi_churri.py')
        _cref = _build_collection_reference(_path)
        # from script_lib import filesystem_functions as rsx
        rsx = "you don't need filesystem resources yet"
        _sess = _cref.session_for_sync_request(rsx, 'listener')
        with _sess as sync_request:
            sync_params = sync_request.release_sync_parameters()
            dict_stream = sync_request.release_item_stream()
        self.assertEqual(sync_params.natural_key_field_name, 'xx yy')
        these = [x for x in dict_stream]
        self.assertEqual(len(these), 1)
        self.assertEqual(these[0], {'choo cha': 'foo fa'})


def _build_collection_reference(string):
    return _subject_format_adapter().FORMAT_ADAPTER.collection_reference_via_string(string)  # noqa: E501


@memoize
def _subject_format_adapter():
    import sakin_agac.format_adapters.json_script as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
