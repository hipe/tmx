# support for hackish EN expression


class _StreamStepper:

    def __init__(self, items):
        from modality_agnostic import streamlib
        self._next_or_none = streamlib.next_or_noner(iter(items))
        self.done = False

    def step(self):
        self.item = self._next_or_none()
        if self.item is None:
            del(self._next_or_none)
            self.done = True


def _oxford_join(itr, interesting_sep=' and ', boring_sep=', '):
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

    return _str_via(_OxfordJoin(itr, interesting_sep, boring_sep).execute())


oxford_join = _oxford_join
"""(although we are almost certain that this function will become an exposed
part of this module, it would be considered early abstraction to do so.
nonetheless we want the doctest tests to read as if it is. :#here2)
"""


class _OxfordJoin(_StreamStepper):
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

    return _str_via(_EllipsisJoin(itr, ellipsis, sep).execute())


ellipsis_join = _ellipsis_join  # #here2 again


class _EllipsisJoin(_StreamStepper):
    """(stream-centric implementation. access t)"""

    def __init__(self, itr, ellipsis, sep):
        self.ellipsis = ellipsis
        self.sep = sep
        super().__init__(itr)

    def execute(self):
        self.step()
        if not self.done:
            yield self.item
            self.step()
            while not self.done:
                yield self.sep
                yield self.item
                self.step()
        yield self.ellipsis


def _str_via(strings):
    buffer = []
    for s in strings:
        buffer.append(s)
    return ''.join(buffer)


# #pending-rename: this was born wanting to be abstracted
# #history-A.1
# #born
