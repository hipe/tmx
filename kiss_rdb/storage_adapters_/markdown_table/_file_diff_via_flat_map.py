from . import single_table_document_FFSA_ as _STD_FFSA, \
        build_throwing_listener_


def sync_agent_builder_(opener, ST_doc_scn_via_lines):

    def do_open_sync_session():
        from contextlib import contextmanager as cm

        @cm
        def cm():
            if (opened := opener()) is None:
                yield None
                return
            with opened as fh:

                def ST_doc_scn_via_listener(listener):
                    return ST_doc_scn_via_lines(fh, listener)

                yield sync_agent_(ST_doc_scn_via_listener, fh.name)
        return cm()

    class sync_agent_builder:  # #class-as-namespace
        open_sync_session = do_open_sync_session
        SYNC_AGENT_CAN_PRODUCE_DIFF_LINES = True
    return sync_agent_builder


def sync_agent_(ST_document_scanner_via_listener, coll_path):

    class sync_agent:  # #class-as-namespace

        def DIFF_LINES_VIA(flat_map, listener):  # (Case2641) (2/2)
            modi = modi_docu_scn_via(flat_map, listener)
            try:
                itr = _diff_lines_via(modi, coll_path)
            except _Stop:
                return
            return itr  # wee, pray

        def NEW_LINES_VIA(flat_map, listener):
            itr = _new_lines_via(modi_docu_scn_via(flat_map, listener))
            try:
                for line in itr:
                    yield line
            except _Stop:
                return

        def NEW_DOCUMENT_SCANNER_VIA(flat_map, listener):
            return modi_docu_scn_via(flat_map, listener)  # hi.

    def modi_docu_scn_via(flat_map, listener):
        listener = build_throwing_listener_(listener, _Stop)
        upstream_docu_scn = ST_document_scanner_via_listener(listener)
        return _ModifiedSingleTableDocumentScanner(
            upstream_docu_scn, flat_map, listener)

    return sync_agent


class _Stop(RuntimeError):
    pass


# _catch_iterator_stops = build_catch_iterator_stops_(_Stop)


def _diff_lines_via(modi, coll_path):

    def sentences(maximum):
        yield f"This readme exceeds {maximum} lines in length."
        yield "As part of its behavioral contract, [kiss-rdb] constrains "\
              "itself against reading \"very large\" files all into memory."
        yield "We need to cover the use case of larger files, possibly by "\
              "doing the diff on the filesystem or otherwise making this "\
              "algorithm smarter."
        yield f"File: {coll_path}"

    counter = _SanityCounter(
        maximum=274,  # approx num lines in longest README circa #history-B.1
        failure_sentences_via=sentences)

    # Leading non-table lines (they don't change)
    leading_non_table_lines = []
    for line in modi.release_leading_non_table_lines():
        counter.increment_by_one()
        leading_non_table_lines.append(line)

    # Schema lines (they don't change)
    cs = modi.release_complete_schema()
    schema_lines = tuple(cs.to_lines())
    counter.increment_by(len(schema_lines))

    # Get down to business
    business_lines_before, business_lines_after = [], []
    sexps = modi._RELEASE_MY_OWN_INTERNAL_SEXP_THING_()

    for typ, ast in sexps:
        counter.increment_by_one()  # not totally "fair" for many edits but meh
        line = ast.to_line()
        if 'both' == typ:
            business_lines_before.append(line)
            business_lines_after.append(line)
            continue
        if 'this_line_is_in_the_after_file_only' == typ:
            business_lines_after.append(line)
            continue
        assert 'this_line_is_in_the_before_file_only' == typ
        business_lines_before.append(line)

    # Trailing non-table lines (they don't change)
    trailing_non_table_lines = []
    for line in modi.release_trailing_non_table_lines():
        counter.increment_by_one()
        trailing_non_table_lines.append(line)

    orig_lines = (
        *leading_non_table_lines, *schema_lines, *business_lines_before,
        *trailing_non_table_lines)
    new_lines = (
        *leading_non_table_lines, *schema_lines, *business_lines_after,
        *trailing_non_table_lines)

    if True:  # retain history for now lol
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


def _new_lines_via(modi):

    for line in modi.release_leading_non_table_lines():
        yield line

    cs = modi.release_complete_schema()
    for line in cs.to_lines():
        yield line

    for ast in modi.release_business_row_ASTs_for_modified_document():
        yield ast.to_line()

    for line in modi.release_trailing_non_table_lines():
        yield line


_must_be_in_state = _STD_FFSA.build_precondition_decorator('_state_name')


class _ModifiedSingleTableDocumentScanner:

    def __init__(self, upstream, flat_map, listener):
        self._upstream, self._flat_map = upstream, flat_map
        self._listener = listener
        self._fsa, self.ok = _STD_FFSA.build_FSA(), True

    @_must_be_in_state('before_leading_non_table_lines')
    def release_leading_non_table_lines(self):
        with self._fsa.open_lock('leading_iteration_in_progress'):
            for line in self._upstream.release_leading_non_table_lines():
                yield line
        self._move_to('before_complete_schema')

    @_must_be_in_state('before_complete_schema')
    def release_complete_schema(self):
        cs = self._upstream.release_complete_schema()
        self._cs = cs
        self._move_to('before_business_ASTs')
        return cs

    def release_business_row_ASTs_for_modified_document(self):
        yes_or_no = {
            'this_line_is_in_the_after_file_only': True,
            'this_line_is_in_the_before_file_only': False,
            'both': True}
        for typ, ast in self._RELEASE_MY_OWN_INTERNAL_SEXP_THING_():
            if yes_or_no[typ]:
                yield ast

    @_must_be_in_state('before_business_ASTs')
    def _RELEASE_MY_OWN_INTERNAL_SEXP_THING_(self):
        with self._fsa.open_lock('doing_the_big_thing'):
            asts = self._upstream.release_business_row_ASTs()
            sxs = _CUSTOM_ASS_SEXP_THING(
                    self._cs, asts, self._flat_map, self._listener)
            for sx in sxs:
                yield sx
        self._move_to('before_trailing_non_table_lines')

    @_must_be_in_state('before_trailing_non_table_lines')
    def release_trailing_non_table_lines(self):
        with self._fsa.open_lock('trailing_iteration_in_progress'):
            for line in self._upstream.release_trailing_non_table_lines():
                yield line
        self._move_to('reached_end_of_output')

    def _move_to(self, state_name):
        self._fsa.move_to(state_name)

    @property
    def _state_name(self):
        return self._fsa.state_name


def _CUSTOM_ASS_SEXP_THING(cs, asts, flat_map, listener):
    mixed_err = flat_map.receive_schema(cs)
    assert not mixed_err  # should have raised stop upstream?

    assert hasattr(asts, '__next__')  # [#022]

    # For an example row, use either the first business row or 1st schema row
    first_ast = None
    for first_ast in asts:
        break
    if first_ast:
        use_eg_ast = first_ast
    else:
        use_eg_ast = cs.rows_[0]  # undocumented

    # Always pass-thru the example item (keeping it topmost)
    if first_ast:
        yield 'both', first_ast

    process_directives_during, process_directives_at_end = \
        _build_directives_processer(cs, use_eg_ast, listener)

    # Traverse over zero or more table lines, doing sync stuff
    for ast in asts:
        directives = flat_map.receive_item(ast)
        for sx in process_directives_during(directives, ast):
            yield sx

    # After finishing your own table, ask flat map for any remaining items
    for sx in process_directives_at_end(flat_map.receive_end()):
        yield sx


def _build_directives_processer(cs, eg_row, listener):

    def process_directives_during(directives, before_ast):
        for directive in directives:
            typ, *direc_args = directive
            if 'pass_through' == typ:
                assert not direc_args
                yield 'both', before_ast
                continue
            if 'insert_item' == typ:
                yield sexp_for_insert_item(*direc_args)
                continue
            if 'delete_item' == typ:
                please_give_me_the_deleted_item, = direc_args
                yield 'this_line_is_in_the_before_file_only', before_ast
                please_give_me_the_deleted_item(before_ast)
                continue
            if typ in ('merge_with_item', 'update_item'):
                direc_stack = list(reversed(direc_args))
                counts = None
                if 'update_item' == typ:
                    edit = direc_stack.pop()
                    assert isinstance(edit, tuple)
                    exi_dct = before_ast.core_attributes
                    dct, counts = _dct_via_edit(edit, exi_dct, cs, listener)
                else:
                    assert 'merge_with_item' == typ
                    yield 'this_line_is_in_the_before_file_only', before_ast
                    dct = direc_stack.pop()
                    assert isinstance(dct, dict)
                row = updated_row_via(dct.items(), before_ast, listener)
                if direc_stack:
                    recv, = direc_stack
                    recv(row)
                if counts:  # #here5
                    eid = before_ast.nonblank_identifier_primitive
                    _emit_edited(listener, counts, eid, 'updated')
                yield 'this_line_is_in_the_after_file_only', row
                continue
            assert 'error' == typ
            listener(*directive)
            raise _Stop()  # (Case3431DP)

    def process_directives_at_end(directives):
        for directive in directives:
            typ = directive[0]
            if 'insert_item' == typ:
                yield sexp_for_insert_item(* directive[1:])
                continue
            assert 'error' == typ
            listener(*directive)
            raise _Stop()  # (Case2641) (1/2)

    def sexp_for_insert_item(dct, recv=None):
        assert isinstance(dct, dict)
        row = new_row_via(dct.items(), listener)
        if recv:
            recv(row)
        return 'this_line_is_in_the_after_file_only', row

    from ._prototype_row_via_example_row_and_complete_schema import \
        BUILD_CREATE_AND_UPDATE_FUNCTIONS_ as build_funcs

    new_row_via, updated_row_via = build_funcs(eg_row, cs)
    # new_row_via = _raise_stop_if_none(new_row_via)
    # updated_row_via = _raise_stop_if_none(updated_row_via)

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


# == A Custom Counter #[#510.13]

class _SanityCounter:
    def __init__(self, maximum, failure_sentences_via):
        self._maximum = maximum
        self._failure_sentences_via = failure_sentences_via
        self._count = 0

    def increment_by_one(self):
        self.increment_by(1)

    def increment_by(self, amount):
        assert 0 < amount
        next_count = self._count + amount
        if next_count <= self._maximum:
            self._count = next_count
            return
        s_s = self._failure_sentences_via(maximum=self._maximum)
        raise RuntimeError(' '.join(s_s))


# == Delegations

def _emit_edited(listener, UCDs, eid, preterite):
    from kiss_rdb.magnetics_.CUD_attributes_request_via_tuples \
        import emit_edited_ as emit
    emit(listener, UCDs, eid, preterite)


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #history-B.5 document scanners not procedural mish-mash against sexp streams
# #history-B.4
# #history-B.3
# #history-B.1 blind rewrite
# #history-A.2: big refactor, go gung-ho with context managers. extracted.
# #history-A.1: add experimental feature "sync keyerser"
# #born.
