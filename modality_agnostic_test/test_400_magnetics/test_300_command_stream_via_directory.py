"""cover the magnetic of the same name (stem)."""

import os, sys, unittest

# boilerplate
_ = os.path
path = _.dirname(_.dirname(_.dirname(_.abspath(__file__))))
a = sys.path
if a[0] != path:
    a.insert(0, path)
# end boilerplate


from helper import (
        memoize,
        shared_subject,
        )

_CommonCase = unittest.TestCase

class Case010_main(_CommonCase):

    def test_010_magnetic_loads(self):
        self.assertIsNotNone(_subject_magnetic())

    def test_020_magnetic_call_happens(self):
        self.assertIsNotNone(self._items)

    def test_030_item_constituency_without_asserting_order(self):
        # NOTE - now this asserts that `name` means lowercase with underscores
        l = self._items;
        _exp = set(['chupa_cabre', 'oh_hello'])
        _act = set( cmd.name for cmd in l )
        self.assertEqual(_exp, _act)

    @property
    @shared_subject
    def _items(self):
        _gen = _subject_magnetic()(_this_one_module())
        return [ x for x in _gen ]


def _this_one_module():
    from game_server_test.fixture_directories import _010_cha_cha as mod
    return mod


def _subject_magnetic():
    from game_server._magnetics import command_stream_via_directory
    return command_stream_via_directory.SELF


if __name__ == '__main__':
    unittest.main()

# #born.
