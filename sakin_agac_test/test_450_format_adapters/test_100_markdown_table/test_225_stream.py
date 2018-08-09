from _init import (
        fixture_file_path,
        minimal_listener_spy,
        )
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        )
import unittest


class _CommonCase(unittest.TestCase):

    def _build_state_expecting_some_emssions(self, path):
        emissions, listener = minimal_listener_spy()
        business_objects, first = self._run(path, listener)
        return _State(business_objects, first, tuple(emissions))

    def _build_state_expecting_no_emissions(self, path):
        business_objects, first = self._run(path, _failey_listener)
        return _State(business_objects, first)

    def _run(self, path, listener):
        _cm = _subject_module().open_traversal_stream(path, listener)
        with _cm as dcts:
            first = None
            try:
                first = next(dcts)
            except StopIteration:
                pass
            business_objects = tuple(dct for dct in dcts)
        return business_objects, first


class Case100_fail(_CommonCase):  # #coverpoin13.1

    def test_100_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_200_fails(self):
        _tup = self._state().emissions
        self.assertRegex(_tup[0], r"^can't infer [a-z]+ type .+ no extensio")

    @shared_subject
    def _state(self):
        _md = fixture_file_path('file-with-no-extension')
        return self._build_state_expecting_some_emssions(_md)


class Case150_work(_CommonCase):

    def test_200_runs(self):
        self.assertIsNotNone(self._state())

    def test_300_sparse_is_sparse(self):  # #coverpoint13.2
        t = self._state().business_objects
        self.assertIn('stamina', t[0])
        self.assertNotIn('stamina', t[1])

    def test_400_empty_is_possible(self):
        dct = self._state().business_objects[-1]
        self.assertEqual(len(dct), 0)

    @shared_subject
    def _state(self):
        _md = fixture_file_path('0115-stream-me.md')
        return self._build_state_expecting_no_emissions(_md)


class _State:
    def __init__(self, _1, _2, _3=None):
        self.business_objects = _1
        self.meta_data = _2
        self.emissions = _3


def _failey_listener(*a):
    raise Exception('expecting no emissions')


def _subject_module():
    import script.stream as mod
    return mod


if __name__ == '__main__':
    unittest.main()

# #born.
