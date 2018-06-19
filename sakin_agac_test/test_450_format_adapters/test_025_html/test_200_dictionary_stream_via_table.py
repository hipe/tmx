# #coverpoint13

from _init import (
        fixture_file_path,
        )
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        memoize,
        )
import unittest


class _CommonCase(unittest.TestCase):

    def _field_names(self):
        return self._shared_state().head_dictionary['field_names']

    def _record(self, k):
        return self._shared_state().business_object_dictionary[k]


class Case100_hello(_CommonCase):

    def test_100_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_200_runs(self):
        self._shared_state()

    def test_300_the_rename_is_reflected_in_the_field_names(self):
        act = self._field_names()
        self.assertIn('grammar', act)
        self.assertNotIn('parses', act)

    def test_350_the_split_is_reflected_in_the_field_names(self):
        act = self._field_names()
        self.assertIn('updated', act)
        self.assertIn('version', act)

    def test_410_a_typical_version_and_date_parse(self):
        dct = self._record('pyparsing')
        self.assertEqual('2014-08', dct['updated'])
        self.assertEqual('v2.0.3', dct['version'])

    def test_420_date_but_no_version(self):
        dct = self._record('plex3')
        self.assertIn('updated', dct)
        self.assertNotIn('version', dct)

    def test_430_gap_after_v_IS_NORMALIZED(self):
        dct = self._record('lepl')
        self.assertEqual('v5.1.3', dct['version'])

    def test_440_version_that_is_just_integer_no_dot(self):
        dct = self._record('berkeley_yacc')
        self.assertEqual(dct['version'], 'v20141128')

    def test_450_complicated_version_with_spaces(self):
        dct = self._record('spark')
        self.assertEqual(dct['version'], 'v0.7 pre-alpha 7')

    def test_460_currently_these_links_are_flattened(self):
        dct = self._record('pyparsing')
        self.assertEqual(dct['used_by'], 'twill')

    @shared_subject
    def _shared_state(self):

        emissions = []

        import modality_agnostic.test_support.listener_via_expectations as lib

        # use_listener = lib.for_DEBUGGING (works)
        use_listener = lib.listener_via_emission_receiver(emissions.append)

        _eek = _subject_module().open_dictionary_stream(
                html_document_path=fixture_file_path('0140-bernstein-subtree.html'),  # noqa: E501
                listener=use_listener,
                )

        def fuzzy_key(dct):
            # #abstraction-candidate (for business)
            _md = rx.search(dct['name'])
            return fn(_md.group(1))
        import re
        rx = re.compile(r'^\[([A-Za-z][a-zA-Z0-9 ]+)\]\(')
        import sakin_agac.magnetics.normal_field_name_via_string as fn

        with _eek as dcts:
            head_dct = next(dcts)
            objs = {fuzzy_key(dct): dct for dct in dcts}

        self.assertEqual(1, len(emissions))

        class _State:
            def __init__(self, _1, _2, _3):
                self.head_dictionary = _1
                self.business_object_dictionary = _2
                self.emissions = _3

        return _State(head_dct, objs, tuple(emissions))


@memoize
def _subject_module():
        import script.tag_lyfe.json_stream_via_bernstein as x
        return x


if __name__ == '__main__':
    unittest.main()

# #born.
