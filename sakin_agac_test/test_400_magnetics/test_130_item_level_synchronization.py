# covers: sakin_agac/magnetics/synchronized_stream_via_new_stream_and_original_stream  # noqa: E501

"""discussion

we want this to hew closer to our catalyst use case without actually
starting to implement it yet, because there's certainly broadly applicable
theory yet to be gained from this, the descent into recursion with
synchronization.

the big open question is whether this collection-centric algorithm for
synchronization can be used at the sub-item level. that is, if collections
are an ordered list of items (each one of which has a natural key), can
we see an item as a collection (that is, an ordered list) of name-value
pairs, where each name-value pair acts as "the item", and the name is
itself the natural key?

this is where policy will really start to matter.

SO, this is a rough sketch, but here is the uptake:

  - yes we *can* use the synchronizer on arbirary business objects

  - yes it is perhaps worth it

  - it should be no surprise that you have to write your own per-property
    policy as #here3. but also:

  - for now you have to write your own collision resolver like this @#here1,
    complete with the little dispatcher thing

  - all over the place there are key-value pairs as tuples @#here2,
    confusingly so at times
"""

from _init import (
        sanity
        )
from modality_agnostic.memoization import (
        memoize,
        )
import unittest


_CommonCase = unittest.TestCase


class Case010_hello(_CommonCase):

    def test_yes_we_can(self):
        _orig = _MyBusinessObject(
                first_name='jim',
                user_ID='012',
                tags=['#aa', '#bb'],
                )
        _new = _MyBusinessObject(
                first_name='james',
                user_ID='012',
                tags=['#bb', '#cc'],
                )
        o = _my_sync(_orig, _new)

        self.assertEqual(o.first_name, 'james')  # per policy, new name wins
        self.assertEqual(o.user_ID, '012')  # no chnage
        self.assertEqual(o.tags, ['#aa', '#bb', '#bb', '#cc'])  # etc


def _my_sync(orig, new):  # #here1

    import sakin_agac.magnetics.synchronized_stream_via_new_stream_and_original_stream as x  # noqa: E501
    f = _MyBusinessObject.name_value_pairs_via_doohah
    sync_st = x.stream_of_mixed_via_sync(
        natural_key_via_far_item=_natty_key_via_object,
        far_item_stream=f(new),
        natural_key_via_near_item=_natty_key_via_object,
        near_item_stream=f(orig),
        item_via_collision=_item_via_collision,
        )
    _these = [x for x in sync_st]
    return _MyBusinessObject(**{k: v for (k, v) in _these})


@memoize
def _format_adapter():
    import sakin_agac.magnetics.format_adapter_via_definition as x
    return x(
            item_via_collision=_item_via_collision,
            item_stream_via_native_stream=None,
            natural_key_via_object=_natty_key_via_object,
            )


def _item_via_collision(far_item, near_item):  # #here1

    far_key, far_value = far_item
    near_key, near_value = near_item

    None if far_key == near_key else sanity()

    f = getattr(_resolve_collision, near_key)

    _merged_value = f(far_value, near_value)  # #here2
    # merged value is often the same as one or the other, so there are times
    # we could re-use the existing tuples instead if we wanted to save memory.
    # (did something like this before #history-A.1.))

    return (near_key, _merged_value)


class _resolve_collision:  # :#here3

    def first_name(new_x, orig_x):
        return new_x  # allow name change

    def user_ID(new_x, orig_x):
        if new_x is not orig_x:
            sanity()
        return orig_x

    def tags(new_x, orig_x):
        return orig_x + new_x  # naive


def _natty_key_via_object(kv):
    return kv[0]  # #here2


class _MyBusinessObject:

    def __init__(self, first_name, user_ID, tags):
        self.first_name = first_name
        self.user_ID = user_ID
        self.tags = tags

    def name_value_pairs_via_doohah(bo):
        # very close to [#408.E] a normal `name_value_pairs_via_nat..` function
        for k in [
                'first_name',
                'user_ID',
                'tags',
                ]:
            x = getattr(bo, k)
            if x is not None:
                yield (k, x)


if __name__ == '__main__':
    unittest.main()

# #history-A.1: got rid of use of format adapter for this test
# #born.
