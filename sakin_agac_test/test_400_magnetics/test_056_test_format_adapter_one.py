import _init  # noqa: F401
from sakin_agac_test.format_adapter import (
        battery,
        )
from modality_agnostic.memoization import (
        memoize,
        )
import unittest


_CommonCase = unittest.TestCase


class Case010_hello(_CommonCase):

    def test_010_magnetic_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_snapshot_builds(self):
        self.assertIsNotNone(_snapshot_one())

    def test_030_we_see_the_values_of_the_field_of_interest(self):  # noqa: ES501
        _ss = _snapshot_one()
        _act = _ss.field_ones
        self.assertEqual(_act, ['xx', 'yy'])


@memoize
def _snapshot_one():
    _this = [
            {'first name': 'jack', 'last name': 'johnson', 'field_one': 'xx'},
            {'first name': 'mork', 'last name': 'mindian', 'field_one': 'yy'},
            ]
    # == == ==

    _format_adapter = _subject_module().FORMAT_ADAPTER
    return battery.SOME_SNAPSHOT(iter(_this), _format_adapter)


def _subject_module():
    import sakin_agac_test.format_adapters.in_memory_dictionaries as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.