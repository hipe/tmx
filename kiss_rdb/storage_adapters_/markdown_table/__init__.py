"""
A defining principle of this format adapter (like many) is that it should
be "streaming" and not a "memory hog" (don't read every entity into memory).

"kiss-rdb" was frontiered to make a toml storage adapter, but to establish
a test case canon, we frontiered an even easier, better known format:
markdown tables. Towards this objective we rewrote a quick-and-dirty,
single-file format adapter for markdown tables meant only to satisfy the
creation of the canon.

There were two DNA strains of markdown table format adapter. This was the
older one. At #history-B.1 we unified the strains.

:[#873.N]:
"""

from dataclasses import dataclass as _dataclass, field as _field


STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = False
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = True
STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS = ('.md',)
STORAGE_ADAPTER_IS_AVAILABLE = True
STORAGE_ADAPTER_UNAVAILABLE_REASON = "it's not yet needed as a storage adapter"


def _build_identifier_builder(_listener, _cstacker=None):  # #testpoint
    def iden_via_primitive(x):  # #[#877.4] this might become default
        assert isinstance(x, str)
        assert len(x)
        return x
    return iden_via_primitive


def FUNCTIONSER_FOR_SINGLE_FILES(
        opn=None,
        iden_er_er=_build_identifier_builder,
        file_grows_downwards=True,
        ):
    # #watch [#857.6] we don't love `opn`

    assert iden_er_er  # who is passing None in?

    class edit_funcs:  # #class-as-namespace

        def SYNC_AGENT_FOR_DATA_PIPES(opener):
            def all_sxs_er_er(fh):
                return _build_sexps_via_listener(fh, iden_er_er)
            from ._file_diff_via_flat_map import sync_agent_builder_ as func
            return func(opener, all_sxs_er_er)

        def UPDATE_VIA_FILEHANDLE(fh, iden, edit_x, listener):
            return cud('update', fh, listener, iden, edit_x)

        def CREATE_VIA_FILEHANDLE(fh, iden_er_er, dct, listener):
            return cud('create', fh, listener, dct, iden_er_er)

        def DELETE_VIA_FILEHANDLE(fh, iden, listener):
            return cud('delete', fh, listener, iden)

        def lines_via_schema_and_entities(schema, ents, listener):
            from ._output_lines_via_far_collection import \
                lines_via_schema_and_entities_ as func
            return func(schema, ents, listener)

    def cud(typ, fh, listener, *cud_args):
        all_sxser = _build_sexps_via_listener(fh, iden_er_er)
        use_filename = fh.name
        yn = file_grows_downwards
        from ._flat_map_via_edit import cud_ as func
        return func(all_sxser, use_filename, opn, typ, cud_args, listener, yn)

    class read_funcs:  # #class-as-namespace

        def RETRIEVE_VIA_FILEHANDLE(fh, iden, listener):
            return _retrieve(fh, iden, listener, iden_er_er)

        def schema_and_entities_via_lines(fh, listener):
            return _schema_and_entities_via_lines(fh, listener, iden_er_er)

    class fxr:  # #class-as-namespace
        def PRODUCE_EDIT_FUNCTIONS_FOR_SINGLE_FILE():
            return edit_funcs

        def PRODUCE_READ_ONLY_FUNCTIONS_FOR_SINGLE_FILE():
            return read_funcs

        class CUSTOM_FUNCTIONS_VERY_EXPERIMENTAL:  # noqa: E501
            def open_schema_and_RAW_entity_traversal(fh, listener):
                return _schema_and_RAW_entities(fh, listener, iden_er_er)
            open_schema_and_RAW_entity_traversal.is_reader = True

        def PRODUCE_IDENTIFIER_FUNCTIONER():
            return iden_er_er
    return fxr


# == RETRIEVE

def _retrieve(fh, iden, listener, iden_er_er):
    _sch, ents = _schema_and_entities_via_lines(fh, listener, iden_er_er)
    if ents is None:
        return

    count = 0
    for ent in ents:
        curr_iden = ent.identifier
        if curr_iden is None:
            continue
        if iden == curr_iden:
            return ent
        count += 1
    tup = emission_components_for_entity_not_found_(_str_via_iden(iden), count)
    listener(*tup)


def emission_components_for_entity_not_found_(eid, count, verb_stem_phrz=None):
    @_message_via_wordruns
    def rsn():
        if verb_stem_phrz is not None:
            yield f"cannot {verb_stem_phrz} because"
        ies = 'y' if 1 == count else 'ies'
        yield f"'{eid}' not found (saw {count} entit{ies})"  # (Case2609)
    assert isinstance(eid, str)  # #[#022]
    return 'error', 'structure', 'entity_not_found', lambda: {'reason': rsn()}


# == New Way

def _schema_and_entities_via_lines(fh, listener, iden_er_er):
    # Exclude any eg row. Exclude ents with empty identif. (both (Case2451))

    sch, ents = _schema_and_RAW_entities(fh, listener, iden_er_er)
    if ents is None:
        return sch, ents

    assert hasattr(ents, '__next__')

    for _ in ents:
        break

    return sch, (ent for ent in ents if ent.nonblank_identifier_primitive)


def _schema_and_RAW_entities(fh, listener, iden_er_er):
    # Include example row. Include "entities" with empty identifier

    astack = _action_stack_for_schema_and_entities()
    sxs = _sexps_via_lines_and_action_stack(fh, astack, listener, iden_er_er)

    # See if you get as far as parsing the two schema rows
    sr2_sx = None
    try:
        for sr2_sx in sxs:
            break
    except _Stop:
        pass

    # If you didn't get that far, you still owe the client a two-tuple
    if sr2_sx is None:
        return None, None

    # Now you can give the client the schema and the zero or more entities
    def entities():
        try:
            for sx in sxs:
                yield sx[1]
        except _Stop:
            pass

    return sr2_sx[2], entities()


# == Stream SEXP's

def _build_sexps_via_listener(fh, iden_er_er):  # #testpoint
    def all_sexps_via_listener(listener):
        memo.count += 1
        if 1 < memo.count:
            xx("something changed at #history-B.4")
        astack = _action_stack_for_all()
        return _sexps_via_lines_and_action_stack(fh, astack, listener, iden_er_er)  # noqa: E501
    memo = all_sexps_via_listener
    memo.count = 0
    return all_sexps_via_listener


def _sexps_via_lines_and_action_stack(fh, astack, listener, iden_er_er):  # th
    context_stack = ({'path': _path_via_lines(fh)},)

    # Resolve tagged lines via lines
    tagged_lines = _tagged_lines_via_lines(fh)

    # Resolve line sexps via tagged lines
    raw_sxs = _line_sexps_via(tagged_lines, context_stack, listener, iden_er_er)  # noqa: E501

    # Merge the argument stack into the one we always use
    use_astack = _action_stack_for_check_single_table()
    _merge_stack_in_to_stack(use_astack, astack)

    return _sexps_via_stack(raw_sxs, use_astack, context_stack, listener)


# == **EXPERIMENTAL** "Action Stacks":
#    Associate with "symbols" in the "grammar" an "action" that is triggered
#    when the state is first transitioned into. Unlike "parse actions" in a
#    grammar, these stacks are injected into traversal as an argument.
#    Actions can for example turn on and off sexp echoing, perform validations,
#    and stop the traversal early. Note that if we ever #here2 support multiple
#    tables, this will undergo a possibly destructive re-architecting, because
#    currently it's written assuming a straight sequence of symbols rather than
#    the looping that happens in documents with multiple tables. Still neat tho

def _action_stack_for_schema_and_entities():
    return [
        ('end_of_file', lambda o: o.turn_yield_off()),  # don't yield this pc
        ('table_schema_line_ONE_of_two',),
        ('other_line', lambda o: o.turn_yield_off()),
        ('business_row_AST',),
        ('table_schema_line_TWO_of_two', lambda o: o.turn_yield_on()),
        ('table_schema_line_ONE_of_two',), ('head_line',),
        ('beginning_of_file',)]


def _action_stack_for_all():
    return [('beginning_of_file', lambda o: o.turn_yield_on())]


def _action_stack_for_check_single_table():
    # Either we #here2 support multiple tables and a table locator wasn't
    # passed, or we don't yet support multiple tables. Either way, it's rude
    # to assume the first table is The One while ignoring the existence of any
    # subsequent table(s). As such, this action stack is (for now) the base
    # into which *all* argument action stacks are merged, so that whether we're
    # rewriting the file or (in theory) merely retrieving one item, we check.

    def at_table_1(_):
        memo.found_table_1 = True

    def at_table_2(o):
        frame = {'line': o.sexp()[1], 'lineno': o.counter.count}
        frame['reason'] = 'for now can only have one table'
        sct = _flatten_context_stack((*o.context_stack, frame))
        o.listener('error', 'structure', 'multiple_tables', lambda: sct)
        o.stop()

    def at_end_of_file(o):
        if memo.found_table_1:
            return
        msg = f"no markdown table found in {o.counter.count} lines"
        sct = _flatten_context_stack((*o.context_stack, {'reason': msg}))
        o.listener('error', 'structure', 'cannot_load_collection', lambda: sct)

    class memo:  # #class-as-namespace
        found_table_1 = False

    return [
        ('end_of_file', at_end_of_file),
        ('table_schema_line_ONE_of_two', at_table_2),
        ('other_line',),
        ('business_row_AST',),
        ('table_schema_line_TWO_of_two',),
        ('table_schema_line_ONE_of_two', at_table_1),
        ('head_line',),
        ('beginning_of_file',)]


def _sexps_via_stack(sexps, stack, cstack, listener):

    class controller:  # #class-as-namespace
        def turn_yield_on():
            self._do_yield = True

        def turn_yield_off():
            self._do_yield = False

        def stop():
            self._do_stop = True

        def sexp():
            return sx

        _do_stop = False
        _do_yield = False

    self = (o := controller)  # ..
    o.context_stack = cstack
    o.listener = listener

    sexps, o.counter = _scnlib().add_counter_to_iterator(sexps)
    # dup #here1 meh

    def expanded_sexps():
        yield ('beginning_of_file',)
        for sexp in sexps:
            yield sexp
        yield ('end_of_file',)

    popper = action_stack_popper_(stack)

    for sx in expanded_sexps():
        func = popper(sx[0])
        if func:
            func(o)
            if o._do_stop:
                break
        if o._do_yield:
            yield sx


# == Pseudo-Models

def schema_row_builder_():
    return _build_row_AST_via_three()


def _build_row_AST_via_three(schema=None):

    def row_AST_via_three(mutable_sexps, line, lineno):

        typ, = mutable_sexps.pop()
        cell_sexps = tuple(mutable_sexps)
        _cell_count, _has_endcap = len(cell_sexps), _endcap_yn[typ]

        class row_AST:

            def to_line(_):
                return line

            def cell_at_offset(_, offset):
                if offset < _cell_count:
                    sx = cell_sexps[offset]
                    assert 'padded_cell' == sx[0]
                    return _cell_AST(sx[1], line)

            cell_count = _cell_count
            has_endcap = _has_endcap
        row_AST.lineno = lineno
        if schema is None:  # kind of crazy experiment to follow..
            return row_AST()

        class row_AST_entity(row_AST):

            def to_dictionary_two_deep(self):
                s = self.nonblank_identifier_primitive
                d = self.core_attributes
                return {'identifier_string': s, 'core_attributes': d}

            @property
            def identifier(_):
                return get_lazy_item(identifier)

            @property
            def nonblank_identifier_primitive(_):
                return get_lazy_item(nonblank_identifier_string)

            @property
            def core_attributes(_):
                return get_lazy_item(core_attrs_dict)

            @property
            def identifier_key__(_):
                return identifier_key

        def get_lazy_item(func):
            key = func.__name__
            if key not in memo:
                x = None
                try:
                    x = func()
                except _Stop:
                    pass
                memo[key] = x
            return memo[key]

        memo = {}

        def identifier():
            if (s := ent.nonblank_identifier_primitive) is None:
                return
            return use_identifier_class(s)

        def nonblank_identifier_string():
            cell = ent.cell_at_offset(identifier_offset)
            if cell is None:
                return
            s = cell.value_string
            if not len(s):
                return
            return s

        def core_attrs_dict():
            def keys_and_values():
                # == BEGIN experiment - adding the ID column here at what cost?
                #    answer: #provision [#857.9] maybe EID, maybe not
                if (x := ent.nonblank_identifier_primitive) is not None:
                    yield identifier_key, x
                # == END
                for k in non_identifier_attr_keys:
                    cell = ent.cell_at_offset(offset_via_key[k])
                    if cell is None:
                        continue
                    s = cell.value_string
                    if 0 == len(s):
                        continue
                    yield k, s
            return {k: v for k, v in keys_and_values()}

        return (ent := row_AST_entity())

    if schema is None:
        return row_AST_via_three

    use_identifier_class = schema.identifier_class_  # #here5 = [#857.C]
    key_via_offset = schema.field_name_keys
    identifier_key = key_via_offset[0]  # #provision: [#871.1]
    offset_via_key = schema.offset_via_key_
    identifier_offset = offset_via_key[identifier_key]

    i = key_via_offset.index(identifier_key)
    non_identifier_attr_keys = (*key_via_offset[:i], *key_via_offset[i+1:])

    return row_AST_via_three


_endcap_yn = {'line_ended_with_pipe': True, 'line_ended_without_pipe': False}


class _identifier:  # #testpoint
    def __init__(self, eid):
        assert isinstance(eid, str)  # [#022]
        self._str = eid

    def to_string(self):
        return self._str

    to_primitive = to_string

    def __eq__(self, otr):
        return 0 == self._cmp(otr)

    def __lt__(self, otr):
        return -1 == self._cmp(otr)

    def _cmp(self, otr):
        assert isinstance(otr, self.__class__)
        mine, yours = self._str, otr._str
        if mine == yours:
            return 0
        if mine < yours:
            return -1
        assert yours < mine
        return 1

    has_depth_ = False


def _cell_AST(span, line):
    class document_cell:
        @property
        def value_string(_):
            return line[span[0]:span[1]].strip()  # strip: (Case2413)
        span__ = span
    assert isinstance(span, tuple)
    return document_cell()


def complete_schema_via_(ast1, ast2, table_cstack=None, iden_er=None):
    def key_via_cell(cell):
        s = normal_field_name_via_string(cell.value_string)
        assert(len(s))  # ..
        return s
    from kiss_rdb import normal_field_name_via_string

    max_cell_count = ast1.cell_count
    rang = range(0, max_cell_count)
    keys = tuple(key_via_cell(ast1.cell_at_offset(i)) for i in rang)
    offset_via_key = {keys[i]: i for i in rang}
    assert max_cell_count == len(offset_via_key)  # else name collision

    class complete_schema:  # #class-as-namespace
        offset_via_key_ = offset_via_key
        field_name_keys = keys  # (Case3459DP)
        rows_ = (ast1, ast2)
        identifier_class_ = (iden_er or _identifier)  # #here5
        table_cstack_ = table_cstack

    complete_schema.row_AST_via_three_ = _build_row_AST_via_three(complete_schema)  # noqa: E501
    return complete_schema


# == Parse a Table Row

def _build_row_AST_via_line(listener, context_stack, schema=None):
    # #testpoint (for unit testing parsing row lines)

    def row_AST_via_line(line, lineno):
        scn = line_scanner_via_line(line)
        sx = list(sexps_via_line_scanner(scn))
        return row_AST_via_three(sx, line, lineno)

    if schema:
        row_AST_via_three = schema.row_AST_via_three_
    else:
        row_AST_via_three = _build_row_AST_via_three()

    def sexps_via_line_scanner(scn):
        while True:
            scn.require_pipe()
            if scn.empty:
                yield ('line_ended_with_pipe',)
                return
            yield 'padded_cell', scn.span_for_scan_zero_or_more_not_pipe()
            if scn.empty:
                yield ('line_ended_without_pipe',)
                return

    def line_scanner_via_line(line):
        leng = len(line)
        last_pos = leng - 1

        class scanner:
            def __init__(self):
                self.pos = 0
                self.empty = False
                self._check_empty()

            def require_pipe(self):
                if '|' == line[self.pos]:
                    self.pos += 1
                    self._check_empty()
                    return
                stop_because_expecting_pipe(line, self.pos)

            def span_for_scan_zero_or_more_not_pipe(self):
                md = zero_or_more_not_pipe_rx.match(line, self.pos)
                rang = md.span()
                self.pos = rang[1]
                self._check_empty()
                return rang

            def _check_empty(self):
                if self.pos < last_pos:
                    return
                if last_pos < self.pos:
                    xx('probably empty string')
                if '\n' == line[self.pos]:
                    self.empty = True
                    return
                stop_because_expecting_newline_at_end_of_line()

        return scanner()

    import re
    zero_or_more_not_pipe_rx = re.compile('[^|\n]*')

    def stop_because_expecting_pipe(line, pos):
        def lineser():
            if pos:
                at_where = f" at offset {pos}"
            else:
                at_where = " at beginning of line"
            actual = repr(line[pos])  # ..
            yield f"expecting '|' had {actual}{at_where}"
        stop_with_error(lineser)

    def stop_because_expecting_newline_at_end_of_line():
        def lineser():
            yield "expecting '\\n' at end of line"
        stop_with_error(lineser)

    def stop_with_error(lineser):
        listener('error', 'expression', lineser)
        raise _Stop()

    return row_AST_via_line


"""Pseudo-grammar showing how we tag and parse (almost) ANY possible file:

    'head_line'*
    (
        'table_schema_line_ONE_of_two' '..two..' 'business_row_AST'*

        ('other_line'* 'table_schema_line_one..' '..two..', 'busi..'*)*

        'other_line'*
    )?

Features:
  - Empty file ok
  - Files with no tables ok: just zero or more 'head_line'
  - Table with no business rows ok
  - Table with schema row 1 but not 2 should trigger a parse failure (see ⬇)
  - More than one table ok

With a loose-enough definition of what a table-row-line is (one pipe followed
by zero or more non-pipes, escaped pipes, or pipes), we could construct a
grammar to accomodate literally any file and still "parse" "tables". However,
in practice we are not so lenient given:

- Our requirement that every table have at least two rows (a schema line 1 and
  necessarily a schema line 2 after it). We could do lookahead-and-ignore to
  avoid parse failures of these cases, but we expect it will be more useful to
  emit failure & stop. (Perhaps even real life markdown has this requirement..)

- We may assert that the 2 schema lines accord w/ each other in expected ways
  and possibly other cosmetic assertions

- In practice we make the parse-time assertion that each business object row
  have a number of cells not exceeding the number of cels (columns) in the
  schema, because fundamentally our isomorphicism relies on deriving a field
  name (key) names for every cell of every business row from the first row.
"""


def _line_sexps_via(tagged_lines, context_stack, listener, iden_er_er):
    # rewrote as FSA not scanner-based, procedural mish-mash at #history-B.5

    # States [#008.2]

    def from_beginning_state():
        yield if_other_line, yield_head_line_or_other_line
        yield if_table_header_line, handle_header_and_transition_to_after
        yield if_table_line, start_TIP_and_handle_schema_line_one

    def from_ready_state():  # (like beginning state but after one table #todo)
        yield if_other_line, yield_head_line_or_other_line
        yield if_table_header_line, handle_header_and_transition_to_after
        yield if_table_line, start_TIP_and_handle_schema_line_one

    def from_after_table_header_line():
        yield if_interstitial, wow_do_something_with_interstitial
        yield if_table_line, handle_schema_line_one

    def from_after_first_schema_line():
        yield if_table_line, on_schema_line_two

    def from_after_second_schema_line():
        yield if_table_line, enter_table_body_state_and_handle_item_row
        xx("you're gonna wanna handle empty tables")

    def from_table_body_state():
        yield if_table_line, handle_item_row
        yield if_other_line, handle_end_of_table_because_other_line

    from_beginning_state.on_EOS = lambda: when_file_with_no_tables()
    from_ready_state.on_EOS = lambda: None  # the most common end
    from_after_first_schema_line.on_EOS = lambda: xx('premature end of file')
    from_after_second_schema_line.on_EOS = lambda: when_end_after_open_table()
    from_table_body_state.on_EOS = lambda: when_table_is_at_EOF()

    # Actions

    def wow_do_something_with_interstitial():
        state.table_in_progress.interstitial_lines.append(line)
        return yield_head_line_or_other_line()

    def handle_header_and_transition_to_after():
        # (externally, pass thru as ordinary lines but internally (Case2516))

        start_table_in_progress(table_header_line=line)
        move_to_state(from_after_table_header_line)
        return yield_head_line_or_other_line()

    def start_TIP_and_handle_schema_line_one():
        start_table_in_progress()
        return handle_schema_line_one()

    def handle_schema_line_one():
        tip = state.table_in_progress
        tsl1of2_ast = schema_row_AST_via_line(line, lineno)
        tip.table_schema_line_ONE_of_two_AST = tsl1of2_ast

        if not tsl1of2_ast.has_endcap:
            stop_because('header row 1 must have "endcap" (trailing pipe)')

        state.head_line_or_other_line = 'other_line'
        # (now, every line that is not a table line will be 'other' if not alr)

        move_to_state(from_after_first_schema_line)
        return 'yield_this', ('table_schema_line_ONE_of_two', line)

    def start_table_in_progress(table_header_line=None):
        assert state.table_in_progress is None
        state.table_in_progress = _TableInProgress(
                line=line, lineno=lineno, table_header_line=table_header_line)

    def on_schema_line_two():
        tip = state.table_in_progress
        tsl1of2_ast = tip.table_schema_line_ONE_of_two_AST
        tsl2of2_ast = schema_row_AST_via_line(line, 0)

        # Make sure the two schema lines accord
        ((count1, has1), (count2, has2)) = \
            ((o.cell_count, o.has_endcap) for o in (tsl1of2_ast, tsl2of2_ast))

        if count1 != count2:
            xx("column counts didn't line up between schema row line 1 & 2")

        if has1 != has2:
            pass  # endcap on one but not the other is okay (Case2557)

        cstck = (*context_stack, tip.to_context_frame())
        complete_schema = complete_schema_via_(
            tsl1of2_ast, tsl2of2_ast, cstck, iden_er)

        tip.item_row_AST_via_line = _build_row_AST_via_line(
                throwing_listener, context_stack, complete_schema)

        tip.formal_cell_count = count1

        move_to_state(from_after_second_schema_line)

        out = 'table_schema_line_TWO_of_two', line, complete_schema  # #here3
        return 'yield_this', out

    def enter_table_body_state_and_handle_item_row():
        move_to_state(from_table_body_state)
        return handle_item_row()

    def handle_item_row():
        tip = state.table_in_progress
        ast = tip.item_row_AST_via_line(line, lineno)
        actual = ast.cell_count
        if tip.formal_cell_count < actual:  # #here4
            reason = _line_about_cell_count_delta(
                    actual, tip.formal_cell_count)
            stop_because(reason)
        return 'yield_this', ('business_row_AST', ast, lineno)

    def handle_end_of_table_because_other_line():
        state.table_in_progress = None
        move_to_state(from_ready_state)
        return yield_head_line_or_other_line()

    def yield_head_line_or_other_line():
        return 'yield_this', (state.head_line_or_other_line, line)

    # Conditions

    def if_other_line():
        return 'other' == token_type

    def if_table_header_line():
        return 'table_header' == token_type

    def if_interstitial():
        return 'table_header_interstitial' == token_type

    def if_table_line():
        return 'table_line' == token_type

    # ==

    def move_to_state(func):
        stack[-1] = func

    # ==

    # == Whiners & Adjacent

    def when_file_with_no_tables():
        pass  # client emits an error, we don't need to notice (Case2428_020)

    def when_end_after_open_table():
        pass  # (Case2428_030)

    def when_table_is_at_EOF():
        pass  # (Case2557)

    # == Support

    def find_transition():
        for condition, action in stack[-1]():
            yn = condition()
            if yn:
                return action
        from_where = stack[-1].__name__.replace('_', ' ')
        what = repr(token_type)
        xx(f"{from_where} got line of type {what}. add a transition for this")

    def throwing_listener(sev, *rest):
        listener(sev, *rest)
        if 'error' == sev:
            raise _Stop()

    def stop_because(reason):
        sct = _flatten_context_stack((*build_cstack(), {'reason': reason}))
        listener('error', 'structure', 'stop', lambda: sct)
        raise _Stop()

    def build_cstack():
        return (*(context_stack or ()), {'line': line, 'lineno': lineno})

    # == Functions derived from above

    schema_row_AST_via_line = _build_row_AST_via_line(
            throwing_listener, context_stack)

    iden_er = None
    if iden_er_er:
        iden_er = iden_er_er(throwing_listener, build_cstack)  # VERY EXPERIM

    state = from_ready_state  # #watch-the-world-burn
    state.table_in_progress = None

    state.head_line_or_other_line = 'head_line'
    # (lines that aren't table lines are 'head_line' or 'other_line')

    stack = [from_beginning_state]  # (incidentally, we don't ever push/pop)

    lineno = 0
    for token_type, line in tagged_lines:
        lineno += 1
        while True:  # (placeheld for a possible future "retry" directive)
            action = find_transition()
            direc = action()
            typ = direc[0]
            assert 'yield_this' == typ
            x, = direc[1:]
            yield x
            break  # go on to process the next line

    direc = stack[-1].on_EOS()
    if direc is None:
        return
    xx('ok easy')


@_dataclass
class _TableInProgress:
    """mutable parse state for building AST progressively over several lines"""

    table_header_line: str
    lineno: int
    line: str
    interstitial_lines: list[str] = _field(default_factory=list)

    def to_context_frame(self):  # maybe used in #here2
        kw = {'line': self.line, 'lineno': self.lineno}
        if (s := self.table_header_line):
            kw['table_header_line'] = s
        return kw


def _line_about_cell_count_delta(count3, count1):
    more_or_less = 'more' if count1 < count3 else 'less'
    return (f'row cannot have {more_or_less} cels than the schema row has. '
            f'(had {count3}, needed {count1}.)')


class _Stop(RuntimeError):
    pass


# == Produce a Stream of Tagged Lines

def _tagged_lines_via_lines(lines):
    # Cannot fail (given zero or more newline-terminated lines) (Might mis-tag)
    # #testpoint: exposed for visual testing in neighbor "__main__".
    # #testpoint: used as helper in unit test for higher-level function

    def type_via_line(line):
        if '\n' == line:
            return 'blank'
        char = line[0]
        if '|' == char:
            return 'table'
        if '#' == char:
            return 'header'
        return 'other'

    def on_advance():
        if scn.more:
            type_ptr[0] = type_via_line(scn.peek)
        else:
            type_ptr[0] = 'ALL_DONE'

    type_ptr = [0]  # #meh
    scn = _scnlib().scanner_via_iterator(iter(lines))
    on_advance()  # set it for the first peek
    _scnlib().MUTATE_add_advance_observer(scn, on_advance)

    def typ():
        return type_ptr[0]

    is_junk = {'blank': True, 'other': True, 'table': False, 'header': False}

    cache = []

    while scn.more:
        if is_junk[typ()]:
            yield 'other', scn.next()
            continue

        # HEADER { COMMENT | BLANK }* TABLE
        if 'header' == typ():
            cache.append(scn.next())
            while scn.more and ('blank' == typ() or '(' == scn.peek[0]):
                cache.append(scn.next())
            if scn.empty or 'table' != typ():
                for line in cache:
                    yield 'other', line
                cache.clear()
                continue
            stack = list(reversed(cache))
            cache.clear()
            yield 'table_header', stack.pop()
            while len(stack):
                yield 'table_header_interstitial', stack.pop()

        assert 'table' == typ()

        while True:
            yield 'table_line', scn.next()
            if scn.empty:
                break
            if 'table' == typ():
                continue
            break


# == Expression Support

def _message_via_wordruns(orig_f):  # #decorator
    def use_f():
        return ' '.join(orig_f())
    return use_f


def _str_via_iden(iden):
    if hasattr(iden, 'to_string'):
        return iden.to_string()
    assert isinstance(iden, str)  # ..
    return iden


# == Action Stacks (experiment)

def _any_2nd_of_max_two(frame):
    _, *rest = frame
    if len(rest):
        res, = rest
        return res


def action_stack_popper_(stack, result_via_frame=_any_2nd_of_max_two):
    # simply detect when sexp type changed, and pop the stack till find match

    def popper(typ):
        if is_same(typ):
            return
        while True:
            frame = stack.pop()  # ..
            if typ == frame[0]:
                return result_via_frame(frame)

    is_same = _build_change_detector()
    return popper


def _build_change_detector(initial_type=None):  # #[#508.2] chunker
    def is_same(typ):
        if memo.current_type == typ:
            return True
        memo.current_type = typ
        return False

    class memo:  # #class-as-namespace
        current_type = initial_type

    return is_same


def _merge_stack_in_to_stack(main_stack, second_stack):  # goofy experiment
    main_offset = len(main_stack)
    while len(second_stack):
        main_offset -= 1
        assert 0 <= main_offset
        second_frame = second_stack.pop()
        main_frame = main_stack[main_offset]
        typ1, *rest1 = main_frame
        typ2, *rest2 = second_frame
        assert typ1 == typ2
        if not len(rest2):  # no content in 2nd frame, just placeholder
            continue
        f2, = rest2
        if not len(rest1):  # no content in main frame, easy
            main_stack[main_offset] = (typ1, f2)
            continue
        f1, = rest1
        # there's a goddam action in main AND second stack
        f3 = _combine_two_monadics(f1, f2)  # order might matter w/ stop
        main_stack[main_offset] = (typ1, f3)


# == Smalls

def _path_via_lines(fh):
    if hasattr(fh, 'name'):
        return fh.name
    assert hasattr(fh, '__next__')
    return "«line generator, not path»"


def _combine_two_monadics(f1, f2):
    def f3(arg):
        f1(arg)
        f2(arg)
    return f3


def _flatten_context_stack(context_stack):  # #[#510.14]
    return {k: v for row in context_stack for k, v in row.items()}


def _scnlib():
    from text_lib.magnetics import scanner_via as module
    return module


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #history-B.5
# #history-B.4
# #history-B.1: blind rewrite. absorb four modules
# #history-A.4: no more format adapter
# #history-A.3: no more sync-side entity mapping
# #history-A.2
# #history-A.1: markdown table as producer
# #born.
