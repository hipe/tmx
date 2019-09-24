"""(algorithm documented (first) exhaustively at [#447])"""


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
    the [#447] interleaving algorithm. spiked at #history-A.4
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
                # (Case1320DP) (obliquely)
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
            assert(not self._near_is_open)
            # how is it that both sides are still active?
            which = _FAR
            yes = True
        elif self._near_is_open:
            which = _NEAR
            yes = True
        else:
            # both hit the end at the same step (Case0262)
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
        # NOTE: both near and far are served by this same function interleaved

        iter_attr = _iter_attribute_for[which]
        setattr(self, iter_attr, normal_stream)
        item_attr = _item_attribute_for[which]
        key_attr = _key_attribute_for[which]

        def step():
            at_end = True
            for pair in normal_stream:  # #once
                at_end = False
                break
            if at_end:
                setattr(self, _is_open_attribute_for[which], False)
                self._both_open = False  # might be the 2nd time. ##here3
                clear_props()
            else:
                recv_item(*pair)

        class ThisState:  # #[#510.2]
            pass

        state = ThisState()
        state.prev_key = None

        def recv_item(key, item):
            setattr(self, item_attr, item)
            if key is None:
                cover_me('when key is none')
            else:
                state.recv_key(key)

        def recv_key_initially(first_key):
            store_key(first_key)
            state.prev_key = first_key
            state.recv_key = recv_key_subsequently

        state.recv_key = recv_key_initially

        def recv_key_subsequently(key):
            if state.prev_key < key:
                store_key(key)
                state.prev_key = key
            elif state.prev_key == key:
                self._unable_because_duplicate_key(key, which)
            else:
                self._emit(
                        ('error', 'expression', 'disorder'),
                        '{} traversal is not in order ({!r} then {!r})',
                        (_adj_for[which], state.prev_key, key))

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
        sanity = 200  # ##[#873.6]
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


# :#here1: realize #provision [#458.6] four args for collision callback


def pop_property(self, attr):
    x = getattr(self, attr)
    delattr(self, attr)
    return x


def cover_me(s=None):
    raise Exception('cover me' if s is None else f'cover me: {s}')


def xx():
    raise Exception('write me')


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


# #history-A.7: no more traversal_parameters_version
# #history-A.6: bumped version because added deny list
# #history-A.5: bumped version because added several components
# #history-A.4: sunset diminishing pool algorithm while spike interleaving
# #history-A.2: when wrapper fails (sketch)
# #history-A.1 (can be temporary): "inject" wrapper function
# #born.
