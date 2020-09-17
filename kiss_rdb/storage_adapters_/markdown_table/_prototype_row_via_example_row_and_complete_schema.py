import re


def BUILD_CREATE_AND_UPDATE_FUNCTIONS_(eg_row, complete_schema):  # #testpoint

    def updated_row_via(nv_pairs, existing_row, listener):
        try:
            parts = new_line_parts_via(nv_pairs, 'U', listener, existing_row)
            return row_via_parts(parts)
        except stop:
            pass

    def new_row_via(nv_pairs, listener):
        try:
            parts = new_line_parts_via(nv_pairs, 'C', listener)
            return row_via_parts(parts)
        except stop:
            pass

    def new_line_parts_via(nv_pairs, u_or_c, listener, existing_row=None):
        # WAS KeyError (Case0110DP)

        if existing_row:  # implies 'U'
            def my_exi_cell_at(i):
                if i < exi_row_length:
                    return my_exi_row.cells[i]
                pass  # (Case2667DP)
            exi_row_length = existing_row.cell_count
            existing_line = existing_row.to_line()
            my_exi_row = _my_row(existing_line)
        else:
            my_exi_cell_at = _monadic_emptiness

        nv_pairs = tuple(nv_pairs)  # allow a second pass for better error msgs
        unsanitized_pool = {k: v for k, v in nv_pairs}

        for i in rang:
            k = field_name_keys[i]
            my_exi_cell = my_exi_cell_at(i)
            if k in unsanitized_pool:
                value_string = unsanitized_pool.pop(k)  # #here1
                if not isinstance(value_string, str):
                    if value_string is None:
                        # now, None means "delete_attribute" (Case2716)
                        value_string = ''
                    else:
                        xx(f"for '{k}', please use strings or none, not {type(value_string)}")  # noqa: E501
            else:  # (Case0130DP)
                if 'U' == u_or_c and my_exi_cell:
                    yield 'cell_part', *my_exi_cell.to_pieces(existing_line)
                    continue
                value_string = ''

            # my_eg_cell = my_eg_cell_via(i)
            alignment = alignments[i]

            if re.search(r'[\\|]', value_string):
                xx(f"cover these adventurous strings: {repr(value_string)}")

            if 'shrink_to_fit' == alignment:  # (Case2481KR)
                yield 'cell_part', left_pads[i], value_string, right_pads[i]
                continue

            if 'align_center' == alignment:
                remain = example_widths[i] - len(value_string)
                if remain < 1:
                    yield 'cell_part', '', value_string, ''
                    continue
                each_side, was_odd = divmod(remain, 2)  # (Case2480KR)
                left_w, right_w = each_side, each_side
                if was_odd:
                    lt_eq_gt = center_tiebreakers[i]
                    if -1 == lt_eq_gt:
                        right_w += 1
                    else:
                        assert lt_eq_gt in (0, 1)
                        left_w += 1
                yield 'cell_part', ' '*left_w, value_string, ' '*right_w
                continue

            assert alignment in ('align_left', 'align_right')

            def stretch(fixed_pad):
                remain = example_widths[i] - len(value_string) - len(fixed_pad)
                if remain < 1:
                    return ''  # content overflow (Case0140DP)
                return ' ' * remain

            if 'align_left' == alignment:
                left_pad = left_pads[i]  # (Case2478KR)
                yield 'cell_part', left_pad, value_string, stretch(left_pad)
                continue

            if 'align_right' == alignment:
                right_pad = right_pads[i]  # (Case2479KR)
                yield 'cell_part', stretch(right_pad), value_string, right_pad
                continue

        if len(unsanitized_pool):
            bads = tuple(unsanitized_pool.keys())
            goods = tuple(set(field_name_keys) & set(i for i, _ in nv_pairs))
            listener(*_when_extra(bads, goods, u_or_c, complete_schema))
            raise stop()  # (Case1319DP)

        if 'U' == u_or_c:
            if existing_row.cell_count < formal_cell_count:
                endcap_yn = eg_row.has_endcap  # (Case2667DP)
            else:
                endcap_yn = existing_row.has_endcap  # (Case2665DP)
        else:
            endcap_yn = eg_row.has_endcap

        yield 'endcap', 'has_endcap' if endcap_yn else 'no_endcap'

    field_name_keys = complete_schema.field_name_keys
    formal_cell_count = len(field_name_keys)
    rang = range(0, formal_cell_count)

    names_row, alignment_row = complete_schema.rows_

    eg_line = eg_row.to_line()
    my_eg_row = _my_row(eg_line)

    if (aa := len(my_eg_row.cells)) < (bb := formal_cell_count):
        xx(f"example row needs as many cells as schema ({bb}). has {aa}")

    my_eg_cell_via = my_eg_row.cells.__getitem__

    example_widths = [None for _ in rang]
    alignments = [None for _ in rang]

    left_pads, right_pads, center_tiebreakers = {}, {}, {}

    for i in rang:
        mec = my_eg_cell_via(i)

        example_widths[i] = mec.padded_end - mec.padded_begin
        left_padding = eg_line[mec.padded_begin:mec.value_begin]
        right_padding = eg_line[mec.value_end:mec.padded_end]

        vs = alignment_row.cell_at_offset(i).value_string
        alignment = _alignment_type_via_value_string(vs)
        alignments[i] = alignment

        if 'align_left' == alignment:
            left_pads[i] = left_padding
        elif 'align_right' == alignment:
            right_pads[i] = right_padding
        elif 'shrink_to_fit' == alignment:
            left_pads[i] = left_padding
            right_pads[i] = right_padding
        else:
            assert 'align_center' == alignment
            lf, rt = len(left_padding), len(right_padding)
            _ = ((lambda: lf < rt, -1), (lambda: rt < lf, 1), (lambda: lf == rt, 0))  # noqa: E501
            center_tiebreakers[i] = next(x for yes, x in _ if yes())

    example_widths = tuple(example_widths)
    alignments = tuple(alignments)

    def row_via_parts(parts):
        mutable_sexps, line = _sexps_and_line_via_parts(parts)
        return row_AST_via_two(mutable_sexps, line)

    row_AST_via_two = complete_schema.row_AST_via_two_

    class stop(RuntimeError):
        pass

    return new_row_via, updated_row_via


def _when_extra(bads, goods, u_or_c, cs):
    def details():
        def jumble():  # tech demo for (Case2676) overcrowded, needs abstractio
            y = 1 == len(bads)
            s, these, do = ('', 'This', 'does') if y else ('s', 'These', 'do')
            yield f"Unrecognized attribute{s}", ox.keys_join(bads)
            yield these, f"field{s}", do, "not apear in"
            h = dct.get('table_header_line')
            yield ('"', re.match('^# (.+)', h)[1], '"') if h else "the table"
            if len(ks := set(cs.field_name_keys) - set(goods)):
                yield "Did you mean", ox.oxford_OR(ox.keys_map(ks)), '?'
            yield 'in', dct['collection_path'], ':', dct['lineno']
        dct = {k: v for row in cs.table_cstack_ for k, v in row.items()}
        import kiss_rdb.magnetics.via_collection as ox
        sentencz = (''.join(pcs) for pcs in ox.piece_rows_via_jumble(jumble()))
        dct['reason'] = ' '.join(sentencz)
        return dct

    category = ('cannot_update', 'cannot_create')[('U', 'C').index(u_or_c)]
    return 'error', 'structure', category, 'unrecgonized_attributes', details


def _alignment_type_via_value_string(value_string):
    # ':---' align left  '---:' align right   ':---:' center  '---' shrink
    md = re.match('^(?:(:)|(-))-+(?:(:)|(-))$', value_string)
    if md is None:
        xx(f"expecting alignment value string: {repr(value_string)}")
    left_colon, left_dash, right_colon, right_dash = md.groups()
    if left_colon:
        if right_dash:
            return 'align_left'  # (Case2479KR)
        assert right_colon
        return 'align_center'  # (Case2480)
    assert left_dash
    if right_dash:
        return 'shrink_to_fit'  # (Case2481KR)
    assert right_colon
    return 'align_right'  # (Case2478KR)


def _sexps_and_line_via_parts(parts):
    mutable_sxs, line_pieces = [], []

    def append(piece):
        memo.current_width += len(piece)
        line_pieces.append(piece)

    class memo:  # #class-as-namespace
        current_width = 0

    parts = list(parts)
    encap = parts.pop()

    for typ, lp, vs, rp in parts:
        assert 'cell_part' == typ
        append('|')
        append(lp)
        v_begin = memo.current_width
        append(vs)
        v_end = memo.current_width
        append(rp)
        mutable_sxs.append(('padded_cell', (v_begin, v_end)))

    typ, kw = encap
    assert 'endcap' == typ
    endcap_yn = ('no_endcap', 'has_endcap').index(kw)

    if endcap_yn:
        mutable_sxs.append(('line_ended_with_pipe',))
        append('|')
    else:
        mutable_sxs.append(('line_ended_without_pipe',))
    append('\n')

    return mutable_sxs, ''.join(line_pieces)


class _my_row:
    def __init__(self, line):
        wee = list(_complete_sexp_via_line(line))
        self.has_endcap = ('no_endcap', 'has_endcap').index(wee.pop()[1])
        self.cells = tuple(_my_cell(*sx) for sx in wee)


class _my_cell:
    def __init__(self, typ, psx, vsx):
        assert 'complete_cell' == typ
        typ, self.padded_begin, self.padded_end = psx
        assert 'padded_span' == typ
        typ, self.value_begin, self.value_end = vsx
        assert 'value_span' == typ

    def to_pieces(self, line):
        yield line[self.padded_begin:self.value_begin]
        yield line[self.value_begin:self.value_end]
        yield line[self.value_end:self.padded_end]


def _complete_sexp_via_line(line):  # #testpoint
    # in the main file we KISS how we parse lines. here we have to doe more

    assert len(line)
    assert '|' == line[0]
    assert '\n' == line[-1]

    def main():
        while True:
            parse_pipe()
            yield parse_zero_or_more_not_pipes_or_escaped_pipes()
            if parse_endcap():
                break
        yield endcap()

    def parse_zero_or_more_not_pipes_or_escaped_pipes():
        pad_begin = (cursor := self.cursor)
        while True:
            md = zero_or_more_straightforward_chars.match(line, cursor)
            _, cursor = md.span()
            char = line[cursor]
            if char in ('|', '\n'):
                break
            assert '\\' == char
            cursor += 1
            next_char = line[cursor]
            if next_char in ('\\', '|'):
                cursor += 1  # this looks like a decoding algo but we're not ..
                continue
            xx(f"invalid escape sequence {repr(char)}")
        self.cursor = cursor
        pad_span = 'padded_span', pad_begin, (pad_end := cursor)

        # Basically we take 20 lines to implement strip() that keeps offsets

        # Back up over trailing whitespace
        while True:
            cursor -= 1
            if pad_begin == cursor:
                break
            if ' ' == line[cursor]:
                continue
            break
        value_end = cursor + 1

        # Go forward over leading whitespace (we could just use regex BUT WHY!)
        cursor = pad_begin
        while True:
            if pad_end == cursor:
                break
            if ' ' == line[cursor]:
                cursor += 1
                continue
            break
        value_begin = cursor

        value_span = 'value_span', value_begin, value_end
        return 'complete_cell', pad_span, value_span

    def parse_endcap():
        md = endcap_rx.match(line, self.cursor)
        if md is None:
            return
        self.endcap_matchdata = md
        return True

    def endcap():
        md = self.endcap_matchdata
        return 'endcap', ('has_endcap' if md[1] else 'no_endcap')

    def parse_pipe():
        assert '|' == line[self.cursor]
        self.cursor += 1

    class self:  # #class-as-namespace
        cursor = 0

    zero_or_more_straightforward_chars = re.compile(r'[^|\\\n]*')
    endcap_rx = re.compile(r'(\|)?\n')

    return main()


def _monadic_emptiness(_):
    pass


def xx(msg=None):
    raise RuntimeError('oops: write me/cover me' + (f': {msg}' if msg else ''))

# #history-A.4 (almost) blind rewrite
# #history-A.3 (can be temporary): dog-eared specific code
#   (before #history-A.2 we use to do (Case0150DP) here)
# #history-A.2: short-circuiting out of updating single-field records moved up
# #history-A.1: sneak merge into here to be alongside create new
# #born.
