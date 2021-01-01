def cli_for_production():

    class efx:  # #class-as-namespace

        def produce_monitor():
            from script_lib.magnetics.error_monitor_via_stderr import func
            return func(stderr, default_error_exitstatus=5678)

        def produce_environ():
            from os import environ as result
            return result

    from sys import stdin, stdout, stderr, argv
    exit(_CLI(stdin, stdout, stderr, argv, efx))


def _CLI(sin, sout, serr, argv, efx):  # efx = external functions
    def line_contents():
        yield 'experiments in generating documents from "notecards"'
    from script_lib.cheap_arg_parse import cheap_arg_parse_branch as func
    return func(sin, sout, serr, argv, _commands(), line_contents, efx)


def _lazy(build):  # [#510.8] yet another take on "lazy"
    class Lazy:
        def __init__(self):
            self._is_first = True

        def __call__(self):
            if self._is_first:
                self._is_first = False
                self._value = build()
            return self._value
    return Lazy()


def _build_memoized_thing():

    coll_path_env_var_name = 'PHO_COLLECTION_PATH'

    class Fellow:

        @property
        def descs(_):
            yield 'The path to the directory with the notecards '
            yield '(the directory that contains the `entities` directory)'
            yield f'(or set the env var {coll_path_env_var_name})'

        def require_collection_path(_, efx, listener):
            collection_path = efx.enver().get(coll_path_env_var_name)
            if collection_path is not None:
                return collection_path
            whine_about(listener)

    def whine_about(listener):
        listener('error', 'structure', 'parameter_is_currently_required',
                 lambda: {'reason_tail': '--collection-path'})

    return Fellow()


CP_ = _lazy(_build_memoized_thing)


def _commands():
    # Discussion: originally we liked the auto-magic-ness of relying on only
    # the filesystem to produce our command tree; but there's two problems with
    # that: 1) the filesystem (not us) chooses the order; 2) we have to hit the
    # filesystem to determine the constituency for every invocation of every
    # pho command. Clever thing that used to do this buried at #history-B.4

    yield 'issues', lambda: _load_commonly('issues')
    yield 'listen', lambda: _listen_command
    yield 'watch', lambda: _watch_command
    yield 'connect', _load_the_connect_COMMAND
    yield 'document-generate', lambda: _load_commonly('document_generate')
    yield 'notecards-graph', lambda: _load_commonly('notecards_graph')
    yield 'static-webserver', lambda: _static_webserver_command
    yield 'toml2eno', lambda: _load_commonly('toml2eno')


def _load_commonly(mod_tail):
    from importlib import import_module as func
    return func(f'pho.cli.commands.{mod_tail}').CLI


def _formals_for_listen():
    yield '-c', '--command=CMD', "Don't run the server, invoke a command", \
            "against the config, like `foo.bar.baz`. type `list`"
    yield '-h', '--help', 'this screen'
    yield 'config-path?', 'xx xx xx'


def _listen_command(sin, sout, serr, argv, efx):
    "Run the generation service"

    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = _foz_via(_formals_for_listen(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es
    if vals.get('help'):
        _ = _listen_command.__doc__
        return foz.write_help_into(sout, _)

    config_path = vals.pop('config_path', None)
    cmd = vals.pop('command', None)
    assert not vals

    kw = {}
    config = None
    if config_path:
        from pho.generation_service_.generation_config_via_definition import \
                via_path as func

        use_environ = efx.produce_environ()
        config = func(config_path, use_environ)
        kw['config'] = config

    mon = efx.produce_monitor()
    if cmd:
        if config is None:
            serr.write("-c option needs a <config-path> argument\n")
            return 1

        for line in config.EXECUTE_COMMAND(cmd, mon.listener):
            sout.write(line)
    else:
        from pho.generation_service_.run_message_broker_via_config import func
        func(mon.listener, _port, **kw)  # run forever or until interrupt
    return mon.returncode


def _formals_for_watch():
    yield '--preview', 'write generated ARGV to stdout and exit'
    yield '-h', '--help', 'this screen'
    yield '<dir>', 'zib zib zub zub'


def _watch_command(sin, sout, serr, argv, efx):
    """Watch a directory for changes (EXPERIMENTAL).
    Currently hardcoded to use {which}, the only one we have an adapter for.
    """

    which = 'watchexec'

    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = _foz_via(_formals_for_watch(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es
    if vals.get('help'):
        doc = _watch_command.__doc__.format(which=which)
        return foz.write_help_into(sout, doc)

    do_preview = vals.pop('preview', False)
    dir_path = vals.pop('dir')
    assert not vals

    mon = efx.produce_monitor()

    from importlib import import_module as func
    ada = func(f"pho.file_watch_adapters_.{which}.run")

    # Check version
    if not ada.CHECK_VERSION(mon.listener):
        return mon.returncode

    # Money
    argv = ada.ARGV_VIA_DIRECTORY(dir_path)

    if do_preview:
        serr.write("Here is a preview of the command:\n")
        from shlex import join as func
        line = func(argv)
        sout.write(line)
        sout.write('\n')
        return 0

    from os import execvp as func
    func(argv[0], argv)
    raise RuntimeError('never see')


def _load_the_connect_COMMAND():
    from pho.cli.commands.connect import build_CLI_command_ as func
    return func(_port, _foz_via)


def _formals_for_static_webserver():
    yield '-t', '--target=TARGET', '(pass thru to livereload)'
    yield '-h', '--help', 'this screen'
    yield 'document-root', 'path to the directory of static files'


def _static_webserver_command(sin, sout, serr, argv, efx):
    "(for now, just livereload) Just for dev not prod"

    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = _foz_via(_formals_for_static_webserver(), lambda: prog_name)

    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es
    if vals.get('help'):
        _ = _static_webserver_command.__doc__
        return foz.write_help_into(sout, _)

    path = vals.pop('document_root')
    target = vals.pop('target', None)
    assert not vals

    kw = {}
    if target:
        kw['target'] = target
    mon = efx.produce_monitor()
    from pho.web_adapters_.livereload import SOMETHING_DUMPLING as func
    func(path, mon.listener, **kw)
    return mon.returncode


def _foz_via(defs, pner, x=None):
    from script_lib.cheap_arg_parse import formals_via_definitions as func
    return func(defs, pner, x)


_port = 10_007  # purely arbitrary historical reasons

# #history-B.4
# #history-A.1 rewrite during cheap arg parse not click
# #born.
