def piece_rows_via_jumble(itr):  # #testpoint ~(Case5180)-(Case5192)
    # Mainly, make the construction of emission messages prettier by freeing
    # them from the low-level logic of conditional spaces and punctuation

    def main():
        while scn.more:
            parse_next_piece()
            if global_state.has_sentence:
                yield flush_piece_row()
        run_any_on_pops_while_flushing_stack()
        if (row := flush_final_piece_row()):
            yield row

    # == State Machine

    def start_state():
        yield if_capitalized, push_sentence_state_the_first_time
        yield base_case, whine_about_not_capitalized

    def base_state():
        yield if_lowercase, push_hacked_parenthesis_state
        yield if_capitalized, push_sentence_state
        yield base_case, whine_about_not_capitalized

    def sentence_state():
        yield if_capitalized, pop_push_between_sentences
        yield if_lowercase, add_space_and_token
        yield if_quote, push_quote_state
        yield if_colon, handle_colon_with_some_hacking
        yield if_sentence_ending_punct, pop_sentence_state
        yield base_case, add_space_and_token

    def hacked_parenthesis_state():  # in survival mode right now. needs stack
        yield if_lowercase, add_space_and_token
        yield if_colon, handle_colon_with_some_hacking
        yield if_capitalized, pop_out_of_hacked_parenthesis_state
        yield base_case, add_space_and_token

    def quote_state():
        yield if_end_quote, handle_end_quote
        yield base_case, add_space_and_token

    # == Actions

    def push_sentence_state_the_first_time():
        assert 1 == len(stack)
        stack.pop()
        stack_push(base_state)
        stack_push(sentence_state)
        add_piece(scn.advance())

    def pop_push_between_sentences():
        assert 2 == len(stack)  # or not
        stack_pop()
        stack_push(sentence_state)
        if pieces[-1][-1] not in sentence_ending_punc_char:
            add_piece('.')  # the trick of not perioding the last sentence
        prepare_for_flush()
        add_piece(scn.advance())

    def push_sentence_state():
        prepare_for_flush()
        add_piece(scn.advance())

    def pop_sentence_state():
        add_piece(scn.advance())  # the punctuation
        prepare_for_flush()
        stack_pop()

    def push_quote_state():
        stack_push(quote_state)
        (frame := top_frame()).which_quote = scn.peek
        add_pieces(' ', scn.advance())
        frame.do_add_space = False

    def handle_end_quote():
        add_pieces(scn.advance())
        stack_pop()

    def handle_colon_with_some_hacking():
        path = pieces[-1]
        add_piece(scn.advance())  # the colon
        if re.search(r'\.[a-z0-9]{2,3}$', path) and isinstance(scn.peek, int):
            top_frame().do_add_space = False
            scn.peek = str(scn.peek)  # watch the world burn

    def push_hacked_parenthesis_state():
        stack_push(hacked_parenthesis_state, close_parenthesis_on_pop)
        add_pieces('(', scn.advance())

    def close_parenthesis_on_pop():
        add_piece(')')  # ..

    def pop_out_of_hacked_parenthesis_state():
        xx()  # needs coverage. not in target case

    def add_space_and_token():
        maybe_add_space()
        add_piece(scn.advance())

    def whine_about_not_capitalized():
        xx()

    # == Support for Actions

    def maybe_add_space():
        if not (frame := top_frame()).do_add_space:
            frame.do_add_space = True
            return
        add_space()

    def add_space():
        add_piece(' ')

    def prepare_for_flush():
        assert not global_state.has_sentence
        global_state.has_sentence = True
        global_state.flush_me = tuple(pieces)
        pieces.clear()

    def add_pieces(*pcs):
        for pc in pcs:
            add_piece(pc)

    def add_piece(pc):
        pieces.append(pc)

    pieces = []

    # == Matchers

    def if_capitalized():
        return re.match('^[A-Z][a-z]', scn.peek)

    def if_lowercase():
        return re.match('^[a-z]{2}', scn.peek)  # ..

    def if_quote():
        return scn.peek in ('"', "'")

    def if_end_quote():
        return top_frame().which_quote == scn.peek

    def if_colon():
        return ':' == scn.peek[0]

    def if_sentence_ending_punct():
        return scn.peek in sentence_ending_punc_char

    def base_case():
        return True

    # == Support for Matchers and Actions

    sentence_ending_punc_char = ('.', '?', '!')

    # == Parse Loop

    def parse_next_piece():
        for matcher, action in top_frame().cases_function():
            if matcher():
                action()
                return
        xx("write your case statements to have always a base case")

    def flush_piece_row():
        global_state.has_sentence = False
        rv = global_state.flush_me
        del global_state.flush_me
        return rv

    def flush_final_piece_row():
        if len(pieces):
            rv = tuple(pieces)
            pieces.clear()
            return rv

    class global_state:
        has_sentence = False

    scn = _scanner_via_iterator(_pieces_via_jumble(itr))

    # == Stack

    def stack_push(func, on_pop=None):
        stack.append(Frame(func, on_pop))

    def stack_pop():
        assert 1 < len(stack)  # don't ever pop the base frame
        stack.pop()

    def run_any_on_pops_while_flushing_stack():
        while len(stack):
            if (on_pop := top_frame().on_pop):
                on_pop()
            stack.pop()

    def top_frame():
        return stack[-1]

    class Frame:
        def __init__(self, func, on_pop=None):
            self.cases_function = func
            self.do_add_space = True
            self.on_pop = on_pop

    stack = [Frame(start_state)]

    # ==

    import re
    return main()


def _pieces_via_jumble(itr):
    return (s for row in itr for s in (row if isinstance(row, tuple) else (row,)))  # noqa: E501


def _scanner_via_iterator(itr):
    def _advance():
        rv = scn.peek
        for nrv in itr:
            scn.peek = nrv
            return rv
        scn.more, scn.empty = False, True
        del scn.advance
        del scn.peek
        return rv

    class scn:
        advance = _advance
        more, empty, peek = True, False, None

    _advance()
    return scn


"""
DISCUSSION:

This little "stack" is for when you want to do a certain something to each
item in a list and you want to do different somethings based on how far the
item is from the end of the list and you don't know beforehand how how long
the list is (and the list is a stream lol and you don't want to have to
flush the whole thing just to find the end).

As it turns out, there is perhaps a not tiny class of problems that seem to
fit into this macro category of problem.

Origin story: we were implementing something elsewhere and we needed one
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

    if hasattr(string_iterator, '__len__'):  # #[#022] wish for strong types
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

    _spatialized_itr = spatialize_with_2_items_of_lookahead(string_iterator)

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


spatialize_with_2_items_of_lookahead = rotating_bufferer(
        _NeitherLastNorSecondToLastItem,
        _SecondToLastItem,
        _LastItem,
        lambda: _EMPTY_SINGLETON)


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #history-A.2: re-integrate some linguistic functions to use rotating buffer
# #history-A.1: introduce rotating buffer
# #abstracted.
