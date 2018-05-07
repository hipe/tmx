"""(algorithm documented (first) exhaustively at [#407])"""

from sakin_agac import (
        cover_me,
        )


class SYNC_REQUEST_VIA_DICTIONARY_STREAM:
    """experiment...

    a sync request is:
      - some properties talking bout natural key
      - a stream of items

    we make "dictionary stream" be the lingua franca because it's trivial
    to convert a dictionary to named arguments to build the etc..

    but if this is to be useful for different formats we may want to
    granulate this out into smaller pieces..
    """

    def __init__(self, dict_stream, format_adapter):
        self._dict_stream = dict_stream
        self._format_adapter = format_adapter

    def release_sync_parameters(self):
        itr = self._dict_stream
        del(self._dict_stream)
        _hi = next(itr)
        self._dict_stream_part_two = itr
        return _SyncParameters(**_hi)

    def release_item_stream(self):
        x = self._dict_stream_part_two
        del(self._dict_stream_part_two)
        return x


class _SyncParameters:
    """consider the role of 'natural key' in a sync:

    what is the natural key of the near collection? of the far collection?
    is _it_ (as a particular field) a property of the collection?

    how we conceive of it in fact is that it is not an intrinsic part of
    either collection, but rather we are conceiving of it as a property
    (a parameter) of the synchorniation itself...
    """

    def __init__(
            self,
            _is_sync_meta_data,
            natural_key_field_name,
            ):

        if _is_sync_meta_data is not True:
            cover_me('hi')

        self.natural_key_field_name = natural_key_field_name


def SELF(
        natural_key_via_far_item,
        far_item_stream,
        natural_key_via_near_item,
        near_item_stream,
        item_via_collision,
        ):

    far_collection = _collection(far_item_stream, natural_key_via_far_item)
    near_collection = _collection(near_item_stream, natural_key_via_near_item)

    # the below comments are copy-pasted directly from algorithm

    # index the new collection (which traverses it)

    diminishing_pool = __index_the_far_collection(far_collection)
    seen = {k: None for k in diminishing_pool.keys()}

    # traverse the original collection, while doing a thing

    for (k, item) in near_collection:
        if k in seen:
            _new_item = diminishing_pool.pop(k)
            _use_item = item_via_collision(_new_item, item)
            yield _use_item  # might change this to be yield if not None
        else:
            yield item

    # flush the diminishing pool

    for item in diminishing_pool.values():
        yield item


def __index_the_far_collection(far_collection):

    d = {}
    for (k, item) in far_collection:
        if k in d:
            cover_me('[#407.e1]')
        d[k] = item
    return d


def _collection(stream, keyer):

    return ((keyer(x), x) for x in stream)


# #pending-rename: we might name every "new stream" as "far stream" ibid near
# #born.
