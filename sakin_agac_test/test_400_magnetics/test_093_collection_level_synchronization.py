# covers: sakin_agac/magnetics/synchronized_stream_via_new_stream_and_original_stream  # noqa: E501

from _init import (
        sanity,
        )
import unittest


class _CommonCase(unittest.TestCase):

    def _expect_these(self, *s_a):

        _ = _build_snapshot(self.original_collection(), self.new_collection())
        self.assertEqual(_.result, s_a)


class Case010_hello(_CommonCase):

    def test_010_magnetic_loads(self):
        self.assertIsNotNone(_subject_module())


class Case020_none_down_on_to_none_produces_none(_CommonCase):

    def test(self):
        self._expect_these()

    def new_collection(self):
        return ()

    def original_collection(self):
        return ()


class Case030_none_down_on_to_some_is_unsurprising(_CommonCase):

    def test(self):
        self._expect_these('a', 'b', 'c')

    def new_collection(self):
        return ()

    def original_collection(self):
        return ('a', 'b', 'c')


class Case040_some_down_on_to_none_is_unsurprising(_CommonCase):

    def test(self):
        self._expect_these('d', 'e', 'f')

    def new_collection(self):
        return ('d', 'e', 'f')

    def original_collection(self):
        return ()


class Case050_some_down_on_to_some_no_collisions_appends(_CommonCase):

    def test(self):
        self._expect_these('a', 'b', 'c', 'd', 'e', 'f')

    def new_collection(self):
        return ('d', 'e', 'f')

    def original_collection(self):
        return ('a', 'b', 'c')


class Case060_some_down_on_to_some_yes_collisions(_CommonCase):

    def test(self):
        self._expect_these('a', 'B', 'c', 'D', 'e', 'f')

    def new_collection(self):
        return ('b', 'd', 'e', 'f')

    def original_collection(self):
        return ('a', 'b', 'c', 'd')


class _build_snapshot:

    def __init__(self, orig, new):

        def identity(s):
            return s

        _st = _subject_module().stream_of_mixed_via_sync(
            natural_key_via_far_user_item=identity,
            far_stream=new,
            natural_key_via_near_user_item=identity,
            near_stream=orig,
            item_via_collision=_item_via_collision,
            )

        self.result = tuple(x for x in _st)


def _item_via_collision(far_s, near_s):
    None if far_s == near_s else sanity()
    return near_s.upper()


def _subject_module():
    import sakin_agac.magnetics.synchronized_stream_via_new_stream_and_original_stream as x  # noqa: E501
    return x


if __name__ == '__main__':
    unittest.main()

# #history-A.1: removed use of format adapter from this test
# #born.
