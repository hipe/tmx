"""(algorithm documented (first) exhaustively at [#407])"""

from sakin_agac import (
        cover_me,
        pop_property,
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
        itr = pop_property(self, '_dict_stream')
        _hi = next(itr)
        # #cover-me (above) - when user gives empty stream, this is confusing
        self._dict_stream_part_two = itr
        return _SyncParameters(**_hi)

    def release_dictionary_stream(self):
        return pop_property(self, '_dict_stream_part_two')


class SYNC_REQUEST_VIA_TWO_FUNCTIONS:

    def __init__(
            self,
            release_sync_parameters,
            release_dictionary_stream,
            ):

        self._order = [
                ('two', release_dictionary_stream),
                ('one', release_sync_parameters),
                ]

    def release_sync_parameters(self):
        return self._same('one')

    def release_dictionary_stream(self):
        return self._same('two')

    def _same(self, k):
        have, f = self._order.pop()
        None if have == k else cover_me('no')
        return f()


class _SyncParameters:
    """consider the role of 'natural key' in a sync:

    what is the natural key of the near collection? of the far collection?
    is _it_ (as a particular field) a property of the collection?

    how we conceive of it in fact is that it is not an intrinsic part of
    either collection, but rather we are conceiving of it as a property
    (a parameter) of the synchronization itself...
    """

    def __init__(
            self,
            _is_sync_meta_data,
            natural_key_field_name,
            # (#coverpoint7.2 is simply the names of the above arguments)
            field_names=None,
            traversal_will_be_alphabetized_by_human_key=None,
            ):

        if _is_sync_meta_data is not True:
            cover_me('hi')

        self.natural_key_field_name = natural_key_field_name
        # self.field_names = field_names  not needed yet
        self.traversal_will_be_alphabetized_by_human_key = traversal_will_be_alphabetized_by_human_key  # noqa: E501

    @property
    def sync_parameters_version(self):
        return 2  # bump this WHEN you add to constituency


def _result_in_identity(result_categories, listener):

    def _identity(item):
        return (ok, item)

    ok = result_categories.OK
    return _identity


def stream_of_mixed_via_sync(
        natural_key_via_far_user_item,
        far_stream,
        natural_key_via_near_user_item,
        near_stream,
        item_via_collision,
        far_item_wrapperer=_result_in_identity,
        far_traversal_is_ordered=None,
        listener=None,
        ):

    # --
    def wrap_far_item(item):
        # only once you've had a chance to see the near items, ask for the ..
        nonlocal wrap_far_item
        x = far_item_wrapperer(_result_categories, listener)
        if x is None:
            cover_me('you saw this work once but meh - #history-A.2')
            # assume something failed
            _error("couldn't make far item wrapper. stopping early.")
            wrap_far_item = None  # sanity
            return ('_stop_now', None)
        else:
            wrap_far_item = x
            return wrap_far_item(item)

    def _error(msg):
        from modality_agnostic import listening as li
        error = li.leveler_via_listener('error', listener)
        error(msg)
    # --

    far_collection = _collection(far_stream, natural_key_via_far_user_item)
    near_collection = _collection(near_stream, natural_key_via_near_user_item)

    # the below comments are copy-pasted directly from algorithm

    # index the new collection (which traverses it)

    diminishing_pool = __index_the_far_collection(far_collection, listener)
    if diminishing_pool is None:
        return

    seen = {k: None for k in diminishing_pool.keys()}

    # sort if desired

    if far_traversal_is_ordered is False:
        diminishing_pool = _COVER_ME(diminishing_pool)

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
        result_category, wrapped_item = wrap_far_item(item)
        if 'OK' == result_category:
            yield wrapped_item
        elif '_stop_now' == result_category:
            break
        else:
            cover_me(result_category)  # probably { 'failed' | 'skip' }


def __index_the_far_collection(far_collection, listener):
    d = {}
    for (k, item) in far_collection:
        if k in d:
            __when_duplicate_etc(k, listener)
            d = None
            break
        d[k] = item
    return d


def __when_duplicate_etc(k, listener):  # #coverpoint5.3
    def f(o, _):
        _ = "duplicate human key value in far collection ('%s')"
        o(_ % k)
    listener('error', 'expression', 'duplicate_human_key_value', f)


def _COVER_ME(diminishing_pool):
    """
    currently,
      - #cover-me. drafted at #history-A.3 for small real generation.

      - this behavior is triggered by an associated option (parameter).

      - the only interesting value for that option to have is `False`. all
        other values (including (quite importantly) None) will make things
        behave as they did before this feature existed.

      - False is an indication that the far collection traversal will occur in
        a sequence that is *not* in any meaningful order.

      - furthermore, this is an indication that the synchronization *could*
        order the far collection by the natural key if the client desires.
        (although this particular provision should be always true, given
        what "natural key" is supposed to mean.)
    """

    mutable_list = [k for k in diminishing_pool]
    mutable_list.sort(key=lambda hk: hk.lower())
    return {k: diminishing_pool[k] for k in mutable_list}


class _result_categories:  # as namespace
    # skip = 'skip' maybe one day
    failed = 'failed'
    OK = 'OK'


def _collection(stream, keyer):
    return ((keyer(x), x) for x in stream)


# #history-A.3 (can be temporary): as referenced
# #history-A.2: when wrapper fails (sketch)
# #history-A.1 (can be temporary): "inject" wrapper function
# #pending-rename: we might name every "new stream" as "far stream" ibid near
# #born.
