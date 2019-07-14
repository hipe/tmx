import data_pipes_test.LEGACY_format_adapter_canon as canon
from modality_agnostic.memoization import lazy
import unittest


_CommonCase = unittest.TestCase


class Case1102_hello(_CommonCase):

    def test_010_magnetic_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_snapshot_builds(self):
        self.assertIsNotNone(_snapshot_one())

    def test_030_we_see_the_values_of_the_field_of_interest(self):  # noqa: ES501
        _ss = _snapshot_one()
        _act = _ss.field_ones
        self.assertEqual(_act, ['xx', 'yy'])


@lazy
def _snapshot_one():
    _this = [
            {'first name': 'jack', 'last name': 'johnson', 'field_one': 'xx'},
            {'first name': 'mork', 'last name': 'mindian', 'field_one': 'yy'},
            ]
    # == == ==

    _format_adapter = _subject_module().FORMAT_ADAPTER
    return canon.SOME_SNAPSHOT(iter(_this), _format_adapter)


def _subject_module():
    import data_pipes_test.format_adapters.in_memory_dictionaries as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
