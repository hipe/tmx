_max_rows_per_label = 3
_max_cols_per_label = 9


def output_lines_via_big_index_(o, listener):

    # begin

    yield 'digraph g {'
    yield 'rankdir=BT'

    # previouses

    for me, prev in o.previous_of.items():
        yield f'_{me}->_{prev}[label="prev"]'

    # parents

    for parent, cx in o.children_of.items():
        for child in cx:
            yield f'_{child}->_{parent}[label="parent"]'

    # no parents

    for iid in o.ids_of_frags_with_no_parent_or_previous:
        yield f'_{iid}->"(no parent)"'

    # labels for nodes
    notch = len(' (ABC)') - 4  # ??
    these = _these_via_these(_max_cols_per_label, _max_rows_per_label, notch)
    label_via = _build_label_maker(these, '(', ')')

    frag_of = o.notecard_of
    for k, frag in frag_of.items():
        label = label_via(frag.heading, frag.identifier_string)
        yield f'_{k}[label={label}]'

    # done

    yield ('label="\\n(generated) notecard relationships\\n'
           'in your whole collection"')
    yield '}'

    def f():
        _num = len(frag_of)
        _message = f'graph reflects relationships among {_num} notecards.'
        return {'message': _message}
    listener('info', 'structure', 'summary', f)


def _build_label_maker(row_max_widths, op='', cp='', ellipsis_string='…'):
    """DISCUSSION: Please enjoy the custom word-wrapper we built bespoke for
    this visualization omg.
    Start by imagining a 3x9 (for example) ASCII rectangular area:

        XxxXxxXxx
        XxxXxxXxx
        XxxXxxXxx

    Notch-out a corner of it to fit internal identifier label (" (ABC)").

        XxxXxxXxx
        XxxXxxXxx
        Xxx

    This remaining "fixed shape" defines the ASCII .. shape into which the
    heading's words will be word-wrapped. If it doesn't all fit (just as
    likely as not), the copy is appended with an ellipsis and we try to
    arrange things so the ellipsis surface form itself doesn't break our
    placement constraints.

    (Our word wrapping never breaks words and always expresses the ellipsis
    when it truncates. A corollary of these two provisions is that we cannot
    guarantee we don't draw outside the lines; but generally we expect the
    behavior to express aesthetic results.)

    (We will cheat and give the third line four (4) more chars than what is
    pictured above.) :[#882.P]
    """

    def make_label(body_content, notch_content):
        itr = word_wrapped_lines_via(body_content)
        pcs = pieces_via_lines((o.to_string() for o in itr), notch_content)
        return ''.join(pcs)

    def pieces_via_lines(lines, notch_content):
        yield '"'
        is_first = True
        for line in lines:
            if is_first:
                is_first = False
            else:
                yield r'\n'
            yield line.replace('"', r'\"')
        yield ' '
        yield op
        yield notch_content
        yield cp
        yield '"'

    from text_lib.magnetics.via_words import fixed_shape_word_wrapperer as fun
    word_wrapped_lines_via = fun(row_max_widths, 'big_string', ellipsis_string)
    return make_label


def _these_via_these(max_cols_per_label, max_rows_per_label, notch_w):
    assert 0 < max_rows_per_label
    assert 4 < max_cols_per_label  # sanity
    assert -1 < notch_w
    assert notch_w < max_cols_per_label
    result = [max_cols_per_label for _ in range(0, max_rows_per_label)]
    result[-1] = max_cols_per_label - notch_w
    return tuple(result)

# #born.
