from script_lib.cheap_arg_parse import formals_via_definitions as formals_via


def _formals_for_toplevel():
    yield '-r', '--readme=PATH', "or use PHO_README. '-' might read from STDIN"
    yield '-h', '--help', 'This screen'
    yield 'command [..]', "One of the below"


def _subcommands():
    yield 'list', lambda: _subcommand_list
    yield 'find-readmes', lambda: _subcommand_find_readmes


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


def _formals_for_list():
    yield '-h', '--help', 'this screen'
    yield '-b', '--batch', "treat --readme (or PHO_README) as list of paths"
    yield '[query […]]', "e.g '#open'. Currently limited to 1 tag."


def _subcommand_list(sin, sout, serr, argv, env_stacker):
    """Do a thing, mainly query"""

    bash_argv = list(reversed(argv))
    prog_name = bash_argv.pop()
    foz = formals_via(_formals_for_list(), lambda: prog_name)
    vals, es = foz.nonterminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return _write_help_into(serr, _subcommand_list.__doc__, foz)

    # Local variables via vals
    env_stack = env_stacker()
    readme = env_stack[1].get('readme') or env_stack[0].get('PHO_README')
    if not readme:
        serr.write("please use -r or PHO_README for now.\n")
        return 4
    readme_is_dash = '-' == readme
    do_batch = vals.get('batch')
    query = vals.get('query')

    # Resolve query
    from script_lib.magnetics import error_monitor_via_stderr as func
    mon = func(serr, default_error_exitstatus=4)
    from pho._issues import parse_query_, list_
    if query and (query := parse_query_(query, mon.listener)) is None:
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

    # Go money
    file_count, item_count = 0, 0
    with opened as readme_paths:
        for readme_path in readme_paths:
            file_count += 1
            if do_batch:
                sout.write(f"## {readme_path}")
                readme_path = readme_path[0:-1]  # chop
            itr = list_(query, readme_path, mon.listener)
            if not itr:
                return mon.exitstatus
            for row_AST in itr:
                item_count += 1
                sout.write(row_AST.to_line())
    if do_batch:
        serr.write(f"({item_count} items(s) in {file_count} file(s)\n")
    return mon.exitstatus


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


def _write_help_into(serr, doc, foz):
    for line in foz.help_lines(doc):
        serr.write(line)
    return 0


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
