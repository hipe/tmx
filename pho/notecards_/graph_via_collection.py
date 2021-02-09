_max_rows_per_label = 3
_max_cols_per_label = 9


def graphviz_dotfile_lines_via_(big_index, listener):

    yield 'digraph g {\n'
    yield '  rankdir=BT\n'

    unordered = tuple(big_index.to_node_tree_index_items())
    ordered = _same_order(unordered)

    def lines_for_subgraph(eid, tree_index):
        yield f"  subgraph cluster_{eid} {{\n"
        yield f"    label=\"\\nThe '{eid}' node tree\"\n"

        all_eids = [eid]

        for parent_eid, eids in tree_index.children_of.items():  # ..
            for ch_eid in eids:
                yield f"    _{ch_eid}->_{parent_eid}\n"
                all_eids.append(ch_eid)

        totals.node += len(all_eids)
        totals.tree += 1

        for ch_eid in all_eids:
            node = cache[ch_eid]
            plus = ''
            if 'document' == node.hierarchical_container_type:
                plus = " style=filled"
            label = label_via(node.heading, ch_eid)
            yield f"    _{ch_eid}[label={label}{plus}]\n"

        yield '  }\n'

    notch = len(' (ABC)') - 4  # ??
    these = _these_via_these(_max_cols_per_label, _max_rows_per_label, notch)
    label_via = _build_label_maker(these, '(', ')')

    totals = lines_for_subgraph  # #watch-the-world-burn
    totals.tree = 0
    totals.node = 0

    cache = big_index.cache

    for eid, tree_index in ordered:
        for line in lines_for_subgraph(eid, tree_index):
            yield line

    yield "}\n"

    def f():
        msg = f"graph reflects {totals.node} node(s) in {totals.tree} tree(s)."
        return {'message': msg}
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


# == BEGIN sneak-in the ASCII tree visualization

def tree_ASCII_art_lines_via(big_index):
    normal_tree = _normal_tree_via_big_index(big_index)
    return _tree_ASCII_art_lines_via(normal_tree)


def _tree_ASCII_art_lines_via(top_normal_tree):

    def main():
        return recurse('', '', *top_normal_tree)

    def recurse(head, smear, label, childrener):
        yield f"{head}{label}\n"
        items = childrener()
        if items is None:
            return
        items = tuple(items)  # (it's usually a generator)
        leng = len(items)
        assert 0 < leng  # ..
        last = leng - 1
        if last:
            ch_head = f"{smear}├──"
            ch_smear = f"{smear}|  "

        last_ch_head = f"{smear}└──"
        last_ch_smear = f"{smear}  "

        for i in range(0, leng):
            if last == i:
                ch_head = last_ch_head
                ch_smear = last_ch_smear
            ch_label, ch_childrener = items[i]
            for line in recurse(ch_head, ch_smear, ch_label, ch_childrener):
                yield line

    return main()


def _normal_tree_via_big_index(big_index):
    # The big index is not recursively symmetrical: ..

    def tree_indexes_as_children():
        for k, tree_index in ordered:
            label = _label_for(cache[k])
            yield label, childrener_via_tree_index(k, tree_index)

    def childrener_via_tree_index(top_key, tree_index):

        def make_childrener(key):
            def childrener():
                return do(key)
            return childrener

        def do(key):
            cx = cx_of.get(key)
            return cx and do_do(cx)

        def do_do(cx):
            for k in cx:
                ch_label = _label_for(cache[k])
                yield ch_label, make_childrener(k)

        cx_of = tree_index.children_of
        return make_childrener(top_key)

    unordered = tuple(big_index.to_node_tree_index_items())
    ordered = _same_order(unordered)
    cache = big_index.cache

    return 'collection', tree_indexes_as_children


def _label_for(node):
    return ''.join(_label_pieces_for(node))


def _label_pieces_for(node):
    yield node.identifier_string
    if (s := node.hierarchical_container_type):
        yield f" [{s}]"
    if (s := node.heading):
        yield f" {s!r}"


def _same_order(unordered):
    if 1 == len(unordered):
        return unordered
    return sorted(unordered, key=lambda tup: (-tup[1].to_node_count(), tup[0]))

# == END


def _these_via_these(max_cols_per_label, max_rows_per_label, notch_w):
    assert 0 < max_rows_per_label
    assert 4 < max_cols_per_label  # sanity
    assert -1 < notch_w
    assert notch_w < max_cols_per_label
    result = [max_cols_per_label for _ in range(0, max_rows_per_label)]
    result[-1] = max_cols_per_label - notch_w
    return tuple(result)


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #history-B.4 splice-in ASCII tree visualization
# #born.
