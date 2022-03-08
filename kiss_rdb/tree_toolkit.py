def lines_via_tree_dictionary(
        dct,
        branch_node_opening_line_by,
        leaf_node_line_by,
        branch_node_closing_line_string,
        listener=None, root_node_EID=None, indent=2):

    # Emit a notice if there are no nodes at all
    if 0 == len(dct):
        listener('notice', 'expression', 'empty_tree', lambda: ('empty tree',))
        return

    if root_node_EID is None:
        root_node_EID = next(iter(dct.keys()))

    # Emit a notice if the root node has no children
    root_node = dct[root_node_EID]
    if not root_node.children:
        msg = 'root tree has no children'
        listener('notice', 'expression', 'empty_tree', lambda: (msg,))
        return

    def lines_from_recursing_into_this_branch_node(bnode, my_indent_string):
        some_cx_eids = bnode.children
        assert some_cx_eids
        ch_indent_string = f"{my_indent_string}{tab_string}"  # cache but why
        if branch_node_closing_line_string:
            ch_branch_node_closing_line_string = \
                    f"{my_indent_string}{branch_node_closing_line_string}"

        for eid in some_cx_eids:
            ch_node = dct[eid]
            child_is_leaf = not ch_node.children
            if child_is_leaf:
                tail = leaf_node_line_by(ch_node)
            else:
                tail = branch_node_opening_line_by(ch_node)
            yield f"{my_indent_string}{tail}"
            if child_is_leaf:
                continue
            for line in lines_from_recursing_into_this_branch_node(
                    ch_node, ch_indent_string):
                yield line
            if branch_node_closing_line_string:
                yield ch_branch_node_closing_line_string

    tab_string = ' ' * indent
    return lines_from_recursing_into_this_branch_node(root_node, '')


def tree_dictionary_via_tree_nodes(scts, listener):
    recs = {}
    fwd_refs = {}
    for rec in scts:
        eid = rec.EID
        if eid in recs:
            xx(f"collision, redefined {eid!r}")
        fwd_refs.pop(eid, None)
        recs[eid] = rec
        for ch_eid in (rec.children or ()):
            fwd_refs[ch_eid] = None  # might be a redundant assignment
        recs[eid] = rec

    if fwd_refs:
        these = tuple(fwd_refs.keys())
        xx(f"children not defined: {these!r}")

    return recs


def xx(msg=None):
    raise RuntimeError(''.join(('wahoo', * ((': ', msg) if msg else ()))))

# #born

