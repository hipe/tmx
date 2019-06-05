""".#birth coincides with the *unification* of this test unit's counterpart

facility (subject under test) from its many implementations down into one.
As such, the asset code is contemporaneous with #birth but the "spirit" of
both the cases and the SUT may be up to 1.5 years older.
"""

import _init  # noqa: F401
from modality_agnostic.memoization import (
         dangerous_memoize as shared_subject)
import unittest


_CommonCase = unittest.TestCase


class Case1010_basic_write(_CommonCase):

    def test_100_returns_num_bytes_wrote_no_matter_what_you_result_in(self):
        def f(s):
            seen.append(s)
        seen = []
        io = _write_only_IO_proxy(f)
        res = io.write('ohai')
        self.assertSequenceEqual(seen, ('ohai',))
        self.assertEqual(res, 4)


class Case1020_flush(_CommonCase):

    def test_100_there_is_no_flush_normally(self):
        o = _write_only_IO_proxy(None)
        self.assertFalse(hasattr(o, 'flush'))

    def test_200_but_you_do_have_one_if_you_pass_one(self):
        def f():
            nonlocal seen
            seen = True
        seen = False
        o = _write_only_IO_proxy(None, flush=f)
        self.assertTrue(hasattr(o, 'flush'))
        o.flush()
        self.assertTrue(seen)

    def test_300_unlike_write_you_yes_get_the_result_back(self):
        def f():
            nonlocal count
            count += 5
            return count
        count = 0
        o = _write_only_IO_proxy(None, flush=f)
        self.assertEqual(o.flush(), 5)
        self.assertEqual(count, 5)


class Case1030_context_manager(_CommonCase):

    def test_100_wrote(self):
        writes = self.o()['writes']
        self.assertSequenceEqual(writes, ('ohai',))

    def test_200_called_the_close_callback(self):
        i = self.o()['count']
        self.assertEqual(i, 1)

    def test_300_inside_tonext_manager_is_same_object(self):
        yes = self.o()['is_same']
        self.assertTrue(yes)

    @shared_subject
    def o(self):
        def f():
            nonlocal count
            count += 1
            return 'NO_SEE'
        count = 0
        writes = []
        o = _write_only_IO_proxy(
                writes.append,
                on_OK_exit=f,
                )
        with o as fh:
            is_same = o is fh
            fh.write('ohai')

        return {
                'count': count,
                'writes': writes,
                'is_same': is_same,
                }


def _write_only_IO_proxy(*args, **kwargs):
    from modality_agnostic import io as io_lib
    return io_lib.write_only_IO_proxy(*args, **kwargs)


if __name__ == '__main__':
    unittest.main()

# #birth.
