def cli_for_production():
    import sys as o
    exit(_CLI(o.stdin, o.stdout, o.stderr, o.argv, lambda *_: xx()))


def _formals_for_toplevel():
    yield '-h', '--help', 'This screen'
    yield 'command [..]', "One of the below"


def _subcommands():
    yield 'select', lambda: _command_called_select
    yield 'filter-by-tags', lambda: _load('.filter_by_tags')
    yield 'convert-collection', lambda: _load('.convert_collection')
    yield 'cc', lambda: _hack_an_alias_to_cc
    yield 'sync', lambda: _load('.sync')


def _hack_an_alias_to_cc(*_5):  # #wish [#608.11]
    "(alias to `convert-collection` (hacky experiment))"

    return _load('.convert_collection')(*_5)


def _CLI(sin, sout, serr, argv, enver):
    """Data Pipes is an experimental potpourri of higher-level operations

    that operate on top of collections, sort of in the spirit of ReactiveX
    """

    long_prog_name = (bash_argv := list(reversed(argv))).pop()

    def prog_name():
        pcs = long_prog_name.split(' ')
        from os.path import basename
        pcs[0] = basename(pcs[0])
        return ' '.join(pcs)

    foz = formals_via_(_formals_for_toplevel(), prog_name, _subcommands)
    vals, es = foz.nonterminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return write_help_into_(serr, _CLI.__doc__, foz)

    # The Ultra-Sexy Mounting of an Alternation Component:
    cmd_tup = vals.pop('command')
    cmd_name, cmd_funcer, es = foz.parse_alternation_fuzzily(serr, cmd_tup[0])
    if not cmd_name:
        return es

    ch_pn = ' '.join((prog_name(), cmd_name))  # we don't love it, but later
    ch_argv = (ch_pn, * cmd_tup[1:])

    def env_and_related():
        xx()

    return cmd_funcer()(sin, sout, serr, ch_argv, env_and_related)


def _formals_for_select():
    yield '-h', '--help', this_screen_
    yield '<collection>', _desc_for_collection
    yield '<field-name>', 'maybe one day..'


def _command_called_select(sin, sout, serr, argv, _rscser):
    """(experimental) something sorta like the SQL command. needs design
    """

    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = formals_via_(_formals_for_select(), lambda: prog_name)

    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es
    if vals.get('help'):
        return write_help_into_(serr, _command_called_select.__doc__, foz)
    xx('soon')


def monitor_via_(serr):
    from script_lib.magnetics.error_monitor_via_stderr import func
    return func(serr, default_error_exitstatus=4)


def SPLAY_FORMAT_ADAPTERS(stdout, stderr):
    """if the user passes the string "help" for the argument, display

    help for that format and terminate early. otherwise, do nothing.
    """

    o = stderr.write
    o('the filename extension can imply a format adapter.\n')
    o('(or you can specify an adapter explicitly by name.)\n')
    o('known format adapters (and associated extensions):\n')

    out = stdout.write  # imagine piping output (! errput) (Case3459DP)
    count = 0

    from kiss_rdb import collectionerer
    _ = collectionerer().SPLAY_STORAGE_ADAPTERS()

    for (k, ref) in _:
        _storage_adapter = ref()
        mod = _storage_adapter.module
        if mod.STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES:
            _these = mod.STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS
            _these = ', '.join(_these)
            _surface = f'({_these})'
        else:
            _surface = '(schema-based)'

        _name = k.replace('_', '-')
        out(f'    {_name} {_surface}\n')
        count += 1
    o(f'({count} total.)\n')
    return 0  # _exitstatus_for_success


def _load(key):
    from importlib import import_module
    mod = import_module(key, __name__)
    return mod.CLI_


def write_help_into_(serr, doc, foz):
    for line in foz.help_lines(doc):
        serr.write(line)
    return 0


def formals_via_(itr, prog_name, subcommands=None):
    from script_lib.cheap_arg_parse import formals_via_definitions as func
    return func(itr, prog_name, subcommands)


_desc_for_collection = 'usually a fileystem path to your collection'
this_screen_ = 'this screen'


def xx(msg=None):
    raise RuntimeError(''.join(('hello', * ((': ', msg) if msg else ()))))


# #history-A.5: lost almost all the stuff
# #history-A.4: become not executable any more
# #history-A.3: no more sync-side stream-mapping
# #history-A.2 can be temporary. as referenced.
# #history-A.1: begin become library, will eventually support "map for sync"
# #born.
