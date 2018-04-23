"""cover the magnetic of the same name (stem)."""

from _init import (
        fixture_directory,
        )
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        )
import unittest


_CommonCase = unittest.TestCase


class Case010_main(_CommonCase):

    def test_010_magnetic_loads(self):
        self.assertIsNotNone(_subject_magnetic())

    def test_020_magnetic_call_happens(self):
        self.assertIsNotNone(self._items)

    def test_030_item_constituency_without_asserting_order(self):
        # NOTE - now this asserts that `name` means lowercase with underscores
        a = self._items
        _exp = set(['chupa_cabre', 'oh_hello'])
        _act = set(cmd.name for cmd in a)
        self.assertEqual(_exp, _act)

    @property
    @shared_subject
    def _items(self):
        _gen = _subject_magnetic()(_this_one_module())
        return [x for x in _gen]


def _this_one_module():
    fixture_directory.hello()
    import modality_agnostic_test.fixture_directories._010_cha_cha as x
    return x


def _subject_magnetic():
    import modality_agnostic.magnetics.command_stream_via_directory as x
    return x.SELF


if __name__ == '__main__':
    unittest.main()

# #born.
