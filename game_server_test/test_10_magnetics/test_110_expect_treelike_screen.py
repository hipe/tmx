"""expect treelike screen

this is #meta-testing
"""

import os, sys, unittest

# boilerplate
_ = os.path
path = _.dirname(_.dirname(_.dirname(_.abspath(__file__))))
a = sys.path
if a[0] != path:
    a.insert(0, path)
# end boilerplate


from game_server_test import helper
shared_subject = helper.shared_subject


import game_server
memoize = game_server.memoize

class _NormalLinerCase(unittest.TestCase):

    # -- assertion

    def _this_many_lines(self, num):
        _s_a = self._lines()
        self.assertEqual(num, len(_s_a))

    def _lines_via_big_string(self, big_s):
        _iter = _subject_module()._line_stream_via_big_string(big_s)
        return [ x for x in _iter ]


class Case010_empty_string(_NormalLinerCase):

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_zero_lines(self):
        self._this_many_lines(0)

    @shared_subject
    def _lines(self):
        return self._lines_via_big_string('')  # EMPTY_S


class Case020_one_string_no_newline(_NormalLinerCase):

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_one_line__content_OK(self):
        _s_a = self._lines()
        self.assertEqual(['foo'], _s_a)

    @shared_subject
    def _lines(self):
        return self._lines_via_big_string('foo')


class Case030_one_string_yes_newline(_NormalLinerCase):

    def test_010_one_line__content_OK(self):
        _s_a = self._lines()
        self.assertEqual(["foo\n"], _s_a)

    @shared_subject
    def _lines(self):
        return self._lines_via_big_string("foo\n")


class Case040_blank_lines_inside(_NormalLinerCase):

    def test_010_three_lines__content_OK(self):
        _s_a = self._lines()
        self.assertEqual(["foo\n", "\n", "bar\n"], _s_a)

    @shared_subject
    def _lines(self):
        return self._lines_via_big_string("foo\n\nbar\n")


def _subject_module():
    import game_server_test.expect_treelike_screen as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
