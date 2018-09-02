"""(algorithm documented (first) exhaustively at [#407])"""

from sakin_agac import (
        cover_me,
        pop_property,
        sanity,
        )
from modality_agnostic import (
        streamlib as _,
        )


next_or_none = _.next_or_none


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
        # #coverpoint7.6
        self._dict_stream = dict_stream
        self._format_adapter = format_adapter

    def release_traversal_parameters(self):
        itr = pop_property(self, '_dict_stream')
        _hi = next(itr)
        # #cover-me (above) - when user gives empty stream, this is confusing
        # :#here4
        self._dict_stream_part_two = itr
        return _TraversalParameters(**_hi)

    def release_dictionary_stream(self):
        return pop_property(self, '_dict_stream_part_two')


class SYNC_REQUEST_VIA_TWO_FUNCTIONS:

    def __init__(
            self,
            release_sync_parameters_dictionary,
            release_dictionary_stream,
            ):

        self._order = [
                ('two', release_dictionary_stream),
                ('one', release_sync_parameters_dictionary),
                ]

    def release_traversal_parameters(self):
        dct = self._same('one')
        if dct is None:
            # for example when you need tag lyfe field names
            # (same *type* of thing as #here4 above)
            return None  # #coverpointTL.1.5.1.1
        else:
            return _TraversalParameters(**dct)

    def release_dictionary_stream(self):
        return self._same('two')

    def _same(self, k):
        have, f = self._order.pop()
        None if have == k else cover_me('no')
        return f()


class _TraversalParameters:
    """consider the role of 'natural key' in a sync:

    what is the natural key of the near collection? of the far collection?
    is _it_ (as a particular field) a property of the collection?

    how we conceive of it in fact is that it is not an intrinsic part of
    either collection, but rather we are conceiving of it as a property
    (a parameter) of the synchronization itself...

    [#418.E] is dedicated to thoughts on this class and its future
    """

    def __init__(
            self,
            _is_sync_meta_data,
            natural_key_field_name,
            # (#coverpoint7.2 is simply the names of the above arguments)
            field_names=None,
            tag_lyfe_field_names=None,  # yuck, experiement
            traversal_will_be_alphabetized_by_human_key=None,
            custom_mapper_for_syncing=None,
            custom_far_keyer_for_syncing=None,
            custom_near_keyer_for_syncing=None,
            custom_pass_filter_for_syncing=None,
            ):

        if _is_sync_meta_data is not True:
            cover_me('hi')

        self.natural_key_field_name = natural_key_field_name
        self.field_names = field_names
        self.tag_lyfe_field_names = tag_lyfe_field_names
        self.traversal_will_be_alphabetized_by_human_key = traversal_will_be_alphabetized_by_human_key  # noqa: E501
        self.custom_mapper_for_syncing = custom_mapper_for_syncing
        self.custom_far_keyer_for_syncing = custom_far_keyer_for_syncing
        self.custom_near_keyer_for_syncing = custom_near_keyer_for_syncing
        self.custom_pass_filter_for_syncing = custom_pass_filter_for_syncing

    traversal_parameters_version = 3

    # bump this WHEN you add to constituency (#provision [#418.J])
    # bumped from 2 to 3 at #history-A.5

    def to_dictionary(self):  # (just for debugging)
        dct = {'_is_sync_meta_data': True}
        o = _specialty_thing(dct, self)
        o('natural_key_field_name')
        o('field_names')
        o('tag_lyfe_field_names')
        o('traversal_will_be_alphabetized_by_human_key')
        o('custom_mapper_for_syncing')
        o('custom_far_keyer_for_syncing')
        o('custom_near_keyer_for_syncing')
        o('custom_pass_filter_for_syncing')
        return dct


def _specialty_thing(dct, self):
    def f(attr):
        x = getattr(self, attr)
        if x is not None:
            dct[attr] = x
    return f


def stream_of_mixed_via_sync(
        preserve_freeform_order_and_insert_at_end=False,
        **kwargs):

    if preserve_freeform_order_and_insert_at_end:
        return _WorkerWhenDiminishingPool(**kwargs).execute()
    else:
        return _WorkerWhenInterleaving(**kwargs).execute()


class _Worker:

    def _unable_because_duplicate_key(self, key, which):
        self._emit(
                ('error', 'expression', 'duplicate_key'),
                'duplicate key in {} traversal: {!r}',
                (_adj_for[which], key),
                )

    def _emit(self, channel, template, values=()):
        if 'error' == channel[0]:
            self._when_error_emission()  # #hook-out

        def msgs_f():
            yield template.format(*values)
        self._listener(*channel, msgs_f)


class _WorkerWhenInterleaving(_Worker):
    """
    the [#407] interleaving algorithm. spiked at #history-A.4
    """

    def __init__(
        self,
        normal_far_stream,
        normal_near_stream,
        item_via_collision,
        nativizer=None,
        listener=None,
            ):

        if nativizer is None:
            def f():
                return self._far_item
        else:
            def f():
                # #coverpoint7.4 (obliquely)
                return nativizer(self._far_key, self._far_item)
        self._nativized_far_item = f

        self._init_traversers(_FAR, normal_far_stream)
        self._init_traversers(_NEAR, normal_near_stream)
        self._merge = item_via_collision
        self._nativizer = nativizer
        self._listener = listener
        self._both_open = True
        self._far_is_open = True
        self._near_is_open = True
        self._OK = True

    def execute(self):

        self._step_far()
        self._step_near()
        while self._both_open:  # ##here3
            if self._near_key < self._far_key:
                yield self._near_item
                self._step_near()
            elif self._near_key == self._far_key:
                pair = self._merge(self._far_key, self._far_item,
                                   self._near_key, self._near_item)  # ##here1
                if pair is None:
                    cover_me("we've imagined supporting this - error at merge")
                yield pair
                self._step_far()
                self._step_near()
            else:
                yield self._nativized_far_item()
                self._step_far()
        for item in self.__run_down_the_rest():
            yield item

    def __run_down_the_rest(self):
        """we know we have reached the end of at least one of the streams.

        we know this because we are after the while loop, and the while loop
        doesn't exit until its exit condition is met, and that condition is
        tripped only when one or both of the streams reached its end. (see
        all #here3.)

        see in the above code how the two streams sometimes step side-by-
        side. it's possible that both streams reached their end at the same
        step-pair. in such cases, you are done.

        otherwise, you have one more stream to "run down". (note it's
        impossible to have both streams still open, given the exit condition.)

        in such a phase you no longer have to look for collisions (merges)
        between items in the near and far collections. however, it is
        imperative that we still check that 1) the remaining stream is itself
        sorted and that 2) it does not have any collisions with itself. (2)
        is in the interest of not having a corrupt dataset but (1) is because
        without it as a provision, item merges can be missed; i.e. the whole
        algorithm breaks down.

        the asymmetry introduced by the possible use of a "nativizer" is
        a can we are kicking down the road for now.
        """

        if not self._OK:  # (putting this here makes main func read nicer)
            return _empty_iterator()

        # == do we run down far stream, near stream or no stream?

        if self._far_is_open:
            if self._near_is_open:
                sanity('how is it that both sides are still active?')
            else:
                which = _FAR
                yes = True
        elif self._near_is_open:
            which = _NEAR
            yes = True
        else:
            # #coverpoint14.1: both hit the end at the same step
            yes = False

        if not yes:
            return _empty_iterator()

        # == yuck more special handling for nativization

        if _FAR == which:
            current_item = self._nativized_far_item
        elif _NEAR == which:
            def current_item():
                return self._near_item
        # ==

        step = getattr(self, _step_attribute_for[which])
        is_open = _is_open_attribute_for[which]

        yield current_item()
        step()
        while self._OK and getattr(self, is_open):
            yield current_item()
            step()

    def _init_traversers(self, which, normal_stream):

        iter_attr = _iter_attribute_for[which]
        setattr(self, iter_attr, normal_stream)
        item_attr = _item_attribute_for[which]
        key_attr = _key_attribute_for[which]

        def step():
            pair = next_or_none(normal_stream)
            if pair is None:
                setattr(self, _is_open_attribute_for[which], False)
                self._both_open = False  # might be the 2nd time. ##here3
                clear_props()
            else:
                recv_item(*pair)

        def recv_item(key, item):
            setattr(self, item_attr, item)
            if key is None:
                cover_me('when key is none')
            else:
                recv_key(key)

        def recv_key(first_key):
            store_key(first_key)
            nonlocal prev_key
            prev_key = first_key
            nonlocal recv_key
            recv_key = recv_key_subsequently

        def recv_key_subsequently(key):
            nonlocal prev_key
            if prev_key < key:
                store_key(key)
                prev_key = key
            elif prev_key == key:
                self._unable_because_duplicate_key(key, which)
            else:
                self._emit(
                        ('error', 'expression', 'disorder'),
                        '{} traversal is not in order ({!r} then {!r})',
                        (_adj_for[which], prev_key, key),
                        )

        prev_key = None

        def store_key(key):
            setattr(self, key_attr, key)

        def clear_props():
            # (had never been set IFF empty streams)
            setattr(self, item_attr, None)
            setattr(self, key_attr, None)
            # --
            delattr(self, iter_attr)
            delattr(self, item_attr)
            delattr(self, key_attr)

        setattr(self, _step_attribute_for[which], step)

    def _when_error_emission(self):
        self._both_open = False
        self._OK = False


class _WorkerWhenDiminishingPool(_Worker):

    def __init__(
        self,
        normal_far_stream,
        normal_near_stream,
        item_via_collision,
        nativizer=None,
        listener=None,
            ):

        self._normal_far_stream = normal_far_stream
        self._normal_near_stream = normal_near_stream
        self._merge = item_via_collision
        self._nativizer = nativizer
        self._listener = listener
        self._OK = True

    def execute(self):
        self._OK and self.__resolve_diminishing_pool_via_big_flush()
        if self._OK:
            return self.__work()
        else:
            return _empty_iterator()

    def __work(self):
        seen = {}
        dim_pool = pop_property(self, '_diminishing_pool')
        merge = pop_property(self, '_merge')

        _ = pop_property(self, '_normal_near_stream')
        for key, item in _:
            if key in seen:
                self._unable_because_duplicate_key(key, _NEAR)
                break
            seen[key] = None
            if key in dim_pool:
                _far_native_item = dim_pool.pop(key)
                hm = merge(key, _far_native_item, key, item)  # ##here1
                if hm is None:
                    cover_me('never been seen - merge failure')
                yield hm  # not a pair, but maybe should be
            else:
                yield item

        nativizer = pop_property(self, '_nativizer')
        if nativizer is None:
            def nativizer(x):  # _identity
                return x
        for far_item in dim_pool.values():
            nativized_item = nativizer(far_item)
            if nativized_item is None:
                cover_me('never seen before - nativizer failure')
            yield nativized_item

    def __resolve_diminishing_pool_via_big_flush(self):
        pool = {}
        sanity = 200  # ##[#410.R]
        count = 0

        _ = pop_property(self, '_normal_far_stream')
        for key, item in _:
            count += 1
            if sanity == count:
                cover_me('redis etc')
            if key in pool:
                self._unable_because_duplicate_key(key, _FAR)
                break
            pool[key] = item
        if self._OK:  # just for sanity
            self._diminishing_pool = pool

    def _when_error_emission(self):
        self._OK = False


# :#here1: realize #provision [#418.F] four args for collision callback


# --
_FAR = 0
_NEAR = 1
_step_attribute_for = ('_step_far', '_step_near')
_is_open_attribute_for = ('_far_is_open', '_near_is_open')
_iter_attribute_for = ('_far_iterator', '_near_iterator')
_item_attribute_for = ('_far_item', '_near_item')
_key_attribute_for = ('_far_key', '_near_key')
_adj_for = ('far', 'near')
# ---


class result_categories:  # as namespace
    # skip = 'skip' maybe one day
    failed = 'failed'
    OK = 'OK'


def _empty_iterator():
    return iter(())


# #history-A.5: bumped version because added several components
# #history-A.4: sunset diminishing pool algorithm while spike interleaving
# #history-A.2: when wrapper fails (sketch)
# #history-A.1 (can be temporary): "inject" wrapper function
# #born.
