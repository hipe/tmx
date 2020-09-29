from script_lib.cheap_arg_parse import formals_via_definitions as formals_via


def _formals_for_toplevel():
    yield '-r', '--readme=PATH', "or use PHO_README. '-' might read from STDIN"
    yield '-h', '--help', 'This screen'
    yield 'command [..]', "One of the below"


def _subcommands():
    yield 'list', lambda: _subcommand_list
    yield 'open', lambda: _subcommand_open
    yield 'close', lambda: _subcommand_close
    yield 'find-readmes', lambda: _subcommand_find_readmes
    yield 'which', lambda: _subcommand_which


def CLI(sin, sout, serr, argv, enver):
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

    foz = formals_via(_formals_for_toplevel(), prog_name, _subcommands)
    vals, es = foz.nonterminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return _write_help_into(serr, CLI.__doc__, foz)

    # The Ultra-Sexy Mounting of an Alternation Component:
    cmd_tup = vals.pop('command')
    cmd_name, cmd_funcer, es = foz.parse_alternation_fuzzily(serr, cmd_tup[0])
    if not cmd_name:
        return es

    ch_pn = ' '.join((prog_name(), cmd_name))  # we don't love it, but later
    ch_argv = (ch_pn, * cmd_tup[1:])

    def env_and_related():
        from os import environ
        return environ, vals

    return cmd_funcer()(sin, sout, serr, ch_argv, env_and_related)


# == FROM

def _formals_for_open():
    yield '-h', '--help', 'this screen'
    yield '<message>', 'any one line of some appropriate length'


def _subcommand_open(sin, sout, serr, argv, env_stacker):
    """Does a complicated identifier provisioning thing"""

    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = formals_via(_formals_for_open(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return _write_help_into(serr, _subcommand_open.__doc__, foz)

    env_stack = env_stacker()
    if (readme := _resolve_readme(serr, env_stack)) is None:
        return 4

    dct = {'main_tag': '#open', 'content': vals['message']}
    mon = _error_monitor(serr)
    from pho._issues.edit import open_issue as func
    bef_aft = func(readme, dct, mon.listener)
    if bef_aft is not None:
        before, after = bef_aft
        if before:
            serr.write(f"before: {before.to_line()}")
            serr.write(f"after:  {after.to_line()}")
        else:
            serr.write("line:   {after.to_line()}")
    return mon.exitstatus

# == TO


def _formals_for_close():
    yield '-h', '--help', 'this screen'
    yield '<identifier>', 'whomst ("123" or "#123" or "[#123]" all OK)'


def _subcommand_close(sin, sout, serr, argv, env_stacker):
    """Actually a macro around update..."""

    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = formals_via(_formals_for_close(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return _write_help_into(serr, _subcommand_close.__doc__, foz)

    env_stack = env_stacker()
    if (readme := _resolve_readme(serr, env_stack)) is None:
        return 4

    eid = vals['identifier']

    mon = _error_monitor(serr)
    from pho._issues.edit import close_issue as func
    func(readme, eid, mon.listener)
    return mon.exitstatus


def _formals_for_list():
    yield '-h', '--help', 'this screen'
    yield '-m', '--oldest-first', 'sort by time last modified (acc. to VCS)'
    yield '-M', '--newest-first', 'sort by time last modified (acc. to VCS)'
    yield '-b', '--batch', "treat --readme (or PHO_README) as list of paths"
    yield '[query […]]', "e.g '#open'. Currently limited to 1 tag."


def _subcommand_list(sin, sout, serr, argv, env_stacker):
    """Do a thing, mainly query"""

    bash_argv = list(reversed(argv))
    prog_name = bash_argv.pop()
    foz = formals_via(_formals_for_list(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return _write_help_into(serr, _subcommand_list.__doc__, foz)

    # Local variables via vals
    sort_by_time = None
    if vals.get('oldest_first'):
        if vals.get('newest_first'):
            serr.write(f"-m and -M are mutually exclusive. {foz.invite_line}")
            return 4
        sort_by_time = 'ASCENDING'
    elif vals.get('newest_first'):
        sort_by_time = 'DESCENDING'

    env_stack = env_stacker()
    if (readme := _resolve_readme(serr, env_stack)) is None:
        return 4

    readme_is_dash = '-' == readme
    do_batch = vals.get('batch')
    query = vals.get('query')

    # Resolve query
    mon = _error_monitor(serr)
    if query is not None:
        from pho._issues import parse_query_ as func
        if (query := func(query, mon.listener)) is None:
            return 4

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
    itr = func(opened, sort_by_time, query, do_batch, mon.listener)
    jsoner, counts = next(itr)

    # Prepare for output
    def maybe_output_header(_):
        pass

    maybe_output_header(None)  # #todo syntax checker bug

    do_json = False
    if sort_by_time is None:
        def output_record(rec):
            sout.write(rec.row_AST.to_line())
        if do_batch:
            def maybe_output_header(rec):
                sout.write(f"## {rec.readme}\n")
    else:
        output_record = jsoner(sout)
        do_json = True

    # Output results
    if do_json:
        sout.write('[')

    curr_readme = None
    for rec in itr:
        counts.items += 1
        output_record(rec)
        if curr_readme != rec.readme:
            curr_readme = rec.readme
            maybe_output_header(rec)

    if do_json:
        sout.write(']\n')

    if do_batch or 0 == counts.items:
        serr.write(f"({counts.items} items(s) in {counts.files} file(s)\n")
    return mon.exitstatus


def _resolve_readme(serr, env_stack):
    readme = env_stack[1].get('readme') or env_stack[0].get('PHO_README')
    if readme:
        return readme
    serr.write("please use -r or PHO_README for now.\n")


def _formals_for_find_readmes():
    yield '-h', '--help', 'This screen'
    yield 'path?', "Filesystem path to search (default: '.')"  # [path] #todo


def _subcommand_find_readmes(sin, sout, serr, argv, env_and_vals_er):
    """find the README.md files in our sub-projects

    This is a development aid.
    """

    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = formals_via(_formals_for_find_readmes(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return _write_help_into(serr, _subcommand_find_readmes.__doc__, foz)

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


def _subcommand_which(sin, sout, serr, argv, env_stacker):
    """Which readme is selected? (per env variable 'PHO_README')"""

    prog_name = (bash_argv := list(reversed(argv))).pop()
    formals = (('-h', '--help', 'this screen'),)
    foz = formals_via(formals, lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return _write_help_into(serr, _subcommand_which.__doc__, foz)

    env_stack = env_stacker()
    if (readme := _resolve_readme(serr, env_stack)) is None:
        serr.write("no readme selected.\n")
        return 4

    sout.write(readme)
    sout.write('\n')
    return 0


def _write_help_into(serr, doc, foz):
    for line in foz.help_lines(doc):
        serr.write(line)
    return 0


def _error_monitor(serr):
    from script_lib.magnetics import error_monitor_via_stderr as func
    return func(serr, default_error_exitstatus=4)


def _pass_thru_context_manager(lines):  # #[#510.12] pass-thru context manager
    class cm:
        def __enter__(_):
            return lines

        def __exit__(self, *_3):
            pass

    return cm()


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))


if '__main__' == __name__:
    def enver():
        xx()
    from sys import stdin, stdout, stderr, argv
    exit(CLI(stdin, stdout, stderr, argv, enver))

# #born
