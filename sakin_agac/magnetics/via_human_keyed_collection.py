# support for hackish EN expression


def _strings_from_stream(the_iterator_function):  # local decorator
    def receive_outer_function(f):
        def g(*args, **kwargs):
            buffer = []
            _strings = the_iterator_function(*args, **kwargs)
            for s in _strings:
                buffer.append(s)
            return ''.join(buffer)
        g.__doc__ = f.__doc__
        return g
    return receive_outer_function


def __strings_for_oxford_join(itr, interesting_sep=' and ', boring_sep=', '):
    """(stream-centric implementation for client)"""

    def step():
        nonlocal item
        item = next_or_none()
        if item is None:
            nonlocal done
            done = True

    from modality_agnostic import streamlib
    next_or_none = streamlib.next_or_noner(iter(itr))

    item = None
    done = False

    step()
    if done:
        yield 'nothing'  # ..
        return
    yield item
    step()
    if done:
        return
    while True:
        item_on_deck = item
        step()
        if done:
            yield interesting_sep
            yield item_on_deck
            break
        yield boring_sep
        yield item_on_deck


@_strings_from_stream(__strings_for_oxford_join)
def _oxford_join():
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

    pass


oxford_join = _oxford_join
"""(although we are almost certain that this function will become an exposed
part of this module, it would be considered early abstraction to do so.
nonetheless we want the doctest tests to read as if it is. :#here2)
"""


def __strings_for_ellipsis_join(itr, ellipsis='…', sep=', '):
    """(stream-centric implementation for client)"""

    def step():
        nonlocal item
        item = next_or_none()
        if item is None:
            nonlocal done
            done = True

    from modality_agnostic import streamlib
    next_or_none = streamlib.next_or_noner(iter(itr))

    item = None
    done = False

    step()
    if not done:
        yield item
        step()
        while not done:
            yield sep
            yield item
            step()

    yield ellipsis


@_strings_from_stream(__strings_for_ellipsis_join)
def _ellipsis_join():
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

    pass


ellipsis_join = _ellipsis_join  # #here2 again

# #pending-rename: this was born wanting to be abstracted
# #born
