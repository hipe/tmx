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

    def test_030_first_item_in_the_collection_has_natural_key__and__looks_right(self):  # noqa: ES501
        x = battery.some_natural_key_of_first_item(_snapshot_one(), self)
        self.assertEqual('jack johnson', x)


@memoize
def _snapshot_one():
    _this = [
            {'first name': 'jack', 'last name': 'johnson'},
            ]
    # == == ==
    _format_adapter = _subject_module()
    _item_stream = _format_adapter.item_stream_via_native_stream(
            stream=iter(_this),
            natural_key_via_object=_natural_key_via_object,
            )
    return battery.SOME_SNAPSHOT(_item_stream)


def _natural_key_via_object(x):
    return '{} {}'.format(x['first name'], x['last name'])


def _subject_module():
    import sakin_agac_test.format_adapters.in_memory_dictionaries as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
