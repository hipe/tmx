def connection_via_graph_viz_lines(
        database_path, graph_viz_schema_lines, listener=None):
    try:
        return _main(database_path, graph_viz_schema_lines, listener)
    except _Stop:
        pass


def _main(database_path, graph_viz_schema_lines, listener=None):

    strange_tables_are_OK = False
    create_tables_if_not_exist = True

    # Produce the abstract schema of the GraphViz fella
    _validate_extname(database_path, listener)
    GV_absch = _abs_schema_via_graph_viz(graph_viz_schema_lines, listener)

    # Produce the abstract schema of the database connection
    from sqlite3 import connect as func
    conn = func(database_path)
    DB_absch = _abs_schema_via_conn(conn, listener)

    # If there is no difference, we are OK
    d = DB_absch.schema_diff_to(GV_absch)
    if d is None:
        return conn

    # Since there is a difference, see if we can resolve it with some SQL
    lineses = _SQL_lineses(
        d, database_path, graph_viz_schema_lines, listener,
        create_tables_if_not_exist, strange_tables_are_OK)

    # There is a lot we don't handle yet, like no ALTER TABLE, no DROP TABLE
    if lineses is None:
        conn.close()
        return

    # There are some differences we can ignore
    if () == lineses:  # #here1
        return conn

    # Attempt to execute the SQL to update the database schema
    c = conn.cursor()
    for lines in lineses:
        big_string = ''.join(lines)
        c.execute(big_string)
        conn.commit()  # not clear when this is necessary

    return conn


func = connection_via_graph_viz_lines


def _SQL_lineses(  # #testpoint
        d, database_path, visualization_namer, listener,
        create_tables_if_not_exist, strange_tables_are_OK):

    # When there's a diff, can you resolve it with SQL?

    left_only = d.tables_in_left_not_in_right
    middle = d.table_diffs
    right_only = d.tables_in_right_not_in_left
    context = database_path, visualization_namer

    # For now, short circuit, coarse errors first
    if left_only and not strange_tables_are_OK:
        return _when_extra_tables(listener, left_only, *context)

    # Imagine a day where we have alter table etc
    if middle:
        return _when_table_diffs(listener, middle, *context)

    # Create tables if any need to be created
    if right_only:
        if create_tables_if_not_exist:
            abstract_tables = right_only.values()
            from kiss_rdb.storage_adapters_.sqlite3.\
                _abstract_schema_to_and_fro import \
                SQL_lineses_for_CREATE_TABLEs_ as func
            return func(abstract_tables, listener)
        return _when_missing_tables(listener, right_only, *context)
    return ()  # #here1


def _validate_extname(database_path, _listener):
    from os.path import basename
    bn = basename(database_path)

    exp = '.sqlite3'

    if -1 == (i := bn.rfind('.')):
        xx(f"needs extension of {exp!r}: {bn!r}")

    act = bn[i:]
    if exp != act:
        xx(f"needs extension of {exp!r} not {act!r}: {bn!r}")


def _abs_schema_via_graph_viz(graph_viz_schema_lines, listener):  # #testpoint
    from kiss_rdb.magnetics_.abstract_schema_via_definition import \
        abstract_schema_via_graph_via_lines as func
    abs_sch = func(graph_viz_schema_lines, listener)
    if abs_sch:
        return abs_sch
    raise _Stop()


def _abs_schema_via_conn(conn, listener):
    from kiss_rdb.storage_adapters_.sqlite3._abstract_schema_to_and_fro \
        import abstract_schema_via_sqlite3_connection as func
    abs_sch = func(conn, listener)
    if abs_sch:
        return abs_sch
    raise _Stop()


# == Whiners

def _when_table_diffs(listener, table_diffs, database_path, namer):
    def lines():
        _ = ', '.join(repr(s) for s in ks)
        yield f"Database and visual schema are different in table(s): ({_})"
        for line in _lines_of_context(database_path, namer):
            yield line
        for table_diff in table_diffs.values():
            for line in table_diff.to_description_lines():
                yield line

    ks = tuple(table_diffs.keys())
    listener('error', 'expression', 'schema_out_of_sync', 'tables_different', lines)  # noqa: E501


def _when_missing_tables(listener, right_only, database_path, namer):
    def lz():
        _ = ', '.join(repr(s) for s in ks)
        yield f"Database needs these table(s): ({_})"
        yield "and `create_tables_if_not_exist` is false."
        yield "Either create these tables or change the dotfile."
        for line in _lines_of_context(database_path, namer):
            yield line

    ks = tuple(right_only.keys())
    listener('error', 'expression', 'schema_out_of_sync', 'missing_tables', lz)


def _when_extra_tables(listener, left_only, database_path, namer):
    def lz():
        _ = ', '.join(repr(s) for s in ks)
        yield "`strange_tables_are_OK` is set to false and"
        yield f"database has unrecognized table(s): ({_})"
        yield "Either drop these tables (IF YOU'RE SURE) or change dotfile."
        for line in _lines_of_context(database_path, namer):
            yield line
    ks = tuple(left_only.keys())
    listener('error', 'expression', 'schema_out_of_sync', 'strange_tables', lz)


def _lines_of_context(database_path, namer):
    yield f"database: {database_path}"
    name = getattr(namer, 'name', None)
    if name is None:
        return
    yield f"dotfile: {name}"


# ==

class _Stop(RuntimeError):
    pass


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
