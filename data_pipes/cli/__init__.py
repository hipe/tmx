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
        class resources:  # #class-as-namespace
            monitor = monitor_via_(serr)
        return resources

    return cmd_funcer()(sin, sout, serr, ch_argv, env_and_related)


# == Select

def _formals_for_select():
    yield '-h', '--help', this_screen_
    yield '<collection>', _desc_for_collection
    yield '<field-name>', 'maybe one day..'


def _command_called_select(sin, sout, serr, argv, rscser):
    """(experimental) something sorta like the SQL command. needs design
    """

    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = formals_via_(_formals_for_select(), lambda: prog_name)

    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es
    if vals.get('help'):
        return write_help_into_(serr, _command_called_select.__doc__, foz)

    coll_ref, field_name = (vals[k] for k in 'collection field_name'.split())

    # == BEGIN

    listener = (mon := rscser().monitor).listener

    input_coll = resolve_input_collection_(sin, coll_ref, listener)
    if input_coll is None:
        return mon.exitstatus

    def funky(schema, input_ents):
        if schema:
            missing_keys = set((field_name,)) - set(schema.field_name_keys)
            if missing_keys:
                xx(f"field(s) not found: {', '.join(missing_keys)}")

        def out_ents():
            for ent in input_ents:
                out_ents.count += 1
                out_dict = {field_name: ent.core_attributes[field_name]}
                # .. for one thing, KeyError. for another, multiple fields..
                # .. we don't know what behavior we want yet so, rien ..
                yield _MinimalEntity(out_dict)

        out_ents.count = 0  # #watch-the-world-burn

        def summarizer():
            class summary:  # #class-as-namespace
                def to_lines():
                    yield f"`select` saw {out_ents.count} entit{{y|ies}}\n"
            return summary

        out_schema = _MinimalSchema((field_name,))
        return out_schema, out_ents(), summarizer

    return _GO_DAVID_HOGG_WILD(sout, serr, input_coll, funky, mon)


def _GO_DAVID_HOGG_WILD(sout, serr, input_coll, funky, mon):
    def exit_early():
        return mon.exitstatu
    listener = mon.listener

    with _OPEN_APPLY_FUNCTION_TO_COLLECTION(input_coll, funky, listener) as _3:
        out_schema, out_ents, summarizer = _3
        if out_ents is None:
            return exit_early()

        out_coll = _json_collection_via(sout)
        with out_coll.open_collection_to_write_given_traversal(listener) as rc:
            if rc is None:
                return exit_early()
            out_ents = tuple(out_ents)  # TEMPORARY
            rc.receive_schema_and_entities(out_schema, out_ents, listener)

    summary = summarizer()
    for line in summary.to_lines():
        serr.write(line)
    return mon.exitstatus


def _OPEN_APPLY_FUNCTION_TO_COLLECTION(coll, funky, listener):
    # (One day you could push this up to realize [#457.A] get over the wall)
    @_contextmanager
    def cm():
        with coll.open_schema_and_entity_traversal(listener) as (sch, ents):
            if ents is None:
                yield None, None, None  # (input schema is not output schema)
                return
            yield funky(sch, ents)
    return cm()


# ==

def monitor_via_(serr):  # #todo
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


def resolve_input_collection_(sin, coll_path, listener):
    if sin.isatty():
        if '-' == coll_path:
            xx("not ok - when you pass '-' as path, STDIN must be non-intera")
        return _collection_via_path(coll_path, listener)
    if '-':
        return _json_collection_via(sin, listener)
    xx("not ok - if you want to read from STDIN pass '-'")


def _collection_via_path(coll_path, listener):
    from data_pipes import meta_collection_ as func
    mc = func()
    return mc.coll_via_path(coll_path, listener)


def _json_collection_via(f, listener=None):
    sa_mod = _json_storage_adapter()
    from kiss_rdb import collection_via_storage_adapter_and_path as func
    return func(sa_mod, f, listener)


def _json_storage_adapter():
    import data_pipes.format_adapters.json as module
    return module


# == Models

def _lol(orig_f):  # #decorator
    def use_f(*components):
        if not ptr:
            ptr.append(_nt(orig_f.__name__, orig_f()))
        return ptr[0](*components)
    ptr = []
    return use_f


@_lol
def _MinimalSchema():
    return ('field_name_keys',)


@_lol
def _MinimalEntity():
    return ('core_attributes',)


# == Smalls

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


def _contextmanager(orig_f):
    from contextlib import contextmanager as decorator
    return decorator(orig_f)


def _nt(symbol_name, attrs):
    from collections import namedtuple as nt
    return nt(symbol_name, attrs)


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
