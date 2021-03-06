from dataclasses import dataclass as _dataclass


# == BEGIN via dotfile

def abstract_schema_via_graph_via_lines(graph_viz_schema_lines, listener):
    tlistener = _build_throwing_listener(listener, _Stop)
    try:
        atables = _main(graph_viz_schema_lines, tlistener)
        return abstract_schema_via_abstract_tables(atables)
    except _Stop:
        pass


def _main(graph_viz_schema_lines, tlistener):

    # Flush the whole definition now to get all the forward references
    offsets_of_edge_expressions = []
    offset_via_node_name = _StrictDict()
    all_elements = []
    for sx in _each_element(graph_viz_schema_lines, tlistener):
        exp_offset = len(all_elements)
        all_elements.append(sx)
        typ = sx[0]
        if 'my_edge_def' == typ:
            offsets_of_edge_expressions.append(exp_offset)
            continue
        assert 'my_table_def' == typ
        mtd = sx[-1]
        offset_via_node_name[mtd.AST.node_identifier] = exp_offset

    # Mutate the table's column definitions so they know about foreign keys
    _do_foreign_keys(all_elements, offset_via_node_name,
                     offsets_of_edge_expressions, tlistener)

    # Now each table definition is ready
    for mtd in (all_elements[i][1] for i in offset_via_node_name.values()):
        abs_cols = (_abstract_column_via_my_column(o) for o in mtd.my_cols)
        yield abstract_table_via_name_and_abstract_columns(
            mtd.table_name, abs_cols, tlistener)


def _abstract_column_via_my_column(mcd):
    is_fk = (mcd.is_foreign_key_ref or None)
    return abstract_column_via(
        column_name=mcd.col_name,
        column_type_storage_class=mcd.col_abs_typ,
        is_foreign_key_reference=(is_fk or False),
        referenced_table_name=(is_fk and mcd.parent_table_name),
        referenced_column_name=(is_fk and mcd.parent_column_name),
        is_primary_key=mcd.is_prim,
        null_is_OK=mcd.null_OK,
        is_unique=mcd.is_uniq)


def _do_foreign_keys(all_elements, offset_via_node_name,
                     offsets_of_edge_expressions, tlistener):

    """The forward references are all in the edges. For now, assert all of:

    - Each edge must be mono-directional
    - Each edge must point right
    - Each edge must be of type 'odot' or be not specified (this is WIP)
    - The left side of each edge must be <parent_table>:<its_primary_key>
      (so assert that it is in fact the primary key of that table)
    - The right side of each edge indicates the foreign key (table:field)
      (sqlite calls it a "child key") that needs the constraint. As long as
      we can, we're gonna assert that etc, we KISS. One day maybe we won't
    - Keep in mind we say "table" but in the graph it's "node identifier"
      and we have to map those from one to the other eventually
    """

    def dereference_table(node_iden):
        i = offset_via_node_name[node_iden]  # ..
        sx = all_elements[i]
        assert 'my_table_def' == sx[0]
        ret, = sx[1:]
        return ret

    for i in offsets_of_edge_expressions:
        sx = all_elements[i]
        typ = sx[0]
        assert 'my_edge_def' == typ
        ast, = sx[1:]
        typ, L_iden, L_port, R_iden, R_port, attrs, lineno = ast

        assert 'edge_expression' == typ

        my_left_table = dereference_table(L_iden)
        my_right_table = dereference_table(R_iden)

        left_col = my_left_table.my_column_via_port(L_port, tlistener)
        right_col = my_right_table.my_column_via_port(R_port, tlistener)

        # Oh boy: if it looks like this: "-𐩑" the right side is the
        # child table and the left side is the parent table, and
        # if it looks like this "→" it's the opposite

        shape = attrs.get('arrowhead')
        if shape:
            assert 'odot' == shape
            remote_table = my_left_table
            remote_col, local_col = left_col, right_col
        else:
            remote_table = my_right_table
            local_col, remote_col = left_col, right_col

        remote_table_name = remote_table.table_name

        if not remote_col.is_prim:
            s = ast.to_string()
            xx(f"remote key {remote_col.col_name!r} must be primary key: {s!r}")  # noqa: E501

        # While we have all this stuff out, eliminate the unnecessary
        # column name when it is unnecessary

        if local_col.col_name == remote_col.col_name:
            use_remote_col_name = None
        else:
            use_remote_col_name = remote_col.col_name

        local_col.recv_is_foreign_key(remote_table_name, use_remote_col_name)


def _each_element(graph_viz_schema_lines, tlistener):
    path = getattr(graph_viz_schema_lines, 'name', None)
    parse_element = _build_element_parser(tlistener, path=path)
    from kiss_rdb.storage_adapters.graph_viz.AST_via_lines import \
        sexps_via_lines as func
    for ast in func(graph_viz_schema_lines, tlistener):
        yield parse_element(ast)


def _build_element_parser(tlistener, path=None):

    def parse_element(ast):
        typ = ast[0]
        if 'node_expression' == typ:
            return parse_node(ast)
        assert 'edge_expression' == typ
        return 'my_edge_def', ast  # it's fine as-is as a forward def

    def parse_node(ast):

        label = ast.attributes['label']
        cstacker = cstacker_via_AST(ast)
        scn = StringScanner(label, tlistener, cstacker)
        table_name = scn.scan_required(identifier)
        scn.skip_required(pipe_and_newline)
        cstacker.plus += 1

        my_cols = []
        while True:
            my_col = parse_column_definition(scn)
            cstacker.plus += 1
            my_cols.append(my_col)
            if scn.empty:
                break
        return 'my_table_def', _MyTableDef(table_name, my_cols, ast)

    def parse_column_definition(scn):

        # Parse any port name
        port_name = None
        if scn.skip(less_than):
            port_name = scn.scan_required(identifier)
            scn.skip_required(greater_than)
            scn.skip_required(space)

        # Parse the column name and type (very strict for now)
        col_name = scn.scan_required(identifier)
        scn.skip_required(space)
        col_abs_typ = scn.scan_required(abstract_types)

        # Constraints
        kw = {'is_prim': False, 'null_OK': False, 'is_uniq': False}
        pool = {'is_prim': primary, 'is_uniq': unique, 'null_OK': null_ok}  # o

        def find_first_one():
            for k, v in pool.items():
                yn = scn.scan(v)
                if yn:
                    return k

        while pool:
            # Do you match any constraint in the pool from this point?
            k = find_first_one()

            # If you matched no constraints, forget the pool, you're done
            if k is None:
                break

            # (special handling for this one that's a two-token sequence meh)
            if 'is_prim' == k:
                scn.skip_required(key_token)

            # While every attribute is false by default this is easier
            assert kw[k] is False
            kw[k] = True

            # Keep looking for more constraints as long as you have unused ones
            pool.pop(k)

        w = scn.skip(end_of_column_def)
        if w is None:
            oh_boy = (primary, unique, null_ok, end_of_column_def)
            scn.whine_about_expecting(*oh_boy)

        return _MyColDef(port_name, col_name, col_abs_typ, **kw)

    def cstacker_via_AST(ast):
        def cstacker():
            dct = {}
            dct['lineno'] = (ast.lineno + cstacker.plus)
            if path:
                dct['path'] = path
            return (dct,)
        cstacker.plus = 0
        return cstacker

    from text_lib.magnetics.string_scanner_via_string import \
        StringScanner, pattern_via_description_and_regex_string as o

    # ==

    # Port
    less_than = o('less_than than', '<')
    greater_than = o('greater than', '>')

    # (The below follow the order of here just because:)
    # https://www.sqlite.org/lang_createtable.html

    # Type
    abstract_types = o("'int' or 'text'", '(?:int|text)')

    # Primary or "null OK" or Unique
    primary = o('primary', r'[ ]primary\b')
    null_ok = o('null_ok', r'[ ]null_ok\b')
    unique = o('unique', r'[ ]unique\b')
    key_token = o('key', r'[ ]key\b')

    # Common
    identifier = o(
        'identifier',
        '[a-zA-Z][a-zA-Z0-9]*(?:_[a-zA-Z][a-zA-Z0-9]*)*')
    space = o('space', '[ ]')
    pipe_and_newline = o('pipe and newline', r'\|\n')  # redundant w/ next
    end_of_column_def = o('pipe and newline or end of string', r'(?:\|\n|$)')

    # ==

    return parse_element


@_dataclass
class _MyTableDef:
    table_name: str
    my_cols: tuple
    AST: object

    def my_column_via_port(self, port, tlistener):
        for my_col in self.my_cols:
            if port == my_col.port_name:
                return my_col
        _ = ', '.join(s for s in (mc.port_name for mc in self.my_cols) if s)
        xx(f'port {port!r} not found. had ({_})')


@_dataclass
class _MyColDef:
    port_name: str
    col_name: str
    col_abs_typ: str
    is_foreign_key_ref: bool = False
    is_prim: bool = False
    null_OK: bool = False
    is_uniq: bool = False

    def recv_is_foreign_key(self, parent_table_name, parent_col_name=None):
        assert not self.is_foreign_key_ref
        self.is_foreign_key_ref = True
        self.parent_table_name = parent_table_name
        self.parent_column_name = parent_col_name


# == Schema diff

def _schema_diff(left_tables, right_tables):

    left_keys = set(left_tables.keys())
    right_keys = set(right_tables.keys())

    in_both = left_keys & right_keys
    left_only = left_keys - in_both
    right_only = right_keys - in_both

    # Middle
    dct = {}
    for k in sorted(in_both):
        tdiff = _table_diff(k, left_tables[k], right_tables[k])
        if tdiff:
            dct[k] = tdiff
    if not dct:
        dct = None

    left_dict = right_dict = None
    if left_only:
        left_dict = {k: left_tables[k] for k in sorted(left_only)}

    if right_only:
        right_dict = {k: right_tables[k] for k in sorted(right_only)}

    if not any((left_dict, dct, right_dict)):
        return

    return _SchemaDiff(left_dict, dct, right_dict)


@_dataclass
class _SchemaDiff:
    tables_in_left_not_in_right: dict
    table_diffs: dict
    tables_in_right_not_in_left: dict

    def to_description_lines(self):
        yield "Schema diff:\n"
        left = self.tables_in_left_not_in_right
        mid = self.table_diffs
        right = self.tables_in_right_not_in_left
        if not any((left, mid, right)):
            yield "  no difference in the two schemas\n"
            return

        def same(dct, line_head):
            if not dct:
                return
            _ = ', '.join(repr(s) for s in dct.keys())
            line_tail = ''.join(('(', _, ')\n'))
            yield ''.join((line_head, line_tail))

        for line in same(left, '  Tables in left not right:'):
            yield line

        for line in same(right, '  Tables in right not left:'):
            yield line

        if not mid:
            return

        for tdiff in mid.values():
            for line in tdiff.to_description_lines():
                yield ''.join(('  ', line))


# == Whole Schema

def abstract_schema_via_abstract_tables(tables):
    dct = {}
    for t in tables:
        k = t.table_name
        if k in dct:
            xx(f"collision: multiple tables with the name {k!r}")
        dct[k] = t
    return _AbstractSchema(dct)


class _AbstractSchema:
    def __init__(self, dct):
        self._tables = dct

    def to_description_lines(self):
        for table in self.to_tables():
            for line in table.to_description_lines():
                yield line

    def to_tables(self):
        return self._tables.values()

    def schema_diff_to(self, otr):
        return _schema_diff(self._tables, otr._tables)


# == Table

def _table_diff(table_name, left, right):
    left_cols, right_cols = (getattr(o, '_columns') for o in (left, right))
    left_keys = set(left_cols.keys())
    right_keys = set(right_cols.keys())
    in_both = left_keys & right_keys
    left_only = left_keys - in_both
    right_only = right_keys - in_both

    dct = None
    for k in sorted(in_both):
        col_diff = _column_diff(left_cols[k], right_cols[k])
        if col_diff is None:
            continue
        if dct is None:
            dct = {}
        dct[k] = col_diff

    left_dict = right_dict = None
    if left_only:
        left_dict = {k: left_cols[k] for k in sorted(left_only)}

    if right_only:
        right_dict = {k: right_cols[k] for k in sorted(right_only)}

    if not any((left_dict, dct, right_dict)):
        return

    return _TableDiff(table_name, left_dict, dct, right_dict)


@_dataclass
class _TableDiff:
    table_name: str
    columns_in_left_table_not_in_right: dict
    column_diffs: dict
    columns_in_right_table_not_in_left: dict

    def to_description_lines(self):
        # (lines via words but scan for a newline piece)

        def flush():
            ret = ''.join(piece_cache)
            piece_cache.clear()
            return ret
        piece_cache = []
        for w in (s for row in self._to_desc_rows() for s in row):
            if '\n' == w:
                piece_cache.append(w)
                yield flush()
                continue
            if len(piece_cache):
                piece_cache.append(' ')
            piece_cache.append(w)
        if piece_cache:
            piece_cache.append('\n')
            yield flush()

    def _to_desc_rows(self):
        left = self.columns_in_left_table_not_in_right
        mid = self.column_diffs
        right = self.columns_in_right_table_not_in_left
        moniker = repr(self.table_name)
        if not any((left, mid, right)):
            yield 'table', moniker, 'is up to date'
            return

        def introduce_or_reintroduce_table():
            o = introduce_or_reintroduce_table
            if o.seen:
                return 'The', 'table'
            o.seen = True
            return 'Table', moniker

        introduce_or_reintroduce_table.seen = False

        if right:
            yield introduce_or_reintroduce_table()
            o = _columns_inflector(right)
            yield 'is missing', o.this_these(), ''.join((o.s('column'), ':'))
            yield _add_period_and_newline(o.splay())

        if left:
            yield introduce_or_reintroduce_table()
            o = _columns_inflector(left)
            yield 'has', o.this_these(), 'unexpected', ''.join((o.s('column'), ':'))  # noqa: E501
            yield _add_period_and_newline(o.splay())

        if mid:
            yield introduce_or_reintroduce_table()
            yield ('is out of sync',)
            o = _columns_inflector(mid)
            if 1 == len(mid):
                yield 'in the', repr(tuple(mid.keys())[0]), 'column:', '\n'
            else:
                yield 'in the following columns:', '\n'
            for col_diff in mid.values():
                for row in col_diff.to_word_and_newline_rows():
                    yield row


class _columns_inflector:
    def __init__(self, dct):
        self._keys = tuple(dct.keys())
        self._leng = len(self._keys)

    def this_these(self):
        return 'this' if 1 == self._leng else 'these'

    def s(self, noun_stem):
        return noun_stem if 1 == self._leng else ''.join((noun_stem, 's'))

    def splay(self):
        s = ', '.join(repr(s) for s in self._keys)
        if 1 != self._leng:
            s = ''.join(('(', s, ')'))
        return [s]  # #here1


def _add_period_and_newline(words):
    words[-1] = ''.join((words[-1], '.'))  # #here1
    words.append('\n')
    return words


def abstract_table_via_name_and_abstract_columns(name, cols, listener):
    pkfn, fks, dct = None, [], {}
    for col in cols:
        k = col.column_name
        if k in dct:
            xx(f"collision: multiple columns with the name {k!r}")
        if col.is_primary_key:
            if pkfn is not None:
                xx(f"Can't have >1 PK ({pkfn!r} then {k!r})")
            pkfn = k
        if col.is_foreign_key_reference:
            fks.append(k)
        dct[k] = col

    return _AbstractTable(name, pkfn, dct, fks)


class _AbstractTable:

    def __init__(self, name, pkfn, dct, fks):
        self.table_name = name
        self._primary_key_field_name = pkfn
        self._columns = dct
        self._FOREIGN_KEYS = tuple(fks) if fks else None

    def to_description_lines(self):
        yield f"Abstract table: {self.table_name!r}\n"
        for col in self._columns.values():
            for line in col.to_description_lines():
                yield line

    def to_columns(self):
        return self._columns.values()


# == Column

def _column_diff(left, right):
    itr = _do_column_diff(left, right)
    for k, v in itr:  # once
        dct = {k: v}
        dct.update({k: v for k, v in itr})
        return _ColumnDiff(left.column_name, dct)


def _do_column_diff(left, right):
    for k in _AbstractColumn._fields:
        lval = getattr(left, k)
        rval = getattr(right, k)
        if lval != rval:  # (have fun on booleans)
            yield k, (lval, rval)


class _ColumnDiff:

    def __init__(self, s, dct):
        self._column_name = s
        self._dict = dct

    def to_word_and_newline_rows(self):  # sorry
        dct = self._dict
        moniker = repr(self._column_name)
        if 0 == len(dct):
            yield 'column', moniker, 'is in sync.', '\n'  # probably never
            return

        yield 'For column', ''.join((moniker, ','))
        rows = []
        for k, (left, right) in self._dict.items():

            # Any time you have 2 rows cached, flush the oldest row plus comma
            if 2 == len(rows):
                output, move = rows
                output[-1] = ''.join((output[-1], ','))
                rows.pop()
                rows[0] = move
                yield output
            body = [repr(k), 'is', repr(left), 'but should be', repr(right)]
            rows.append(body)

        # If you have two rows cached by the end, you want 'and'
        if 2 == len(rows):
            penult, final = rows
            penult.append('and')
            yield penult
        else:
            final, = rows

        # The final item (guaranteed) gets a period
        final[-1] = ''.join((final[-1], '.'))
        final.append('\n')
        yield final


def abstract_column_via(
        column_name, column_type_storage_class, listener=None, **kw):

    if column_type_storage_class not in _abstract_types:
        xx(f"keeping this painfully minimal for now. bad type: {column_type_storage_class!r}")   # noqa: E501
    return _AbstractColumn(column_name, column_type_storage_class, **kw)


@_dataclass
class _AbstractColumn:
    column_name: str
    column_type_storage_class: str
    is_primary_key: bool = False  # mutex with `is_unique` per #here2
    null_is_OK: bool = False  # API provis: NOT NULL is default at #history-B.4
    is_unique: bool = False  # mutex with `is_primary_key` per #here2
    is_foreign_key_reference: bool = False
    referenced_table_name: str = None
    referenced_column_name: str = None

    def to_description_lines(self):
        mm = '  '
        ch_m = '    '
        typ = self.column_type_storage_class
        yield f"{mm}Abstract column: {self.column_name!r} {typ}\n"
        if self.null_is_OK:
            yield f"{ch_m}NULL is OK\n"
        if self.is_primary_key:
            yield f"{ch_m}Is primary key\n"
        elif self.is_unique:
            yield f"{ch_m}Is unique\n"
        if not self.is_foreign_key_reference:
            return
        pcs = [self.referenced_table_name]
        if self.referenced_column_name:
            pcs.append(''.join(('(', self.referenced_column_name, ')')))
        yield f"{ch_m}Foreign key: {' '.join(pcs)!r}\n"

    _fields = (
        'column_type_storage_class', 'null_is_OK',
        'is_foreign_key_reference',
        'is_primary_key', 'is_unique',  # mutex
        'referenced_table_name', 'referenced_column_name')


_abstract_types = {k: None for k in 'int text'.split()}


def _build_throwing_listener(listener, stop):
    def tlistener(sev, *rest):
        listener(sev, *rest)
        if 'error' == sev:
            raise stop()
    return tlistener


class _StrictDict(dict):
    def __setitem__(self, k, v):
        assert k not in self
        return super().__setitem__(k, v)


class _Stop(RuntimeError):
    pass


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #history-B.5
# #history-B.4 spike "via graph viz lines"
# #born
