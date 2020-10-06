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


_tab_string = '    '
_group_label_w, _group_label_h = 20, 2  # (psst: try not to make tests
_node_label_w, _node_label_h = 15, 3  # ..depend on these heuristics 🙃)


def to_graph_lines_(ic, listener):

    # Output the first line first before any errors for a more responsive UX
    yield 'digraph g {\n'
    yield f'{_tab_string}rankdir=BT;\n'

    # (maybe one day not hard-coded:)
    allow = {'part-of': 'part_of', 'after': 'after'}

    def main():
        fla = _build_a_flat_list_of_the_associations(ic, allow, listener)
        tka = _index_the_two_kinds_of_associations(fla, listener)
        roots = _find_all_roots(tka, fla, listener)
        for line in _render_lines(roots, tka, fla):
            yield line
    try:
        for line in main():
            yield line
    except _Stop:
        return

    yield '}\n'


def _render_lines(roots, tka, fla):

    def render_branch(k, ind, parent_gvid=None):
        prer = node_prerender(k)
        yield f"{ind}subgraph cluster_{prer.gvid} {{\n"
        ch_ind = ''.join((ind, tab_string))
        label = prer.to_quoted_escaped_truncated_label_with_leading_EID()
        yield f"{ch_ind}label={label}\n"

        for line in render_terminal(prer, ch_ind, parent_gvid):
            yield line

        cx = sort_keys_in_document_order(children_of[k])
        for ch_k in cx:
            if ch_k in children_of:
                lines = render_branch(ch_k, ch_ind, prer.gvid)
            else:
                ch_prer = node_prerender(ch_k)
                lines = render_terminal(ch_prer, ch_ind, prer.gvid)
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
            yield ''.join((ind, prer.gvid, '->', parent_gvid, ';\n'))  # ..

        if (na := node_associations.get(prer.key)) is None:
            return  # not all parents custode associations of their own

        render_line_for_after = build_render_line_for_after(prer.gvid, ind)

        for ch_k in na.afters:
            yield render_line_for_after(ch_k)

    def attr_pairs_via(prer):
        v = prer.to_quoted_escaped_truncated_label_with_trailing_EID()
        yield 'label', v
        # (eventually other tags like style=filled or w/e)

    class node_prerender:
        def __init__(self, k):
            self.row = row_via_key(k)
            pool.remove(k)
            self.gvid = graph_viz_node_ID_via_key(k)
            self.key = k

        def to_quoted_escaped_truncated_label_with_leading_EID(self):
            return double_quoted_label(self, label_renderers.leading)

        def to_quoted_escaped_truncated_label_with_trailing_EID(self):
            return double_quoted_label(self, label_renderers.trailing)

    def double_quoted_label(row, lr):
        return ''.join(pieces_for_escaped_surface_label_value(row, lr))

    def pieces_for_escaped_surface_label_value(prer, lr):

        words = words_via_row(prer.row)
        structured_lines = lr.structured_lines_via(words)
        lines = [sl.to_string() for sl in structured_lines]  # and w, cx

        line_before_add_eid = lines[lr.offset]
        new_line_slots = [None, None]
        offset_for_eid = lr.offset  # strange but true
        offset_for_content = (0, -1)[(-1, 0).index(offset_for_eid)]
        new_line_slots[offset_for_eid] = prer.row.identifier.to_string()
        new_line_slots[offset_for_content] = line_before_add_eid
        new_line = ' '.join(new_line_slots)

        lines[lr.offset] = new_line
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
            grid[where] -= notch_w
            self.structured_lines_via = fu(grid, 'words')
            self.offset = where

    notch_w = len(' [#123.4]')  # see notching described at [#882.P]
    from script_lib.magnetics.via_words import fixed_shape_word_wrapperer as fu

    class label_renderers:  # #class-as-namespace
        leading = label_renderer(0, _group_label_w, _group_label_h)
        trailing = label_renderer(-1, _node_label_w, _node_label_h)

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
            pcs = ind, otr_gvnid, '->', custod_gvid, '[label="then"];\n'
            return ''.join(pcs)
        return render_line_for_after

    def graph_viz_node_ID_via_key(k):
        maj_i, minor_i = k
        rest = () if minor_i is None else ('_', str(minor_i))
        return ''.join(('n', str(maj_i), *rest))

    pool = set(tka.participating_keys)

    children_of, node_associations = tka.children_of, tka.node_associations
    sort_keys_in_document_order = fla.sort_keys_in_document_order
    row_via_key, tab_string = fla.row_via_key, _tab_string

    for root in sort_keys_in_document_order(roots):
        for line in render_branch(root, tab_string):
            yield line

    if not len(pool):  # if every node was participating in group-age, done
        return

    for k in sort_keys_in_document_order(pool):
        prer = node_prerender(k)
        for line in render_terminal(prer, tab_string):
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


def _build_a_flat_list_of_the_associations(ic, allow, listener):
    def main():
        def cstacker():
            return ({'lineno': o.lineno, 'line': o.row_AST.to_line()},)

        classified_deep_taggings_via = _build_tag_classifier(allow, cstacker)

        for o in itr:
            if o.notice_message:
                has_notices.append(o)
                continue
            if not see_row_with_identifer(o):
                return
            if not len(o.all_taggings):
                no_tags.append(o)
                continue
            if not len(o.deep_taggings):
                no_deep_tags.append(o)
                continue
            for oo in classified_deep_taggings_via(o):
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

        return _FlatListOfAssociations(
            tuple(good_associations),
            classified_row_offset_via_key, tuple(classified_rows))

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

    itr = _classified_row_ASTs_via_issues_collection(ic)
    if itr is None:
        raise _Stop()

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


def _build_tag_classifier(allow, cstacker):

    def classified_deep_taggings_via(row):
        for dtag in row.deep_taggings:
            row_itrs = (iter(row) for row in classify_deep_tagging(dtag))
            dct = {k: next(row_itr) for row_itr in row_itrs for k in row_itr}
            yield _ClassifiedTagging(dtag, row, **dct)

    def classify_deep_tagging(dtag):
        # Maybe the head stem of the deep tag isn't of a recognized type
        if (assoc_typ := allow.get(dtag.head_stem)) is None:
            yield 'deep_tag_head_stem_not_recognized', True
            return  # (Case3907)

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
        if (iden := parse_iden(bl._to_string())) is None:
            emi, = DANGEROUS_emission_cache  # yuck
            DANGEROUS_emission_cache.clear()

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
    def DANGEROUS_listener(*emi):
        DANGEROUS_emission_cache.append(emi)

    from . import build_identifier_parser_ as func
    parse_iden = func(DANGEROUS_listener, cstacker)
    DANGEROUS_emission_cache = []
    # == END YIKES

    return classified_deep_taggings_via


def _classified_row_ASTs_via_issues_collection(ic):
    def main():
        for sx in sxs:
            attr_rows = keys_and_values_via_row_sexp(* sx[1:])
            row_itrs = (iter(row) for row in attr_rows)
            kvs = ((k, next(row_itr)) for row_itr in row_itrs for k in row_itr)
            dct = {k: v for k, v in kvs}
            yield _ClassifiedRow(**dct)

    def keys_and_values_via_row_sexp(ent, lineno):
        yield 'row_AST', ent, 'lineno', lineno
        if ent.identifier is None:
            yield 'notice_message', "Row{s} {doesnt_dont} have an identifier {on}"  # noqa: E501
            return
        dct = ent.core_attributes_dictionary_as_storage_adapter_entity
        pcs = tuple(dct[k] for k in ks if k in dct)
        if not len(pcs):
            yield 'notice_message', "Strange - {num}totally blank issue{s}{idens}"  # noqa: E501  #here3
            return
        one_string = ' '.join(pcs)
        top_thing = top_thing_via_string(one_string)
        yield 'doc_pairs', top_thing.doc_pairs

    # See if the readme file begins to parse OK
    sxs = ic.to_schema_then_entity_sexps()
    if sxs is None:
        return
    schema = next(sxs)
    ks = schema.field_name_keys[1:]
    del schema

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


def _plur(classis=None, keyer=None, noun_stem=None, linenos=None):
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
    def __init__(self):
        self.part_of = None
        self.afters = []


class _ClassifiedTagging:
    def __init__(
            self, dtag, row,
            association_type=None, RHS_identifier=None,
            deep_tag_head_stem_not_recognized=None, deep_tag_is_too_deep=None,
            failed_to_parse_identifier=None, emission=None):
        self.deep_tagging, self.row = dtag, row
        # fast and loose

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

class _Stop(RuntimeError):
    pass


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


if __name__ == "__main__":
    _test()

# #born
