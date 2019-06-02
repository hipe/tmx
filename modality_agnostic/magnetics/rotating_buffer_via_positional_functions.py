"""
DISCUSSION:

This little "stack" is for when you want to do a certain something to each
item in a list and you want to do different somethings based on how far the
item is from the end of the list and you don't know beforehand how how long
the list is (and the list is a stream lol and you don't want to have to
flush the whole thing just to find the end).

As it turns out, there is perhaps a not tiny class of problems that seem to
fit into this macro category of problem.

Origin story: wwere implementing something elsewhere and we needed one
element of lookahead to determine when we had reached the end of the stream
before we processed and expressed the current item.

Again somewhere else in the same effort, we needed *two* elements of
lookahead (so that when we got to the end, we could know we were still
holding the last and second-to-last ("penultimate") items).

All at once we had had two small epiphanies:

1) The "temporary variable" pattern of effecting one element of lookahead
by always holding on to the previous item before emitting it (with a variable
often called `tmp`, or cohorts of variables called some variant of ~`previous`
and ~`current` or ~`current` and ~`next`); we realized that is a specialized
case of what we're calling the "rotating buffer" "pattern", which is to say
buffering a stream with an arbitary N (positive nonzero) items of lookahead,
which allows you (as something of a side-effect) to "know" these spatially-
defined qualifications (only once you find the end of the stream).

2) Such a facility seems like it was born to write the "oxford join" family
of functions in the streamiest and most platform-idiomatic way yet..
"""


def oxford_AND(these):
    return oxford_join(these, ' and ')


def oxford_OR(these):
    return oxford_join(these, ' or ')


def oxford_join(
        string_iterator,
        more_significant_separator=' and ',
        less_significant_separator=', ',
        ):

    """given an iterable that produces 0-N strings, result in a string that

    expresses the list of strings in the way that is probably familiar in
    a lot of natural languages.

    This family of functions gets its name from the "oxford comma", and
    indeed these functions can produce that phenomenon, although in practice
    we always prefer *not* to use an actual oxford comma, as the defaults to
    this method exhibit 🤪

    This is basically just a `join` with a few extra rules, and it's probably
    easiest to understand from examples:

    the empty collection produces this hardcoded default:

    >>> oxford_join(iter(()))
    'nothing'


    a collection with one item produces only that item:

    >>> oxford_join(iter(('A',)))
    'A'


    With two items, we use the "more significant" separator:

    >>> oxford_join(iter(('A', 'B')))
    'A and B'


    With three items, we use the "less significant" separator for all but
    the last joint, and the "more significant" one for he last:

    >>> oxford_join(iter(('A', 'B', 'C')))
    'A, B and C'


    You can provide any arbitrary strings for the two separators:

    >>> oxford_join(iter(('A', 'B', 'C', 'D')), ' or ', '; ')
    'A; B; C or D'

    we can describe this production pattern by seeing it as much like an
    ordinary "join" but that the separator used varies based on how far
    in from the end the gap is. more formally, for 2 or more tems:

    If we are at the gap between item N-1 and item N, use the more significant
    separator.

    otherwise (and we are at one of the gaps between any adjacent two
    items among 1 thru N-1 (which happens IFF there are more than two items
    in the collection)), use the less significant separator.
    """

    if hasattr(string_iterator, '__len__'):  # #[#008.D]
        # this is nasty if you don't catch this
        _ = f'need iterator of strings had {type(string_iterator)}'
        raise TypeError(_)

    _itr = __strings_for_oxford_join(
            string_iterator,
            more_significant_separator, less_significant_separator)

    return ''.join(_itr)


def __strings_for_oxford_join(
        string_iterator,
        more_significant_separator,
        less_significant_separator):

    _spatialized_itr = __spatialize_with_2_items_of_lookahead(string_iterator)

    for o in _spatialized_itr:
        if o.is_neither_last_nor_second_to_last_item:
            yield o.item
            yield less_significant_separator
        elif o.is_second_to_last_item:
            yield o.item
            yield more_significant_separator
        elif o.is_last_item:
            assert(o.is_last_item)
            yield o.item
        else:
            assert(o.is_the_empty_item)
            yield 'nothing'  # move it up when u need to


def rotating_bufferer(*these):
    """
    Turn a stream into another stream with position-aware mappers applied.

    Call this function with N function-ishes (at least three, all but the
    last are "map functions") and it results in a function.

    That result function takes an iterator as an argument and results in
    another iterator, one with the map functions applied to its items while
    still preserving the streamy-ness of the argument iterator.

    (The use of a rotating buffer is an implementation detail, but it's one
    we're really running on because of how broadly applicable it's proving
    to be as a sort of superset algorithm to simpler cases/algorithms.)

    The N function-ishes are mostly "map functions"; simply: functions that
    take one item and result in an item (which is usually a wrapped form
    of the argument item).

    Experimentally this facility allows you to preserve the efficiency of
    iterators while still giving you the ability to know immediately (in a
    for loop, say), whether your current item is the last one, etc.

    Schematic illustration of usage:

        itr_via_itr = rotating_bufferer(
            map_otherwise, [...] [map_2nd_to_last], map_last, when_none)

        #                    ^                                      ^
        #             (to infinity)                     (pass None to not emit)

    The meaning of each function-ish corresponds to its position:

      - The last "slot" takes a callback function that will be called in the
        event of an empty input stream. If provided, this callback is *only*
        called in such an event. Whatever the callback (called with no
        arguments) results in will be yielded as the only item in the result
        stream. If you do not want special behavior for the empty stream,
        you must pass None in this spot.

      - The second-to-last function will be passed the final item in the
        input stream and its result is yielded by the result stream.

      - You can pass any number of functions between the second-to-last and
        the (described next) first function to serve as additional positional
        mappers. The last (rightmost) mapper acts on the last item in the
        stream. Pass a mapper to the left of that to act on the any
        second-to-last item in the stream. Pass a mapper to the left of *that*
        to act on any third-to-last item and so on. (In nature and at writing
        we haven't needed more than 2 such specific, positional mappers.)

      - The *first* function will be passed any items that don't fall into
        any of the above categories.
    """

    these_length = len(these)
    assert(2 < these_length)

    these_length_minus_one = these_length - 1
    ring_size = these_length - 2
    largest_i = ring_size - 1

    def wrapped_items_via(itr):

        # load up the ring
        ring = []
        for item in itr:
            ring.append(item)
            if len(ring) == ring_size:
                break

        # handle edge case: number of items is less than rotating buffer size
        cache_length = len(ring)
        if cache_length < ring_size:

            if 0 == cache_length:
                callback_when_none = these[-1]
                if callback_when_none is not None:
                    yield callback_when_none()
                return

            for i in range(0, len(ring)):
                yield these[ring_size - i](ring[i])
            return

        ring = list(reversed(ring))
        i = 0

        uninteresting_item = these[0]  # ..

        # normally
        for item in itr:
            if i:
                i -= 1
            else:
                i = largest_i
            yield uninteresting_item(ring[i])
            ring[i] = item

        # flush the cache
        for these_offset in range(1, these_length_minus_one):
            # the first time: you have a full ring (you checked above)) so
            # ticking it fwd one actually ticks it back to the oldestmost item
            if i:
                i -= 1
            else:
                i = largest_i
            yield these[these_offset](ring[i])

    return wrapped_items_via


class _WrappedItem:
    def __init__(self, item):
        self.item = item


class _NeitherLastNorSecondToLastItem(_WrappedItem):
    is_neither_last_nor_second_to_last_item = True


class _SecondToLastItem(_WrappedItem):
    is_neither_last_nor_second_to_last_item = False
    is_second_to_last_item = True


class _LastItem(_WrappedItem):
    is_neither_last_nor_second_to_last_item = False
    is_second_to_last_item = False
    is_last_item = True


class _EMPTY_SINGLETON:  # #as-namespace-only
    is_neither_last_nor_second_to_last_item = False
    is_second_to_last_item = False
    is_last_item = False
    is_the_empty_item = True


__spatialize_with_2_items_of_lookahead = rotating_bufferer(
        _NeitherLastNorSecondToLastItem,
        _SecondToLastItem,
        _LastItem,
        lambda: _EMPTY_SINGLETON
        )

# #history-A.2: re-integrate some linguistic functions to use rotating buffer
# #history-A.1: introduce rotating buffer
# #abstracted.
