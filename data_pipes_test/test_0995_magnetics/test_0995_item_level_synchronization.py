# covers: data_pipes/magnetics/synchronized_stream_via_far_stream_and_near_stream  # noqa: E501

"""discussion

the birth of this test suite (file) was for exploring the big question
of whether this collection-centric algorithm for
synchronization can be used at the sub-item level. that is, if collections
are an ordered list of items (each one of which has a natural key), can
we see an item as a collection (that is, an ordered list) of name-value
pairs, where each name-value pair acts as "the item", and the name is
itself the natural key? (more at [#447].)

sometime before #history-A.2 we established that yes, our synchronization
facility can be applied usefully to this use case. the cost:

  - it should be no surprise that you have to write your own per-property
    policy as #here3. but also:

  - new in this edition (#history-A.2) you gotta present the keys
    in alphabetical order #here4

  - for now you have to write your own collision resolver like this @#here1,
    complete with the little dispatcher thing

  - all over the place there are key-value pairs as tuples @#here2,
    confusingly so at times
"""

import unittest


_CommonCase = unittest.TestCase


class Case0995_hello(_CommonCase):

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

    _normal_far_st = new._to_normal_stream()
    _normal_near_st = orig._to_normal_stream()

    import data_pipes.magnetics.synchronized_stream_via_far_stream_and_near_stream as _  # noqa: E501
    sync_st = _.stream_of_mixed_via_sync(
        normal_far_stream=_normal_far_st,
        normal_near_stream=_normal_near_st,
        item_via_collision=_item_via_collision,
        )
    _these = [x for x in sync_st]
    return _MyBusinessObject(**{k: v for (k, v) in _these})


def _item_via_collision(far_key, far_value, near_key, near_value):
    # (#provision [#458.F] four args)

    assert(far_key == near_key)

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
        assert(new_x is orig_x)
        return orig_x

    def tags(new_x, orig_x):
        return orig_x + new_x  # naive


class _MyBusinessObject:

    def __init__(self, first_name, user_ID, tags):
        self.first_name = first_name
        self.user_ID = user_ID
        self.tags = tags

    def _to_normal_stream(bo):
        """so:
        - this feels similar to [#458.E.2] a "native item normalizer"
        - new at #history-A.2, :#here4 you must present the below in
          alphabetical order (or an error is emitted)
        """

        for k in [
                'first_name',
                'tags',
                'user_ID',
                ]:
            x = getattr(bo, k)
            if x is not None:
                yield (k, x)


if __name__ == '__main__':
    unittest.main()

# #history-A.2: default algorithm changed to interfolding. now order must be az
# #history-A.1: got rid of use of format adapter for this test
# #born.