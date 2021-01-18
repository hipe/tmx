""""via words": operations that operate on a stream of words (mostly),

conceived of as familiar stream-based (and see ReactiveX) operations. E.g.,
"word wrap" is a chunking operation; "oxford AND" is a join; and others.

A lot of the resources in this module can be summarized as: when for each item
in a list (stream actually) you want to do a certain something determined by
how far the item is from the end of the list (the class of problems requiring
some N items of lookahead) and you don't know beforehand how long the list is
and you don't want to flush the whole stream into memory just to find the end.

We expose a function that produces an N-slotted rotating buffer, given N (+1)
"positional" functions, each of which determines how to "wrap" those items
in the stream that are that far from the end. The hypothesis is that we can
generalize several language production problems requiring lookahead to be
applications of this same foundational function.

(Indeed, under this methodology a [#611] scanner is a specialized type of
rotating buffer, and we use those all over the place. But we don't go so far
as to require this rotating buffer for these scanners, to avoid overcomplicated
coupling/dependency. On this subject, our rotating buffer function used to
live in a lower-level module but we re-housed it here at #history-B.3 to unify
frequently used language production functions.)
"""

from modality_agnostic import lazy


# == Piece Rows via Jumble

def piece_rows_via_jumble(itr):
    """EXPERIMENTAL. Make construction of emission messages prettier

    by freeing them from the low-level logic of conditional spaces and punct.
    Argument is "jumble": a stream each item of which is either a "piece"
    (string, like a "word") or a tuple of pieces. We do a buch of heuristics
    to "make it work" such that the output is a stream of "rows" where each
    row is a tuple of "pieces" which are like the argument pieces but with
    single spaces (and other punctuation?) interspersed approrpriately.
    """
    # ~(Case3696-(Case3731)

    def main():
        while scn.more:
            parse_next_piece()
            if global_state.has_sentence:
                yield flush_piece_row()
        run_any_on_pops_while_flushing_stack()
        if (row := flush_final_piece_row()):
            yield row

    # == State Machine #[#008.2]

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
        add_piece(scn.next())

    def pop_push_between_sentences():
        assert 2 == len(stack)  # or not
        stack_pop()
        stack_push(sentence_state)
        if pieces[-1][-1] not in sentence_ending_punc_char:
            add_piece('.')  # the trick of not perioding the last sentence
        prepare_for_flush()
        add_piece(scn.next())

    def push_sentence_state():
        prepare_for_flush()
        add_piece(scn.next())

    def pop_sentence_state():
        add_piece(scn.next())  # the punctuation
        prepare_for_flush()
        stack_pop()

    def push_quote_state():
        stack_push(quote_state)
        (frame := top_frame()).which_quote = scn.peek
        add_pieces(' ', scn.next())
        frame.do_add_space = False

    def handle_end_quote():
        add_pieces(scn.next())
        stack_pop()

    def handle_colon_with_some_hacking():
        path = pieces[-1]
        add_piece(scn.next())  # the colon
        if re.search(r'\.[a-z0-9]{2,3}$', path) and isinstance(scn.peek, int):
            top_frame().do_add_space = False
            scn.peek = str(scn.peek)  # watch the world burn

    def push_hacked_parenthesis_state():
        stack_push(hacked_parenthesis_state, close_parenthesis_on_pop)
        add_pieces('(', scn.next())

    def close_parenthesis_on_pop():
        add_piece(')')  # ..

    def pop_out_of_hacked_parenthesis_state():
        xx()  # needs coverage. not in target case

    def add_space_and_token():
        maybe_add_space()
        add_piece(scn.next())

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

    from .scanner_via import scanner_via_iterator as func
    scn = func(_pieces_via_jumble(itr))

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


def _pieces_via_jumble(itr):  # 👆
    return (s for row in itr for s in (row if isinstance(row, tuple) else (row,)))  # noqa: E501


# == Word Wrap

def fixed_shape_word_wrapperer(  # #[#612.6] a word-wrap implementation
        row_max_widths, input_format, ellipsis_string='…'):

    if 'big_string' == input_format:
        def word_wrapped_lines_via_big_stream(big_string):
            tox = _spatialized_tokens_via_big_string(big_string)
            return word_wrapped_lines_via_tokens(tox)
        rv = word_wrapped_lines_via_big_stream

    else:
        assert 'words' == input_format

        def word_wrapped_lines_via_words(words):
            tox = _spatialize_with_1_item_of_lookahead()(words)
            return word_wrapped_lines_via_tokens(tox)
        rv = word_wrapped_lines_via_words

    def word_wrapped_lines_via_tokens(tox):
        return ww_proto.duplicate_plus(tox).flush_to_structured_lines()

    ww_proto = _FixedShapeWordWrap(row_max_widths, ellipsis_string)
    return rv


def _spatialized_tokens_via_big_string(big_string):  # 👆
    itr = _re().finditer('([^ ]+)([ ]+|$)', big_string)  # risky
    itr = (md[1] for md in itr)
    return _spatialize_with_1_item_of_lookahead()(itr)


# == Oxford Join

def keys_map(pcs):  # these items are frequently bought together
    return (f"'{pc}'" for pc in pcs)


def oxford_AND(these):
    return oxford_join(these, ' and ')


def oxford_OR(these):
    return oxford_join(these, ' or ')


def oxford_join(string_iterator, major_sep=' and ', minor_sep=', '):

    """Given an iterable that produces 0-N strings, result in one string that
    is a specialized join using the separator arguments positionally:

    >>> oxford_join(('A', 'B', 'C'))
    'A, B and C'

    >>> oxford_join(('A', 'B'))
    'A and B'

    >>> oxford_join(('A',))
    'A'

    >>> oxford_join(())
    'nothing'

    >>> oxford_join(('A', 'B', 'C', 'D'))
    'A, B, C and D'

    This function does not actually employ the "oxford comma" by default;
    nor do we ever produce one in practice. Vampire Weekend.
    """

    if hasattr(string_iterator, '__len__'):
        string_iterator = iter(string_iterator)
    itr = _strings_for_oxford_join(
            string_iterator,
            major_sep, minor_sep)
    return ''.join(itr)


def _strings_for_oxford_join(string_iterator, major_sep, minor_sep):

    classified = _spatialize_with_2_items_of_lookahead()(string_iterator)
    for o in classified:
        if o.is_neither_last_nor_second_to_last_item:
            yield o.item
            yield minor_sep
        elif o.is_second_to_last_item:
            yield o.item
            yield major_sep
        elif o.is_last_item:
            yield o.item
        else:
            assert o.is_the_empty_item
            yield 'nothing'  # move it up when u need to


# == Complicated Join (island)

def _complicated_join_ISLAN(left, sep, right, itr, max_width, string_via_item):
    """
    this is something like a width-sensitive `str.join` (and is experimental):

    result in a string whose width does not exceed `max_width` (provided your
    string arguments make sense in the expected way), whereby the items from
    `itr` are stringified using `string_via_item` and ellipsified as necessary;
    all nested in the `left` and `right` delimiter strings and joined with
    the `sep` string. whew!

    >>> func = _complicated_join_ISLAN
    >>> func("👀:(", ", ", ")", iter(('a', 'b', 'c')), 11, lambda x: x.upper())
    '👀:(A, B…)'

    Issues:
      - because we don't bother with lookahead, full traversals that
        would exactly fit (or come within one (maybe 2)) will be missed,
        because we always assume we will be adding the '..'. if your full
        traversal comes out to a width that is at or less than maxwidth
        minus ~2, ok.

    Became coverage island at [#707.10]
    """

    tail_ellipsis = '…'
    current_width = len(left) + len(right) + len(tail_ellipsis)
    pieces = [left]

    def separator_stuff_at_this_step_initially():
        real_tuple = (len(sep), sep)
        self.separator_stuff_at_this_step = lambda: real_tuple
        return (0, '')

    class self:  # #class-as-namespace
        separator_stuff_at_this_step = separator_stuff_at_this_step_initially

    broke = False
    for x in itr:
        as_string = string_via_item(x)
        w, use_sep = self.separator_stuff_at_this_step()

        would_be_width = current_width + w + len(as_string)

        if would_be_width > max_width:
            broke = True
            break

        pieces.append(use_sep)
        pieces.append(as_string)
        current_width = would_be_width

        if would_be_width == max_width:
            broke = True
            break

    if broke:
        pieces.append(tail_ellipsis)

    pieces.append(right)
    return ''.join(pieces)


def ELLIPSIS_JOIN(itr, ellipsis='…', sep=', '):  # (only one client at writing)
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

    # Extracted to here history-B.3. Their #!history-A.3 buries something
    # complicated & awkward (but "streaming")

    return ''.join((sep.join(itr), ellipsis))


ellipsis_join = ELLIPSIS_JOIN  # NOTE only to make the doctest pretty


# == Word Wrap Implementation

class _FixedShapeWordWrap:

    def __init__(self, row_max_widths, ellipsis_string):
        self.tokens = None
        self.ellipsis_string = ellipsis_string
        self.row_max_widths = row_max_widths

    def duplicate_plus(self, tokens):
        otr = self.__class__(self.row_max_widths, self.ellipsis_string)
        otr.tokens = tokens
        return otr

    def flush_to_structured_lines(self):
        itr = self._flush_to_structured_lines_without_ellipsifying()
        itr = _spatialize_with_2_items_of_lookahead()(itr)
        had_at_least_2 = False
        for o in itr:
            if o.is_neither_last_nor_second_to_last_item:
                yield o.item
            elif o.is_second_to_last_item:
                had_at_least_2 = True
                second_to_last_line = o.item
            elif o.is_last_item:
                last_line = o.item
            else:
                assert(o.is_the_empty_item)  # (Case3760)
                return

        if not self._do_ellipsify:
            if had_at_least_2:
                yield second_to_last_line
            yield last_line
            return

        # you need to add an ellipsis. this means you filled the shape
        # which means the last real line corresponds to the last formal line

        append_me = _Word(self.ellipsis_string)
        orig_cx = last_line.children
        available_width = self.row_max_widths[-1] - last_line.width

        last_resort = False
        went_cray = False

        # if there's room on the last line, just append that badboy
        if append_me.width <= available_width:

            cx = (*orig_cx, append_me)  # (Case3745)
            went_cray = False

        # if there's more than one element on the last line, replace last item
        # (and don't bother checking lengths meh)
        elif 1 < len(orig_cx):

            cx = (*orig_cx[0:-1], append_me)  # (Case3748)

        # you have only one element on last line and you needed to bump it
        elif had_at_least_2:

            orig_cx = second_to_last_line.children
            available_width = self.row_max_widths[-2] - second_to_last_line.width  # noqa: E501

            # is there available room on the second to last line, just append
            if append_me.width <= available_width:

                cx = (*orig_cx, append_me)  # (Case3751)
                went_cray = True

            # if there's more than one element, replace the last with ellipsis
            elif 1 < len(orig_cx):
                cx = (*orig_cx[0:-1], append_me)  # (Case3754)
                went_cray = True
            else:
                last_resort = True
        else:
            last_resort = True

        if last_resort:
            cx = (*last_line.children, append_me)  # (Case3757)

        from functools import reduce
        _w = reduce(lambda m, i: m+i, (o.width for o in cx))   # meh
        altered_line = last_line.__class__(_w, cx)

        if had_at_least_2 and not went_cray:
            yield second_to_last_line

        yield altered_line

    def _flush_to_structured_lines_without_ellipsifying(self):

        self._do_ellipsify = False

        words = self.tokens
        del self.tokens

        for word in words:  # #once
            break

        if word is _WAS_EMPTY:
            return  # (Case3760)

        # --

        class my_state:  # #class-as-namespace
            pass

        state = my_state
        state.current_width = 0
        state.offset_of_the_row_we_are_on = -1
        state.shape_is_filled = False
        state.max_width = None

        # --

        cache = []
        would_be_width = None

        def do_accept_word(word):
            state.current_width = would_be_width
            cache.append(_SpacePlusWord(word) if len(cache) else word)

        def do_flush_row():
            res = _StructuredLine(state.current_width, tuple(cache))
            cache.clear()
            state.current_width = 0
            return res

        def begin_next_row():
            i = state.offset_of_the_row_we_are_on + 1
            if i == len(self.row_max_widths):
                state.shape_is_filled = True
                return
            state.offset_of_the_row_we_are_on = i
            self.max_width = self.row_max_widths[i]

        begin_next_row()
        assert(not state.shape_is_filled)  # iff the empty shape

        while True:  # there are multiple exit conditions
            if state.current_width:
                would_be_width = state.current_width + 1 + word.width
            else:
                would_be_width = word.width

            if would_be_width < self.max_width:
                # the new word doesn't put us over or on, just add it
                accept_word = True
                flush_row = False
            elif would_be_width == self.max_width:
                # the new word would land us right on the money
                accept_word = True
                flush_row = True
            elif len(cache):
                # the new word would put us over and there are already words
                accept_word = False
                flush_row = True
            else:
                # the new word would be the leftmost word and puts us over
                accept_word = True
                flush_row = True

            assert(accept_word or flush_row)  # else no state change; inf loop

            if accept_word:
                do_accept_word(word)
                if word.is_final_word:
                    yield do_flush_row()
                    break
                word = next(words)

            if flush_row:
                yield do_flush_row()
                begin_next_row()
                if state.shape_is_filled:
                    self._do_ellipsify = True  # (Case3745)
                    break


# == Model for Word Wrap

class _StructuredLine:

    def __init__(self, w, tup):
        self.width = w
        self.children = tup

    def to_string(self):
        return ''.join(o.to_string() for o in self.children)


class _SpacePlusWord:

    def __init__(self, word):
        self._word = word

    @property
    def width(self):
        return 1 + self._word.width

    def to_string(self):
        return f' {self._word.string}'


# == These Two Popular Rotating Buffers That Classify Items Positionally

@lazy
def _spatialize_with_2_items_of_lookahead():

    class ClassifiedItem:
        def __init__(self, item):
            self.item = item

    class NeitherLastNorSecondToLastItem(ClassifiedItem):
        is_neither_last_nor_second_to_last_item = True

    class SecondToLastItem(ClassifiedItem):
        is_neither_last_nor_second_to_last_item = False
        is_second_to_last_item = True

    class LastItem(ClassifiedItem):
        is_neither_last_nor_second_to_last_item = False
        is_second_to_last_item = False
        is_last_item = True

    class EMPTY_SINGLETON:  # #class-as-namespace
        is_neither_last_nor_second_to_last_item = False
        is_second_to_last_item = False
        is_last_item = False
        is_the_empty_item = True

    return rotating_bufferer(
        NeitherLastNorSecondToLastItem, SecondToLastItem, LastItem,
        lambda: EMPTY_SINGLETON)


@lazy
def _spatialize_with_1_item_of_lookahead():

    class NotFinalWord(_Word):
        is_final_word = False

    class FinalWord(_Word):
        is_final_word = True

    return rotating_bufferer(NotFinalWord, FinalWord, lambda: _WAS_EMPTY)


class _Word:
    def __init__(self, s):
        self.width = len(s)
        self.string = s

    def to_string(self):
        return self.string


class _WAS_EMPTY:
    pass


# == Rotating Buffer

def rotating_bufferer(*funcs):  # #[#510.15] one of several rotating buffers
    """
    We produce a flat-map that classifies each item of the argument stream
    based on how far it is from the end of the stream by some fixed N amount,
    and optionally we can emit special classification object to be emitted
    in those cases when the stream was empty to begin with.

    So, normally this emits N items for every stream of N input items, but in
    the case of the empty stream it might emit N+1 items (1 item), making it a
    sort of flat map.

    We call it "rotating buffer" because we use one internally for
    implementation, and it became a convenient label for the whole idea
    that otherwise doesn't have a good name (but this is subject to change).

    Construct your rotating buffer with N functions (2 should be ok, but
    currently we require at least 3). All but the last are "map" functions
    that are typically used to wrap the items from the input stream.

    That result function takes as its only argument an iterator and results in
    another iterator, one whose output items will have been passed through
    the map functions appropriately given each item's distance from what
    ends up being the end of the stream. We use only as much lookahead as
    is necessary; the resultant function still "streams".

    Schematic illustration of usage:

        itr_via_itr = rotating_bufferer(
            map_otherwise, […] [map_2nd_to_last], map_last, when_none)

        #                   ^                                  ^
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

    assert 2 < (leng := len(funcs))
    largest_i = (ring_size := (leng_minus_one := leng - 1) - 1) - 1

    def wrapped_items_via(itr):
        # Load items up into the ring
        ring = []
        for item in itr:
            ring.append(item)
            if ring_size == len(ring):
                break

        # Handle edge case: the input exhausted before filling the buffer ring
        if (cache_length := len(ring)) < ring_size:
            if 0 == cache_length:
                if (callback_when_none := funcs[-1]):
                    yield callback_when_none()
                return

            for i in range(0, len(ring)):
                yield funcs[ring_size - i](ring[i])
            return

        # Now you have a full ring, which means you'll be using each of your
        # positional special functions. For each one more item that you can
        # read, output it as an "uninteresting" item and replace it
        uninteresting = funcs[0]
        ring = list(reversed(ring))
        i = 0
        for item in itr:
            if i:
                i -= 1
            else:
                i = largest_i
            yield uninteresting(ring[i])
            ring[i] = item

        # Flush the ring (cache)
        for func_offset in range(1, leng_minus_one):
            # the first time: you have a full ring (you checked above)) so
            # ticking it fwd one actually ticks it back to the oldestmost item
            if i:
                i -= 1
            else:
                i = largest_i
            yield funcs[func_offset](ring[i])

    return wrapped_items_via


# == Unindent (sort of a stowaway here: a split rather than a join)

def unindent(big_string):
    """Use margin of the first line to unindent every line"""

    return _the_unindent_function()(big_string)


@lazy
def _the_unindent_function():
    def unindent(big_string):

        if '' == big_string:
            return  # (Case4258KR) the empty string becomes the empty iterator

        md = the_first_run_of_whitespace_rx.match(big_string)
        cursor = md.end('head_anchored_newline')
        margin = md['margin_at_head_of_first_line']
        margin_rx = re.compile(re.escape(margin))
        length = len(big_string)

        while True:
            # Advance over any margin
            md = margin_rx.match(big_string, cursor)

            # If it matched, advance to the end of the margin
            if md:
                cursor = md.end()

            # (If it didn't match, there's a blank line, keep the cursor as-is)

            if length == cursor:
                break

            md = line_rx.match(big_string, cursor)
            yield md['whole_line_including_newline']
            cursor = md.end()

    re = _re()
    the_first_run_of_whitespace_rx = re.compile(r"""
        ^(?P<head_anchored_newline> \n )
        (?P<margin_at_head_of_first_line> [ ]+ )
    """, re.VERBOSE)
    line_rx = re.compile(r'(?P<whole_line_including_newline>[^\n]*\n)')
    return unindent


def _re():
    import re as module
    return module


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))


def _run_doctest():
    from doctest import testmod as func
    func()


if __name__ == "__main__":
    _run_doctest()

# #history-B.3 subsume rotating buffer, oxfords, unindent
# #history-A.1: introduce word wrap
# #born.
