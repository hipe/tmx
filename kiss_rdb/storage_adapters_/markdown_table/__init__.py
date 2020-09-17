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


STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = False
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = True
STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS = ('.md',)
STORAGE_ADAPTER_IS_AVAILABLE = True
STORAGE_ADAPTER_UNAVAILABLE_REASON = "it's not yet needed as a storage adapter"


def COLLECTION_IMPLEMENTATION_VIA_SINGLE_FILE(
        collection_path, listener=None, opn=None, rng=None):
    del rng  # ..

    # If collection path looks like a filehandle open for write (e.g STDOUT)
    if hasattr(collection_path, 'fileno'):
        fh = collection_path
        assert 'w' == fh.mode[0]
        assert 1 == fh.fileno()  # until it isn't..
        from ._output_lines_via_far_collection import \
            pass_thru_collection_for_write_ as func
        return func(fh, listener)

    def cud(typ, listener, *cud_args):
        from ._flat_map_via_edit import cud_ as func
        return func(all_sexps, collection_path, opn, typ, cud_args, listener)

    def identifiers(listener):
        return (ent.identifier for ent in entities(listener))

    def entities(listener):
        return any_entities(listener) or ()

    def any_entities(listener):
        if (sexps := _via_stack(_action_stack_for_entities(), listener)):
            ents = (sexp[1] for sexp in sexps)
            for _ in ents:
                break  # [#867.E] advance over example row even if blank ID
            return (ent for ent in ents if ent.nonblank_identifier_primitive)

    def all_sexps(listener):
        action_stack = [('beginning_of_file', lambda o: o.turn_yield_on())]
        return _via_stack(action_stack, listener)

    def _via_stack(stack, listener):
        use_stack = _action_stack_for_check_single_table()
        _merge_action_stacks(use_stack, stack)
        try:
            opened = (opn or open)(collection_path)
        except FileNotFoundError as ee:
            from modality_agnostic import \
                emission_details_via_file_not_found_error as func
            e = ee  # 😢, (Case2662DP)
            return listener('error', 'structure', 'cannot_load_collection',
                            'no_such_file_or_directory', lambda: func(e))
        sexps = _every_line_sexp(opened, listener, context_stack)
        return _sexps_via_stack(sexps, use_stack, listener, context_stack)

    context_stack = ({'collection_path': collection_path},)

    class single_traversal_collection:  # #class-as-namespace
        def update_entity_as_storage_adapter_collection(iden, edit, listener):
            return cud('update', listener, iden, edit)

        def create_entity_as_storage_adapter_collection(dct, listener):
            return cud('create', listener, dct)

        def delete_entity_as_storage_adapter_collection(iden, listener):
            return cud('delete', listener, iden)

        def retrieve_entity_as_storage_adapter_collection(iden, listener):
            if (ents := any_entities(listener)):
                return _retrieve(ents, iden, listener)

        to_entity_stream_as_storage_adapter_collection = entities
        to_identifier_stream_as_storage_adapter_collection = identifiers
        sexps_via_stack = _via_stack  # (Case3306DP)

        def SYNC_AGENT_FOR_DATA_PIPES():
            from ._file_diff_via_flat_map import sync_agent_ as func
            return func(all_sexps, collection_path)

    return single_traversal_collection


# == RETRIEVE

def _retrieve(ents, iden, listener):
    if iden.has_depth_ and 3 < iden.number_of_digits:  # will go away
        return _when_identifier_too_deep(listener, iden, 3)
    needle_eid = iden.to_string()
    count = 0
    for ent in ents:
        if (eid := ent.nonblank_identifier_primitive) is None:
            continue
        if needle_eid == eid:
            return ent
        count += 1
    tup = emission_components_for_entity_not_found_(iden.to_string(), count)
    listener(* tup)


def emission_components_for_entity_not_found_(eid, count, verb_stem_phrz=None):
    @_message_via_wordruns
    def rsn():
        if verb_stem_phrz is not None:
            yield f"cannot {verb_stem_phrz} because"
        ies = 'y' if 1 == count else 'ies'
        yield f"'{eid}' not found (saw {count} entit{ies})"  # (Case2609)
    assert isinstance(eid, str)  # #[#022]
    return 'error', 'structure', 'entity_not_found', lambda: {'reason': rsn()}


def _when_identifier_too_deep(listener, iden, max_depth):  # will go away
    eid, depth = iden.to_string(), iden.number_of_digits  # (Case2606)
    msg = (f"can't retrieve '{eid}' because that identifier depth "
           f"({depth}) exceeds the max for this format ({max_depth})")
    listener('error', 'structure', 'entity_not_found', lambda: {'reason': msg})


# == **EXPERIMENTAL** "Action Stacks":
#    Associate with "symbols" in the "grammar" an "action" that is triggered
#    when the state is first transitioned into. Unlike "parse actions" in a
#    grammar, these stacks are injected into traversal as an argument.
#    Actions can for example turn on and off sexp echoing, perform validations,
#    and stop the traversal early. Note that if we ever #here2 support multiple
#    tables, this will undergo a possibly destructive re-architecting, because
#    currently it's written assuming a straight sequence of symbols rather than
#    the looping that happens in documents with multiple tables. Still neat tho

def _action_stack_for_entities():
    return [
        ('end_of_file', lambda o: o.turn_yield_off()),  # don't yield this pc
        ('table_schema_line_ONE_of_two',),
        ('other_line', lambda o: o.turn_yield_off()),
        ('business_row_AST', lambda o: o.turn_yield_on()),
        ('table_schema_line_TWO_of_two',),
        ('table_schema_line_ONE_of_two',),
        ('head_line',),
        ('beginning_of_file',)]


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


def _sexps_via_stack(sexps, stack, _listener, _context_stack):

    class controller:  # #class-as-namespace
        def turn_yield_on():
            self._do_yield = True

        def turn_yield_off():
            self._do_yield = False

        def stop():
            self._do_stop = True

        def sexp():
            return sx

        context_stack = _context_stack
        listener = _listener

        _do_stop = False
        _do_yield = False

    self = (o := controller)  # ..

    sexps, o.counter = _add_counter_to_iterator(sexps)  # dup #here1 meh

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


# ==

def _every_line_sexp(opened, listener, context_stack):
    with opened as lines:
        tagged_lines = _tagged_lines_via_lines(lines)
        sexps = _tagged_row_ASTs_or_lines_via_tagged_lines(
                tagged_lines, listener, context_stack)
        for sexp in sexps:
            yield sexp


# == Pseudo-Models

def schema_row_builder_():
    return _build_row_AST_via_two()


def _build_row_AST_via_two(schema=None):

    def row_AST_via_two(mutable_sexps, line):

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

        if schema is None:  # kind of crazy experiment to follow..
            return row_AST()

        class row_AST_entity(row_AST):

            def to_dictionary_two_deep_as_storage_adapter_entity(self):
                s = self.nonblank_identifier_primitive
                d = self.core_attributes_dictionary_as_storage_adapter_entity
                return {'identifier_string': s, 'core_attributes': d}

            @property
            def identifier(_):
                return get_lazy_item(identifier)

            @property
            def nonblank_identifier_primitive(_):
                return get_lazy_item(nonblank_identifier_string)

            @property
            def core_attributes_dictionary_as_storage_adapter_entity(_):
                return get_lazy_item(core_attrs_dict)

            @property
            def identifier_key__(_):
                return identifier_key

        def get_lazy_item(func):
            key = func.__name__
            if key not in memo:
                memo[key] = func()
            return memo[key]

        memo = {}

        def identifier():
            s = ent.nonblank_identifier_primitive
            if s is None:
                return
            return _identifier(s)

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
        return row_AST_via_two

    key_via_offset = schema.field_name_keys
    identifier_key = key_via_offset[0]  # #provision: [#871.1]
    offset_via_key = schema.offset_via_key_
    identifier_offset = offset_via_key[identifier_key]

    i = key_via_offset.index(identifier_key)
    non_identifier_attr_keys = (*key_via_offset[:i], *key_via_offset[i+1:])

    return row_AST_via_two


_endcap_yn = {'line_ended_with_pipe': True, 'line_ended_without_pipe': False}


class _identifier:  # #testpoint
    def __init__(self, eid):
        def eq(otr):
            assert isinstance(otr, _identifier)
            return eid == otr.to_string()
        self._eq = eq
        self.to_string = lambda: eid
        self.to_primitive = self.to_string

    def __eq__(self, otr):
        return self._eq(otr)

    has_depth_ = False


def _cell_AST(span, line):
    class document_cell:
        @property
        def value_string(_):
            return line[span[0]:span[1]].strip()  # strip: (Case2413)
        span__ = span
    assert isinstance(span, tuple)
    return document_cell()


def complete_schema_via_(ast1, ast2, table_cstack=None):
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
        field_name_keys = keys  # (Case3306DP)
        rows_ = (ast1, ast2)
        table_cstack_ = table_cstack

    complete_schema.row_AST_via_two_ = _build_row_AST_via_two(complete_schema)
    return complete_schema


# == Parse a Table Row

def _build_row_AST_via_line(listener, context_stack, schema=None):
    # #testpoint (for unit testing parsing row lines)

    def row_AST_via_line(line):
        try:
            scn = line_scanner_via_line(line)
            return row_AST_via_two(list(sexps_via_line_scanner(scn)), line)
        except stop:
            pass

    if schema:
        row_AST_via_two = schema.row_AST_via_two_
    else:
        row_AST_via_two = _build_row_AST_via_two()

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
        raise stop()

    class stop(RuntimeError):
        pass

    return row_AST_via_line


"""Pseudo-grammar showing how we tag and parse (almost) ANY possible file:

    'head_line'*
    (
        'table_schema_line_ONE_of_two' '..two..' 'business_row_AST'*

        ('other_line'* 'table_schema_line_one..' '..two..', 'busi..'*)?

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


def _tagged_row_ASTs_or_lines_via_tagged_lines(tagged_lines, listener, stack):
    # #testpoint: has its own unit test file

    itr = _tagged_row_ASTs_or_lines_via(tagged_lines, listener, stack)
    exception_class = next(itr)  # so sinful
    try:
        for two in itr:
            yield two
    except exception_class:
        pass


def _tagged_row_ASTs_or_lines_via(tagged_lines, listener, context_stack):

    # -- exception stuff at top because we hackishly yield our exception class

    def stop_because(reason):
        sct = {'reason': reason, 'line': line, 'lineno': lineno_er()}
        if context_stack:
            sct = _flatten_context_stack((*context_stack, sct))
        throwing_listener('error', 'structure', 'stop', lambda: sct)

    def throwing_listener(severity, *rest):
        listener(severity, *rest)
        if 'error' == severity:
            raise stop()

    class stop(RuntimeError):
        pass

    yield stop  # ick/meh

    # --

    scn = _scanner_via_iterator(tagged_lines)
    lineno_er = _hackishly_derive_counter(scn)  # duplication #here1 meh

    # Skip over leading other lines
    while not scn.empty and 'other' == scn.peek[0]:
        yield 'head_line', scn.advance()[1]

    is_first = True

    # (It may be that no table was found in zero or more lines)

    while not scn.empty:
        # Something other than 'other' is guaranteed; so, a table

        # For now we don't keep 'table_header_interstitial'*
        table_context_frame = {}  # used in error messages, maybe in #here2
        if 'table_header' == scn.peek[0]:
            table_context_frame['table_header_line'] = scn.peek[1]
            if is_first:
                is_first = False
                head_line_or_other_line = 'head_line'
            else:
                head_line_or_other_line = 'other_line'  # (Case2516)

            while True:
                yield head_line_or_other_line, scn.advance()[1]
                if 'table_header_interstitial' != scn.peek[0]:
                    break

        schema_row_AST_via_line = _build_row_AST_via_line(
                throwing_listener, context_stack, schema=None)

        # First table schema line
        table_lineno = lineno_er()
        typ, line = scn.advance()
        assert 'table_line' == typ  # per the upstream grammar
        tsl1of2_ast = schema_row_AST_via_line(line)
        if not tsl1of2_ast.has_endcap:
            stop_because('header row 1 must have "endcap" (trailing pipe)')
        yield 'table_schema_line_ONE_of_two', line  # for now, AST 4 me not u

        table_context_frame.update({'line': line, 'lineno': table_lineno})
        if scn.empty:
            xx("file ended on first table schema line - what do we output?")

        # Second table schema line
        typ, line = scn.advance()
        if 'table_line' != typ:
            xx(f"expected table schema line 2 (alignments), had '{typ}'")
        tsl2of2_ast = schema_row_AST_via_line(line)

        # Make sure the two schema lines accord
        two = (tsl1of2_ast, tsl2of2_ast)
        count1, count2 = (o.cell_count for o in two)
        has1, has2 = (o.has_endcap for o in two)

        if count1 != count2:
            xx("column counts didn't line up between schema row line 1 & 2")

        if has1 != has2:
            pass  # endcap on one but not the other is okay (Case2557)

        cstck = (*context_stack, table_context_frame)
        complete_schema = complete_schema_via_(tsl1of2_ast, tsl2of2_ast, cstck)

        yield 'table_schema_line_TWO_of_two', line, complete_schema  # #here3

        row_AST_via_line = _build_row_AST_via_line(
                throwing_listener, context_stack, complete_schema)

        # Zero or more business object rows
        while not scn.empty and 'table_line' == scn.peek[0]:
            ast = row_AST_via_line(line := scn.peek[1])
            count3 = ast.cell_count
            if count1 < count3:  # #here4
                stop_because(_line_about_cell_count_delta(count3, count1))
            yield 'business_row_AST', ast
            scn.advance()

        # Zero or more "other" lines (either til end of file or til next table)
        while not scn.empty and 'other' == scn.peek[0]:
            yield 'other_line', scn.advance()[1]


def _line_about_cell_count_delta(count3, count1):
    more_or_less = 'more' if count1 < count3 else 'less'
    return (f'row cannot have {more_or_less} cels than the schema row has. '
            f'(had {count3}, needed {count1}.)')


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
        type_ptr[0] = type_via_line(scn.peek)

    type_ptr = [0]  # #meh

    scn = _scanner_via_iterator(iter(lines))
    _hackishly_add_subscriber(scn, on_advance)

    def typ():
        return type_ptr[0]

    is_junk = {'blank': True, 'other': True, 'table': False, 'header': False}

    cache = []

    while not scn.empty:

        if is_junk[typ()]:
            yield 'other', scn.advance()
            continue

        # HEADER { COMMENT | BLANK }* TABLE
        if 'header' == typ():
            cache.append(scn.advance())
            while not scn.empty and ('blank' == typ() or '(' == scn.peek[0]):
                cache.append(scn.advance())
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
            yield 'table_line', scn.advance()
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


def _merge_action_stacks(main_stack, second_stack):  # goofy experiment
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


def _combine_two_monadics(f1, f2):
    def f3(arg):
        f1(arg)
        f2(arg)
    return f3


# == Scanners

def _hackishly_derive_counter(scn):
    def on_advance():
        counter.increment()

    def count():
        return counter.count

    counter = _Counter()
    _hackishly_add_subscriber(scn, on_advance)
    return count


def _add_counter_to_iterator(itr):
    def use_iterator():
        for item in itr:
            counter.increment()
            yield item
    counter = _Counter()
    return use_iterator(), counter


class _Counter:  # #[#510.13]
    def __init__(self):
        self.count = 0

    def increment(self):
        self.count += 1


def _hackishly_add_subscriber(scn, on_advance):
    if scn.empty:
        return  # because next line
    on_advance()  # YIKES

    def use_advance():
        x = orig_advance()
        if not scn.empty:
            on_advance()
        return x

    orig_advance = scn.advance
    scn.advance = use_advance
    return scn


def _scanner_via_iterator(itr):
    def next_item():
        for item in itr:
            return item
    return _scanner_via_next_function(next_item)


def _scanner_via_next_function(next_item):
    class scanner:
        def __init__(self):
            self.empty = False
            self.peek = None
            self.advance()

        def advance(self):
            res = self.peek
            item = next_item()
            if item is None:
                del self.peek
                self.empty = True
            else:
                self.peek = item
            return res
    return scanner()


def _flatten_context_stack(context_stack):
    def walk():
        for frame in context_stack:
            for k, v in frame.items():
                yield k, v
    return {k: v for k, v in walk()}


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #history-B.1: blind rewrite. absorb four modules
# #history-A.4: no more format adapter
# #history-A.3: no more sync-side entity mapping
# #history-A.2
# #history-A.1: markdown table as producer
# #born.
