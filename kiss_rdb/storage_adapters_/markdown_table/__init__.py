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

from modality_agnostic.minimal_FSA import Minimal_Formal_FSA as _Minimal_FSA
from dataclasses import dataclass as _dataclass


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
        which_table=None,
        file_grows_downwards=True,
        ):
    # #watch [#857.6] we don't love `opn`

    assert iden_er_er  # who is passing None in?

    class edit_funcs:  # #class-as-namespace

        def SYNC_AGENT_FOR_DATA_PIPES(opener):
            def ST_doc_scn_via_lines(fh, listener):  # compare #here6
                return _single_table_doc_scanner_via_lines(
                    fh, listener,
                    which_table=which_table, iden_er_er=iden_er_er)
            from ._file_diff_via_flat_map import sync_agent_builder_ as func
            return func(opener, ST_doc_scn_via_lines)

        def UPDATE_VIA_FILEHANDLE(fh, iden, edit_x, listener):
            return cud('update', fh, listener, iden, edit_x)

        def CREATE_VIA_FILEHANDLE(fh, eid, iden_er_er, dct, listener):
            return cud('create', fh, listener, (eid, iden_er_er), dct)

        def DELETE_VIA_FILEHANDLE(fh, iden, listener):
            return cud('delete', fh, listener, iden)

        def lines_via_schema_and_entities(schema, ents, listener):
            from ._output_lines_via_far_collection import \
                lines_via_schema_and_entities_ as func
            return func(schema, ents, listener)

    def cud(typ, fh, listener, identity_args, attr_args=None):
        def ST_doc_scn_via_listener(listener):  # compare #here6
            return _single_table_doc_scanner_via_lines(
                fh, listener, which_table=which_table, iden_er_er=iden_er_er)
        use_filename = fh.name
        from ._flat_map_via_edit import CUD_markdown_ as func
        return func(
            create_update_or_delete=typ,
            identity_arguments=identity_args, attribute_arguments=attr_args,
            ST_document_scanner_via_listener=ST_doc_scn_via_listener,
            collection_path=use_filename,
            grow_downwards=file_grows_downwards, opn=opn, listener=listener)

    class read_funcs:  # #class-as-namespace

        def RETRIEVE_VIA_FILEHANDLE(fh, iden, listener):
            return _retrieve(fh, iden, which_table, iden_er_er, listener)

        def schema_and_entities_via_lines(fh, listener):
            return _schema_and_entities_via_lines(
                    fh, which_table, iden_er_er, listener)

    class fxr:  # #class-as-namespace
        def PRODUCE_EDIT_FUNCTIONS_FOR_SINGLE_FILE():
            return edit_funcs

        def PRODUCE_READ_ONLY_FUNCTIONS_FOR_SINGLE_FILE():
            return read_funcs

        class CUSTOM_FUNCTIONS_VERY_EXPERIMENTAL:  # noqa: E501
            def open_schema_and_RAW_entity_traversal(fh, listener):
                return _schema_and_RAW_entities(
                    fh, which_table=which_table,
                    iden_er_er=iden_er_er, listener=listener)
            open_schema_and_RAW_entity_traversal.is_reader = True

        def PRODUCE_IDENTIFIER_FUNCTIONER():
            return iden_er_er
    return fxr


# ==

class _Experimental_FSA_Client:

    def _not_OK_and_failure_lock(self, lock_name):
        self._fsa.failure_lock(lock_name)
        self.ok = False

    def _enter_lock(self, lock_name):
        return self._fsa.enter_lock(lock_name)

    def _exit_lock(self, lock_name):
        return self._fsa.exit_lock(lock_name)

    def _move_to(self, state_name):
        self._fsa.move_to(state_name)

    @property
    def _state_name(self):
        return self._fsa.state_name


single_table_document_FFSA_ = _Minimal_FSA(
    before_leading_non_table_lines=('before_complete_schema',),
    before_complete_schema=('before_business_ASTs',),
    before_business_ASTs=('before_trailing_non_table_lines',),
    before_trailing_non_table_lines=('reached_end_of_output',),
    reached_end_of_output=())


# == experimental Stops Library (makes decorators)

def _build_iterator_stops_decorator(stop, on_stop=None):
    def decorator(orig_func):
        def use_func(self):
            def use_on_stop():
                if on_stop:
                    on_stop(self)
            itr = orig_func(self)
            return _do_catch_iterator_stops(itr, stop, use_on_stop)
        return use_func
    return decorator


def _do_catch_iterator_stops(itr, stop, on_stop):
    try:
        for x in itr:
            yield x
    except stop:
        on_stop and on_stop()


def build_throwing_listener_(listener, stop):
    def use_listener(sev, *rest):
        listener(sev, *rest)
        if 'error' == sev:
            raise stop()
    return use_listener


# == (define stop-related decorators)

class _Stop(RuntimeError):
    pass


def _on_stop(self):
    self.ok = False


_catch_STD_iterator_stops = _build_iterator_stops_decorator(_Stop, _on_stop)


# == RETRIEVE

def _retrieve(fh, iden, which_table, iden_er_er, listener):
    _sch, ents = _schema_and_entities_via_lines(
            fh, which_table, iden_er_er, listener)
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
    def rsn():
        return ' '.join(reason_words())

    def reason_words():
        if verb_stem_phrz is not None:
            yield f"cannot {verb_stem_phrz} because"
        ies = 'y' if 1 == count else 'ies'
        yield f"'{eid}' not found (saw {count} entit{ies})"  # (Case2609)
    assert isinstance(eid, str)  # #[#022]
    return 'error', 'structure', 'entity_not_found', lambda: {'reason': rsn()}


def _schema_and_entities_via_lines(fh, which_table, iden_er_er, listener):
    # Exclude any eg row. Exclude ents with empty identif. (both (Case2451))

    sch, ents = _schema_and_RAW_entities(fh, which_table, iden_er_er, listener)
    if ents is None:
        return sch, ents

    assert hasattr(ents, '__next__')

    for _ in ents:
        break

    return sch, (ent for ent in ents if ent.nonblank_identifier_primitive)


def _schema_and_RAW_entities(fh, which_table, iden_er_er, listener):
    # Include example row. Include "entities" with empty identifier
    # all this changes after thing #todo2

    dscn = _single_table_doc_scanner_via_lines(
        fh, listener, which_table, iden_er_er)

    # Advance over non-participating lines
    itr = dscn.release_leading_non_table_lines()
    for line in itr:
        pass

    cs = dscn.ok and dscn.release_complete_schema()  # (Case2437)

    if not cs:
        return None, None  # would have complained

    asts = dscn.release_business_row_ASTs()

    def entities():
        for ast in asts:
            yield ast

        if not dscn.ok:
            return  # emitted

        # Flush the trailing lines to find errors like multi-table (ambiguous)
        for line in dscn.release_trailing_non_table_lines():
            pass

    return cs, entities()


def _single_table_doc_scanner_via_lines(  # #testpoint
        fh, listener, which_table, iden_er_er):
    sxs = _sexps_via_lines(fh, iden_er_er, listener)
    mtds = _MultipleTableDocumentScanner(sxs)
    return _SingleTableDocumentScanner(listener, mtds, which_table)


_must_be_in_state = single_table_document_FFSA_.build_precondition_decorator(
        '_state_name')


class _SingleTableDocumentScanner(_Experimental_FSA_Client):

    def __init__(self, listener, mtds, which_table):
        if which_table is not None:
            xx("implement me: #table-locators")
        self._yes_match_via_CS = _build_this_table_matches_the_locator()
        self._fsa = single_table_document_FFSA_.build_FSA()
        self._listener, self._mtds, self.ok = listener, mtds, True
        self._the_CS = None

    @_catch_STD_iterator_stops  # (Case2437)
    @_must_be_in_state('before_leading_non_table_lines')
    def release_leading_non_table_lines(self):

        mtds = self._mtds
        found = None

        self._enter_lock('iterating_over_leading_non_table_lines')
        while True:  # for each next table (very similar to #here2 below)

            # Pass thru the zero or more lines before any next table
            for line in mtds.release_lines_before_next_table():
                yield line

            # If there's no more tables, you didn't find a match
            cs = mtds.release_any_next_complete_schema()
            if not cs:
                break

            # If there was one more table and it matched, you found a match
            yes = self._yes_match_via_CS(cs)
            if yes:
                found = self._the_CS = cs
                break

            # Since you hit a table that doesn't match, pass it thru as lines
            for line in _lines_via_table(cs, mtds):
                yield line
        self._exit_lock('iterating_over_leading_non_table_lines')

        # note even tho in the "before lines" func, very not convenient to etc
        if not found:  # (Case2428_020) file with no table
            self._not_OK_and_failure_lock('found_zero_tables_in_file')
            _whine_about_table_not_found(self._listener, self._build_cstack())
            return

        self._complete_schema_that_matched_on_deck = found

        self._move_to('before_complete_schema')

    @_must_be_in_state('before_complete_schema')
    def release_complete_schema(self):
        x = self._complete_schema_that_matched_on_deck
        del self._complete_schema_that_matched_on_deck
        if x is None:
            self._fsa.failure_lock('table_matching_locator_not_found')
            return
        self._move_to('before_business_ASTs')
        return x

    @_catch_STD_iterator_stops
    @_must_be_in_state('before_business_ASTs')
    def release_business_row_ASTs(self):
        with self._fsa.open_lock('iterating_over_business_rows'):
            for ast in self._mtds.release_business_row_ASTs():
                yield ast
        self._move_to('before_trailing_non_table_lines')

    @_must_be_in_state('before_trailing_non_table_lines')
    def release_trailing_non_table_lines(self):

        mtds = self._mtds

        self._enter_lock('iterating_over_trailing_non_table_lines')
        while True:  # for each remaining table (very similar to #here2 above)

            # Pass thru the zero or more lines before any next table
            for line in mtds.release_lines_before_next_table():
                yield line

            # If there's no more tables, you are done
            cs = mtds.release_any_next_complete_schema()
            if cs is None:
                break

            # If there was one more table and it matched, trouble
            yes = self._yes_match_via_CS(cs)
            if yes:  # (Case2428_040) too many tables
                self._not_OK_and_failure_lock('too_many_matching_tables')
                _whine_about_too_many_tables(self._listener, self._build_cstack())  # noqa: E501
                return

            # Since the table didn't match, pass it thru
            for line in _lines_via_table(cs, mtds):
                yield line
        self._exit_lock('iterating_over_trailing_non_table_lines')

        self._move_to('reached_end_of_output')

    def _build_cstack(self):
        return self._mtds._build_context_stack()


del _catch_STD_iterator_stops  # don't accidentally catch stops below


def _lines_via_table(cs, mtds):
    for line in cs.to_lines():
        yield line
    for ast in mtds.release_business_row_ASTs():
        yield ast.to_line()


def _build_this_table_matches_the_locator():
    # for now, a hard-coded "directive" for ignoring a table

    import re
    rx = re.compile(r'^\(ignore this table\b')

    def yes_this_table(sch):
        for line in sch.interstitial_lines:
            if '\n' == line:
                continue
            if rx.match(line):
                return False
        return True
    return yes_this_table


_MTDSFFSA = _Minimal_FSA(
    before_lines_before_table=('complete_schema_on_deck',),
    complete_schema_on_deck=(
        'reached_end_of_input_stream',
        'after_complete_schema'),
    after_complete_schema=('before_lines_before_table',),  # cycle back to top
    reached_end_of_input_stream=())


_must_be_in_state = _MTDSFFSA.build_precondition_decorator('_state_name')


class _MultipleTableDocumentScanner(_Experimental_FSA_Client):

    def __init__(self, sxs):
        typ, x = next(sxs)
        assert 'parse_context_stacker' == typ
        self._build_context_stack = x
        self._iterator = sxs
        self._fsa = _MTDSFFSA.build_FSA()
        self._non_table_line_on_deck, self.ok = None, True

    @_must_be_in_state('before_lines_before_table')
    def release_lines_before_next_table(self):
        self._enter_lock('iterating_over_lines_before_table')
        if self._non_table_line_on_deck:
            yield self._non_table_line_on_deck
            self._non_table_line_on_deck = None
        self._complete_schema_on_deck = None
        for sx in self._iterator:
            typ, x = sx
            if 'non_table_line' == typ:
                yield x
                continue
            assert 'complete_schema' == typ
            self._complete_schema_on_deck = x
            break
        self._exit_lock('iterating_over_lines_before_table')
        self._move_to('complete_schema_on_deck')

    @_must_be_in_state('complete_schema_on_deck')
    def release_any_next_complete_schema(self):
        if self._complete_schema_on_deck is None:
            self._move_to('reached_end_of_input_stream')
            return
        self._move_to('after_complete_schema')
        x = self._complete_schema_on_deck
        self._complete_schema_on_deck = None
        return x

    @_must_be_in_state('after_complete_schema')
    def release_business_row_ASTs(self):
        self._enter_lock('iterating_over_business_ASTs')
        assert self._non_table_line_on_deck is None
        for sx in self._iterator:
            typ, x = sx
            if 'business_row_AST' == typ:
                yield x
                continue
            assert 'non_table_line' == typ
            self._non_table_line_on_deck = x
            break
        self._exit_lock('iterating_over_business_ASTs')
        self._move_to('before_lines_before_table')


"""Parse any stream of lines (any file) producing these S-expressions:

    ['non_table_line', x]*
    (
       ['complete_schema', x+],
       ['business_row_AST', x+]*
       ['non_table_line', x]*
    )*

(Square brackets represent the tuples produced.)

This stream of sexp's is to be consumed by higher-level stream processors
(FSA's, probably) to parse files for single tables or mulitple tables.

Note:
  - Empty file ok
  - Files with no tables ok: just zero or more 'non_table_line' (Case2428_020)
  - Table with no business rows ok
  - Table with schema row 1 but not 2 should trigger a parse failure (see ⬇)
  - More than one table ok
  - (End after open table (Case2428_030); Table at EOF (Case2557))


Details & Discussion:

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


def _sexps_via_lines(fh, iden_er_er, listener):
    # Merged the below two FSA's at #history-B.6.B
    # Introduced new FSA to whine on multiple tables at #history-B.6.A
    # ("Action Stacks" were also sunsetted in the above commit.)
    # Rewrote as FSA not scanner-based procedural mish-mash at #history-B.5

    # == FSA States #[#008.2]

    # input tokens pattern:
    #     main = 'other'* (table 'other'*)*
    #     table = ('table_header' 'table_header_interstitial'*)?  'table_line'+

    def from_before_table():
        yield 'other', emit_non_table_line
        yield 'table_header', begin_table_given_header_and_move
        yield 'table_line', begin_table_given_first_schema_line_and_move

    def from_after_table_header():
        yield 'table_header_interstitial', add_interstitial_to_table
        yield 'table_line', handle_first_schema_line_and_move

    def from_after_first_schema_line():
        yield 'table_line', handle_second_schema_line_and_emit_and_move

    def from_after_second_schema_line():
        yield 'table_line', emit_business_row
        yield 'other', emit_other_line_and_reset_to_first_state
        yield 'table_header', begin_table_given_header_and_move

    # == FSA Actions

    # (Even though headers & interstitials are associatd with a table, they as
    # as sexp items are passed through as regular lines :#here3 (Case2428_050))

    def begin_table_given_header_and_move():
        yield 'emit_this', ('non_table_line', current_line)  # #here3
        yield 'begin_table', {'table_header_line': current_line}
        yield 'move_to_state', from_after_table_header

    def add_interstitial_to_table():
        yield 'emit_this', ('non_table_line', current_line)  # #here3
        schema_args['interstitial_lines'].append(current_line)
        return ()

    def begin_table_given_first_schema_line_and_move():
        yield 'begin_table', {}
        for direc in handle_first_schema_line_and_move():
            yield direc

    def handle_first_schema_line_and_move():
        ast = schema_row_AST_via_line(current_line, current_line_number)
        if not ast.has_endcap:
            stop_because('header row 1 must have "endcap" (trailing pipe)')
        schema_args['ast1'] = ast
        yield 'move_to_state', from_after_first_schema_line

    def handle_second_schema_line_and_emit_and_move():
        ast1 = schema_args['ast1']
        ast2 = schema_row_AST_via_line(current_line, current_line_number)

        if ast1.cell_count != ast2.cell_count:
            stop_because("column counts didn't line up between schema row line 1 & 2")  # noqa: E501

        if ast1.has_endcap != ast2.has_endcap:
            pass  # endcap on one but not the other is okay (Case2557)

        cs = complete_schema_via_(ast2=ast2, **schema_args)
        schema_args.clear()  # #here1

        def func(line, lineno):
            ast = upstream_func(line, lineno)
            if formal_cell_count < ast.cell_count:  # #here4
                stop_because(_line_about_cell_count_delta(
                    ast.cell_count, formal_cell_count))
            return ast
        upstream_func = _build_row_AST_via_line(listener, cs)  # raises _Stop
        formal_cell_count = ast1.cell_count
        emit_business_row.busi_row_via = func

        yield 'emit_this', ('complete_schema', cs)
        yield 'move_to_state', from_after_second_schema_line

    def emit_business_row():
        ast = emit_business_row.busi_row_via(current_line, current_line_number)
        yield 'emit_this', ('business_row_AST', ast)

    def emit_other_line_and_reset_to_first_state():
        for direc in emit_non_table_line():
            yield direc
        yield 'move_to_state', from_before_table

    def emit_non_table_line():
        yield 'emit_this', ('non_table_line', current_line)

    # ==

    def find_action():
        for line_tag, action_func in current_state_function():
            if current_line_tag == line_tag:
                return action_func
        from_where = current_state_function.__name__.replace('_', ' ')
        xx(f"grammar sanity: {from_where}, we didn't know it was possible "
           f"to get a '{line_tag}' line")

    def stop_because(reason):
        sct = _flatten_context_stack((*build_cstack(), {'reason': reason}))
        listener('error', 'structure', 'stop', lambda: sct)
        raise _Stop()

    def build_cstack():
        return ({x: y for x, y in cstack_components()},)

    yield 'parse_context_stacker', build_cstack  # experimental

    def cstack_components():
        yield 'line', current_line
        yield 'lineno', current_line_number
        yield 'path', _path_via_lines(fh)

    if iden_er_er:
        tlist = build_throwing_listener_(listener, _Stop)
        iden_er = iden_er_er(tlist, build_cstack)
    else:
        iden_er = None

    schema_row_AST_via_line = _build_row_AST_via_line(listener)  # raises _Stop

    current_state_function = from_before_table
    schema_args = {}  # #here1

    current_line, current_line_number = None, 0
    tagged_lines = _tagged_lines_via_lines(fh)
    for current_line_tag, current_line in tagged_lines:
        current_line_number += 1
        act_func = find_action()
        for directive_type, directive_arg in act_func():
            if 'emit_this' == directive_type:
                yield directive_arg
            elif 'move_to_state' == directive_type:
                current_state_function = directive_arg
            else:
                assert 'begin_table' == directive_type
                assert 0 == len(schema_args)  # #here1

                # As of now, if the table has a markdown header line above it,
                # that line is considered the start line of the table

                schema_args['interstitial_lines'] = []
                schema_args['iden_er'] = iden_er  # if any
                schema_args['table_cstack'] = build_cstack()

                for k, v in directive_arg.items():
                    assert k not in schema_args
                    schema_args[k] = v


# == Pseudo-Models

def schema_row_builder_():
    return _build_row_AST_via_sexps()


def _build_row_AST_via_sexps(schema=None):

    def row_AST_via_sexps(mutable_sexps, line, lineno):

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
        return row_AST_via_sexps

    use_identifier_class = schema.identifier_class_  # #here5 = [#857.C]
    key_via_offset = schema.field_name_keys
    identifier_key = key_via_offset[0]  # #provision: [#871.1]
    offset_via_key = schema.offset_via_key_
    identifier_offset = offset_via_key[identifier_key]

    i = key_via_offset.index(identifier_key)
    non_identifier_attr_keys = (*key_via_offset[:i], *key_via_offset[i+1:])

    return row_AST_via_sexps


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


def complete_schema_via_(
        ast1, ast2, table_header_line=None, interstitial_lines=(),
        iden_er=None, table_cstack=None):

    def key_via_cell(cell):
        s = normal_field_name_via_string(cell.value_string)
        if not len(s):
            xx(f'Failed to derive normal field name from label: {s!r}')
        return s
    from kiss_rdb import normal_field_name_via_string

    max_cell_count = ast1.cell_count
    rang = range(0, max_cell_count)
    keys = tuple(key_via_cell(ast1.cell_at_offset(i)) for i in rang)
    offset_via_key = {keys[i]: i for i in rang}
    assert max_cell_count == len(offset_via_key)  # else name collision

    cs = _CompleteSchema(
            table_header_line=table_header_line,
            interstitial_lines=tuple(interstitial_lines),
            offset_via_key_=offset_via_key,
            field_name_keys=keys,  # (Case3459DP)
            rows_=(ast1, ast2),
            identifier_class_=(iden_er or _identifier),  # #here5
            table_cstack_=table_cstack)

    cs.row_AST_via_sexps_ = _build_row_AST_via_sexps(cs)
    return cs


@_dataclass
class _CompleteSchema:
    table_header_line: str
    interstitial_lines: tuple[str]
    offset_via_key_: callable
    field_name_keys: tuple
    rows_: tuple
    identifier_class_: object
    table_cstack_: tuple
    row_AST_via_sexps_: callable = None

    def to_lines(self):
        ast1, ast2 = self.rows_
        yield ast1.to_line()
        yield ast2.to_line()


# == Parse a Table Row

def _build_row_AST_via_line(listener, schema=None):  # raises _Stop
    # #testpoint (for unit testing parsing row lines)

    def row_AST_via_line(line, lineno):
        scn = line_scanner_via_line(line)
        sx = list(sexps_via_line_scanner(scn))
        return row_AST_via_sexps(sx, line, lineno)

    if schema:
        row_AST_via_sexps = schema.row_AST_via_sexps_
    else:
        row_AST_via_sexps = _build_row_AST_via_sexps()

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


# == Produce a Stream of Tagged Lines

def _tagged_lines_via_lines(lines):
    # Cannot fail (given zero or more newline-terminated lines) (Might mis-tag)
    # #testpoint: exposed for visual testing in neighbor "__main__".

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


# == Whiners

def _whine_about_too_many_tables(listener, cstack):
    sct = _flatten_context_stack(cstack)
    sct['reason'] = 'for now can only have one table'
    listener('error', 'structure', 'multiple_tables', lambda: sct)


def _whine_about_table_not_found(listener, cstack):
    sct = _flatten_context_stack(cstack)
    sct['reason'] = f"no markdown table found in {sct['lineno']} lines"
    listener('error', 'structure', 'cannot_load_collection', lambda: sct)


def _line_about_cell_count_delta(actual_count, formal_count):
    more_or_less = 'more' if formal_count < actual_count else 'less'
    return f'row cannot have {more_or_less} cels than the schema row has. ' \
           f'(had {actual_count}, needed {formal_count}.)'


# == Expression Support

def _str_via_iden(iden):
    if hasattr(iden, 'to_string'):
        return iden.to_string()
    assert isinstance(iden, str)  # ..
    return iden


# == Smalls

def _path_via_lines(fh):
    if hasattr(fh, 'name'):
        return fh.name
    assert hasattr(fh, '__next__')
    return "«line generator, not path»"


def _flatten_context_stack(context_stack):  # #[#510.14]
    return {k: v for row in context_stack for k, v in row.items()}


def _scnlib():
    from text_lib.magnetics import scanner_via as module
    return module


def xx(msg=None):
    raise RuntimeError('ohai' + ('' if msg is None else f": {msg}"))


# #history-B.6.B document scanners not sexp iterators and procedural mish-mash
# #history-B.6.A
# #history-B.5
# #history-B.4
# #history-B.1: blind rewrite. absorb four modules
# #history-A.4: no more format adapter
# #history-A.3: no more sync-side entity mapping
# #history-A.2
# #history-A.1: markdown table as producer
# #born.
