def oxford_AND_HELLO_FROM_KISS(these):
    return oxford_join_VARIANT_B(these, ' and ')


def oxford_OR(these):
    return oxford_join_VARIANT_B(these, ' or ')


def oxford_join_VARIANT_A(itr, interesting_sep=' and ', boring_sep=', '):
    """given an iterable that produces 0-N strings, result in a string that

    expresses the list of strings in the typically english way. this is
    basically just a `join` but with a few extra rules. it's easier to
    understand from examples than it is to explain.

    the empty collection produces this hardcoded default:

    >>> oxford_join(())
    'nothing'


    a collection with one item produces only that item:

    >>> oxford_join(('A',))
    'A'


    with two items, we use the "interesting" separator:

    >>> oxford_join(('A', 'B'))
    'A and B'


    with three items, we use the "boring" separators and the "interesting" one:

    >>> oxford_join(('A', 'B', 'C'))
    'A, B and C'


    you can provide other separators:

    >>> oxford_join(('A', 'B', 'C', 'D'), interesting_sep=' or ', boring_sep='; ')  # noqa: E501
    'A; B; C or D'

    we can describe this production pattern by seeing it as much like an
    ordinary "join" but that the separator used varies based on how far
    in from the end the gap is. more formally, for 2 or more tems:

    if we are at the gap between item N-1 and item N, we use the interesting
    separator.

    otherwise (and we are at one of the gaps between any adjacent two
    items among 1 thru N-1 (which happens IFF there are more than two items
    in the collection)), we use the boring separator.

    a bit of etymology, this is of course named after the idea of "oxford
    comma" but (ironically or not) we won't be producing any actual "oxford
    comma" construction, both because it's slightly more complicated than the
    above and because it's bad. this is more named after the Vampire Weekend
    song.
    """

    return ''.join(_OxfordJoin(itr, interesting_sep, boring_sep).execute())


oxford_join = oxford_join_VARIANT_A  # just for doctest, just for now


class STREAM_STEPPER_DEPRECATING_NOW:

    def __init__(self, items):
        from modality_agnostic import streamlib
        self._next_or_none = streamlib.next_or_noner(iter(items))
        self.done = False

    def step(self):
        self.item = self._next_or_none()
        if self.item is None:
            del(self._next_or_none)
            self.done = True


class _OxfordJoin(STREAM_STEPPER_DEPRECATING_NOW):
    """(stream-centric implementation for client)"""

    def __init__(self, itr, interesting_sep, boring_sep):
        self.interesting_sep = interesting_sep
        self.boring_sep = boring_sep
        super().__init__(itr)

    def execute(self):
        self.step()
        if self.done:
            yield 'nothing'  # ..
            return
        yield self.item
        self.step()
        if self.done:
            return
        while True:
            item_on_deck = self.item
            self.step()
            if self.done:
                yield self.interesting_sep
                yield item_on_deck
                break
            yield self.boring_sep
            yield item_on_deck


def oxford_join_VARIANT_B(these, ult_sep):
    length = len(these)
    if 0 == length:
        return 'nothing'
    elif 1 == length:
        return these[0]
    else:
        *head, penult, ult = these
        tail = f'{ penult }{ ult_sep }{ ult }'
        if len(head):
            return ', '.join((*head, tail))
        else:
            return tail


def rotating_bufferer(*these):

    these_length = len(these)
    assert(1 < these_length)

    ring_size = these_length - 1
    largest_i = ring_size - 1

    def wrapped_items_via(itr):

        # load up the ring
        ring = []
        for item in itr:
            ring.append(item)
            if len(ring) == ring_size:
                break

        # handle edge case: number of items is less than rotating buffer size
        if len(ring) < ring_size:
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
        for these_offset in range(1, these_length):
            # the first time: you have a full ring (you checked above)) so
            # ticking it fwd one actually ticks it back to the oldestmost item
            if i:
                i -= 1
            else:
                i = largest_i
            yield these[these_offset](ring[i])

    return wrapped_items_via

# #history-A.1: introduce rotating buffer
# #abstracted.
