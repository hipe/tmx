"""
(this is a rough seed for [#505] "feature branch" (collection) functions..)

this will *very* likely move to the [#500] subproject but we want to avoid
early abstraction at first.
"""


def _subfeatures_via_item_default_function(human_key, _item):
    """(the default subfeature to search against an item is its key)"""

    return iter((human_key,))


def procure(
            human_keyed_collection,
            needle_function,
            listener,
            item_noun_phrase=None,
            do_splay=True,
            subfeatures_via_item=_subfeatures_via_item_default_function,
            channel_tail_component_on_not_found=None,
            say_needle=None,
            say_collection=None,
            ):
    """
    given the request, resolve exactly one item from the collection or None.

    when one item can be resolved, it is returned as a tuple alongside its
    human key (as `(human_key, item)`).

    an essential function of [#505]. currently an ad-hoc spike.
    """

    _ui_tuple = (
            channel_tail_component_on_not_found,
            say_needle,
            item_noun_phrase,
            say_collection,
            listener)

    _use_this = _procure_when_splay if do_splay else _procure_when_no_splay
    return _use_this(
            human_keyed_collection=human_keyed_collection,
            needle_function=needle_function,
            subfeatures_via_item=subfeatures_via_item,
            ui_tuple=_ui_tuple,
            )


def _procure_when_splay(
        human_keyed_collection,
        needle_function,
        subfeatures_via_item,
        ui_tuple,
        ):

    matching_pairs = []  # every human-key/native object pair that you match
    negative_memory = []  # every feature value that you don't match
    positive_memory = []  # every feature value that you do match

    feature_does_match = _normalize_needle_function(needle_function)

    for human_key in human_keyed_collection:

        native_object = human_keyed_collection[human_key]

        _features = subfeatures_via_item(human_key, native_object)

        for feat_x in _features:
            _yes = feature_does_match(feat_x)
            if _yes:
                matching_pairs.append((human_key, native_object))
                positive_memory.append(feat_x)
                break  # once one subfeature matches, don't check the rest
            negative_memory.append(feat_x)

    num = len(matching_pairs)
    if 0 is num:
        _when_not_found(needle_function, ui_tuple, negative_memory)
    elif 1 is num:
        return matching_pairs[0]
    else:
        return _when_ambiguous(needle_function, ui_tuple, positive_memory)


def _procure_when_no_splay(
        human_keyed_collection,
        needle_function,
        subfeatures_via_item,
        ui_tuple,
        ):

    human_key = needle_function  # ..
    x = human_keyed_collection[human_key]  # ..
    if x is None:
        _when_not_found(needle_function, ui_tuple)
    else:
        return (human_key, x)


def _ui_thing(f):

    def g(needle_x, ui_tuple, *one_extra):

        (
            channel_tail_component_on_not_found,
            say_needle,
            item_NP,
            say_coll,
            listener,
        ) = ui_tuple

        if say_needle is None:
            say_needle = __needle_sayer_via(needle_x)

        def err(msg, *params):
            def DEPRECATED_emission_receiver(o, styler=None):  # #open [#508]
                if 0 == len(params):
                    use_msg = msg
                else:
                    use_msg = msg.format(*params)
                o(use_msg)
            listener(*these, DEPRECATED_emission_receiver)

        these = ['error', 'expression']
        if channel_tail_component_on_not_found is not None:
            these.append(channel_tail_component_on_not_found)

        return f(say_needle, item_NP, say_coll, err, * one_extra)
    return g


def __needle_sayer_via(needle_x):
    if str is type(needle_x):
        def f():
            return repr(needle_x)
    else:
        def f():
            return 'item'
    return f


@_ui_thing
def _when_ambiguous(say_needle, item_noun_phrase, say_coll, err, posi_mem):

    # (Case1431)

    f = placeholder_for_say_subfeature

    _these = (f(x) for x in posi_mem)
    _this_or_this = _oxford_join(_these, ' or ')

    err('{} was ambiguous. did you mean {}?', say_needle(), _this_or_this)


@_ui_thing
def _when_not_found(say_needle, item_noun_phrase, say_coll, err, neg_mem=None):

    # (Case1428)

    def yes(k, x):
        tmpl_args[k] = x
        zero_or_ones.append(1)

    def no():
        zero_or_ones.append(0)

    tmpl_args = {}
    zero_or_ones = []

    no() if say_coll is None else yes('haystack', _say(say_coll))
    no() if item_noun_phrase is None else yes('widget', _say(item_noun_phrase))
    no() if say_needle is None else yes('needle', _say(say_needle))

    _tmpl = _when_not_found_table[tuple(zero_or_ones)]
    msg_head = _tmpl.format(**tmpl_args)
    msg_tail = None if neg_mem is None else __splay_memory(neg_mem)
    msg = msg_head if msg_tail is None else '%s. %s' % (msg_head, msg_tail)

    err(msg)
    return None


_when_not_found_table = {
        # | coll | NP | needle | target output
        (0, 0, 0): "not found",
        (0, 0, 1): "{needle} not found",
        (0, 1, 0): "{widget} not found",
        (0, 1, 1): "no {widget} for {needle}",  # {widget} {needle} not found
        (1, 0, 0): "not found in {haystack}",
        (1, 0, 1): "{needle} not found in {haystack}",
        (1, 1, 0): "{widget} not found in {haystack}",
        (1, 1, 1): "{haystack} has no {widget} for {needle}",
        }


def __splay_memory(neg_mem):

    max_displayed = 2  # the number of features you display can meet not exceed
    num_displayed = 0  # keep track of how many *unique* features you've seen
    max_exceeded = False  # is there at least one more than the max

    seen = {}
    display = []

    for feat_x in neg_mem:
        if seen.get(feat_x, False):
            continue

        if max_displayed == num_displayed:
            max_exceeded = True
            break

        seen[feat_x] = True
        num_displayed += 1
        display.append(feat_x)

    f = placeholder_for_say_subfeature
    _these = (f(x) for x in display)
    _use_f = _ellipsis_join if max_exceeded else _oxford_join
    _this_and_this = _use_f(_these)
    return "(there's %s)" % _this_and_this


def _normalize_needle_function(needle_function):

    if not callable(needle_function):
        needle = needle_function

        def needle_function(subfeature):
            return needle == subfeature

    return needle_function


def _say(say_x):
    """for all those argument parameters use for producing strings to be used

    in error messages, they follow this pattern:
    """

    if callable(say_x):
        return say_x()
    else:
        return say_x  # or more "type safety" than this mabye ..


"""this is this one interface :#here1

"participants" of this interface will typically implement at least one of:

  - `get` to look and act like the same method from `dict`
  - `__getitem__` to look and act like the `[]` method from `dict` or list
  - `__iter__` so that you can `for k in thing` (iterate) like `dict`

we say "participants" and not "adaptations" because it can be useful to
implement only part of the interface. full participation is not made mandatory.
"""


class human_keyed_collection_via_object:
    """the #here1 adaptation for arbitarary objects

    the idea is that you're using an arbitarary object as the collection,
    and the names of its attributes as keys. (be careful)
    """

    def __init__(self, obj):
        self._object = obj

    def get(self, human_key, default_x=None):
        if hasattr(self._object, human_key):
            return self.__getitem__(human_key)
        else:
            return default_x

    def __getitem__(self, human_key):
        return getattr(self._object, human_key)


class human_keyed_collection_via_pairs_cached:
    """the #here1 adaptation for streams of pairs.

    imagine an iterator (we will say "stream" here) of name-value pairs. the
    target API we are implementing against accomodates both random-access and
    sequential traversal. (the platform language's _dictionary_ (which is
    ordered) is a familiar practical example of a collection that exposes an
    interface like this.)

    in effect, we want a stream of name-value pairs to "act like" an ordered
    dictionary. if you like, it's a "lazy" dictionary. this is how we do so:

    in the very beginning, whether we are doing a "retrieval" (given a key)
    or a traversal of all items; we must consume items off the source stream.

    for a retrieval, the source stream is traversed lazily, only as much as
    is necessary to find the association with the target key.

    as we enounter each new association during our traversal, we put this
    association *into* a dictionary that serves as a cache. (note the
    association is cached whether or not has the target key (if relevant).)

    if it's a traversal (not retrieval) that's being performed externally,
    we likewise place each encountered association in the cache. note too if
    the traversal is interrupted (like with a `break` because a certain
    needle is found), the internal traversal of the source stream is also
    halted (perhaps temporarily) there.

    all subsequent traversals and retrievals of the outward-facing façade
    will then consult the cache dictionary as appropriate to do traversals
    and retrievals from it before continuing to flush any remaining stream.

    in implementation how this works out is that we model the collection to
    be in one of two states internally (states that must be totally
    unknowable to outside clients): an "open" state and a "closed" state.
    when the internal stream has not yet reached the end, we are in an open
    state. once we find the end of the stream, we move to the "closed" state.
    (the closed state is much simpler because it's merely representing a
    dictonary *as* a dictionary, more or less.)

    considerations:

      - the internal cache/dictionary is in-memory so there are practical
        considersations against using this against large collections for some
        definition of. (redis would be neat here, but holy scope creep.)
        ([#410.R] (perhaps first mention)

      - just as a curious corollary, it's worth noting that if your
        retrievals always use existant keys and never do a full traversal,
        then internally the collection will always stay in the "open" state
        and never reach the "closed" state.

      - currently the "locking" we do for sanity might be costly at some
        scales.
    """

    def __init__(self, pairs):
        self._state = _OpenState(self._receive_new_state, pairs)

    def get(self, k, default_x=None):
        return self._state._two_argument_get(k, default_x)

    def __getitem__(self, k):
        return self._state._getitem(k)

    def __iter__(self):
        return self._state._iter()

    def _receive_new_state(self, x):
        self._state = x


class _OpenState:

    def __init__(self, change_state, pairs):
        self._pairs = pairs
        self._change_state = change_state
        self._cache = {}

    def _two_argument_get(self, human_key, default_x):

        found, x = self._lookup(human_key)
        if found:
            return x
        else:
            return default_x

    def _getitem(self, human_key):

        found, x = self._lookup(human_key)
        if found:
            return x
        else:
            """this one is a real trip: since it was not found (but we are
            still here), we know that:

              - we must have traversed the whole stream and
              - an exception was not thrown.

            the above, in turn, means our parent has transitioned off of us
            as a state. which means this should be here GULP:
            """
            return self.__NEW_STATE._getitem(human_key)

    def _lookup(self, human_key):

        cache = self._cache
        value = None
        if human_key in cache:
            value = cache[human_key]
            found = True
        else:
            found = False
            for k in self._each_next_real_new_key():
                if human_key == k:
                    found = True
                    value = cache[human_key]
                    break

        if found:
            """if it was in the cache, OK that's fine. otherwise, we must have
            found it in the loop. when you find it in the loop, you break out
            of the loop early. when you break out of the loop early, you don't
            know if you've seen the last item in the "stream". as long as there
            could be more items in the stream, we must stay in this state. so
            if you never use any strange key, you never transition out of this
            "open" state. that's OK. it's just a corollary of streaming over a
            collection without using lookahead (slightly more complicated).
            """
            return (found, value)
        else:
            return (found)

    def _iter(self):
        """assume we are partway though, even though we won't always be.

        """
        for k in self._cache:
            yield k

        _itr = self._each_next_real_new_key()
        for k in _itr:
            yield k

    def _each_next_real_new_key(self):
        """with this architecture, certain operations (like traversal) could

        be NASTY under some circumstances like loops inside loops that each
        try to traverse the same collection concurrently (#cover-me).
        (imagine that during a first item retrieval, part of the process of
        building the item involves randomly accessing another item that is
        ahead of the item being built. it boggles the mind what kind of error
        this would normally produce, but it is certainly not something we
        want to try and accomodate.)

        so we "lock" the state of our front-level façade while doing certain
        operations just as a sanity check..

        the "pairs" collection that this object is constructed with can be of
        any implementation. it's certainly possible that mid-traversal, any
        arbitrary exceptional condition can occur (for example, from client
        code of an ad-hoc collection implementation).

        if an exception was thrown while we were in a locked state, we would
        otherwise be stuck in a locked state unless we do the cleanup below,
        so that the user can catch arbitrary exceptions that may be emitted
        from our injected collection backend.

        (at least, that's the idea.)
        """

        cache = self._cache

        is_open = True
        while True:  # at each step of the traversal:
            self._change_state(None)  # lock it
            try:
                k, v = next(self._pairs)  # this could throw arbitrary
                cache[k] = v
            except StopIteration:
                is_open = False
            finally:
                self._change_state(self)  # whether or not raised, unlock

            if is_open:
                # yield this out only once we've unlocked again
                # (so allow the client to retrieve the value of this key)
                yield k
            else:
                break

        """true or false?: you don't reach this point in code UNLESS:

        1) no Exception was thrown (i.e no user exception)

        2) no user `break` was encountered in the loop. (note if the user
           throws a StopIteration it is not caught by us because our yield
           is outside that one clode block.)

        we assume this is the case. so this means we reached the end of the
        injected stream so this means:
        """

        del(self._cache)  # sanity
        del(self._pairs)  # same
        new_state = _ClosedState(cache)
        self._change_state(new_state)
        self.__NEW_STATE = new_state


class _ClosedState:

    def __init__(self, cache):
        self._cache = cache

    def _two_argument_get(self, human_key, default_x):
        return self._cache.get(human_key, default_x)

    def _getitem(self, human_key):
        return self._cache[human_key]

    def _iter(self):
        # NOTE - currently this may not be covered unless you run the whole fil
        return iter(self._cache)


placeholder_for_say_subfeature = repr


# support for hackish EN expression


def _oxford_join(itr, interesting_sep=' and ', boring_sep=', '):
    from modality_agnostic.magnetics.rotating_buffer_via_positional_functions import (  # noqa: E501
            oxford_join)
    return oxford_join(itr, interesting_sep, boring_sep)


def _ellipsis_join(itr, ellipsis='…', sep=', '):
    """this is the un-sexy counterpart to "oxford join" above.

    simply join the zero or more items with the separator, and append the
    ellipsis glyph.

    >>> ellipsis_join(())
    '…'

    (eew/meh) ☝️

    >>> ellipsis_join(('A'))
    'A…'

    >>> ellipsis_join(('A', 'B'))
    'A, B…'

    >>> ellipsis_join(('A', 'B', 'C'))
    'A, B, C…'

    """

    # #history-A.3 buries something complicated & awkward (but "streaming")

    _ = sep.join(itr)
    return f'{_}{ellipsis}'


ellipsis_join = _ellipsis_join
# at writing the function is module (file) private, but for aesthetics,
# we want the doctest tests to read as if it's an "ordinary" function.


# #pending-rename: wouldn't you rather call this "natural key"?
# #history-A.3 (as referenced)
# #history-A.2
# #history-A.1
# #born
