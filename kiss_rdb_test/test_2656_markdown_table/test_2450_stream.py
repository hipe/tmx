from kiss_rdb_test.common_initial_state import (
        functions_for)
from modality_agnostic.test_support.structured_emission import (
        listener_and_emissioner_for)
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject)
import unittest


fixture_path = functions_for('markdown').fixture_path


class _CommonCase(unittest.TestCase):

    def _build_state_expecting_some_emssions(self, path):
        listener, emissioner = listener_and_emissioner_for(self)
        business_objects = self._run(path, listener)
        chan, payloader = emissioner()
        return _State(business_objects, ((chan, payloader),))

    def _build_state_expecting_no_emissions(self, path):
        business_objects = self._run(path, _failey_listener)
        return _State(business_objects)

    def _run(self, path, listener):

        from kiss_rdb import collection_via_collection_path
        coll = collection_via_collection_path(
                collection_path=path,
                adapter_variant='THE_ADAPTER_VARIANT_FOR_STREAMING',
                listener=listener)
        if coll is None:
            return (), None  # (Case2449DP)

        cm = coll.YIKES__.OPEN_TRAVERSAL_STREAM__(listener)
        with cm as dcts:
            business_objects = tuple(dcts)
        return business_objects


class Case2449DP_fail(_CommonCase):

    def test_100_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_200_fails(self):
        (chan, payloader), = self._state().emissions
        self.assertSequenceEqual(chan,
                ('error', 'structure', 'cannot_load_collection', 'file_has_no_extname'))  # noqa: E501
        _reason = payloader()['reason']
        self.assertRegex(_reason, r'^cannot infer .+om file with no extension')

    @shared_subject
    def _state(self):
        _md = fixture_path('0080-no-extension')
        return self._build_state_expecting_some_emssions(_md)


# Case2450  #midpoint


class Case2451_work(_CommonCase):

    def test_200_runs(self):
        self.assertIsNotNone(self._state())

    def test_300_sparse_is_sparse(self):
        t = self._state().business_objects
        self.assertIn('stamina', t[0])
        self.assertNotIn('stamina', t[1])

    def test_400_empty_is_possible(self):
        dct = self._state().business_objects[-1]
        self.assertEqual(len(dct), 0)

    @shared_subject
    def _state(self):
        _md = fixture_path('0115-stream-me.md')
        return self._build_state_expecting_no_emissions(_md)


class _State:
    def __init__(self, business_objects, emissions=None):
        self.business_objects = business_objects
        self.emissions = emissions


def _failey_listener(*a):
    raise Exception('expecting no emissions')


def _subject_module():
    import kiss_rdb.cli.LEGACY_stream as mod
    return mod


if __name__ == '__main__':
    unittest.main()

# #born.
