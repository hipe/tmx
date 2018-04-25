"""(algorithm documented (first) exhaustively at [#407])"""

from sakin_agac import (
        cover_me,
        )


def _SELF(new_item_stream, original_item_stream, item_via_collision):

    # the below comments are copy-pasted directly from algorithm

    # index the new collection (which traverses it)
    diminishing_pool = __index_the_new_collection(new_item_stream)
    seen = {k: None for k in diminishing_pool.keys()}

    # traverse the original collection, while doing a thing

    for item in original_item_stream:
        k = item.natural_key
        if k in seen:
            _new_item = diminishing_pool.pop(k)
            _use_item = item_via_collision(_new_item, item)
            yield _use_item  # might change this to be yield if not None
        else:
            yield item

    # flush the diminishing pool

    for item in diminishing_pool.values():
        yield item


def __index_the_new_collection(new_item_stream):

    d = {}
    for item in new_item_stream:
        k = item.natural_key
        if k in d:
            cover_me('[#407.e1]')
        d[k] = item
    return d


import sys  # noqa: E402
sys.modules[__name__] = _SELF  # #[#008.G] so module is callable

# #born.
