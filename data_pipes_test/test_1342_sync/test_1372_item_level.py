# covers: data_pipes/magnetics/flat_map_via_far_collection  # noqa: E501

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


class Case1372_hello(unittest.TestCase):

    def test_yes_we_can(self):
        _orig = _MyBusinessObject(
                first_name='jim',
                user_ID='012',
                tags=['#aa', '#bb'])
        _new = _MyBusinessObject(
                first_name='james',
                user_ID='012',
                tags=['#bb', '#cc'])
        o = _my_sync(_orig, _new)

        self.assertEqual(o.first_name, 'james')  # per policy, new name wins
        self.assertEqual(o.user_ID, '012')  # no chnage
        self.assertEqual(o.tags, ['#aa', '#bb', '#bb', '#cc'])  # etc


def _my_sync(orig, new):  # #here1
    value_dct = {k: v for k, v in _pairs_from_my_sync(orig, new)}
    return _MyBusinessObject(**value_dct)


def _pairs_from_my_sync(orig, new):

    far_pairs = new._to_normal_stream()
    near_pairs = orig._to_normal_stream()

    # == BEGIN [#459.R]
    def keyerer(_normally):  #
        return keyer  # hi.

    def keyer(k):  # because #here5
        return k  # hi.
    # == END

    flat_map = subject_function()(far_pairs, build_near_sync_keyer=keyerer)

    # First, send each near item into the flat map and follow its directives
    for near_key, near_value in near_pairs:
        directives = flat_map.receive_item(near_key)  # #here5
        for directive in directives:
            typ = (stack := list(reversed(directive))).pop()
            if 'pass_through' == typ:
                yield near_key, near_value
                continue
            if 'insert_item' == typ:
                value, key = stack
                yield key, value
                continue
            if 'merge_with_item' == typ:
                far_value, = stack
                yield _item_via_collision(near_key, far_value, near_key, near_value)  # noqa: E501
                continue
            assert 'error' == typ
            assert()

    # Then, ask the flat map to give you any remaining items to insert
    for directive in flat_map.receive_end():
        typ = (stack := list(reversed(directive))).pop()
        if 'insert_item' == typ:
            value, key = stack
            yield key, value
            continue
        assert 'error' == typ
        assert()


def _item_via_collision(far_key, far_value, near_key, near_value):

    assert(far_key == near_key)

    f = getattr(_resolve_collision, near_key)

    _merged_value = f(far_value, near_value)  # #here2
    # merged value is often the same as one or the other, so there are times
    # we could re-use the existing tuples instead if we wanted to save memory.
    # (did something like this before #history-A.1.))

    return (near_key, _merged_value)


class _resolve_collision:  # :#here3 #class-as-namespace

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


def subject_function():
    from data_pipes.magnetics.flat_map_via_far_collection import \
            flat_map_via_producer_script as function
    return function


if __name__ == '__main__':
    unittest.main()

# #history-A.2: default algorithm changed to interfolding. now order must be az
# #history-A.1: got rid of use of format adapter for this test
# #born.
