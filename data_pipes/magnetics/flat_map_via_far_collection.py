# two syncing algorithms, both documented exhaustively (and first) at [447]

# we called this "flat map" because {see the ReactiveX pattern}

def flat_map_via_producer_script(
        far_pairs,
        preserve_freeform_order_and_insert_at_end=False,
        stream_for_sync_is_alphabetized_by_key_for_sync=None,
        build_near_sync_keyer=None):

    if preserve_freeform_order_and_insert_at_end:
        return _flat_map_with_diminishing_pool_algorithm(far_pairs)

    error = None
    if not stream_for_sync_is_alphabetized_by_key_for_sync:
        far_pairs, error = _big_blowout(far_pairs)

    def _receive_item(near_sync_key):
        try:
            for directive in do_receive_item(near_sync_key):
                yield directive
        except _Stop as e:
            yield e.args

    def _receive_end():
        try:
            while scn.more:
                sync_key, far_mixed = scn.advance()
                yield 'insert_item', far_mixed  # #here2
        except _Stop as e:
            yield e.args

    def do_receive_item(ent):
        near_sync_key = near_sync_key_for(ent)
        check_order_of_near_items(near_sync_key)
        del ent

        # the main thing: flush out the zero or more insertions from the
        # far collection (us) that come before the current near item

        while scn.more:
            if scn.peek_key < near_sync_key:  # #here1
                far_key, far_mixed = scn.advance()
                yield 'insert_item', far_mixed  # #here2
                scn.maybe_raise_error()  # ugh
                continue

            if scn.peek_key == near_sync_key:  # #here1
                yield 'merge_with_item', scn.advance()[1]  # #here2
                scn.maybe_raise_error()  # ugh
                return  # don't emit the pass thru below

            assert near_sync_key < scn.peek_key  # #here1
            break

        yield 'pass_through',

    def check_order_of_near_items(near_sync_key):
        if self.is_first_far_item:
            self.is_first_far_item = False
            self.prev_far_sync_key = near_sync_key
            return
        if self.prev_far_sync_key < near_sync_key:
            self.prev_far_sync_key = near_sync_key
            return
        raise _disorder('near', self.prev_far_sync_key, near_sync_key)

    # == BEGIN [#459.R]

    def near_sync_key_for_ent_normally(ent):
        # for now we bake the handling of kiss ents in as a default..
        eid = ent.nonblank_identifier_primitive
        # ent.identifier.to_primitive() same
        if eid is None:
            return
        assert isinstance(eid, str)
        return eid

    if build_near_sync_keyer:
        near_sync_key_for = build_near_sync_keyer(near_sync_key_for_ent_normally)  # noqa: E501 # #here3
    else:
        near_sync_key_for = near_sync_key_for_ent_normally

    # == END

    class self:
        is_first_far_item = True

    scn = _far_scanner(far_pairs)

    class flat_map:  # #class-as-namespace
        def receive_schema(_):  # #here3
            pass
        receive_item = _receive_item
        receive_end = _receive_end

    if error:
        _massive_error_hack(flat_map, error)

    return flat_map


def _flat_map_with_diminishing_pool_algorithm(far_pairs):
    pool, error = {}, None
    for k, v in far_pairs:
        if k in pool:
            error = _disorder('far', k, k)
            break
        pool[k] = v

    seen_near = set()

    def _receive_item(near_sync_key):
        if near_sync_key in seen_near:
            yield _disorder('near', near_sync_key, near_sync_key).args
            return
        seen_near.add(near_sync_key)
        if near_sync_key in pool:
            yield 'merge_with_item', pool.pop(near_sync_key)
            return
        yield 'pass_through',

    def _receive_end():
        stack = list(reversed(pool.keys()))  # iterate over items() vs OCD
        while len(stack):
            yield 'insert_item', pool.pop(stack.pop())  # #here2

    class flat_map:  # #class-as-namespace
        receive_item = _receive_item
        receive_end = _receive_end

    if error:
        _massive_error_hack(flat_map, error)

    return flat_map


def _massive_error_hack(flat_map, error):
    def yield_error(*a, **kw):
        yield error.args
    flat_map.receive_item = yield_error
    flat_map.receive_end = yield_error


def _far_scanner(far_pairs):

    def check_order_of_far_items():

        # If there are no far items (strange), there is no order to check
        if (two := nxt()) is None:
            return  # no far items

        # On the first item, there is still no order to check
        prev_sync_key, mixed = two
        yield prev_sync_key, mixed, None

        # For each additional item, check the order
        while (two := nxt()) is not None:
            sync_key, mixed = two
            if prev_sync_key < sync_key:  # #here1
                prev_sync_key = sync_key
                yield sync_key, mixed, None
                continue
            err = _disorder('far', prev_sync_key, sync_key)
            yield None, None, err
            return

    def nxt():
        for sync_key, mixed in itr:
            return sync_key, mixed

    itr = iter(far_pairs)

    return _very_custom_far_scanner(check_order_of_far_items())


# #here2: do we want to yield the sync key
# #here1: comparison should be an injection but is not yet [#447] #provision-2


def _big_blowout(far_pairs):
    big_cache = {}
    count = 0
    for k, v in far_pairs:
        count += 1
        if _REDIS_ETC_WHEN == count:
            xx("redis etc")
        if k in big_cache:
            return (), _disorder('far', k, k)
        big_cache[k] = v
    return big_cache.items(), None


def _disorder(near_or_far, prev, now):
    if prev == now:  # #here1
        message = f"duplicate key in {near_or_far} traversal: '{now}'"
        category = 'duplicate_key'
    else:
        message = (f"{near_or_far} traversal is not in order "
                   f"('{prev}' then '{now}')")
        category = 'disorder'
    return _Stop('error', 'expression', category, lambda: (message,))


class _very_custom_far_scanner:
    def __init__(self, itr):
        def advance():
            k, x, err = self.peek_key, self.peek_mixed, self._peek_error
            if err:
                raise err
            if (three := nxt()) is None:
                del self.peek_key
                del self.peek_mixed
                self.more = False
            else:
                self.peek_key, self.peek_mixed, self._peek_error = three
            return k, x

        def nxt():
            for three in itr:
                return three

        self.peek_key, self.peek_mixed, self._peek_error = None, None, None
        self.more = True
        advance()
        if self.more:
            self.advance = advance

    def maybe_raise_error(self):
        if self._peek_error:
            raise self._peek_error


class _Stop(RuntimeError):
    pass


_REDIS_ETC_WHEN = 200  # #[#873.6]


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #history-B.1: blind rewrite -> re-arch into "flat map" injection
# #history-A.7: no more traversal_parameters_version
# #history-A.6: bumped version because added deny list
# #history-A.5: bumped version because added several components
# #history-A.4: sunset diminishing pool algorithm while spike interleaving
# #history-A.2: when wrapper fails (sketch)
# #history-A.1 (can be temporary): "inject" wrapper function
# #born.
