"""cover the magnetic of the same name (stem)."""

from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject
import unittest


CommonCase = unittest.TestCase


class Case8313_the_only_case(CommonCase):

    def test_010_magnetic_loads(self):
        self.assertIsNotNone(_subject_magnetic())

    def test_020_magnetic_call_happens(self):
        self.assertIsNotNone(self._items)

    def test_030_item_constituency_without_asserting_order(self):
        _exp = {'chupa_cabre', 'oh_hello'}
        _act = set(name for name, mod in self._items)
        self.assertEqual(_exp, _act)

    @shared_subject
    def _items(self):
        itr = _subject_magnetic()(_this_one_module())
        return tuple(itr)


def _this_one_module():
    # 'fixture-directories'
    import modality_agnostic_test.fixture_directories._010_cha_cha as x
    return x


def _subject_magnetic():
    from modality_agnostic.magnetics.commands_via_directory import (
            commands_via_MODULE)
    return commands_via_MODULE


if __name__ == '__main__':
    unittest.main()

# #born.
