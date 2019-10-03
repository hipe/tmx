"""
so (chronologically):
  - at #born, one main effort wase to clean out a hard-coded awareness
    of "sections" in the stream of items (`header_level`)
  - in order to do that we created this new traversal parameter, the
    pass filter
  - this is the the first case to cover that, doing double-duty covering
    the enclosing format adapter's implementation of it at the same time.
  - the change in #history-A.1 is exemplary of the associated re-architecting.
"""

from data_pipes_test.common_initial_state import executable_fixture
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject)
import unittest


_CommonCase = unittest.TestCase


class Case1510DP_OHAI(_CommonCase):

    def test_100_runs(self):
        self.assertIsNotNone(self._state())

    def test_200_skipped_the_header_record(self):
        _ = [pair[0] for pair in self._state()]
        self.assertEqual(_, ['four', 'seven'])

    @shared_subject
    def _state(self):
        flat = []

        listener = None  # or throwing listener
        _far_path = executable_fixture('exe_130_edit_add.py')

        from kiss_rdb.cli.LEGACY_stream import module_via_path
        mod = module_via_path(_far_path, listener)

        def recv_far_stream(normal_far_st):
            _one = next(normal_far_st)
            flat.append(_one)
            _two = next(normal_far_st)
            flat.append(_two)
            for no_see in normal_far_st:
                raise Exception('no')

        assert(mod.stream_for_sync_is_alphabetized_by_key_for_sync)

        with mod.open_traversal_stream(listener) as dcts:
            recv_far_stream(mod.stream_for_sync_via_stream(dcts))

        return flat


if __name__ == '__main__':
    unittest.main()

# #history-A.1: no more sync-side traversal-mapping
# #born.
