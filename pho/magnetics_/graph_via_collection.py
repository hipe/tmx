from script_lib.magnetics.via_words import (
        fixed_shape_word_wrapperer as word_wrapperer)


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

    frag_of = o.notecard_of
    for k, frag in frag_of.items():

        _encoded = _ENCODED_heading_for(frag)
        yield f'_{k}[label={_encoded}]'

    # done

    yield (
            'label="\\n(generated) notecard relationships\\n'
            'in your whole collection"'
            )
    yield '}'

    def f():
        _num = len(frag_of)
        _message = f'graph reflects relationships among {_num} notecards.'
        return {'message': _message}
    listener('info', 'structure', 'summary', f)


def _ENCODED_heading_for(frag):
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
    pictured above.)
    """

    _itr = _word_wrapped_lines_via(big_string=frag.heading)
    these = list(_itr)
    lines = list(o.to_string() for o in these)

    pieces = ['"']
    is_first = True
    for line in lines:
        if is_first:
            is_first = False
        else:
            pieces.append('\\n')
        pieces.append(line.replace('"', '\\"'))

    pieces.append(f' ({frag.identifier_string})')
    pieces.append('"')
    return ''.join(pieces)


w = 9
_word_wrapped_lines_via = word_wrapperer(
        row_max_widths=(w, w, w-len(' (ABC)')+4),
        ellipsis_string='…',
        )

# #born.
