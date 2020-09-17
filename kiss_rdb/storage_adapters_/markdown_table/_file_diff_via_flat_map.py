def sync_agent_(all_sexpser, coll_path):
    all_sexpser = _experiment_2(all_sexpser)

    def _diff_lines_via(*sync_args):
        # Read original sexps (then lines) in to memory
        flat_map, *rst, listener = sync_args
        orig_sx_itr = all_sexpser(listener)
        orig_sxs, count, sanity = [], 0, 274  # ~ num lines in longest README
        for sx in orig_sx_itr:
            if count == sanity:
                xx("is there memory saved by doing diff on the filesystem?")
            count += 1
            orig_sxs.append(sx)
        orig_sxs = tuple(orig_sxs)
        orig_lines = tuple(_lines_via_sexps(orig_sxs))

        # Read new sexps (then lines) in to memory
        new_sxs = _new_sexps(iter(orig_sxs), flat_map, *rst, listener)
        new_lines = tuple(_lines_via_sexps(new_sxs))

        # Make the Diff!
        if orig_lines == new_lines:
            xx('no change, no diff to make')
        from os.path import isabs
        if isabs(coll_path):
            from kiss_rdb import build_path_relativizer_ as build
            path_tail = build()(coll_path)
        else:
            path_tail = coll_path  # relative only in tests mebbe (Case2644)
        pathA, pathB = f'a/{path_tail}', f'b/{path_tail}'
        from difflib import unified_diff
        return unified_diff(orig_lines, new_lines, pathA, pathB)

    def _new_lines_via(*sync_args):
        try:
            for line in _lines_via_sexps(_new_sexps_via(*sync_args)):
                yield line
        except _Stop:
            pass

    def _new_sexps_via(flat_map, near_keyerer, listener):
        orig_sxs = all_sexpser(listener)
        return _new_sexps(orig_sxs, flat_map, near_keyerer, listener)

    class sync_agent:  # #class-as-namespace
        SYNC_AGENT_CAN_PRODUCE_DIFF_LINES = True
        DIFF_LINES_VIA = _experiment_1(_diff_lines_via)  # (Case2641) (2/2)
        NEW_LINES_VIA = _new_lines_via
        NEW_SEXPS_VIA = _experiment_3(_new_sexps_via)

    return sync_agent


def _lines_via_sexps(new_sexps):
    def normal(sexp):
        return sexp[1]

    stack = [
        ('end_of_file', None),
        ('table_schema_line_ONE_of_two', xx),
        ('other_line', normal),
        ('business_row_AST', lambda sexp: sexp[1].to_line()),
        ('table_schema_line_TWO_of_two', normal),
        ('table_schema_line_ONE_of_two', normal),
        ('head_line', normal),
        ('beginning_of_file', None)]

    from . import action_stack_popper_
    popper = action_stack_popper_(stack, lambda fra: fra[1:])

    for sx in new_sexps:
        frame = popper(sx[0])
        if frame:
            func, = frame
            skip = func is None
        if skip:
            continue
        yield func(sx)


def _new_sexps(itr, flat_map, near_keyerer, listener):
    # Output zero or more head lines (lines before the table)
    # #todo this was written before action stacks and could be cleaned up

    use_eg_row, actual_eg_row = None, None
    sexps_after_table_on_deck = []

    sx = next(itr)
    assert 'beginning_of_file' == sx[0]
    yield sx

    after_table = {'other_line', 'end_of_file'}

    for tsl1_sx in itr:
        if 'head_line' == tsl1_sx[0]:
            yield tsl1_sx
            continue
        yield tsl1_sx  # table_schema_line_ONE_of_two
        for tsl2_sx in itr:
            yield tsl2_sx  # table_schema_line_TWO_of_two
            cs = tsl2_sx[2]  # yikes
            _2 = (getattr(cs, k) for k in ('field_name_keys', 'table_cstack_'))
            if (d := flat_map.receive_field_name_keys(*_2)) is not None:
                assert 'error' == d[0][0]  # #here3
                listener(*d[0])
                return
            for eg_row_sx in itr:
                if (typ := eg_row_sx[0]) in after_table:
                    sexps_after_table_on_deck.append(eg_row_sx)
                    use_eg_row = cs.rows_[0]  # undocumented
                    break
                assert 'business_row_AST' == typ
                use_eg_row = (actual_eg_row := eg_row_sx[1])
                break
            break
        break

    if use_eg_row is None:
        xx("can't sync without example row")

    # Always output the example row manually, keeping it always topmost
    if actual_eg_row:
        yield 'business_row_AST', actual_eg_row

    near_key_for = _build_near_keyer(near_keyerer, cs)  # ..

    process_directives_during, process_directives_at_end = \
        _build_directives_processer(use_eg_row, cs, listener)

    # Traverse over zero or more table lines, doing sync stuff
    for sx in itr:
        if (typ := sx[0]) in after_table:
            sexps_after_table_on_deck.append(sx)
            break
        assert 'business_row_AST' == sx[0]
        ent = sx[1]
        near_key = near_key_for(ent)
        if near_key is None:
            yield sx  # pass thru table rows with a blank identifier cell or et
            continue

        directives = flat_map.receive_item(near_key)
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
                    exi_dct = exi_row.core_attributes_dictionary_as_storage_adapter_entity  # noqa: E501
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
                yield 'business_row_AST', row
                continue
            if 'give_me_the_AST_please' == typ:
                directive[1](sx[1])
                continue
            assert 'error' == typ
            listener(*directive)
            raise _Stop()  # (Case2664DP)

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
        return 'business_row_AST', row

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
        xx("unrecognized field(s): ({', '.join(pool.keys()})")

    # Update the row with the product dict
    return arg_dct, counts


def _build_near_keyer(near_keyerer, complete_schema):  # (Case0160DP has hist.)

    def near_keyer_normally(ent):
        # might be #provision [#871.1] (leftmost is guy) but we don't know
        # might be None! it's not a validation failure to have blank cell here
        return ent.nonblank_identifier_primitive

    if near_keyerer is None:
        return near_keyer_normally

    return near_keyerer(near_keyer_normally, complete_schema, None)


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

# #history-B.1 blind rewrite
# #history-A.2: big refactor, go gung-ho with context managers. extracted.
# #history-A.1: add experimental feature "sync keyerser"
# #born.
