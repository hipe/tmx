def _output_types():
    yield 'markdown', lambda: _CLI_for_markdown
    yield 'dotfile', lambda: _CLI_for_dotfile
    yield 'tree', lambda: _CLI_for_tree
    yield 'check', lambda: _CLI_for_check


def _formals_for_top():
    yield '-t', '--output-type=TYPE', "(Specify one to see specific help.)"
    yield '-h', '--help', "This screen"


def CLI(sin, sout, serr, argv, efx):  # efx = external functions
    """Generate websites, markdown document trees, visualiaztions, checks…
    """

    # Passive parse because we might need an adapter to parse the rest
    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = _foz_via(_formals_for_top(), lambda: prog_name)
    vals, es = foz.passive_parse(serr, bash_argv)
    if vals is None:
        return es

    # Before we process help, parse any --output-type because of the one trick
    did_request_help = vals.pop('help', False)

    # If output type was specified, validate it
    output_type, rest = None, None
    keep_arg = arg = vals.pop('output_type', None)
    if arg is not None:
        tup, rc = _parse_output_type(serr, bash_argv, arg, foz)
        if tup is None:
            return rc
        output_type, child_CLI, rest = tup

    # For now, require output type
    if not output_type:
        if did_request_help:
            _ = ', '.join(k for (k, _) in _output_types())  # #here1
            big_string = f"{CLI.__doc__} Available output types: ({_})\n"
            return foz.write_help_into(sout, big_string)
        serr.write("For now, must specify --output-type\n")
        serr.write("(One day we'll probably assume default of 'website'.)\n")
        return 123

    if did_request_help:
        bash_argv.append('--help')  # (cleverness as a treat #here4)

    bash_argv.append(f"{prog_name} -t{keep_arg}")

    if rest is not None:
        bash_argv.append(rest)  # terrifying, #here2

    return child_CLI(sin, sout, serr, bash_argv, efx)


def _adapter_powered_command(method_name):
    def decorator(orig_f):
        orig_f.rest_formal = 'SSG_ADAPTER'
        orig_f.adapter_function_name = method_name
        return orig_f
    return decorator


def _base_formals_for_markdown(efx):
    yield efx.collection_path_option_definition
    yield '-n', '--dry-run', "Doesn't actually write files"
    yield '-v', '--verbose', "Output one line per file"
    yield _help_this_screen  # they can request help again here, diff sig
    yield 'output-directory', 'Output directory to put markdown in'


@_adapter_powered_command('generate_markdown')
def _CLI_for_markdown(sin, sout, serr, bash_argv, efx):
    """Generate markdown tailored to the specific SSG.

    If you specify '-' for the output directory, lines are written to
    STDOUT (with each filename written in a line to STDERR)

    Specifying an SSG adapter will show more options.
    Try "-t md:help" or "-t md:list".
    """

    tup, rc = _this_is_a_lot(
            sout, serr, bash_argv, efx,
            _base_formals_for_markdown(efx), _CLI_for_markdown)
    if tup is None:
        return rc
    adapter_func, vals, mon = tup  # #here5

    # ==

    path_head = vals.pop('output_directory')
    is_dry = vals.pop('dry_run', False)
    be_verbose = vals.pop('verbose', False)

    do_output_to_stdout = False
    if '-' == path_head:
        do_output_to_stdout = True
        path_head = '.'

    # ==

    if is_dry and do_output_to_stdout:
        serr.write("-n and collection path of '-' are mutually exclusive\n")
        return 123

    # ==

    if do_output_to_stdout:
        def open_file(wpath):
            serr.write(f"MARKDOWN FILE: {wpath}\n")
            from contextlib import nullcontext as func
            return func(write)

        def write(s):
            return sout.write(s)
        write.write = write  # #watch-the-world-burn
    elif is_dry:
        def open_file(wpath):
            from contextlib import nullcontext as func
            return func(write)

        def write(s):
            return len(s)
        write.write = write  # #watch-the-world-burn
    else:
        def open_file(wpath):
            return open(wpath, 'w')

    from os.path import join as _path_join

    tot_files, tot_lines, tot_something = 0, 0, 0
    did_error = False

    for tup in adapter_func(**vals):
        typ = tup[0]
        if 'adapter_error' == typ:
            did_error = True
            continue  # or w/e
        if 'markdown_file' != typ:
            xx(f"ok neato have fun: {typ!r}")

        path_tail, lines = tup[1:]

        wpath = _path_join(path_head, path_tail)
        with open_file(wpath) as io:
            local_tot_something = 0
            for line in lines:
                local_tot_something += io.write(line)
                tot_lines += 1

            if be_verbose:
                serr.write(f"wrote {wpath} ( ~ {local_tot_something} bytes)\n")

            tot_something += local_tot_something

        tot_files += 1

        for line in lines:
            sout.write(line)

    do_summary = not (did_error and 0 == tot_something)
    # (do summary unless we errored AND no bytes were written)

    if do_summary:
        serr.write(f"wrote {tot_files} file(s), "
                   f"{tot_lines} lines, ~ {tot_something} bytes\n")
    return mon.returncode


def _formals_for_dotfile(efx):
    yield _the_test_option
    yield efx.collection_path_option_definition
    yield _help_this_screen


def _CLI_for_dotfile(sin, sout, serr, bash_argv, efx=None):
    """Generate a graph-viz document from a notecards collection

    Show every relationship between every notecard in the collection.
    Output a graph-viz digraph of the whole collection.
    """

    tup, rc = _common_start(
            sout, serr, bash_argv, efx, _CLI_for_dotfile, _formals_for_dotfile)
    if tup is None:
        return rc
    coll_path, vals, foz, mon = tup
    big_index = _big_index_via(
        coll_path, mon.listener, vals.get('NCID'), vals.get('test'))
    if big_index is None:
        return mon.returncode

    from pho.notecards_.graph_via_collection import \
        graphviz_dotfile_lines_via_ as func

    for line in func(big_index, mon.listener):
        sout.write(line)
    return mon.returncode


def _formals_for_tree(efx):
    yield '--NCID=<ncid>', "use this node as root (see just a subtree)"
    yield _the_test_option
    yield efx.collection_path_option_definition
    yield _help_this_screen


def _CLI_for_tree(sin, sout, serr, bash_argv, efx=None):
    """Generate an ASCII visualization of the collection

    inspired by the `tree` unix utility
    """

    tup, rc = _common_start(
            sout, serr, bash_argv, efx, _CLI_for_tree, _formals_for_tree)
    if tup is None:
        return rc
    coll_path, vals, foz, mon = tup
    big_index = _big_index_via(
        coll_path, mon.listener, vals.get('NCID'), vals.get('test'))
    if big_index is None:
        return mon.returncode

    from pho.notecards_.graph_via_collection import \
        tree_ASCII_art_lines_via as func

    for line in func(big_index):
        sout.write(line)
    return 0


def _formals_for_check(efx):
    yield efx.collection_path_option_definition
    yield _help_this_screen


def _CLI_for_check(sin, sout, serr, bash_argv, efx=None):
    """Run an integrity check on the whole collection and output
    a few summary lines
    """

    tup, rc = _common_start(
            sout, serr, bash_argv, efx, _CLI_for_check, _formals_for_check)
    if tup is None:
        return rc
    coll_path, _vals, foz, mon = tup
    bcoll = _read_only_business_collection(coll_path)
    two = bcoll.build_big_index_(mon.listener)
    if two is None:
        return mon.returncode

    hello = tuple(two.to_node_tree_index_items())
    ordered = sorted(hello, key=lambda tup: (-tup[1].to_node_count(), tup[0]))

    def lines(line_width):
        from pho.magnetics_.text_via import \
            word_wrap_pieces_using_commas as func
        return func(pieces_without_commas(), line_width)

    def pieces_without_commas():
        for k, ti in ordered:
            totals.total_number_of_nodes += ti.to_node_count()
            totals.total_number_of_trees += 1
            yield piece(k, ti)

    totals = pieces_without_commas  # #watch-the-world-burn
    totals.total_number_of_trees = 0
    totals.total_number_of_nodes = 0

    def piece(k, ti):
        n = ti.to_node_count()
        return f"{k!r} ({n} node(s))"

    if False:  # (turn this on for visual testing of word wrap and totals lol)
        ordered = _build_mock_ordered()

    coll_path = bcoll.collection_path
    sout.write(f"Collection {coll_path}:\n")

    for line in lines(79):
        sout.write(line)
        sout.write('\n')

    n1, n2 = totals.total_number_of_nodes, totals.total_number_of_trees
    sout.write(f"{n1} node(s) in {n2} tree(s) all OK.\n")
    return 0


def _build_mock_ordered():
    def ordered():
        yield mock('HJK', 12)
        yield mock('DEF', 7)
        yield mock('123', 7)
        yield mock('456', 6)
        yield mock('123', 6)
        yield mock('ABC', 3)

    def mock(s, d):
        return s, mock_ting(d)

    class mock_ting:
        def __init__(self, d):
            self.d = d

        def to_node_count(self):
            return self.d
    return tuple(ordered())


# == Support related to CLI

def _big_index_via(coll_path, listener, NCID, is_test):
    if is_test:
        bcoll = _read_only_business_collection_via_fixture_path(coll_path)
    else:
        bcoll = _read_only_business_collection(coll_path)
    return bcoll.build_big_index_(listener, NCID=NCID)


def _common_start(sout, serr, bash_argv, efx, CLI_func, foz_func):
    prog_name = bash_argv.pop()
    foz = _foz_via(foz_func(efx), lambda: prog_name)
    vals, rc = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return None, rc
    if vals.get('help'):
        rc = foz.write_help_into(sout, CLI_func.__doc__)
        return None, rc
    mon = efx.produce_monitor()
    listener = mon.listener
    coll_path, rc = efx.require_collection_path(listener, vals)
    if coll_path is None:
        return None, rc
    return (coll_path, vals, foz, mon), None


def _build_extended_FOZ(adapter_func, prog_name, base_formals):

    # Crazy parse the signature AND DOCSTRING of the function
    pool, desc_lines = _crazy_parse(adapter_func)

    # Assume the function takes exactly one of {listener|monitor} eew
    two = ((pool.pop(k, None) is not None) for k in ('monitor', 'listener'))
    two = tuple(two)
    assert any(two)
    assert not all(two)
    monitor_not_listener = two[0]

    # For now, assume function takes exactly one collection_path
    pool.pop('collection_path')

    # Construct a formal ARGV from this omg
    def formals():
        # Options before positionals

        # Options from adapter BEFORE base options
        for tup in ada_opts:
            yield tup

        for tup in base_opts:
            yield tup

        # Positionals adapter AFTER base positionsls
        for tup in base_posis:
            yield tup

        for tup in ada_posis:
            yield tup

    ada_opts, ada_posis = _ARGV_formals_via_formals(pool.items())

    base_opts, base_posis = [], []
    for tup in base_formals:
        if '-' == tup[0][0]:
            base_opts.append(tup)
        else:
            base_posis.append(tup)

    foz = _foz_via(formals(), lambda: prog_name)
    return foz, desc_lines, monitor_not_listener


def _this_is_a_lot(sout, serr, bash_argv, efx, base_formals, caller_func):
    """Effect this rule table balancing loading adapter & serving help

    ({no adapter|bad adapter|good adapter} x {no help|yes help}):

    - not specified adapter not specified help: punish, [ invite to help ]
    - specified invalid adapter not specified help: punish
    - specified good adapter not specified help: normal
    - not specified adapter specified help: no punish, just generic help
    - specified invalid adapter specified help: whine, still show help
    - specified good adapter specified help: show help specific to adapter
    """

    # An ARGV with nothing but --help is valid. Check for that first
    adapter_arg = bash_argv.pop()  # #here2
    prog_name = bash_argv.pop()
    did_request_help = False
    if len(bash_argv) and bash_argv[-1] == '--help':  # #here4
        # (we feel dumb parsing the same argv FOUR times)
        bash_argv.pop()
        did_request_help = True

    # Attempt to load the adapter if A or B
    if adapter_arg or not did_request_help:
        mod, rc = _parse_SSG_adapter_name(sout, serr, adapter_arg, prog_name)
        adapter_loaded_OK = mod is not None

    # Build the extended, final foz from the adapter (if we know one)
    if adapter_arg and adapter_loaded_OK:
        adapter_func = getattr(mod, caller_func.adapter_function_name)  # ..
        three = _build_extended_FOZ(adapter_func, prog_name, base_formals)
        foz, adapter_desc_lines, monitor_not_listener = three

    def mega_lines():
        for line in these_lines():
            yield line
        for line in adapter_desc_lines:
            yield line

    def these_lines():
        return _normal_lines_via_docstring(caller_func.__doc__)

    # Do the rule table above
    if did_request_help:

        if adapter_arg and adapter_loaded_OK:
            return None, foz.write_help_into(sout, mega_lines())

        # (adapter either wasn't specified or was invalid)
        sout.write(f"Usage: {prog_name}:SSG_ADAPTER_NAME [adapter-specific opts]\n")  # noqa: E501
        sout.write('\n')
        itr = these_lines()
        sout.write(f"Description: {next(itr)}")
        for line in itr:
            sout.write(line)
        return None, 0

    if not adapter_arg or not adapter_loaded_OK:  # 🧠
        return None, rc

    # Now parse the remaining args, this time terminal & with adapter
    vals, rc = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return None, rc

    # Maybe the help flag was passed not at the end
    if vals.get('help'):
        return None, foz.write_help_into(sout, mega_lines())

    # For now assume collection path is necessary just like every other command
    mon = efx.produce_monitor()

    coll_path, rc = efx.require_collection_path(mon.listener, vals)
    if coll_path is None:
        return None, rc
    vals['collection_path'] = coll_path  # put it back in probably lol

    if monitor_not_listener:
        vals['monitor'] = mon
    else:
        vals['listener'] = mon.listener

    tup = adapter_func, vals, mon  # #here5
    return tup, None


# == BEGIN this pattern

def _parse_SSG_adapter_name(sout, serr, arg, pname):
    import re
    mod, extra = None, None

    if re.match(r'^[A-Za-z_-]+\Z', arg):

        if 'help' == arg:
            _ = _oxford_join(_SSG_adapter_names(), ' and ')
            serr.write(f"Available SSG adapters: {_}\n")
            return None, 0

        if 'list' == arg:
            for slug in _SSG_adapter_names():
                sout.write(slug)
                sout.write('\n')
            return None, 0

        use = arg.replace('-', '_')
        from importlib import import_module as func
        try:
            mod = func(f"pho.SSG_adapters_.{use}")
        except ModuleNotFoundError as e:
            extra = e.msg

    if mod is None:
        _ = _oxford_join(_SSG_adapter_names(), ' or ')
        serr.write(f"No SSG adapter {arg!r}. Available: {_}\n")
        if extra:
            serr.write(''.join(('(', extra, ')\n')))
        serr.write(f"See '{pname} -h' for help\n")
        return None, 123
    return mod, None


def _SSG_adapter_names():
    from os.path import splitext, basename, dirname as dn, join
    package_path = dn(dn(dn(__file__)))
    here = join(package_path, 'SSG_adapters_')
    glob_path = join(here, '[a-z]*')
    from glob import glob as func
    these = func(glob_path)

    def clean(s):
        bn = basename(s)
        head, _ = splitext(bn)
        return head.replace('_', '-')
    return tuple(sorted(clean(s) for s in these))  # sort, not up to FS

# == END


def _parse_output_type(serr, bash_argv, arg, foz):

    # Split arg around colon (max 1x)
    i = arg.find(':')
    needle, rest = (arg, None) if -1 == i else (arg[:i], arg[i+1:])

    # Resolve sub-command name from arg
    use_needle = _aliases.get(needle, needle)

    found = False
    for slug, func in _output_types():
        if slug == use_needle:
            output_type, child_CLI_funcer = slug, func
            found = True
            break

    # Explain if not found
    if not found:
        _ = _oxford_join((k for (k, _) in _output_types()), ' or ')
        serr.write(f"Unrecognized output type {needle!r}. Expecting {_}\n")
        serr.write(foz.invite_line)
        return None, 123

    # Parse rest
    child_CLI = child_CLI_funcer()
    rf = getattr(child_CLI, 'rest_formal', None)
    if rf is None:
        if rest is not None:
            tail = ''.join((':', rest))
            serr.write(f"Unexpected args to {needle!r}: {tail!r}\n")
            serr.write(foz.invite_line)
            return None, 123
    elif rest is None:
        # serr.write(f"expecting {rf} after {needle!r} (eg '{needle}:foo')\n")
        rest = ''  # #here3

    tup = output_type, child_CLI, rest
    return tup, None


_aliases = {
    'md': 'markdown',
}


_the_test_option = '-t', '--test', "(whether to load --collection-path as ..)"
_help_this_screen = '-h', '--help', "This screen"


def _ARGV_formals_via_formals(formal_items):  # candidate to move to text-lib
    opts, posis = [], []
    for k, param in formal_items:
        desc = param.description
        if not desc:
            xx(f"need google-style pydoc docstring for {k!r}")
        assert isinstance(desc, tuple)
        desc = tuple(s[:-1] for s in desc)  # chomp newlines yikes

        slug = k.replace('_', '-')
        if param.is_required:
            posis.append((slug, *desc))
        elif param.is_flag:
            opts.append((f"--{slug}", *desc))
        else:
            opts.append((f"--{slug}=X", *desc))
    return tuple(opts), tuple(posis)


def _crazy_parse(arg_func):
    from modality_agnostic.magnetics.formal_parameter_via_definition \
        import parameter_index_via_mixed as func
    # (pi = parameter index)
    pi = func(arg_func, do_crazy_hack=True)
    assert not pi.parameters_that_start_with_underscores  # or _listener, _coll
    pool = {k: param for k, param in
            pi.parameters_that_do_not_start_with_underscores}
    return pool, pi.desc_lines


# == Delegations & smalls

def _read_only_business_collection_via_fixture_path(fpath):
    i = fpath.rindex('.')
    head = fpath[:i]
    tail = fpath[i+1:]
    from importlib import import_module as func
    mod = func(head)
    cls = getattr(mod, tail)
    tc = cls(methodName='CAN_BE_USED_BY_VISUAL_TEST')
    return tc.COLLECTION_FOR_VISUAL_TEST


def _read_only_business_collection(collection_path):
    from pho import read_only_business_collection_via_path_ as func
    return func(collection_path)


def _foz_via(defs, pner, x=None):
    from script_lib.cheap_arg_parse import formals_via_definitions as func
    return func(defs, pner, x)


def _oxford_join(slugs, sep):
    from pho.magnetics_.text_via import oxford_join as func
    return func(slugs, sep)


def _normal_lines_via_docstring(big_string):
    from modality_agnostic.magnetics.formal_parameter_via_definition \
        import normal_lines_via_docstring as func
    return func(big_string)


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))


# #history-B.6 remove lots of "old-way" code including "no clobber" and force
# #history-B.5 absorb graph-viz command (file)
# #history-B.4 begin re-arch for different SSG adapters and one god "generate"
# #history-A.1 rewrite during cheap arg parse not click
# #born.
