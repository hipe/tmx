"""
this ended up blowing up into [#458] thoughts on collection metadata..
"""
# (removed lots of comments that became outdated at #history-A.1)


class MarkdownTableScanner:

    # eg.
    #     while not scn.is_empty:
    #         scn.peeked_AST_symbol  # ..
    #         scn.peeked_AST  # ..
    #         scn.advance()  # ..

    def __init__(self, lines, do_parse_example_row, listener):
        # (Case2451), (Case3306DP)

        from kiss_rdb.storage_adapters_.markdown_table.magnetics_.entities_via_collection import (  # noqa: E501
                ExpectedTagOrder_)
        self._ETO = ExpectedTagOrder_()

        from .tagged_native_item_stream_via_line_stream import (
                MarkdownTableLineParser_)
        self._parse = MarkdownTableLineParser_(listener)

        self.is_empty = False  # -- public things
        self.OK = True
        self.peeked_AST_symbol, self.peeked_AST = (None, None)

        self._lines = lines  # -- the rest
        self._do_parse_example_row = do_parse_example_row
        self._listener = listener

        self.advance = self._advance_while_in_beginning
        self.advance()

    def _advance_while_in_beginning(self):
        self._step_and_parse_line()
        if not self.OK:
            return
        if self.is_empty:
            cover_me('beginning of markdown table never found')
            return
        if self._ETO.matches_top(self.peeked_AST_symbol):
            return
        self._ETO.pop_and_assert_matches_top(self.peeked_AST_symbol)
        del self.advance
        self._step_and_parse_line()
        if not self.OK:
            return
        if self.is_empty:
            cover_me('table with header row but not schema row')

        self._ETO.pop_and_assert_matches_top(self.peeked_AST_symbol)
        self.peeked_AST_symbol = 'table_schema_from_two_lines'

        _field_names = self.peeked_AST.complete_schema.schema_field_names
        self._dictionary_via_row_DOM = _dict_via_row_dom(_field_names)

        self._ETO.pop_and_assert_matches_top('business_object_row')  # hacky

        if self._do_parse_example_row:
            self.advance = self._advance_over_example_row
        else:
            self.advance = self._advance_to_next_business_line

    def _advance_over_example_row(self):
        cover_me('whenever we used this, it may be lost. maybe sunset feature')
        self._step_and_parse_line()
        if not self.OK:
            return
        if self.is_empty:
            cover_me("no example row (so empty table) - that's OK but etc")
            return
        self.peeked_AST = self._dictionary_via_row_DOM(self.peeked_AST)  # ..
        self.OK, self.TAG_LYFE_FIELD_NAMES = _tag_lyfe_field_names_hack(
                self.peeked_AST, self._listener)
        if not self.OK:
            return self._close()
        self.peeked_AST_symbol = 'example_row'
        self.advance = self._advance_to_next_business_line

    def _advance_to_next_business_line(self):
        self.advance = self._do_advance_to_next_business_line
        self.advance()

    def _do_advance_to_next_business_line(self):
        self._step_and_parse_line()
        if self.is_empty or not self.OK:
            return
        if not self._ETO.matches_top(self.peeked_AST_symbol):
            self.advance = self._pass_thru
            return
        self.peeked_AST = self._dictionary_via_row_DOM(self.peeked_AST)  # ..

    def _step_and_parse_line(self):
        line = self._next_line()
        if line is None:
            return
        tup = self._parse(line)
        if tup is None:
            self.OK = False
            return self._close()
        self.peeked_AST_symbol, self.peeked_AST = tup

    def _pass_thru(self):
        line = self._next_line()
        if line is None:
            return
        self.peeked_AST = line

    def _next_line(self):
        eos = True
        for line in self._lines:  # #once
            eos = False
            break
        if eos:
            return self._close()
        return line

    def _close(self):
        del self.peeked_AST_symbol
        del self.peeked_AST
        self.is_empty = True


# ==

def _tag_lyfe_field_names_hack(dct, listener):  # :#here2
    """hackishly use the presence of an octothorpe to determine..."""

    # (at #history-A.1, got rid of the idea of "intention", near [#458.2]
    #  (whether to be a "jack of all trades"))

    these = tuple(k for k in dct.keys() if '#' in dct[k])
    result = these if len(these) else None
    if result is None:
        __whine_about_no_whatever(dct, listener)
        return False, None
    return True, result


def __whine_about_no_whatever(dct, listener):

    # (may have lost coverage at [#707.J])

    from script_lib.magnetics.via_words import (
            complicated_join as ellipsis_join)

    def msg_f():
        yield "your example row needs at least one cel with a hashtag in it."
        yield ellipsis_join('(had: ', ', ', ')', dct.values(), 80, repr)
    listener('error', 'expression', 'no_tag_lyfe_field_names', msg_f)


# ==

def _dict_via_row_dom(field_names):
    def f(dom):
        _r = range(0, dom.cels_count)
        _pairs = ((i, dom.cel_at_offset(i).content_string()) for i in _r)
        # #[#873.5] where sparseness is implemented (Case2451)
        return {field_names[t[0]]: t[1] for t in _pairs if len(t[1])}
    return f


def cover_me(msg):  # #open [#876] cover me
    raise Exception(f'cover me: {msg}')

# #history-A.1
# #abstracted.
