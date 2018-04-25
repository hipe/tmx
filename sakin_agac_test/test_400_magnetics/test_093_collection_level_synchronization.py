# covers: sakin_agac/magnetics/synchronized_stream_via_new_stream_and_original_stream  # noqa: E501

import _init  # noqa: F401
from modality_agnostic.memoization import (
       memoize,
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
        fa = format_adapter()
        orig_st = fa.item_stream_via_native_stream(orig)
        new_st = fa.item_stream_via_native_stream(new)
        sync_st = fa.synchronized_stream_via_these_two(new_st, orig_st)
        result = []
        for x in sync_st:
            result.append(x.natural_key)
        self.result = tuple(result)


@memoize
def format_adapter():
    import sakin_agac.magnetics.format_adapter_via_definition as x
    return x(
            item_via_collision=_item_via_collision,
            item_stream_via_native_stream=None,
            natural_key_via_object=lambda x: x,
            )


def _item_via_collision(new_item, orig_item):

    k = orig_item.natural_key
    if new_item.natural_key != k:
        raise Exception('sanity')

    return orig_item.__class__(
            natural_key=k.upper(),
            NATIVE_OBJECT='«nada»',
            )


def _subject_module():
    import sakin_agac.magnetics.synchronized_stream_via_new_stream_and_original_stream as x  # noqa: E501
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
