"""
We have an array of *all* document rows (with or without identifier) in
document order, and we have a list of associations also in document order.
Each association has a "type" and the idens of its 2 participants.

For one thing, we DON'T want to just render every document row as a node,
because we don't want to noisen up the graph with non-participating nodes

Rather, we want to find out what the "participating" nodes are (those that
are involved in associations, which themselves are in the "participating"
set of recognized association types) and render those.

For another thing, the order we render things in the output document is a
whole thing. We're generally gonna try to make the output document follow
the general structure of the input document (what we call "document order"
for reasons of: VCS OCD, file-to-file isomorphics, and narrative-ness
(maybe get semantically related nodes close to each other). But wait, throw
that idea out..

Experimentally the above is also why (FOR NOW) we're NOT gonna have separate
sections for nodes and associations (like everybody else in the world does)
but rather do this recursive descent tree-like thing.

For each (PARTICIPATING) node, output it and the associations it's the
"custodian" of. (if "B" comes after "A", "B" is the custodian of the
association even though we might render "A" as the left hand side. If a
depender is dependent on a dependee, we put the onus on the depender to
"own" (custode) the association, regardless of what surface direction we
decide to make the arrow point.)

Traverse each assocation in document order, grouping by custodian node. At
the end, end up with a list of custodian nodes each of whom is the sole
proprietor of its list of associations. In a recursive tree-like way,
traverse this index dumping it out to the output.

Actually, a lot of the above lays a good foundation but gets thrown out the
window when we tackle grouping (subgraphs).. but it holds within each group.
(Except the thing about VCS OCD is out the window now.)

We vaguely attempt to detect cycles with groups but we won't detect circular
dependencies with the `after` assocation. But it's okay, would render #here5.
"""


def _stylesheet_lol(tagging_offsets_via_stem):

    if 'app' in tagging_offsets_via_stem:
        yield 'shape', 'rect'

    if 'done' in tagging_offsets_via_stem:
        yield 'style', 'filled'


_tab_string = '    '
_group_label_w, _group_label_h = 20, 2  # (psst: try not to make tests
_node_label_w, _node_label_h = 15, 3  # ..depend on these heuristics 🙃)


def to_graph_lines_(
        ic, listener,
        targets=(), show_group_nodes=False, show_identifiers=False):

    show_after_label = False  # hardcoded as always off for now

    # Output the first line first before any errors for a more responsive UX
    yield 'digraph g {\n'
    yield f'{_tab_string}rankdir=BT;\n'

    # (maybe one day not hard-coded:)
    allow = {
        'after': ('association_type', 'after'),
        'part-of': ('association_type', 'part_of'),
        'priority': ('do_ignore_this_tagging', None),
    }

    def main():
        # tivl = tags index via lineno
        fla, tivl = _flat_list_of_assocs_and(ic, allow, listener)
        tka = _index_the_two_kinds_of_associations(fla, listener)
        if targets:
            tlistener = _build_throwing_listener(listener)
            tka = _prune(tka, targets, tlistener)
        roots = _find_all_roots(tka, fla, listener)

        lines = _render_lines(
            show_group_nodes, show_identifiers, show_after_label,
            roots, tka, tivl, fla)

        for line in lines:  # make it throw inside this scope
            yield line
    try:
        for line in main():
            yield line
    except _Stop:
        return

    yield '}\n'


def _render_lines(
        show_group_nodes, show_identifiers, show_after_label,
        roots, tka, row_tag_index_via_lineno, fla):

    def render_branch(k, ind, parent_gvid=None):
        prer = node_prerender(k)

        # gvid = graph viz node id

        yield f"{ind}subgraph cluster_{prer.gvid} {{\n"
        ch_ind = ''.join((ind, tab_string))
        label = double_quoted_label(prer, label_renderers.leading)
        yield f"{ch_ind}label={label}\n"

        if show_group_nodes:  # #here6
            for line in render_terminal(prer, ch_ind, parent_gvid):
                yield line

            rest = (prer.gvid,)
        else:
            rest = ()

        cx = sort_keys_in_document_order(children_of[k])
        for ch_k in cx:

            # If the node has children, render it is a branch (group)
            if ch_k in children_of:
                lines = render_branch(ch_k, ch_ind, prer.gvid)

            # Otherwise render it as terminal
            else:
                ch_prer = node_prerender(ch_k)
                lines = render_terminal(ch_prer, ch_ind, *rest)

            for line in lines:
                yield line
        yield f"{ind}}}\n"

    def render_terminal(prer, ind, parent_gvid=None):

        # Render the node itself (with all its attributes)
        attr_pairs = attr_pairs_via(prer)
        attr_asmts = ((n, '=', v) for n, v in attr_pairs)
        inside_inside_pcs = _pcs_join(', ', attr_asmts)
        inside_pcs = '[', *inside_inside_pcs, ']'
        inside = ''.join(inside_pcs)
        yield ''.join((ind, prer.gvid, inside, ';\n'))

        # Render the associations
        if parent_gvid is not None:
            line = ''.join((ind, prer.gvid, '->', parent_gvid, ';\n'))  # ..
            assoc_line_cache.append(line)

        if (na := node_associations.get(prer.key)) is None:
            return  # not all parents custode associations of their own

        render_line_for_after = build_render_line_for_after(prer.gvid, ind)

        for ch_k in na.afters:
            assoc_line_cache.append(render_line_for_after(ch_k))

    def attr_pairs_via(prer):
        if show_identifiers:
            v = double_quoted_label(prer, label_renderers.trailing)
        else:
            v = double_quoted_label(prer, label_renderers.no_EID)
        yield 'label', v

        # For now, all "stylings" come from tags
        rti = row_tag_index_via_lineno.get(prer.row.lineno)
        if rti is None:
            return

        for k, v in _stylesheet_lol(rti.tagging_offsets_via_stem):
            yield k, v

    class node_prerender:
        def __init__(self, k):
            self.row = row_via_key(k)
            pool.remove(k)
            self.gvid = graph_viz_node_ID_via_key(k)
            self.key = k

    # lr = label renderer

    def double_quoted_label(row, lr):
        return ''.join(pieces_for_escaped_surface_label_value(row, lr))

    def pieces_for_escaped_surface_label_value(prer, lr):

        words = words_via_row(prer.row)
        structured_lines = lr.structured_lines_via(words)
        lines = [sl.to_string() for sl in structured_lines]  # and w, cx

        has_lines, show_EID = len(lines), (lr.offset is not None)
        # Quad table
        if show_EID:
            if has_lines:
                mutate_lines_to_have_iden(lines, prer, lr)
            else:
                lines.append(prer.row.identifier.to_string())
        elif not has_lines:
            xx("no node label content and no EID to show, wat do")

        return pieces_via_lines(lines)

    def mutate_lines_to_have_iden(lines, prer, lr):
        line_before_add_eid = lines[lr.offset]
        new_line_slots = [None, None]
        offset_for_eid = lr.offset  # strange but true
        offset_for_content = (0, -1)[(-1, 0).index(offset_for_eid)]
        new_line_slots[offset_for_eid] = prer.row.identifier.to_string()
        new_line_slots[offset_for_content] = line_before_add_eid
        new_line = ' '.join(new_line_slots)

        lines[lr.offset] = new_line

    def pieces_via_lines(lines):

        itr = iter(lines)

        yield '"'
        yield escape(next(itr))
        for line in itr:
            yield r'\n'
            yield escape(line)
        yield '"'

    def escape(line):
        return re.sub(r'([\\"])', r'\\\1', line)

    class label_renderer:
        def __init__(self, where, w, max_lines):
            grid = [w for _ in range(0, max_lines)]
            if where is not None:
                grid[where] -= notch_w
            self.structured_lines_via = fu(grid, 'words')
            self.offset = where

    notch_w = len(' [#123.4]')  # see notching described at [#882.P]
    from text_lib.magnetics.via_words import fixed_shape_word_wrapperer as fu

    class label_renderers:  # #class-as-namespace
        leading = label_renderer(0, _group_label_w, _group_label_h)
        trailing = label_renderer(-1, _node_label_w, _node_label_h)
        no_EID = label_renderer(None, _node_label_w, _node_label_h)

    def words_via_row(row):
        for dp in row.doc_pairs:
            if (nt := dp.not_tag) is None:
                continue
            for md in re.finditer('[^ ]+', nt):
                yield md[0]

    re = _re()

    def build_render_line_for_after(custod_gvid, ind):
        def render_line_for_after(otr_k):
            otr_gvnid = graph_viz_node_ID_via_key(otr_k)
            pcs = ind, otr_gvnid, '->', custod_gvid, *assoc_attrs, ';\n'
            return ''.join(pcs)
        return render_line_for_after

    assoc_attrs = ('[label="then"]',) if show_after_label else ()

    def graph_viz_node_ID_via_key(k):
        maj_i, minor_i = k
        rest = () if minor_i is None else ('_', str(minor_i))
        return ''.join(('n', str(maj_i), *rest))

    pool = set(tka.participating_keys)

    children_of, node_associations = tka.children_of, tka.node_associations
    sort_keys_in_document_order = fla.sort_keys_in_document_order
    row_via_key, tab_string = fla.row_via_key, _tab_string

    assoc_line_cache = []

    for root in sort_keys_in_document_order(roots):
        for line in render_branch(root, tab_string):
            yield line

    # pool is empty if every node was part of a group

    for k in sort_keys_in_document_order(pool):
        prer = node_prerender(k)
        for line in render_terminal(prer, tab_string):
            yield line

    # Render all assocs after everything else because if not it messes up group
    for line in assoc_line_cache:
        yield line


def _find_all_roots(tka, fla, listener):
    # Given the parent-child relationships in the document, find the zero
    # or more root nodes and somehow (in the same step or a separate pass)
    # determine that none of these trees cycle (ensure they are trees).

    # Note that not all participating nodes are necessarily part of a tree,
    # because there's this orthogonal world of the 'after' relationships (which
    # is easier to render. We might not even care about cycles there #here5.)

    # Make a diminishing pool of all nodes that are parents. We want to find
    # who in this list are the roots by:
    #  - Chose any random item from this pool (but actually the last one)
    #  - Keep going upwards until you find one with no parent, at each hop,
    #    doing all of the following (not necessarily in this order): add it
    #    to a `seen` set, pop it out of the pool, and if you've already
    #    `seen` it, stop. If you got to the top and found a root, add it
    #    to a result set.
    #  - Repeat until the pool is empty.

    result_set_of_roots_found = set()
    children_of, node_associations = tka.children_of, tka.node_associations
    pool, seen = set(children_of.keys()), set()

    while len(pool):
        key = pool.pop()
        if key in seen:
            continue
        while True:
            seen.add(key)
            na = node_associations.get(key)
            parent_k = na and na.part_of
            if parent_k is None:
                result_set_of_roots_found.add(key)
                break
            if parent_k in seen:
                break
            pool.remove(parent_k)
            key = parent_k

    def walk(key):
        cx = children_of.get(key)
        if cx is None:
            return
        pool.remove(key)
        for ch in cx:
            walk(ch)

    pool = set(children_of.keys())
    for key in result_set_of_roots_found:
        walk(key)
    if len(pool):
        # you want the rows sorted by identifier. you have unsorted keys.
        # you can get from key to row to identifier

        ordered_keys = fla.sort_keys_in_ascending_order(pool)
        rows = tuple(fla.row_via_key(key) for key in ordered_keys)
        _whiners['cycle_apparently'](listener, rows)
        raise _Stop()

    return result_set_of_roots_found


def _prune(tka, targets, tlistener):
    # Prune a universe of nodes to a subset universe given target nodes.
    # 👉 The two kinds of associations ("group" and "after") are munged
    #    into a single, generic concept we call "subordinance":
    # 👉 Node A is subordinate to node B if A is in the B group OR if A
    #    comes after B. We then say node B "has" A as one of its subordinates.
    # 👉 Subordinance applies recursively: if node A has subordinate B, and B
    #    has C and D, then A has subordinates B, C and D.
    # 👉 It's not supposed to cycle but it might. We don't check we just "seen"
    # So, the list of targets expands to a larger set thru subordinance.
    # This larger set defines all the nodes in the new universe.

    def main():
        _ = build_befores()
        subs_of = build_big_indiscriminate_subordinates_index(_)
        ks = tuple(build_toplevel_allow_list(subs_of))
        ks = build_expanded_allow_list(ks, subs_of)
        wow = {k: v for k, v in pruned_node_associations(ks)}
        hey = {k: v for k, v in pruned_children_of(ks)}
        o = {}
        o['node_associations'] = wow
        o['children_of'] = hey
        o['participating_keys'] = ks
        return tka._make(o[k] for k in tka._fields)

    def pruned_node_associations(ks):
        for k, na in tka.node_associations.items():
            if k not in ks:
                continue
            yield k, prune_node_association(na, ks)

    def prune_node_association(na, ks):
        afters = tuple(kk for kk in na.afters if kk in ks)
        use_part_of = na.part_of
        if use_part_of and use_part_of not in ks:
            use_part_of = None
        return na.__class__(part_of=use_part_of, afters=afters)

    def pruned_children_of(ks):
        for k, arr in tka.children_of.items():
            if k not in ks:
                continue
            yield k, tuple(kk for kk in arr if kk in ks)

    def build_expanded_allow_list(ks, subs_of):
        def recurse(k):
            if k in seen:
                return
            seen.add(k)
            subs = subs_of[k]
            if 0 == len(subs):
                return
            for kk in subs:
                result.add(kk)
                recurse(kk)
        result, seen = set(), set()
        for k in ks:
            result.add(k)
            recurse(k)
        return result

    def build_toplevel_allow_list(subs_of):
        idener = _build_identifier_parser(tlistener)
        for s in targets:
            iden = idener(s)
            k = iden.key
            subs = subs_of.get(k)
            if subs is None:
                xx(f"not a participating identifier: {iden.to_string()}")
            if 0 == len(subs):
                xx(f"{iden.to_string()} has no subordinates")
            yield k

    def build_big_indiscriminate_subordinates_index(befores):
        def recurse(k):
            if k in seen:
                return
            seen.add(k)
            subs = set()
            for kk in tka.children_of.get(k, ()):
                subs.add(kk)
                recurse(kk)
            for kk in befores.get(k, ()):
                subs.add(kk)
                recurse(kk)
            result[k] = subs
        result, seen = {}, set()
        for k in tka.participating_keys:
            recurse(k)
        return result

    def build_befores():  # we have afters but not befores
        res = {}
        for k, na in tka.node_associations.items():
            for kk in na.afters:
                if (arr := res.get(kk)) is None:
                    res[kk] = (arr := [])
                arr.append(k)
        return res

    return main()


def _index_the_two_kinds_of_associations(_idx, _listener):
    children_of, node_associations, participating_keys = {}, {}, set()
    locs = {k: v for k, v in locals().items() if '_' != k[0]}  # big flex

    for assoc in _idx.associations:
        lhk = assoc.row.identifier.key
        rhk = assoc.RHS_identifier.key
        atyp = assoc.association_type

        participating_keys.add(lhk)
        participating_keys.add(rhk)

        if lhk not in node_associations:
            node_associations[lhk] = _NodeAssociations()
        na = node_associations[lhk]

        if 'after' == atyp:
            na.afters.append(rhk)
            continue

        assert 'part_of' == atyp
        if na.part_of is not None:
            _whiners['more_than_one_parent'](_listener, (assoc.row,))
            raise _Stop()
        if rhk not in children_of:
            children_of[rhk] = []
        children_of[rhk].append(lhk)
        na.part_of = rhk

    return _named_tuple('Prepared', locs.keys())(**locs)


def _flat_list_of_assocs_and(ic, allow, listener):
    def main():
        def cstacker():
            return ({'lineno': o.lineno, 'line': o.row_AST.to_line()},)

        tag_index_via_row = _build_row_tag_indexer(allow, cstacker)
        row_tag_index_via_lineno = {}

        for o in itr:
            if o.notice_message:
                has_notices.append(o)
                continue
            if not see_row_with_identifer(o):
                return
            rti = tag_index_via_row(o)  # rti = row tag index
            if not rti.has_taggings:
                no_tags.append(o)
                continue

            row_tag_index_via_lineno[o.lineno] = rti

            if not rti.has_deep_taggings:
                no_deep_tags.append(o)
                continue

            for oo in rti.classified_deep_taggings:
                if oo.ignore_this_tagging:
                    continue
                if oo.deep_tag_head_stem_not_recognized:
                    deep_tags_not_recognized.append(oo)
                    continue
                if oo.deep_tag_is_too_deep:
                    deep_tagging_too_deep.append(oo)
                    continue
                if oo.failed_to_parse_identifier:
                    failed_to_parse_identifier.append(oo)
                    continue
                if oo.RHS_identifier.key in classified_row_offset_via_key:
                    good_associations.append(oo)
                    continue
                forward_references.append(oo)
        for oo in forward_references:
            if oo.RHS_identifier.key in classified_row_offset_via_key:
                good_associations.append(oo)
                continue
            unresolved_forward_refs.append(oo)

        # If any errors, don't procede
        if len(notis := _filter_noticeables(noticeables_stack, 'error')):
            return _whine_about_these(listener, notis, ic)

        # If there is nothing to graph, let's stop with some feedback
        if not len(good_associations):
            msg = 'No participating issues found.'
            listener('info', 'expression', 'no_participating_issues', lambda: (msg,))  # noqa: E501

            # Find the max severity (if any) and whine about all those
            if len(notis := _group_of_max_severity(noticeables_stack)):
                return _whine_about_these(listener, notis, ic)

            # This last one could use more rigitity
            return _whine_about_nothing(listener, ic)

        # We're gonna graph something. But let's not let notices slip by
        if len(notis := _filter_noticeables(noticeables_stack, 'notice')):
            _whine_about_these(listener, notis, ic)

        fla = _FlatListOfAssociations(
            tuple(good_associations),
            classified_row_offset_via_key, tuple(classified_rows))

        return fla, row_tag_index_via_lineno

    def see_row_with_identifer(o):
        assert (iden := o.identifier)
        key = iden.key
        if key in classified_row_offset_via_key:
            xx("duplicate identifier")
        offset = len(classified_rows)
        classified_rows.append(o)
        classified_row_offset_via_key[key] = offset
        above = self.above_iden
        if above is None:
            self.above_iden = iden
            return True
        if iden < above:
            self.above_iden = iden
            return True
        _, __ = (idn.to_string() for idn in (above, iden))
        xx(f"Collection out of order. Had {_} then {__}")  # provision #here4

    then = (noticeables_stack := []).append  # #here1
    then(('has_notices', has_notices := []))
    then(('no_tags', no_tags := []))
    then(('no_deep_tags', no_deep_tags := []))
    then(('deep_tags_not_recognized', deep_tags_not_recognized := []))
    then(('deep_tagging_too_deep', deep_tagging_too_deep := []))
    then(('failed_to_parse_identifier', failed_to_parse_identifier := []))
    then(('unresolved_forward_refs', unresolved_forward_refs := []))

    good_associations, forward_references = [], []
    classified_row_offset_via_key, classified_rows = {}, []

    class self:  # #class-as-namesapce
        above_iden = None

    with _open_classified_row_ASTs_via_issues_collection(ic) as itr:
        if itr is None:
            raise _Stop()
        fla = main()
    if fla is None:
        raise _Stop()
    return fla


class _FlatListOfAssociations:

    def __init__(self, assocs, offset_via_key, rows):

        def sort_keys_in_ascending_order(keys):
            return tuple(reversed(sort_keys_in_document_order(keys)))

        def sort_keys_in_document_order(keys):
            return sorted(keys, key=offset_via_key.__getitem__)  # #here4

        def row_via_key(key):
            return rows[offset_via_key[key]]

        # == BEGIN experiment
        locs = locals()
        from inspect import signature
        sig = signature(_FlatListOfAssociations.__init__)
        for attr in (set(locs) - set(sig.parameters)):
            setattr(self, attr, locs[attr])
        # == END

        self.associations = assocs
        self.classified_row_offset_via_key = offset_via_key
        self.classified_rows = rows


def _build_row_tag_indexer(allow, cstacker):

    class no_taggings:  # #class-as-namespace
        has_taggings = False

    fields = ('has_deep_taggings', 'classified_deep_taggings',
              'tagging_offsets_via_stem')
    row_tag_index = _named_tuple('RowTagIndex', fields)
    row_tag_index.has_taggings = True

    def tag_index_via_row(row):
        leng = len(row.all_taggings)
        if 0 == leng:
            return no_taggings

        classified_deep_taggings = []
        tagging_offsets_via_stem = {}

        for i in range(0, leng):
            tagging = row.all_taggings[i]

            # For this tag head stem, add this offset to the list of offsets
            stem = tagging.head_stem
            if (arr := tagging_offsets_via_stem.get(stem)) is None:
                tagging_offsets_via_stem[stem] = (arr := [])  # #[#023.2]
            arr.append(i)
            if not tagging.is_deep:
                continue

            # Index this deep tagging in an excessively custom way
            row_itrs = (iter(row) for row in classify_deep_tagging(tagging))
            dct = {k: next(row_itr) for row_itr in row_itrs for k in row_itr}
            cdt = _ClassifiedTagging(tagging, row, **dct)
            classified_deep_taggings.append(cdt)

        has = len(tup := tuple(classified_deep_taggings))
        return row_tag_index(has, tup, tagging_offsets_via_stem)

    def classify_deep_tagging(dtag):
        # Maybe the head stem of the deep tag isn't of a recognized type

        assoc_two = allow.get(dtag.head_stem)
        if assoc_two is None:
            yield 'deep_tag_head_stem_not_recognized', True
            return  # (Case3907)

        typ, assoc_typ = assoc_two
        if 'do_ignore_this_tagging' == typ:
            yield 'ignore_this_tagging', True
            return

        assert 'association_type' == typ

        # Maybe the deep tag is too deep
        if 1 < len(cx := dtag.subcomponents):
            yield 'deep_tag_is_too_deep', True
            return  # (Case3906)

        # Maybe right-hand side of the name-value pair is wrong grammatical typ
        if 'bracketed_lyfe' != (bl := cx[0].body_slot)._type:
            head = 'Needed identifier (e.g. "[#123]"). Had: '
            msg = ''.join((head, repr(bl._to_string())))
            emi = 'error', 'expression', 'parse_error', lambda: (msg,)
            yield 'failed_to_parse_identifier', True, 'emission', emi
            return  # (Case3906)

        # Maybe the identifier doesn't parse. Yes we parse it twice (diff'ly)
        iden, emi = my_parse_iden(bl._to_string())
        if iden is None:
            # We've got to activate these payloads right away because the
            # cstacker references the current line & line number at the moment
            # and some clients (our tests) stack up multiple such errors
            *channel, payloader = emi
            sct = payloader()
            emi = *channel, lambda: sct
            yield 'failed_to_parse_identifier', True, 'emission', emi
            return  # (Case3915)

        yield 'association_type', assoc_typ, 'RHS_identifier', iden

    # == BEGIN YIKES set up
    def my_parse_iden(eid):
        assert 0 == len(yuck)
        iden = yikes_parse_iden(eid)
        if iden is not None:
            return iden, None
        emi, = yuck
        yuck.clear()
        return None, emi

    def danger(*emi):
        yuck.append(emi)
    yikes_parse_iden = _build_identifier_parser(danger, cstacker)
    yuck = []
    # == END YIKES

    return tag_index_via_row


def _open_classified_row_ASTs_via_issues_collection(ic):
    from contextlib import contextmanager as cm

    @cm
    def cm():
        with ic.open_schema_and_issue_traversal() as (schema, ents):
            # Maybe the readme file doesn't begin its parse OK
            if ents is None:
                yield None
                return
            ks = schema.field_name_keys[1:]
            del schema
            yield _classified_row_ASTs_via_issues_collection(ks, ents)
    return cm()


def _classified_row_ASTs_via_issues_collection(ks, ents):
    def main():
        for ent in ents:
            attr_rows = keys_and_values_via_ent(ent)
            row_itrs = (iter(row) for row in attr_rows)
            kvs = ((k, next(row_itr)) for row_itr in row_itrs for k in row_itr)
            dct = {k: v for k, v in kvs}
            yield _ClassifiedRow(**dct)

    def keys_and_values_via_ent(ent):
        yield 'row_AST', ent, 'lineno', ent.lineno
        if ent.identifier is None:
            yield 'notice_message', "Row{s} {doesnt_dont} have an identifier {on}"  # noqa: E501
            return
        dct = ent.core_attributes
        pcs = tuple(dct[k] for k in ks if k in dct)
        if not len(pcs):
            yield 'notice_message', "Strange - {num}totally blank issue{s}{idens}"  # noqa: E501  #here3
            return
        one_string = ' '.join(pcs)
        top_thing = top_thing_via_string(one_string)
        yield 'doc_pairs', top_thing.doc_pairs

    from tag_lyfe.magnetics.tagging_subtree_via_string import \
        doc_pairs_via_string as top_thing_via_string

    return main()


# == Whining

def _group_of_max_severity(noticeables_stack):
    # Find the max severity of produced noticeables and result in all such
    maxx, current_leaders = -1, []
    for wkey, notis in noticeables_stack:  # #here1
        if not len(notis):
            continue
        sev = _severity_via_whine_key[wkey]
        sev_i = _integer_via_severity[sev]
        if sev_i < maxx:
            continue
        if maxx < sev_i:
            maxx = sev_i
            current_leaders.clear()
        current_leaders.append((wkey, notis))
    return tuple(reversed(current_leaders))  # it was a stack


def _filter_noticeables(noticeables_stack, threshold_sev):
    # Return list of zero or more lists of noticeables at or above the severity
    result = []
    minn = _integer_via_severity[threshold_sev]
    for wkey, notis in noticeables_stack:  # #here1
        if not len(notis):
            continue
        sev = _severity_via_whine_key[wkey]
        if _integer_via_severity[sev] < minn:
            continue
        result.append((wkey, notis))
    return tuple(reversed(result))  # it was a stack


_order = 'trace', 'debug', 'info', 'notice', 'warn', 'error', 'fatal'
_integer_via_severity = {_order[i]: i for i in range(0, len(_order))}


def _whine_about_these(listener, notis, ic):
    assert len(notis)
    for wkey, classis in notis:  # #here1
        assert len(classis)
        _whiners[wkey](listener, classis)


def _on(wtyp, sev):
    def decorator(orig_f):
        def use_f(listener, classis):
            rows = (iter(row) for row in orig_f())
            dct = {k: next(row) for row in rows for k in row}
            cat, fmt = dct.pop('cat'), dct.pop('fmt')
            msgs = tuple(_crizzy_tizzy_msgs(classis, fmt, **dct))  # hi.
            listener(sev, 'expression', cat, lambda: msgs)
        _severity_via_whine_key[wtyp] = sev
        _whiners[wtyp] = use_f
        return None
    return decorator


def _whiner_for(wtyp, sev):
    def decorator(orig_f):
        _severity_via_whine_key[wtyp] = sev
        _whiners[wtyp] = orig_f
        return None
    return decorator


_severity_via_whine_key = {}
_whiners = {}


@_on('cycle_apparently', 'error')
def _():
    yield 'cat', 'apparent_cycle'
    yield 'fmt', '{these_issues} {is_are} apparently part of a cycle{idens}'


@_on('more_than_one_parent', 'error')
def _():
    yield 'cat', 'more_than_one_parent'
    yield 'fmt', "{these_issues} belonged to more than one node (and can't){idens}"  # noqa: E501


@_on('unresolved_forward_refs', 'error')
def _():
    yield 'cat', 'unresolved_issue_references'
    yield 'fmt', 'Node referenced but never defined {on}: {k!r}'
    yield 'keyer', lambda classi: classi.RHS_identifier.to_string()


@_on('deep_tagging_too_deep', 'error')
def _():
    yield 'cat', 'tags_too_deep', 'fmt', 'Tag too deep {on}: {k!r}'
    yield 'keyer', lambda classi: classi.deep_tagging._to_string()


@_on('deep_tags_not_recognized', 'notice')
def _():
    yield 'cat', 'unrecognized_deep_tags'
    yield 'fmt', 'Unrecognized deep tag {on}: {k!r}'
    yield 'keyer', lambda classi: ''.join(('#', classi.deep_tagging.head_stem))


@_on('no_deep_tags', 'debug')
def _():
    yield 'cat', 'no_participating_issues'
    yield 'fmt', '{these_issues} had tags but no deep tags{idens}'


@_on('no_tags', 'debug')
def _():
    yield 'cat', 'no_participating_issues'
    yield 'fmt', '{these_issues} had no tags at all{idens}'


@_whiner_for('has_notices', 'notice')
def _(listener, classis):
    classis_via_format = {}
    for classi in classis:
        fmt = classi.notice_message
        if fmt not in classis_via_format:
            classis_via_format[fmt] = []
        classis_via_format[fmt].append(classi)

    def lines():
        for fmt, classis in classis_via_format.items():
            itr = _crizzy_tizzy_msgs(classis, fmt)
            for msg in itr:
                yield msg
    msgs = tuple(lines())  # hi.
    listener('notice', 'expression', 'notice', lambda: msgs)


@_whiner_for('failed_to_parse_identifier', 'error')
def _(listener, classis):
    for classi in classis:
        listener(*classi.emission)


def _whine_about_nothing(listener, ic):
    msg = "File apparently had no issues at all"
    listener('info', 'expression', 'no_issues_at_all', lambda: (msg,))


# == Formats (begging for generalization)

def _crizzy_tizzy_msgs(classis, fmt, keyer=None):
    mds = _re().finditer(r'(?:[^{]+)?(?:\{([a-z_]+)(?:[!]r)?\})?', fmt)
    sig = set(md[1] for md in mds if md[1] is not None)
    func = _func_via_sig(sig)
    return func(classis, sig, fmt, keyer)


def _func_via_sig(sig):
    if 'k' in sig:
        return _format__on__k
    return _generate_lines_procedurally


def _format__on__k(classis, var_names, fmt, keyer):
    # The 'k' variable complicates it: Features (strings) are many-to-many
    # with line( number)s. Group by feature then for each feature splay the
    # line number(s). E.g., imagine the same unresolved ref on many lines.

    assert {'on', 'k'} == var_names
    linenos_via_feature = {}
    for classi in classis:
        k = keyer(classi)
        if k not in linenos_via_feature:
            linenos_via_feature[k] = []
        linenos_via_feature[k].append(classi.lineno)
    for k, linenos in linenos_via_feature.items():  # #here2
        on = _plur(linenos=linenos).on()
        yield fmt.format(on=on, k=k)


def _generate_lines_procedurally(classis, var_names, fmt, keyer):
    if var_names.issuperset({'these_issues', 'idens'}):
        pass  # (Case3903)
    elif {'s', 'doesnt_dont', 'on'} == var_names:
        pass  # (Case3900)
    else:
        assert {'num', 's', 'idens'} == var_names  # (Case3900)
    o = _plur(classis, keyer, 'issue')

    strange_names = {'idens': 'splay_items', 'these_issues': 'these_items'}
    bus_k_lib_k = ((k, strange_names.get(k, k)) for k in var_names)
    dct = {bus_k: getattr(o, lib_k)() for bus_k, lib_k in bus_k_lib_k}
    yield fmt.format(**dct)


def _plur(classis=None, keyer=None, noun_stem=None, linenos=None):  # #[#612.7]
    class plur:  # #class-as-namespace
        def these_items():
            if max_items < le:
                return ''.join((str(le), ' ', noun_stem, _s(le)))
            if 1 == le:
                return ' '.join(('This', noun_stem))
            return ''.join(('These ', noun_stem, _s(le)))

        def is_are():
            return 'is' if 1 == le else 'are'

        def num():  # #here3
            if max_items < le:
                return ''.join((str(le), ' '))
            return ''

        def splay_items():
            if max_items < le:
                return '.'
            use_keyer = keyer or default_keyer
            monikers = tuple(use_keyer(classi) for classi in classis)  # hi.
            monikers = reversed(monikers)  # because these files grow upwards
            return ''.join((': ', ', '.join(monikers), '.'))

        def doesnt_dont():
            return "doesn't" if 1 == le else "don't"

        def on():
            if max_linenos < le:
                return ' '.join(('on', str(le), 'lines'))
            if (use_linenos := linenos) is None:
                use_linenos = (classi.lineno for classi in classis)
            splay = ', '.join(str(i) for i in use_linenos)
            return ''.join(('on line', _s(le), ' ', splay))

        def s():
            return _s(le)

    def default_keyer(classi):
        return classi.identifier.to_string()

    le = len(linenos if classis is None else classis)
    max_items, max_linenos = 5, 3
    return plur


def _s(leng):
    return '' if 1 == leng else 's'


# == Models

class _NodeAssociations:
    def __init__(self, part_of=None, afters=None):
        if afters is None:
            afters = []  # (necessary LIKE THIS, not as default argument)
        self.part_of = part_of
        self.afters = afters


class _ClassifiedTagging:  # #todo would be better as dataclass

    def __init__(
            self, dtag, row,
            ignore_this_tagging=None,
            association_type=None, RHS_identifier=None,
            deep_tag_head_stem_not_recognized=None, deep_tag_is_too_deep=None,
            failed_to_parse_identifier=None, emission=None):
        self.deep_tagging, self.row = dtag, row
        # fast and loose

        self.ignore_this_tagging = ignore_this_tagging
        if self.ignore_this_tagging:
            return

        self.deep_tag_head_stem_not_recognized = \
            deep_tag_head_stem_not_recognized

        if deep_tag_head_stem_not_recognized:
            return

        self.deep_tag_is_too_deep = deep_tag_is_too_deep
        if deep_tag_is_too_deep:
            return

        self.emission = emission

        self.failed_to_parse_identifier = failed_to_parse_identifier
        if failed_to_parse_identifier:
            return

        self.association_type = association_type
        self.RHS_identifier = RHS_identifier

    @property
    def lineno(self):
        return self.row.lineno


class _ClassifiedRow:
    def __init__(self, row_AST, lineno, doc_pairs=None, notice_message=None):
        all_taggings, deep_taggings = (), ()
        if doc_pairs is not None:
            all_taggings = tuple(dp.tag for dp in doc_pairs if dp.tag)
            deep_taggings = tuple(t for t in all_taggings if t.is_deep)
        self.deep_taggings, self.all_taggings = deep_taggings, all_taggings
        self.doc_pairs, self.notice_message = doc_pairs, notice_message
        self.row_AST, self.lineno = row_AST, lineno

    @property
    def identifier(self):
        return self.row_AST.identifier


# ==

def _pcs_join(sep, chunks):
    """
    >>> tuple(_pcs_join('and', (('AA', 'BB'), ('CC', 'DD'))))
    ('AA', 'BB', 'and', 'CC', 'DD')
    """

    itr = iter(chunks)
    chunk = next(itr)  # ..
    for pc in chunk:
        yield pc
    for chunk in itr:
        yield sep
        for pc in chunk:
            yield pc


# ==

def _build_throwing_listener(listener):
    def use_listener(sev, *rest):
        return listener(sev, *rest)
        if 'error' == sev:
            raise _Stop()
    return use_listener


class _Stop(RuntimeError):
    pass


# == Delegations

def _build_identifier_parser(listener, cstacker=None):
    from . import build_identifier_parser_ as func
    return func(listener, cstacker)


def _named_tuple(*a):
    from collections import namedtuple as named_tuple
    return named_tuple(*a)


def _re():
    import re
    return re


def xx(msg=None):
    raise RuntimeError('not covered' + ('' if msg is None else f": {msg}"))


def _test():
    from doctest import testmod as func
    func()

# ==


if __name__ == "__main__":
    _test()

# #born
