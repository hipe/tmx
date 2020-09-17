from modality_agnostic.memoization import lazy


def fixed_shape_word_wrapperer(row_max_widths, ellipsis_string=None):

    ww_proto = _FixedShapeWordWrap(
            row_max_widths=row_max_widths,
            ellipsis_string=ellipsis_string)

    def word_wrapped_lines_via(**kwargs):

        which, = kwargs.keys()
        if 'big_string' == which:
            tokens = __token_stream_via_big_string(kwargs['big_string'])
        else:
            raise KeyError(which)

        _ww = ww_proto.duplicate_plus(tokens=tokens)
        return _ww.flush_to_structured_lines()

    return word_wrapped_lines_via


def complicated_join(left, sep, right, itr, max_width, string_via_item):
    """
    this is something like a width-sensitive `str.join` (and is experimental):

    result in a string whose width does not exceed `max_width` (provided your
    string arguments make sense in the expected way), whereby the items from
    `itr` are stringified using `string_via_item` and ellipsified as necessary;
    all nested in the `left` and `right` delimiter strings and joined with
    the `sep` string. whew!

        subject("wow: (", ", ", ")", iter(['a', 'b', c']), 13, lambda x: x)

    gets you:

        "wow: ('a', 'b'..)"


    Issues:
      - because we don't bother with lookahead, full traversals that
        would exactly fit (or come within one (maybe 2)) will be missed,
        because we always assume we will be adding the '..'. if your full
        traversal comes out to a width that is at or less than maxwidth
        minus ~2, ok.

    (may have lost coverage at [#707.J])
    (#[#007.2] wish for doctest)
    """

    tail_ellipsis = '..'
    current_width = len(left) + len(right) + len(tail_ellipsis)
    pieces = [left]

    self = _ComplicatedJoinState()

    def separator_stuff_at_this_step_initially():
        real_tuple = (len(sep), sep)
        self.separator_stuff_at_this_step = lambda: real_tuple
        return (0, '')

    self.separator_stuff_at_this_step = separator_stuff_at_this_step_initially

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


class _ComplicatedJoinState:  # #[#510.3]

    def __init__(self):
        self.separator_stuff_at_this_step = None


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
        itr = _rotbuf_lib().spatialize_with_2_items_of_lookahead(itr)
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


def __token_stream_via_big_string(big_string):
    import re
    itr = re.finditer('([^ ]+)([ ]+|$)', big_string)  # risky
    itr = (md[1] for md in itr)
    return _tokens_via_token_strings()(itr)


@lazy
def _tokens_via_token_strings():
    return _rotbuf_lib().rotating_bufferer(
            _NotFinalWord, _FinalWord, lambda: _WAS_EMPTY)


class _Word:

    def __init__(self, s):
        self.width = len(s)
        self.string = s

    def to_string(self):
        return self.string


class _NotFinalWord(_Word):
    is_final_word = False


class _FinalWord(_Word):
    is_final_word = True


class _WAS_EMPTY:
    pass


# ==

def _rotbuf_lib():
    from modality_agnostic.magnetics import (
            rotating_buffer_via_positional_functions as lib)
    return lib

# #history-A.1: introduce word wrap
# #born.
