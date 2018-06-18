# #coverpoint12

from _init import (
        fixture_file_path,
        )
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        memoize,
        )
import unittest


_CommonCase = unittest.TestCase


class Case100_hello(_CommonCase):

    def test_100_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_200_runs(self):
        self._shared_state()

    def test_300_new_in_this_thing_field_names_in_schema_record(self):
        # coverpoint [#708.2.2]
        _act = self._shared_state().head_dictionary['field_names']
        _exp = ('name', 'grammar', 'module', 'python', 'comment')
        self.assertSequenceEqual(_act, _exp)

    def test_400_url_with_tail_only_is_qualified(self):  # coverpt [#708.2.3]
        row = self._business_row(1)
        self.assertIn('wiki.python', row['name'])

    def test_410_full_url_are_left_alone(self):
        row = self._business_row(0)
        self.assertNotIn('wiki.python', row['name'])

    def test_420_dicts_are_sparse(self):  # coverpoint [#708.2.4]
        row1 = self._business_row(0)
        row2 = self._business_row(1)

        names1 = [k for k in row1]
        names2 = [k for k in row2]

        self.assertIn('grammar', names2)
        self.assertNotIn('grammar', names1)

    def _business_row(self, offset):
        return self._shared_state().business_objects[offset]

    def test_500_emits_one_thing(self):
        """emits one thing - #fragile"""

        one, = self._shared_state().emissions
        self.assertSequenceEqual(one.channel, ('info', 'expression'))

    @shared_subject
    def _shared_state(self):

        emissions = []

        import modality_agnostic.test_support.listener_via_expectations as lib

        # use_listener = lib.for_DEBUGGING (works)
        use_listener = lib.listener_via_emission_receiver(emissions.append)

        _eek = _subject_module().open_dictionary_stream(
                html_document_path=fixture_file_path('0130-tag-subtree.html'),
                listener=use_listener,
                )

        with _eek as dcts:
            head_dct = next(dcts)
            objs = [dct for dct in dcts]

        class _State:
            def __init__(self, _1, _2, _3):
                self.head_dictionary = _1
                self.business_objects = _2
                self.emissions = _3

        return _State(head_dct, tuple(objs), tuple(emissions))


@memoize
def _subject_module():
        import script.tag_lyfe.json_stream_via_python_wiki as x
        return x


if __name__ == '__main__':
    unittest.main()

# #born.
