from script_lib.cheap_arg_parse import \
        cheap_arg_parse_branch as _cheap_arg_parse_branch, \
        formals_via_definitions as _foz_via


def run_CLI(sin, sout, serr, argv, sources_dir):
    """
    EDIT
    """

    def descer():
        return iter(run_CLI.__doc__.splitlines(keepends=True))

    commands = _command_via_sources_directory(sources_dir)

    efx = {'hello_i_am_efx': 'created_here'}
    return _cheap_arg_parse_branch(
        sin, sout, serr, argv, commands, descer, efx)


func = run_CLI


def _command_via_sources_directory(sources_dir):
    def build_command_funcer(entry):
        def command(sin, sout, serr, argv, efx):
            efx['fixture_source_path'] = path_join(sources_dir, entry)
            return _generic_command(sin, sout, serr, argv, efx)
        command.__doc__ = f"Build tings for {entry}. Writes to STDOUT"
        return lambda: command

    from os.path import join as path_join

    from os import listdir
    splay = listdir(sources_dir)

    from fnmatch import fnmatch
    for entry in splay:
        if not fnmatch(entry, '[!_]*'):  # ..
            continue
        yield entry, build_command_funcer(entry)


def _generic_command(sin, sout, serr, argv, efx):
    """
    The associated path is a directory of files in some obvious order.

    Under the hood; we create a temporary directory, init it as a git
    repository, add the first file snapshot, commit it, copy the second
    file snapshot over to the file, add it, commit it and so on until
    all the snapshots have been written in to the repository.

    There will be tons of other metadata stored in a recfile probably.

    The end result is we write to STDOUT the results of going `git log`
    (with particular options stored in the parameters recfile probably)
    on the respository.
    """

    bash_argv = list(reversed(argv))
    prog_name = bash_argv.pop()
    foz = _foz_via(_formals_for_generic_command(), lambda: prog_name)
    vals, rc = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return None, rc
    if vals.get('help'):
        return foz.write_help_into(sout, _generic_command.__doc__)

    source_path = efx['fixture_source_path']

    from script_lib.magnetics.error_monitor_via_stderr import func
    mon = func(serr)

    from . import real_system_response_via_story_source_path_ as func
    lines = func(source_path, mon.listener)
    sout.writelines(lines)
    return mon.returncode


def _formals_for_generic_command():
    yield '-h', '--help', 'this screen'

# #born
