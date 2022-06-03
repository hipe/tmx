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
        type_macro=mcd.col_abs_typ,
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


# == via dataclass

def abstract_entity_via_dataclass(dataclass):
    def each_column():
        for fie in dc.fields(dataclass):  # fie = field
            yield func(fie)
    _ = _functions_for_abstract_attribute_via_dataclass_field()
    func = _['abstract_attribute_via_dataclass_field']
    import dataclasses as dc
    return abstract_table_via_name_and_abstract_columns(
            dataclass.__name__, each_column(), listener=None)


def _functions_for_abstract_attribute_via_dataclass_field():
    memo = _functions_for_abstract_attribute_via_dataclass_field
    if not memo.value:
        memo.value = \
            _define_functions_for_abstract_attribute_via_dataclass_field()
    return memo.value


_functions_for_abstract_attribute_via_dataclass_field.value = None


def _define_functions_for_abstract_attribute_via_dataclass_field():
    export = _build_exporter()

    @export
    def abstract_attribute_via_dataclass_field(fie):
        kwargs = {k:v for k, v in kwargs_via_dataclass_field(fie)}
        col_name = kwargs.pop('column_name')
        return abstract_column_via(col_name, **kwargs)

    def kwargs_via_dataclass_field(fie):
        # The property name would make a fine field name (probably)
        yield 'column_name', fie.name

        # Requiredness is determined by the presence of default
        # (if it has a default [factory], null is OK (hrm))
        if none == fie.default:
            if none == fie.default_factory:
                yield 'null_is_OK', False
            else:
                yield 'null_is_OK', True
        else:
            yield 'null_is_OK', True

        # Convert the parametized type to a type macro
        yield 'type_macro', type_macro_argument_via_python_type(fie.type)

    def type_macro_argument_via_python_type(typ):
        if isinstance(typ, type):
            s = type_macro_string_via_primitive_type.get(typ)
            if s:
                return s  # Let the TM factory turn this into a cached object

            if isinstance(typ, python_GenericAlias):
                return type_macro_.NEW_FUN_EXPERIMENT_via_GA_(typ)

            xx(f"Fun! first time seeing this type in an annotation: {typ!r}")
        xx(f"For now, expecting type in annotation to be of type `type`: {typ!r}")

    type_macro_string_via_primitive_type = {
        str: 'text',
        tuple: 'tuple',
        int: 'int',
    }

    from dataclasses import MISSING as none
    from types import GenericAlias as python_GenericAlias
    import re
    return export.dictionary


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

    def to_sexp_lines(self):
        yield '("abstract_schema" ("properties")\n'
        for table in self.to_tables():
            for line in table.to_sexp_lines('  ', '  '):
                yield line
        yield ')\n'

    def __getitem__(self, k):
        return self._tables[k]

    def to_tables(self):
        return self._tables.values()

    def TO_FORMAL_ENTITY_KEYS(self):
        return self._tables.keys()

    to_formal_entities = to_tables  # experimenting with namechange

    def schema_diff_to(self, otr):
        return _schema_diff(self._tables, otr._tables)


abstract_schema_via_dictionary = _AbstractSchema


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
        self.primary_key_field_name = pkfn
        self._columns = dct
        self.foreign_keys = tuple(fks) if fks else None

    def to_description_lines(self):
        yield f"Abstract table: {self.table_name!r}\n"
        for col in self._columns.values():
            for line in col.to_description_lines():
                yield line

    def to_sexp_lines(self, margin='', indent_for_children='  '):
        tn = self.table_name
        assert '"' not in tn  # can't use repr, need double-quotes
        yield f'{margin}("abstract_entity" "{tn}"\n'
        ch_margin = f"{margin}{indent_for_children}"
        for abs_attr in self.to_columns():
            for line in abs_attr.to_sexp_lines(ch_margin, indent_for_children):
                yield line
        yield f'{margin})\n'

    def __getitem__(self, k):
        return self._columns[k]

    def TO_ATTRIBUTE_KEYS(self):
        return self._columns.keys()

    def to_columns(self):
        return self._columns.values()

    to_formal_attributes = to_columns


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


def abstract_column_via(column_name, type_macro='text', listener=None, **kw):
    if isinstance(type_macro, str):
        type_macro = type_macro_(type_macro, listener)
    if type_macro is None:
        return
    return _AbstractColumn(column_name, type_macro, **kw)


@_dataclass
class _AbstractColumn:
    column_name: str
    type_macro: object
    IDENTIFIER_FUNCTION: callable = None
    is_primary_key: bool = False  # mutex with `is_unique` per #here2
    null_is_OK: bool = False  # API provis: NOT NULL is default at #history-B.4
    is_unique: bool = False  # mutex with `is_primary_key` per #here2
    is_foreign_key_reference: bool = False
    referenced_table_name: str = None
    referenced_column_name: str = None

    def to_description_lines(self):
        mm = '  '
        ch_m = '    '
        typ = self.type_macro_string
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

    def to_sexp_lines(self, margin, indent_for_children):
        from kiss_rdb.magnetics_.abstract_schema_via_sexp import \
                pretty_print_sexp_ as func
        return func(self._to_sexp_pieces(), indent_for_children, margin)

    def _to_sexp_pieces(self):
        yield 'abstract_attribute'
        yield self.column_name
        yield self.type_macro.string
        if self.null_is_OK:
            yield 'optional'
        if self.is_primary_key:
            yield 'key'
        elif self.is_unique:
            yield 'unique'
        if self.is_foreign_key_reference:
            yield tuple(self._foreign_key_sexp_pieces())

    def _foreign_key_sexp_pieces(self):
        yield 'foreign_key'
        yield self.referenced_table_name
        if self.referenced_column_name:
            xx("can we please deprecate foreign key column name (see..)?")
            # recutils seems fine without them

    def IDENTIFIER_FOR_PURPOSE(self, tup):
        if (f := self.IDENTIFIER_FUNCTION):
            return f(tup)
        first = tup[0]
        if 'key' == first:
            return self.column_name
        if 'label' == first:
            return self.column_name.replace('_', ' ')
        xx(repr(first))

    @property
    def type_macro_string(self):
        return self.type_macro.string

    _fields = (
        'type_macro_string', 'null_is_OK',
        'is_foreign_key_reference',
        'is_primary_key', 'is_unique',  # mutex
        'referenced_table_name', 'referenced_column_name')

FormalAttribute_ = _AbstractColumn


"""Type Macros

A "type macro" expression is typically as simple as a string, like "paragraph".
The idea is that behind such a short expression of type, we may draw from an
agreed-upon set of "opinionated" associations: In this example, "paragraph" is
one node in our "static, universal taxonomy", a "standard, abstract typology
lexicon" that essentially associates a bunch of words together into a
straightforward hierarchy. In this hierarchy, "paragraph" is a child node
of "text". (It is in this sense that we consider it a "macro" because it starts
as a simple word but "expands" into this richer structure through its
implications.)

Knowing where this node fits within a hierarchy allows different "operational
contexts" to zoom-in or zoom-out to whatever level of detail is appropriate
for their on "typology" systems:

Different operational contexts can make different inferences from this
expression of type: For example, a sqlite3 database would be able to know that
expression of type "paragraph" (as a type macro) is a `kind_of("text")` and
so it would know that it can use its own storage class "TEXT" to store a
paragraph.

Elsewhere, a validation/normalization layer might know that it can assume
the constraints for a paragraph is that it be a tuple of lines that is
maximum 24 lines long and each line maximum 80 characters wide; or perhaps
it limits the whole paragraph to 1920 characters; etc. For the known type macro
"int", validation/normalization layers can make the unsurprising validations/
normalizations there.

Internally, every type macro for a "known type" will have as its only member
data a tuple of strings, where the tuple is ordered from general to specific
as a path on the taxonomy, for example `('text', 'paragraph')` or `('int',)`.
Because every known type will always expand into the same `ancestor_strings`
(and the object is immutable), we cache these type macros lazily.

Beyond just this "specification" above, we are now experimenting with type
macros that can ~ leverage ~ the ~ power ~ of type annoations in python.
:#[#872.H]
"""

def _define_type_macro_function():

    def type_macro_via_generic_alias(ga):  # ga = GA = types.GenericAlias
        from typing import get_origin, get_args
        GA_origin = get_origin(ga)
        GA_args = get_args(ga)
        if GA_origin is not tuple:
            xx("proceding cautiously for now. Not tuple? {GA_origin!r}")
        ancestor_strings = 'tuple', str(ga)  # always tuple for now
        return _TypeMacro(ancestor_strings, (GA_origin, GA_args))

    def type_macro_via_string(type_macro_string, listener=None):
        if (o := cache.get(type_macro_string, None)):
            return o

        type_strings = [type_macro_string]
        current_type = type_macro_string
        while True:
            next_type = parent_of.get(current_type, False)
            if next_type is False:
                when_bad_type(listener, current_type)
                return
            if next_type is None:
                break
            type_strings.append(next_type)
            current_type = next_type

        o = _TypeMacro(tuple(reversed(type_strings)))
        cache[type_macro_string] = o
        return o
    cache = {}

    parent_of = {}
    parent_of['tuple'] = None
    parent_of['paragraph'] = 'text'
    parent_of['line'] = 'text'
    parent_of['text'] = None
    parent_of['int'] = None

    class _TypeMacro:
        def __init__(self, ancestors, GA_components=None):
            assert isinstance(ancestors, tuple)
            if GA_components:
                self.generic_alias_origin_, self.generic_alias_args_ = GA_components
            else:
                self.generic_alias_origin_ = None
            self._ancestors = ancestors

        def kind_of(self, type_string):
            yes = type_string in self._ancestors
            if yes:
                return yes
            if type_string in parent_of:
                return False
            xx(f"oops: not a type in the type macro tree: {type_string!r}")

        def __eq__(self, otr):
            assert isinstance(otr, self.__class__)
            return self._ancestors == otr._ancestors

        @property
        def string(self):
            return self._ancestors[-1]

    def when_bad_type(listener, bad_type):
        def lines():
            yield f"Unrecognized abstract type {bad_type!r}"
            yield f"Available: ({', '.join(parent_of.keys())})"
        if listener:
            listener('error', 'expression', 'bad_type', lines)
        else:
            raise RuntimeError(next(lines()))

        def all_symbols(_):
            return parent_of.keys()

    type_macro_via_string.NEW_FUN_EXPERIMENT_via_GA_ = type_macro_via_generic_alias
    return type_macro_via_string


type_macro_ = _define_type_macro_function()


# ==

def _build_exporter():
    class export:
        def __call__(_, asset):
            k = asset.__name__
            assert k not in dct
            dct[k] = asset
            return asset

        @property
        def dictionary(_):
            return dct
    dct = {}
    return export()


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

# #history-C.2: enter via dataclass
# #history-C.1: enter type macro
# #history-B.5
# #history-B.4 spike "via graph viz lines"
# #born
