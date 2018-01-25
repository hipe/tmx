"""cover the magnetic of the same name (stem)."""

import os, sys, unittest

# boilerplate
_ = os.path
path = _.dirname(_.dirname(_.dirname(_.abspath(__file__))))
a = sys.path
if a[0] != path:
    a.insert(0, path)
# end boilerplate


import game_server_test.helper as helper

shared_subject = helper.shared_subject
memoize = helper.memoize

_CommonCase = unittest.TestCase

class Case1_main(_CommonCase):

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
        from game_server_test.fixture_directories import _010_cha_cha as arg
        _gen = _subject_magnetic()(arg)
        return [ x for x in _gen ]


def _subject_magnetic():
    from game_server._magnetics import command_stream_via_directory
    return command_stream_via_directory.SELF


if __name__ == '__main__':
    unittest.main()

# #born.
