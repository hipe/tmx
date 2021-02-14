def _formals_for_toplevel():
    yield '-r', '--readme=PATH', "or use PHO_README. '-' might read from STDIN"
    yield '-h', '--help', 'This screen'
    yield 'command [..]', "One of the below"


def _subcommands():
    yield 'open', lambda: _subcommand_open
    yield 'close', lambda: _subcommand_close
    yield 'list', lambda: _subcommand_list
    yield 'top', lambda: _subcommand_top
    yield 'which', lambda: _subcommand_which
    yield 'use', lambda: _subcommand_use
    yield 'find-readmes', lambda: _subcommand_find_readmes
    yield 'graph', lambda: _subcommand_graph


class _production_external_functions:  # #class-as-namespace

    def apply_patch(diff_lines, is_dry, listener):
        from text_lib.diff_and_patch import apply_patch_via_lines as func
        return func(diff_lines, is_dry, listener, cwd=None)  # t/f result

    def enver():
        from os import environ
        return environ

    def produce_open_function():
        return open


def CLI(sin, sout, serr, argv, efx):  # efx = external functions
    """my dream as a boy and as a man
    desc line 2
    """

    bash_argv = list(reversed(argv))
    long_program_name = bash_argv.pop()

    def prog_name():
        pcs = long_program_name.split(' ')
        from os.path import basename
        pcs[0] = basename(pcs[0])
        return ' '.join(pcs)

    foz = _formals_via(_formals_for_toplevel(), prog_name, _subcommands)
    vals, es = foz.nonterminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return foz.write_help_into(sout, CLI.__doc__)  # sout !serr (Case3960)

    # The Ultra-Sexy Mounting of an Alternation Component:
    cmd_tup = vals.pop('command')
    cmd_name, cmd_funcer, es = foz.parse_alternation_fuzzily(serr, cmd_tup[0])
    if not cmd_name:
        return es

    ch_pn = ' '.join((prog_name(), cmd_name))  # we don't love it, but later
    ch_argv = (ch_pn, * cmd_tup[1:])

    # == FROM
    if efx and not hasattr(efx, 'apply_patch'):
        # This is still ugly and wrong. If it's a test mock, use it.
        # But if we got it by being mounted by a parent, ignore it
        efx = _production_external_functions

    if efx:
        use_efx = _build_external_functions(
            serr, vals, efx.enver,
            efx.apply_patch, efx.produce_open_function)
    else:
        use_efx = None
    # == TO

    return cmd_funcer()(sin, sout, serr, ch_argv, use_efx)


def _formals_for_open():
    yield '-n', '--dry-run', 'dry run'
    yield '-v', '--verbose', 'bold new verbose mode (experimental)'
    yield _formal_for_help
    yield '<message>', 'any one line of some appropriate length'


def _subcommand_open(sin, sout, serr, argv, efx):
    """Open an issue"""

    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = _formals_via(_formals_for_open(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return foz.write_help_into(serr, _subcommand_open.__doc__)

    # == BEGIN experiment
    def listener(chan, *rest):
        if 'verbose' != chan:
            return mon.listener(chan, *rest)
        if not be_verbose:
            return
        mon.listener('info', *rest)
    be_verbose = vals.pop('verbose', False)
    # == END

    dct = {'main_tag': '#open', 'content': vals['message']}
    is_dry = vals.get('dry_run', False)
    opn = efx.produce_open_function()
    mon = efx.emission_monitor

    readme = efx.resolve_issues_file_path()
    if readme is None:
        return 4

    from pho._issues.edit import open_issue as func
    cs = func(readme, dct, listener, be_verbose=be_verbose, opn=opn)
    # cs = custom struct
    if cs is None:
        return mon.exitstatus

    dct = cs._asdict()
    if 'before_entity' in dct:
        before = dct.pop('before_entity')
        after = dct.pop('after_entity')
    else:
        before = None
        after = dct.pop('created_entity')

    if True:
        if before:
            serr.write(f"before: {before.to_line()}")
            serr.write(f"after:  {after.to_line()}")
        else:
            serr.write(f"line:   {after.to_line()}")

    efx.apply_patch(cs.diff_lines, is_dry, listener)  # result is t/f
    return mon.exitstatus


def _formals_for_close():
    yield '-n', '--dry-run', 'dry run'
    yield _formal_for_help
    yield '<identifier>', 'whomst ("123" or "#123" or "[#123]" all OK)'


def _subcommand_close(sin, sout, serr, argv, efx):
    """Close an open issue..

    Actually what this probably does is update *any* issue to become a '#hole'.
    It does not actually confirm that the issue is open, as far as we know.
    """

    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = _formals_via(_formals_for_close(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return foz.write_help_into(serr, _subcommand_close.__doc__)

    eid = vals['identifier']

    is_dry = vals.get('dry_run', False)
    mon = efx.emission_monitor
    listener = mon.listener

    readme = efx.resolve_issues_file_path()
    if readme is None:
        return 4

    from pho._issues.edit import close_issue as func
    cs = func(readme, eid, listener, efx.produce_open_function())
    if cs is None:
        return mon.exitstatus

    efx.apply_patch(cs.diff_lines, is_dry, listener)  # result is t/f
    return mon.exitstatus


def _formals_for_top():
    yield '-m', '--oldest-first', 'override default of select/sort by priority'
    yield '-M', '--newest-first', 'override default of select/sort by priority'
    yield _batch_opt
    yield '-f', '--format=FMT', 'output format. {json|table} (default: table)'
    yield '-<number>', _build_int_matcher, 'show the top N items (default: 3)'
    yield _formal_for_help
    yield '[query […]]', "default: '#open'. Currently limited to 1 tag."


def _subcommand_top(sin, sout, serr, argv, efx):
    "`list` with favorite defaults: '#open' --highest-priority-first -3"

    bash_argv = list(reversed(argv))
    prog_name = bash_argv.pop()
    foz = _formals_via(_formals_for_top(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return foz.write_help_into(serr, _subcommand_top.__doc__)

    # "By hand", put this default in
    if 'oldest_first' not in vals and 'newest_first' not in vals:
        vals['highest_priority_first'] = True

    easy_defaults = {'format': 'table', 'number': 3, 'query': ('#open',)}
    easy_defaults.update(vals)
    vals = easy_defaults

    return _top_or_list(sin, sout, serr, vals, foz, efx)


def _formals_for_list():
    yield '-p', '--highest-priority-first', * _desc_lines_for_priority()
    yield '-m', '--oldest-first', 'sort by time last modified (acc. to VCS)'
    yield '-M', '--newest-first', 'sort by time last modified (acc. to VCS)'
    yield _batch_opt
    yield '-f', '--format=FMT', '{json|table} (default varies)'
    yield '-<number>', _build_int_matcher, 'show the top N items'
    yield _formal_for_help
    yield '[query […]]', "e.g '#open'. Currently limited to 1 tag."


_batch_opt = '-b', '--batch', "treat --readme (or PHO_README) as list of paths"


def _subcommand_list(sin, sout, serr, argv, efx):
    """List issues according to the query"""

    bash_argv = list(reversed(argv))
    prog_name = bash_argv.pop()
    foz = _formals_via(_formals_for_list(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return foz.write_help_into(serr, _subcommand_list.__doc__)

    return _top_or_list(sin, sout, serr, vals, foz, efx)


def _top_or_list(sin, sout, serr, vals, foz, efx):

    # Mutex on these

    def these():
        def highest_priority_first():
            return 'by_priority', 'ASCENDING'

        def oldest_first():
            return 'by_time', 'ASCENDING'

        def newest_first():
            return 'by_time', 'DESCENDING'

        return locals().items()

    these = tuple((k, v()) for (k, v) in these() if vals.pop(k, False))
    if 1 < (leng := len(these)):
        # hack-back the long version of the option. foz has short somewhere
        as_opts = (''.join(('--', tup[0].replace('_', '-'))) for tup in these)
        and_list = ' and '.join(as_opts)
        serr.write(f"{and_list} are mutually exclusive. {foz.invite_line}")
        return 4
    sort_by = these[0][1] if leng else None

    # Resolve the data file itself
    readme = efx.resolve_issues_file_path()
    if readme is None:
        return 4

    readme_is_dash = '-' == readme
    do_batch = vals.get('batch')

    # Resolve query
    mon = efx.emission_monitor
    user_query_tokens = vals.pop('query', None)
    # (used to parse the query here before #history-B.4)

    # Quad table
    if do_batch:
        if readme_is_dash:
            # Read from stdin and each line is a readme path
            opened = sin
        else:
            # Open readme and each line is passed to the collection constructor
            opened = open(readme)
    elif readme_is_dash:
        # Pass stdin to open as the collection
        opened = _pass_thru_context_manager((sin,))
    else:
        # Pass the readme path to the collection
        opened = _pass_thru_context_manager((readme,))

    # Run the query
    from pho._issues import records_via_query_ as func
    itr = func(opened, user_query_tokens, sort_by, do_batch, mon.listener)
    two = next(itr)
    if two is None:
        return mon.returncode
    jsoner, counts = two

    # Prepare for output
    is_by_time = sort_by and 'by_time' == sort_by[0]
    is_complicated = do_batch or is_by_time
    # being "complicated" means needing strange columns

    if (fmt := vals.get('format')) is not None:
        allow = 'json', 'table'
        if fmt not in allow:
            _ = ''.join(('{', '|'.join(allow), '}'))
            inv = foz.invite_line
            serr.write(''.join((f'-f must be {_}. Had: {fmt!r}. ', inv)))
            return 4
        if 'table' == fmt:
            fmt = 'most_complicated' if is_complicated else 'simplest'
    else:
        fmt = 'json' if is_by_time else 'simplest'

    # Prepare to limit output
    if (num := vals.get('number')) is None:
        def stop_here():
            return False
    else:
        def stop_here():
            return num == counts.items

    # Output results
    oa = getattr(_output_adapters, fmt)(sout, do_batch, sort_by, jsoner)
    oa.at_beginning_of_output_collection()
    curr_readme = None
    for rec in itr:
        counts.items += 1
        if curr_readme != rec.readme:
            curr_readme = rec.readme
            oa.maybe_output_header(rec)
        oa.output_record(rec)
        if stop_here():
            break
    oa.at_ending_of_output_collection()

    # Output summary
    if do_batch or 0 == counts.items or 'json' == fmt:
        serr.write(f"({counts.items} items(s) in {counts.files} file(s))\n")
    return mon.exitstatus


# == Output adapters

def _output_adapter(k):
    def decorator(func):
        setattr(_output_adapters, k, func)
    return decorator


_output_adapters = _output_adapter  # #watch-the-world-burn


@_output_adapter('most_complicated')
def _(sout, do_batch, sort_by, jsoner):
    """
    What follows is the "formal" order for the pieces that make up a line.
    We say "formal" because you will never have all these pieces in one
    actual line because mtime and priority are mutex. The formal order:

    1) any mtime cel goes first because fixed width & looks best leftmost
    2) the original line (chomped IFF it has something after it)
    3) any priority idk
    4) any readme
    5) a newline IFF you did (3) and/or (4)

    We build up a row renderer dynamically (once per collection) that is
    a list of cel renderers. At render time the cel renderers are looped
    through once per row (so a loop within a loop, in effect).

    .#history-B.4 buries code where we wrote different permutations
    "by hand" so we could avoid this inner loop. But the performance gain
    of doing this was probably unnoticable, and it came with code that
    became unreasonably complex-looking when we added priority.
    """

    yes_no = {k: False for k in ('by_time', 'orig_line', 'by_priority', 'readme')}  # noqa: E501

    # If there was a sort by, turn on the particular cel to display the value
    if sort_by:
        by_what, _asc_desc = sort_by
        yes_no[by_what]
        yes_no[by_what] = True

    # Display which readme the issue came from IFF you're doing batch mode
    if do_batch:
        yes_no['readme'] = True

    # Always display the original line (sort of)
    yes_no['orig_line'] = True

    # Determine whether we chomp the newline off the original line
    for last_cel in (k for k, v in yes_no.items() if v):
        pass
    orig_line_is_rightmost_cel = 'orig_line' == last_cel

    def cel_renderers():

        if yes_no['by_time']:
            yield cel_for_time

        if orig_line_is_rightmost_cel:
            yield orig_line_as_is
        else:
            yield chomped_orig_line

        if yes_no['by_priority']:
            # (do nothing, it's already in the orig line (thank goodness))
            pass

        if yes_no['readme']:
            yield cel_for_readme

        if not orig_line_is_rightmost_cel:
            yield lambda _: '\n'

    def pieces(rec):
        return (func(rec) for func in cel_renderers)

    def cel_for_time(rec):
        return rec.mtime.strftime(use_strftime_fmt)

    if yes_no['by_time']:
        from kiss_rdb.vcs_adapters.git import DATETIME_FORMAT as strftime_fmt
        use_strftime_fmt = f"| {strftime_fmt} "

    def cel_for_readme(rec):
        return ''.join((' | ', rec.readme))

    def chomped_orig_line(rec):
        return rec.row_AST.to_line()[:-1]

    def orig_line_as_is(rec):
        return rec.row_AST.to_line()

    class lets_go:  # #class-as-namespace
        at_beginning_of_output_collection = _niladic_no_op
        maybe_output_header = _monadic_no_op

        def output_record(rec):
            sout.write(''.join(pieces(rec)))

        at_ending_of_output_collection = _niladic_no_op

    cel_renderers = tuple(cel_renderers())

    return lets_go


@_output_adapter('json')
def _(sout, do_batch, sort_by, jsoner):

    class json_output_adapter:  # #class-as-namespace
        def at_beginning_of_output_collection():
            sout.write('[')

        def maybe_output_header(_):
            pass

        output_record = jsoner(sout, 'by_time' == sort_by[0])

        def at_ending_of_output_collection():
            sout.write(']\n')

    return json_output_adapter


@_output_adapter('simplest')
def _(sout, do_batch, sort_by, jsoner):

    def output_header(rec):
        if subsequent():
            sout.write('\n')
        sout.write(f"## {rec.readme}\n")

    class simplest_output_adapter:  # #class-as-namespace
        at_beginning_of_output_collection = _niladic_no_op

        maybe_output_header = output_header if do_batch else _monadic_no_op

        def output_record(rec):
            sout.write(rec.row_AST.to_line())

        at_ending_of_output_collection = _niladic_no_op

    def subsequent():
        if subsequent.value:
            return True
        subsequent.value = True

    subsequent.value = False

    return simplest_output_adapter


# ==

def _formals_for_find_readmes():
    yield '-h', '--help', 'This screen'
    yield 'path?', "Filesystem path to search (default: '.')"  # [path] #todo


def _subcommand_find_readmes(sin, sout, serr, argv, env_and_vals_er):
    """Find the README.md files in our sub-projects

    This is a development aid.
    """

    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = _formals_via(_formals_for_find_readmes(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return foz.write_help_into(serr, _subcommand_find_readmes.__doc__)

    path = vals.get('path', '.')
    args = ('find', path, '-maxdepth', '2', '-name', 'README.md')
    import subprocess as sp
    opened = sp.Popen(args=args, text=True, cwd='.',
                      stdin=sp.DEVNULL, stdout=sp.PIPE, stderr=sp.PIPE)
    with opened as proc:
        while True:
            did = False
            for line in proc.stderr:
                serr.write(f"error from find?: {line}")
                did = True
            if did:
                exitstatus = 4
                break
            for line in proc.stdout:
                did = True
                sout.write(line)
            if not did:
                break
        proc.wait()
        exitstatus = proc.returncode
    return exitstatus


def _subcommand_which(sin, sout, serr, argv, efx):
    """Which readme is being used? (per env variable 'PHO_README')"""

    prog_name = (bash_argv := list(reversed(argv))).pop()
    formals = (_formal_for_help,)
    foz = _formals_via(formals, lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return foz.write_help_into(serr, _subcommand_which.__doc__)

    readme = efx.resolve_issues_file_path(be_verbose=True)
    if readme is None:
        serr.write("no readme selected.\n")
        return 4

    sout.write(readme)
    sout.write('\n')
    return 0


def _formals_for_use():
    yield '-w', '--write', f"attempts to write the value to ~/{_dotfile_entry}"
    yield _formal_for_help
    yield '<readme>', 'path to file'


def _subcommand_use(sin, sout, serr, argv, efx):
    """Use a different readme (a shellable line. experimental)

    EXPERIMENTALLY you can try `$( pi use ./foo/bar/README.md )`
    You can get a list of available files with the `find` subcommand
    sibling to this one.
    """

    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = _formals_via(_formals_for_use(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return foz.write_help_into(serr, _subcommand_use.__doc__)

    readme = vals.pop('readme')
    do_write = vals.pop('write', False)
    assert not vals

    mon = efx.emission_monitor
    from pho._issues.dotfile_ import write_dotfile as func

    here = efx.produce_dotfile_path()

    for line in func(here, readme, do_write, mon.listener):
        sout.write(line)
        if not line or '\n' != line[-1]:
            sout.write('\n')

    return mon.returncode


def _formals_for_graph():
    yield '-i', '--show-identifiers', 'whether or not to output "[#123.4]"'
    yield '-g', '--show-group-nodes', 'without this, prettier groups'
    yield '-t', '--add-target=IDENTIFIER*', 'output only the subgraphs etc'
    yield _formal_for_help


def _subcommand_graph(sin, sout, serr, argv, efx):
    """Experimental graph-viz visualization of issues..

    Use tags in your issue rows like `#after:[#123.4]` or `#part-of:[#123.4]`
    """

    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = _formals_via(_formals_for_graph(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return foz.write_help_into(serr, _subcommand_graph.__doc__)

    readme = efx.resolve_issues_file_path()
    if readme is None:
        return 4

    mon = efx.emission_monitor
    from pho._issues import issues_collection_via_ as func
    ic = func(readme, mon.listener)
    # ..

    kw = {}
    kw['targets'] = vals.get('add_target', ())
    kw['show_group_nodes'] = vals.get('show_group_nodes', False)
    kw['show_identifiers'] = vals.get('show_identifiers', False)
    from pho._issues.graph import to_graph_lines_ as func
    for line in func(ic, mon.listener, **kw):
        sout.write(line)

    return mon.exitstatus


# == Support

def _resolve_issues_file(efx, listener):

    # If it's set in the parent CLI values, use that
    if (path := efx.parent_CLI_values.get('readme')):
        def lines():
            yield "via parameter"
        listener('verbose', 'expression', 'via_param', lines)
        return path

    # If it's set in the env var, use that
    path = efx.environ.get('PHO_README')
    if path:
        def lines():
            yield "via PHO_README environment variable"
        listener('verbose', 'expression', 'via_env_var', lines)
        return path

    # If this dotfile exists, ham town
    rfile = None
    dotpath = efx.produce_dotfile_path()
    try:
        rfile = open(dotpath, 'r')
    except FileNotFoundError:
        pass
    if rfile is None:
        return

    from pho._issues.dotfile_ import read_issues_file_path_from_dotfile as func
    path = func(rfile, listener)
    if path:
        def lines():
            yield f"via {dotpath}"
        listener('verbose', 'expression', 'via_dotfile', lines)
    return path


def _build_external_functions(
        serr, CLI_vals, enver,
        apply_patch, produce_open_function):

    def memoized_property(orig_f):  # #[#510.4]
        def use_f(self):
            if not hasattr(o, fname):
                setattr(o, fname, orig_f(self))
            return getattr(o, fname)
        fname = orig_f.__name__
        o = memoized_property
        return property(use_f)

    class ExternalFunctions:

        def __init__(o):
            o.apply_patch = apply_patch
            o.produce_open_function = produce_open_function
            o.parent_CLI_values = CLI_vals
            o._once = False

        def resolve_issues_file_path(self, be_verbose=False):
            assert not self._once
            self._once = True

            listener = _verbosify_listener(
                be_verbose, self.emission_monitor.listener)

            readme = _resolve_issues_file(self, listener)
            if readme:
                return readme
            serr.write("please use -r or PHO_README or 'use --write'.\n")

        def produce_dotfile_path(self):
            env = self.environ
            from os.path import join as _path_join
            return _path_join(env['HOME'], '.tmx-pho-issues.rec')

        @memoized_property
        def emission_monitor(_):
            return _error_monitor(serr)

        @memoized_property
        def environ(_):
            return enver()

    return ExternalFunctions()


def _build_int_matcher():
    def match(token):
        if (md := re.match('^-([1-9][0-9]*)$', token)) is None:
            return
        return int(md[1])
    import re
    return match


def _desc_lines_for_priority():
    return (
        'Issues with a #priority tag should have a value between 0.0 and 1.0',
        'EXCLUSIVE like "#priority:0.3" and a value unique to the collection.',
        'The lower the number, the *higher* the priority. (Think of it',
        'as a measure of distance from your immediate attention.)',
        'Ordering by priority implies selecting only those issues tagged',
        'with this tag. As such, it cannot be used in combination with other',
        'sort criteria because a secondary criteria would never be engaged.',
        'EXPERIMENTAL. We may prefer a dependency graph feature over this.',
        'We may flip the polarity so higher numbers are higher priority.')


_formal_for_help = '-h', '--help', 'this screen'
_dotfile_entry = ".tmx-pho-issues.rec"


# == Dispatchers

def _formals_via(defs, prog_namer, sub_commands=None):
    from script_lib.cheap_arg_parse import formals_via_definitions as func
    return func(defs, prog_namer, sub_commands)


def _error_monitor(serr):
    from script_lib.magnetics.error_monitor_via_stderr import func
    return func(serr, default_error_exitstatus=4)


# == Smalls

def _verbosify_listener(be_verbose, listener):
    if be_verbose:
        return listener

    def use_listener(sev, *rest):
        if 'verbose' == sev:
            return
        listener(sev, *rest)
    return use_listener


def _pass_thru_context_manager(lines):
    from contextlib import nullcontext as func
    return func(lines)


def _monadic_no_op(_):
    pass


def _niladic_no_op():
    pass


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))


if '__main__' == __name__:
    efx = _production_external_functions
    from sys import stdin, stdout, stderr, argv
    exit(CLI(stdin, stdout, stderr, argv, efx))

# #history-B.4
# #born
