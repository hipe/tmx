"""
so:
  - at #born, one main effort wase to clean out a hard-coded awareness
    of "sections" in the stream of items (`header_level`)
  - in order to do that we created this new traversal parameter, the
    pass filter
  - this is the the first case to cover that, doing double-duty covering
    the enclosing format adapter's implementation of it at the same time.
"""


from _init import (
        fixture_executable_path,
        )
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
        _far_path = fixture_executable_path('exe_130_edit_add.py')

        def recv_far_stream(normal_far_st):
            _one = next(normal_far_st)
            flat.append(_one)
            _two = next(normal_far_st)
            flat.append(_two)
            for no_see in normal_far_st:
                raise Exception('no')

        import sakin_agac_test.sync_support as sync_lib
        sync_lib.NORMALIZE_FAR(recv_far_stream, _far_path)
        return flat


if __name__ == '__main__':
    unittest.main()

# #born.
