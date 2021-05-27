def sync_agent_builder_(opener, all_sxs_er_er):

    def do_open_sync_session():
        from contextlib import contextmanager as cm

        @cm
        def cm():
            if (opened := opener()) is None:
                yield None
                return
            with opened as fh:
                all_sxs_er = all_sxs_er_er(fh)
                yield sync_agent_(all_sxs_er, fh.name)
        return cm()

    class sync_agent_builder:  # #class-as-namespace
        open_sync_session = do_open_sync_session
        SYNC_AGENT_CAN_PRODUCE_DIFF_LINES = True
    return sync_agent_builder


def sync_agent_(all_sexpser, coll_path):
    all_sexpser = _experiment_2(all_sexpser)

    def _diff_lines_via(flat_map, listener):
        # Read original sexps (then lines) in to memory
        orig_sx_itr = all_sexpser(listener)
        orig_sxs, count, sanity = [], 0, 274  # ~ num lines in longest README
        for sx in orig_sx_itr:
            if count == sanity:
                xx("is there memory saved by doing diff on the filesystem?")
            count += 1
            orig_sxs.append(sx)
        orig_sxs = tuple(orig_sxs)
        orig_lines = tuple(_lines_via_sexps(iter(orig_sxs)))

        # Read new sexps (then lines) in to memory
        new_sxs = _new_sexps(iter(orig_sxs), flat_map, listener)
        new_lines = tuple(_lines_via_sexps(new_sxs))

        # Make the Diff!
        if orig_lines == new_lines:
            xx('no change, no diff to make')
        from os.path import isabs
        if isabs(coll_path):
            from script_lib import build_path_relativizer as build
            path_tail = build()(coll_path)
        else:
            path_tail = coll_path  # relative only in tests mebbe (Case2644)
        pathA, pathB = f'a/{path_tail}', f'b/{path_tail}'
        from difflib import unified_diff
        return unified_diff(orig_lines, new_lines, pathA, pathB)

    def _new_lines_via(flat_map, listener):
        try:
            for line in _lines_via_sexps(_new_sexps_via(flat_map, listener)):
                yield line
        except _Stop:
            pass

    def _new_sexps_via(flat_map, listener):
        orig_sxs = all_sexpser(listener)
        return _new_sexps(orig_sxs, flat_map, listener)

    class sync_agent:  # #class-as-namespace
        DIFF_LINES_VIA = _experiment_1(_diff_lines_via)  # (Case2641) (2/2)
        NEW_LINES_VIA = _new_lines_via
        NEW_SEXPS_VIA = _experiment_3(_new_sexps_via)

    return sync_agent


def _lines_via_sexps(new_sexps):

    assert hasattr(new_sexps, '__next__')  # [#022]

    # #open [#877.E]

    for typ, *rest in new_sexps:
        if 'non_table_line' != typ:
            break
        line, = rest
        yield line


    assert 'complete_schema' == typ
    sch, = rest
    row1, row2 = sch.rows_
    yield row1.to_line()
    yield row2.to_line()

    for typ, *rest in new_sexps:
        if 'business_row_AST' != typ:
            assert 'non_table_line' == typ
            line, = rest
            yield line
            break
        ast, _ = rest
        yield ast.to_line()

    for typ, *rest in new_sexps:
        assert 'non_table_line' == typ
        line, = rest
        yield line


def _new_sexps(itr, flat_map, listener):
    # Output zero or more head lines (lines before the table)
    # #todo this was written before action stacks and could be cleaned up

    assert hasattr(itr, '__next__')  # [#022]

    # #open [#877.E]

    for sx in itr:
        if 'non_table_line' != sx[0]:
            break
        yield sx

    assert 'complete_schema' == sx[0]
    yield sx

    sch, = sx[1:]
    mixed_err = flat_map.receive_schema(sch)
    if mixed_err is not None:
        listener(xx('hole is upstream too'))
        return

    use_eg_row, actual_eg_sx = None, None
    sexps_after_table_on_deck = []

    # PEEK ONE YUCK
    for sx in itr:
        if 'business_row_AST' == sx[0]:
            use_eg_row = sx[1]
            actual_eg_sx = sx
        else:
            assert 'non_table_line' == sx[0]
            sexps_after_table_on_deck.append(sx)
        break

    if use_eg_row is None:
        use_eg_row = sch.rows_[0]  # undocumented

    # Always output the example row manually, keeping it always topmost
    if actual_eg_sx:
        yield actual_eg_sx

    # == SPOT B

    process_directives_during, process_directives_at_end = \
        _build_directives_processer(use_eg_row, sch, listener)

    # Traverse over zero or more table lines, doing sync stuff
    for sx in itr:
        if 'business_row_AST' != sx[0]:
            assert 'non_table_line' == sx[0]
            sexps_after_table_on_deck.append(sx)
            break
        ent = sx[1]

        # == SPOT C

        directives = flat_map.receive_item(ent)
        for sx in process_directives_during(directives, sx):
            yield sx

    # After finishing your own table, ask flat map for any remaining items
    for sx in process_directives_at_end(flat_map.receive_end()):
        yield sx

    # Any of these that we cached
    for sx in sexps_after_table_on_deck:
        yield sx

    # Flush any remaining file
    for sx in itr:
        yield sx


def _build_directives_processer(eg_row, cs, listener):
    def process_directives_during(directives, sx):
        for directive in directives:
            if 'pass_through' == (typ := directive[0]):
                yield sx
                continue
            if 'insert_item' == typ:
                yield sexp_for_insert_item(directive)
                continue
            if typ in ('merge_with_item', 'update_item'):
                exi_row, counts = sx[1], None
                if 'update_item' == typ:
                    assert isinstance(edit := directive[1], tuple)
                    exi_dct = exi_row.core_attributes
                    dct, counts = _dct_via_edit(edit, exi_dct, cs, listener)
                else:
                    assert 'merge_with_item' == typ
                    assert isinstance(dct := directive[1], dict)
                row = updated_row_via(dct.items(), exi_row, listener)
                if 2 < len(directive):
                    directive[2](row)
                if counts:  # #here5
                    eid = sx[1].nonblank_identifier_primitive
                    _emit_edited(listener, counts, eid, 'updated')
                yield 'business_row_AST', row, None
                continue
            if 'give_me_the_AST_please' == typ:
                directive[1](sx[1])
                continue
            assert 'error' == typ
            listener(*directive)
            raise _Stop()  # (Case3431DP)

    def process_directives_at_end(directives):
        for directive in directives:
            typ = directive[0]
            if 'insert_item' == typ:
                yield sexp_for_insert_item(directive)
                continue
            assert 'error' == typ
            listener(*directive)
            raise _Stop()  # (Case2641) (1/2)

    def sexp_for_insert_item(directive):
        assert isinstance(dct := directive[1], dict)
        row = new_row_via(dct.items(), listener)
        if 2 < len(directive):
            directive[2](row)
        return 'business_row_AST', row, None

    from ._prototype_row_via_example_row_and_complete_schema import \
        BUILD_CREATE_AND_UPDATE_FUNCTIONS_ as build_funcs

    new_row_via, updated_row_via = build_funcs(eg_row, cs)
    new_row_via = _experiment_2(new_row_via)
    updated_row_via = _experiment_2(updated_row_via)

    return process_directives_during, process_directives_at_end


def _dct_via_edit(edit, exi_dct, cs, listener):

    # Put the directives in an attr-keyed dim pool while checking for clobber
    pool = {}
    for typ, attr, *val in edit:
        if attr in pool:
            xx("multiple directives for attribute")
        pool[attr] = (typ, *val)

    # Go thru the formal fields in formal order. Skip if no pool
    # component. For each remaining, confirm and do the following
    #
    #    update  must be present      put in product dict
    #    create  must be not present  put in product dict
    #    delete  must be present      ..try putting None in product dict??
    these_via_type = {
        'update_attribute': (True, lambda k, x: update_arg_dct(k, x), 0),
        'create_attribute': (False, lambda k, x: update_arg_dct(k, x), 1),
        'delete_attribute': (True, lambda k: update_arg_dct(k, None), 2)}

    def update_arg_dct(k, x):
        arg_dct[k] = x

    arg_dct, counts = {}, ([], [], [])

    for k in cs.field_name_keys:  # unnecessarily check leftmost field
        if (attr_direc := pool.get(k)) is None:
            continue
        typ, *args = attr_direc
        yn, call_me, offset = these_via_type[typ]
        counts[offset].append(None)  # #open [#874.5]
        if yn:
            if k not in exi_dct:
                def deets():
                    return {'reason': f"'{k}' has no existing value"}
                listener('error', 'structure', 'cannot_update', deets)
                raise _Stop()  # (Case2713)
        elif k in exi_dct:
            xx(f"can't '{typ}' '{k}' because was already present")
        call_me(k, *args)
        pool.pop(k)

    # Any that remain are extra keys
    if len(pool):
        these = ', '.join(pool.keys())
        xx(f"unrecognized field(s): {these!r}")

    # Update the row with the product dict
    return arg_dct, counts


# == SPOT A


# == Low-Level Support

def _experiment_3(orig_f):
    def use_f(*a, **kw):
        itr = orig_f(*a, **kw)
        try:
            for item in itr:
                yield item
        except _Stop:
            pass
    return use_f


def _experiment_2(orig_f):
    def use_f(*a):
        x = orig_f(*a)
        if x is None:
            raise _Stop()
        return x
    return use_f


def _experiment_1(orig_f):
    def use_f(*a):
        try:
            return orig_f(*a)
        except _Stop:
            pass
    return use_f


class _Stop(RuntimeError):
    pass


# == Delegations

def _emit_edited(listener, UCDs, eid, preterite):
    from kiss_rdb.magnetics_.CUD_attributes_request_via_tuples \
        import emit_edited_ as emit
    emit(listener, UCDs, eid, preterite)


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #history-B.4
# #history-B.3
# #history-B.1 blind rewrite
# #history-A.2: big refactor, go gung-ho with context managers. extracted.
# #history-A.1: add experimental feature "sync keyerser"
# #born.
