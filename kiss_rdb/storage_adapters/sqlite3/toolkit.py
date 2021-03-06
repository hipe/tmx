def cli_for_production():
    from sys import stdout, stderr, argv
    exit(CLI(None, stdout, stderr, argv))


def _commands():
    yield 'round-trip', lambda: _command_round_trip
    yield 'CREATE-TABLEs-sql', lambda: _command_CREATE_TABLEs_sql
    yield 'abstract-schema', lambda: _command_absch
    yield 'graphviz-AST', lambda: _command_graphviz_AST


def CLI(sin, sout, serr, argv):
    """"kiss sqlite3 toolkit": commands for developing kiss's sqlite3 library

    Reminder: if you're coming to this from 'kss', you can invoke it
    directly with 'kst' (kiss sqlite3 toolkit) which will save a few blips

    Although "sqlite" is in the name, this family of commands is in its
    conception "GraphViz"-centric: it's mainly for developing the
    vaporware non-command `dot2sql`

    Commands are vaguely (or not vaguely) in reverse-dependency order,
    with the highest-level commands at the top. So typically, if the higher-
    level commands (as visual tests) pass, the lower-level ones will also
    pass (but the reverse is not not necessarily true).

    So if you are troubleshooting how a GraphViz dotfile is parsing and you
    want "regression-friendly" order, start from the bottommost command and
    work upwards (or bisect the tests or whatever).
    """

    func_argv, rc = _prepare_tail_call(serr, argv, _commands(), CLI)
    if not func_argv:
        return rc
    func, ch_argv = func_argv
    efx = _ExternalFunctions(serr)
    return func(sin, sout, serr, ch_argv, efx)


def _formals_for_round_trip(efx):
    yield _the_help_option
    yield _the_GraphViz_file_argument


def _command_round_trip(sin, sout, serr, argv, efx):
    """(dotfile -> abstract schema -> sql -> abstract schema) and compare"""

    doc = _command_round_trip.__doc__
    defns = _formals_for_round_trip(efx)
    vals, rc = _common_terminal(serr, argv, defns, doc)
    if vals is None:
        return rc

    path = vals.pop(_path_arg_key)
    assert not vals

    mon = efx.produce_monitor()
    listener = mon.listener

    from kiss_rdb.magnetics_.abstract_schema_via_definition \
        import abstract_schema_via_graph_via_lines as func

    with open(path) as fh:
        abs_sch_one = func(fh, listener)
        if abs_sch_one is None:
            return mon.returncode

    abstract_tables = abs_sch_one.to_tables()
    sql_lineses_via = _this_func()

    def sql_lines():
        lineses = sql_lineses_via(abstract_tables, listener)
        for lines in lineses:
            for line in lines:
                yield line

    sql_lines = sql_lines()
    from kiss_rdb.storage_adapters_.sqlite3._abstract_schema_to_and_fro \
        import abstract_schema_via_sqlite_SQL_lines as func
    abs_sch_two = func(sql_lines)

    sch_diff = abs_sch_two.schema_diff_to(abs_sch_one)

    if sch_diff:
        serr.write("OH NOES\n")
        serr.writelines(sch_diff.to_description_lines())
        return 123

    serr.write("Success! no difference detected after round trip\n")
    return mon.returncode


def _formals_for_CREATE_TABLEs_sql(efx):
    yield _the_help_option
    yield _the_GraphViz_file_argument


def _command_CREATE_TABLEs_sql(sin, sout, serr, argv, efx):
    """write to STDOUT the SQL that our sqlite storage adapter makes"""

    doc = _command_CREATE_TABLEs_sql.__doc__
    defns = _formals_for_CREATE_TABLEs_sql(efx)
    vals, rc = _common_terminal(serr, argv, defns, doc)
    if vals is None:
        return rc

    path = vals.pop(_path_arg_key)
    assert not vals

    mon = efx.produce_monitor()
    listener = mon.listener

    from kiss_rdb.magnetics_.abstract_schema_via_definition \
        import abstract_schema_via_graph_via_lines as func

    with open(path) as fh:
        abs_sch = func(fh, listener)
        if abs_sch is None:
            return mon.returncode

    abstract_tables = abs_sch.to_tables()
    func = _this_func()
    lineses = func(abstract_tables, listener)

    for lines in lineses:
        sout.writelines(lines)

    return mon.returncode


def _formals_for_absch(efx):
    yield _the_help_option
    yield _the_GraphViz_file_argument


def _command_absch(sin, sout, serr, argv, efx):
    """Can we get as far as an abstract schema?"""

    doc = _command_absch.__doc__
    defns = _formals_for_absch(efx)
    vals, rc = _common_terminal(serr, argv, defns, doc)
    if vals is None:
        return rc

    path = vals.pop(_path_arg_key)
    assert not vals

    mon = efx.produce_monitor()
    listener = mon.listener

    from kiss_rdb.magnetics_.abstract_schema_via_definition \
        import abstract_schema_via_graph_via_lines as func

    with open(path) as fh:
        abs_sch = func(fh, listener)
        if abs_sch is None:
            return mon.returncode
        sout.writelines(abs_sch.to_description_lines())

    return mon.returncode


def _formals_for_graphviz_AST(efx):
    yield _the_help_option
    yield _the_GraphViz_file_argument


def _command_graphviz_AST(sin, sout, serr, argv, efx):
    """See if a dotfile parses and how it breaks down in to an AST"""

    doc = _command_graphviz_AST.__doc__
    defns = _formals_for_graphviz_AST(efx)
    vals, rc = _common_terminal(serr, argv, defns, doc)
    if vals is None:
        return rc

    path = vals.pop(_path_arg_key)
    assert not vals

    mon = efx.produce_monitor()
    listener = mon.listener

    from kiss_rdb.storage_adapters.graph_viz.AST_via_lines \
        import sexps_via_lines as func

    count = 0
    with open(path) as fh:
        sxs = func(fh, listener)
        for sx in sxs:
            count += 1
            sout.writelines(sx.to_description_lines())

    serr.write(f"(GraphViz file parsed into {count} elements)\n")
    return mon.returncode


_the_GraphViz_file_argument = '<dotfile>', \
    'A GraphViz file (only a subset of such files will parse)'
_path_arg_key = 'dotfile'
_the_help_option = '-h', '--help', 'this screen'


# ==


def _prepare_tail_call(serr, argv, cx, docer):

    bash_argv = list(reversed(argv))
    foz = _foz_for_branch(bash_argv, cx)

    vals, rc = foz.nonterminal_parse(serr, bash_argv)
    if vals is None:
        return None, rc

    if vals.get('help'):
        for line in foz.help_lines(doc=docer.__doc__):
            serr.write(line)
        return None, 0

    cmd_tup = vals.pop('command')  # our grammar specifies at least one
    head_cmd, *rest = cmd_tup
    cmd_name, cmd_funcer, rc = foz.parse_alternation_fuzzily(serr, head_cmd)
    if not cmd_name:
        return None, rc

    cmd_func = cmd_funcer()
    ch_pn = ' '.join((foz.program_name, cmd_name))  # we don't love it, but meh
    ch_argv = ch_pn, *rest
    return (cmd_func, ch_argv), None


def _foz_for_branch(bash_argv, cx):

    long_program_name = bash_argv.pop()

    def prog_name():
        return _shorten_prog_name(long_program_name)

    from script_lib.cheap_arg_parse import \
        shorten_long_program_name as _shorten_prog_name

    def formals():
        yield '-h', '--help', 'This screen'
        yield '<command> [..]', "One of the below"

    return _foz_via(formals(), prog_name, lambda: cx)


def _common_terminal(serr, argv, defns, doc):
    bash_argv = list(reversed(argv))
    prog_name = bash_argv.pop()

    foz = _foz_via(defns, lambda: prog_name)

    vals, rc = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return None, rc

    if vals.get('help'):
        serr.writelines(foz.help_lines(doc=doc))
        return None, 0

    return vals, None


def _foz_via(defns, prog_name, cxer=None):
    from script_lib.cheap_arg_parse import formals_via_definitions as func
    return func(defns, prog_name, cxer)


def _ExternalFunctions(serr):

    class external_functions:  # #class-as-namespace

        def produce_monitor():
            from script_lib.magnetics.error_monitor_via_stderr import func
            return func(serr)

    return external_functions


# ==

def _this_func():
    from kiss_rdb.storage_adapters_.sqlite3._abstract_schema_to_and_fro \
        import SQL_lineses_for_CREATE_TABLEs_ as func
    return func


# ==

def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
