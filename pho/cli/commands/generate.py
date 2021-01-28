def _output_types():
    yield 'markdown', lambda: _CLI_for_markdown
    yield 'check', lambda: _CLI_for_check


def _formals_for_top():
    yield '-t', '--output-type=TYPE', "(Specify one to see specific help.)"
    yield '-h', '--help', "This screen"


def CLI(sin, sout, serr, argv, efx=None):  # efx = external functions
    "(Our oldschool command to assemble a hugo markdown from notecards..)"""

    # == BEGIN temporary bridge to new code with this secret way [#882.D]
    if 1 < len(argv) and '-t' == argv[1][:2]:
        return _CLI_NEW_WAY(sin, sout, serr, argv, efx)
    # == END

    from script_lib.cheap_arg_parse import cheap_arg_parse
    return cheap_arg_parse(
            _do_CLI, sin, sout, serr, argv, tuple(_params()), efx=efx)


def _params():
    CP_ = _legacy_bridge_1()

    yield ('-c', '--collection-path=PATH', * CP_().descs)

    yield ('-r', '--recursive',
           'TEMPORARY/EXPERIMENTAL attempts to generate *all* documents "in"',
           'the collection. <notecard-ID> (required) is ignored.')

    yield '-F', '--force', 'Must be provided to overwrite existing file(s)'

    yield '-n', '--dry-run', "Don't actually write the output file(s)"

    yield '-h', '--help', "This screen"

    yield 'notecard-id', 'The head notecard of the document to generate.'

    yield ('out-path',
           'The directory into which to write the files',
           '(whose filenames are derived from the head notecard headings).',
           'Use "-" to write to STDOUT (IN PROGRESS).')


def _CLI_NEW_WAY(sin, sout, serr, argv, efx):

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


def _do_CLI(
        monitor, sin, sout, serr, efx,
        collection_path, recursive, force, dry_run, notecard_id, out_path):

    """Generate a document or documents.

    Generate a document or documents from the notecards in the collection.
    """

    # simple normalizations (partly because #wish [#608.13] `<arg-like-this>?`)

    if out_path in ('-', ''):
        out_path = None

    if notecard_id == '':
        notecard_id = None

    listener = monitor.listener

    # ==

    def main():
        tup = resolve_conditionally_required_arguments()
        if tup is None:
            return
        can_be_dry, out_type, out_value = tup

        if dry_run and not can_be_dry:
            return _whine_about_dry_run(listener)

        bcoll = _read_only_business_collection(collection_path)
        big_index = bcoll.build_big_index_OLD_(listener)
        if big_index is None:
            return

        # get money

        from pho.SSG_adapters_.hugo import func
        _ok = func(
                out_tuple=(out_type, out_value),
                notecard_IID_string=notecard_id,
                big_index=big_index,
                be_recursive=recursive,
                force_is_present=force,
                is_dry_run=dry_run,
                listener=listener)

        assert _ok in (None, True)

    def resolve_conditionally_required_arguments():

        can_be_dry = True

        # a rule table with three inputs: (recursve, notecard_id, out_path)

        if recursive:
            if notecard_id is not None:
                # for recursive, you can't pass a notecard ID
                return error('is_recursive', 'has_frag_id')

            if out_path is None:
                # for recursive, output must be to directory not STDOUT
                return error('is_recursive', 'has_out_path')

            # write recursively to directory
            return can_be_dry, 'output_directory_path', out_path

        if notecard_id is None:
            # for single document, you must pass notecard ID
            return error('is_recursive', 'has_frag_id')

        if out_path is None:
            # write single document to STDOUT
            import sys
            can_be_dry = False
            return can_be_dry, 'open_output_filehandle', sys.stdout

        # write single document to file
        return can_be_dry, 'output_file_path', out_path

    def error(focus_one, focus_two):
        o = {'is_recursive': lambda: recursive,
             'has_frag_id': lambda: notecard_id is not None,
             'has_out_path': lambda: out_path is not None}
        kwargs = {k: o.pop(k)() for k in (focus_one, focus_two)}
        k, = o.keys()
        kwargs[k] = None
        _whine_big_flex(listener, kwargs)

    def resolve_collection_path():
        if collection_path is not None:
            return collection_path
        CP_ = _legacy_bridge_1()
        return CP_().require_collection_path(efx, listener)

    main()
    return monitor.exitstatus


@_adapter_powered_command('generate_markdown')
def _CLI_for_markdown(sin, sout, serr, bash_argv, efx=None):
    """Generate markdown tailored to the specific SSG.

    Specify the SSG adapter, e.g.: "-t md:pelican".
    You can specify "-t md:help" or "-t md:list".
    """

    tup, rc = _this_is_a_lot(sout, serr, bash_argv, efx, _CLI_for_markdown)
    if tup is None:
        return rc
    adapter_func, vals, mon = tup  # #here5

    omg = adapter_func(**vals)
    for tup in omg:
        typ = tup[0]
        if 'adapter_error' == typ:
            continue  # or w/e
        if 'markdown_file' != typ:
            xx("ok neato have fun: {typ!r}")
        entry, lines = tup[1:]

        sout.write(f"DAMN SHAWTY OKAYY: {entry!r}\n")
        for line in lines:
            sout.write(line)

    return mon.returncode


def _formals_for_check():
    yield _collection_path()
    yield _help_this_screen


def _CLI_for_check(sin, sout, serr, bash_argv, efx=None):
    """Run an integrity check on the whole collection and output
    a few summary lines
    """

    tup, rc = _common_start(
            sout, serr, bash_argv, efx, _CLI_for_check, _formals_for_check)
    if tup is None:
        return rc
    coll_path, foz, mon = tup
    bcoll = _read_only_business_collection(coll_path)
    two = bcoll.build_big_index_NEW_(mon.listener)
    if two is None:
        return mon.returncode

    hello = tuple(two.to_node_tree_index_items())
    ordered = sorted(hello, key=lambda tup: (-tup[1].to_node_count(), tup[0]))

    # == BEGIN, our own word-wrap again [#612.6], why always so long 😩

    def lines(line_width):
        tot, cache = 0, []
        for piece in pieces():
            leng = len(piece)
            is_first_piece_on_line = 0 == len(cache)
            next_tot = leng if is_first_piece_on_line else (tot + 1 + leng)

            # If we would still be under the limit by adding this content..
            if next_tot < line_width:
                if not is_first_piece_on_line:
                    cache.append(' ')
                cache.append(piece)
                tot = next_tot
                continue

            # If adding this content puts us exactly at the limit..
            if next_tot == line_width:
                cache.extend((' ', piece))
                yield ''.join(cache)  # #here6
                cache.clear()
                tot = 0
                continue

            # Adding this content would put us over
            assert line_width < next_tot

            # If this is the first piece, output it anyway -
            # breaking long words is well outside our scope
            if is_first_piece_on_line:
                yield piece  # #here6
                continue

            # Flush the definitely existing content then start a new line
            yield ''.join(cache)  # #here6
            cache.clear()
            cache.append(piece)
            tot = leng

        if len(cache):
            yield ''.join(cache)  # #here6

    # == END

    def pieces():  # (avoiding using "scanner" as an exercise)
        itr = pieces_without_commas()
        prev = next(itr)  # ..
        for pc in itr:
            yield f"{prev},"
            prev = pc
        yield f"{prev}."  # or no period

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
        ordered = tuple(ordered())

    coll_path = bcoll.collection_path
    sout.write(f"Collection {coll_path}:\n")

    for line in lines(79):
        sout.write(line)
        sout.write('\n')

    n1, n2 = totals.total_number_of_nodes, totals.total_number_of_trees
    sout.write(f"{n1} node(s) in {n2} tree(s) all OK.\n")
    return 0


# == Support related to CLI

def _common_start(sout, serr, bash_argv, efx, CLI_func, foz_func):
    prog_name = bash_argv.pop()
    foz = _foz_via(foz_func(), lambda: prog_name)
    vals, rc = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return None, rc
    if vals.get('help'):
        rc = foz.write_help_into(sout, CLI_func.__doc__)
        return None, rc
    mon = efx.produce_monitor()
    coll_path, rc = _require_collection_path(mon.listener, vals, efx)
    if coll_path is None:
        return None, rc
    return (coll_path, foz, mon), None


def _build_extended_FOZ_for_MD(adapter_func, prog_name):

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
        for tup in opts:
            yield tup
        yield _collection_path()  # because assumption above
        yield _help_this_screen  # they can request help again here, diff sig

        # Positionals after options
        for tup in posis:
            yield tup
    opts, posis = _ARGV_formals_via_formals(pool.items())
    foz = _foz_via(formals(), lambda: prog_name)
    return foz, desc_lines, monitor_not_listener


def _this_is_a_lot(sout, serr, bash_argv, efx, caller_func):
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
        three = _build_extended_FOZ_for_MD(adapter_func, prog_name)
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

    coll_path, es = _require_collection_path(mon.listener, vals, efx)
    if coll_path is None:
        return None, 123
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


def _collection_path():
    return '-c', '--collection-path=PATH', *_CPT().descs


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


# == Whiners

def _whine_about_dry_run(listener):
    def _():
        return {'reason': '«dry-run» is meaningless when output is stdout'}
    listener('error', 'structure', 'parameter_conditionally_unavailable', _)


def _whine_big_flex(listener, kwargs):
    def payloader():
        _msg = ''.join(__whine_big_flex_pieces(**kwargs))
        return {'reason_tail': _msg}
    listener('error', 'structure', 'conditional_argument_error', payloader)


def __whine_big_flex_pieces(is_recursive, has_frag_id, has_out_path):

    these = ((has_frag_id, '«notecard-ID»', 'a'),
             (has_out_path, '«out-path» on the filesystem', 'an'))

    # eliminate the None's from our expression
    these = tuple(x for x in these if x[0] is not None)

    # for now life is easy in this regard
    assert(1 == len(these))

    (t_or_f, label, article), = these

    if is_recursive:
        pp = "for --recursive"
    else:
        pp = "when outputting a single document"

    if t_or_f:
        sp = f"""you can't pass {article} {label} (maybe use "" instead)"""
    else:
        sp = f'you must provide {article} {label}'

    yield pp
    yield ', '
    yield sp


# == Delegations & smalls

def _read_only_business_collection(collection_path):
    from pho import read_only_business_collection_via_path_ as func
    return func(collection_path)


def _require_collection_path(listener, vals, efx):
    val = vals.pop('collection_path', None)
    if val is not None:
        return val, None
    return _CPT().require_collection_path(listener, efx)


def _legacy_bridge_1():
    cpt = _CPT()
    return lambda: cpt


def _CPT():
    from pho.cli import collection_path_tools_ as func
    return func()


def _foz_via(defs, pner, x=None):
    from script_lib.cheap_arg_parse import formals_via_definitions as func
    return func(defs, pner, x)


def _oxford_join(slugs, sep):  # rewrite something in text_lib
    leng = len(slugs := tuple(slugs))
    seps = '', *(', ' for _ in range(0, leng-2)), sep
    rows = tuple((seps[i], repr(slugs[i])) for i in range(0, leng))
    return ''.join(s for row in rows for s in row)


def _normal_lines_via_docstring(big_string):
    from modality_agnostic.magnetics.formal_parameter_via_definition \
        import normal_lines_via_docstring as func
    return func(big_string)


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))


# #history-B.4 begin re-arch for different SSG adapters and one god "generate"
# #history-A.1 rewrite during cheap arg parse not click
# #born.
