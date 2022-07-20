def _childrener(o):
    return o.children


def lines_via_tree_dictionary(
        dct,
        branch_node_opening_line_by,
        leaf_node_line_by,
        branch_node_closing_line_string,
        childrener=_childrener,
        listener=None, root_node_EID=None, indent=2):

    # Emit a notice if there are no nodes at all
    if 0 == len(dct):
        listener('notice', 'expression', 'empty_tree', lambda: ('empty tree',))
        return

    if root_node_EID is None:
        root_node_EID = next(iter(dct.keys()))

    # Emit a notice if the root node has no children
    root_node = dct[root_node_EID]
    if not childrener(root_node):
        msg = 'root tree has no children'
        listener('notice', 'expression', 'empty_tree', lambda: (msg,))
        return

    def lines_from_recursing_into_this_branch_node(bnode, depth):
        some_cx_eids = childrener(bnode)
        assert some_cx_eids
        ch_depth = depth + 1
        my_indent_string = margin_via_depth(depth)
        ch_indent_string = margin_via_depth(ch_depth)
        if branch_node_closing_line_string:
            ch_branch_node_closing_line_string = \
                    f"{my_indent_string}{branch_node_closing_line_string}"

        for eid in some_cx_eids:
            ch_node = dct[eid]
            child_is_leaf = not childrener(ch_node)
            if child_is_leaf:
                tail = leaf_node_line_by(ch_node, ch_depth)
            else:
                tail = branch_node_opening_line_by(ch_node, ch_depth)
            yield f"{my_indent_string}{tail}"
            if child_is_leaf:
                continue
            for line in lines_from_recursing_into_this_branch_node(
                    ch_node, ch_depth):
                yield line
            if branch_node_closing_line_string:
                yield ch_branch_node_closing_line_string

    if 0 == indent:
        def margin_via_depth(depth):
            return ''
    else:
        def margin_via_depth(depth):
            s = MVD_cache.get(depth, None)
            if s is None:
                s = ' ' * (indent * depth)
                MVD_cache[depth] = s
            return s
        MVD_cache = {}

    return lines_from_recursing_into_this_branch_node(root_node, depth=0)


def tree_dictionary_via_tree_nodes(scts, childrener=_childrener, listener=None):
    # (this doesn't do anything interesting except validate the refs
    # and put it all into a dictionary.)

    recs = {}
    fwd_refs = {}
    for rec in scts:
        eid = rec.EID
        if eid in recs:
            xx(f"collision, redefined {eid!r}")
        fwd_refs.pop(eid, None)
        recs[eid] = rec
        for ch_eid in (childrener(rec) or ()):
            # #todo: this seems like a bug: if the original collection
            # isn't already in pre-order, you will be incorrectly calling
            # something a fwd ref when it is already defined and it will
            # incorreclty trigger the below (below) exception

            fwd_refs[ch_eid] = None  # might be a redundant assignment
        recs[eid] = rec

    if fwd_refs:
        these = tuple(fwd_refs.keys())
        xx(f"children not defined: {these!r}")

    return recs


def xx(msg=None):
    raise RuntimeError(''.join(('wahoo', * ((': ', msg) if msg else ()))))

# #born

