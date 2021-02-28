def cli_for_production():

    class efx(_ExternalFunctions):

        def produce_monitor(_):
            from script_lib.magnetics.error_monitor_via_stderr import func
            return func(stderr, default_error_exitstatus=5678)

        def produce_environ(_):
            from os import environ as result
            return result

    from sys import stdin, stdout, stderr, argv
    exit(_CLI(stdin, stdout, stderr, argv, efx()))


def _CLI(sin, sout, serr, argv, efx):  # efx = external functions
    def line_contents():
        yield 'experiments in generating documents from "notecards"'
    func = _cheap_arg_parse_branch
    return func(sin, sout, serr, argv, _commands(), line_contents, efx)


def _memoized_property(orig_f):  # custom memoizy decorator #[#510.6]
    def use_f(self):
        if (dct := getattr(self, '_memo', None)) is None:
            self._memo = (dct := {})
        if key not in dct:
            dct[key] = orig_f(self)
        return dct[key]
    key = orig_f.__name__
    return property(use_f)


class _ExternalFunctions:

    @_memoized_property
    def collection_path_option_definition(self):
        return self._coll_path_tools['build_coll_path_option_definition']()

    def require_collection_path(self, listener, vals):
        dct = self._coll_path_tools
        return _require_collection_path(listener, vals, self, dct)

    @_memoized_property
    def _coll_path_tools(_):
        return _build_collection_path_tools()


def _build_collection_path_tools():

    coll_path_env_var_name = 'PHO_COLLECTION_PATH'

    def build_coll_path_option_definition():
        return '-c', '--collection-path=PATH', * descs()

    def descs():
        if True:
            yield 'The path to the directory with the notecards '
            yield '(the directory that contains the `entities` directory)'
            yield f'(or set the env var {coll_path_env_var_name})'

    def whine_about(listener):
        listener('error', 'structure', 'parameter_is_currently_required',
                 lambda: {'reason_tail': '--collection-path'})

    return locals()


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
    yield 'generate', lambda: _load_commonly('generate')
    yield 'history', lambda: _history_command
    yield 'static-webserver', lambda: _static_webserver_command
    yield 'toml2eno', lambda: _load_commonly('toml2eno')


def _load_commonly(mod_tail):
    from importlib import import_module as func
    return func(f'pho.cli.commands.{mod_tail}').CLI


def _formals_for_listen():
    yield '-c', '--command=CMD', "Don't run the server, invoke a command", \
            "against the config, like `foo.bar.baz`. type `list`"
    yield '-p', '--port=PORT', "the port to listen on (there is a default)"
    yield '-h', '--help', 'this screen'
    yield 'config-path?', 'not nec. to ping the server. nec. to generate files'


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

    if (rc := parse_port_(serr, vals, _port, foz)):
        return rc

    config_path = vals.pop('config_path', None)
    cmd = vals.pop('command', None)
    port = vals.pop('port')
    assert not vals

    kw = {}
    mon = efx.produce_monitor()

    # Process the config option if it was passed (processing it can fail)
    config = None
    if config_path:
        use_environ = efx.produce_environ()
        from pho.generation_service_.generation_config_via_definition import \
            via_path as func
        config = func(config_path, use_environ, mon.listener)

        if config is None:
            return mon.returncode

        kw['config'] = config

    # The --command option requires a config
    if cmd:
        return _execute_command_now__no_daemonize(sout, serr, cmd, config, mon)

    from pho.generation_service_.run_message_broker_via_config import func
    func(mon.listener, port, **kw)  # run forever or until interrupt
    return mon.returncode


def _execute_command_now__no_daemonize(sout, serr, cmd, config, mon):
    if config is None:
        serr.write("-c option needs a <config-path> argument\n")
        return 123

    def recv_output_line(line):
        sout.write(line)
        sout.write('\n')
    from pho.config_component_ import capture_output_lines_ as func
    listener = func(recv_output_line, mon.listener)
    rc = config.EXECUTE_COMMAND(cmd, listener)
    if not isinstance(rc, int):  # #todo
        raise RuntimeError(f"oops: {type(rc)}")
    return rc


def _formals_for_watch():
    yield '--preview', 'write generated ARGV to stdout and exit'
    yield '-x', '--file-extension=EXT', '"md" or "eno" (default: "md")'
    yield '-p', '--port=PORT', 'how to reach the message broker (has default)'
    yield '-v', '--verbose', 'turn on verbose output (probably to vendor)'
    yield '-h', '--help', 'this screen'
    yield '<dir>', 'the directory to watch'


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

    ext = vals.pop('file_extension', 'md')
    if ext not in (these := ('md', 'eno')):
        or_list = ' or '.join(repr(s) for s in these)
        serr.write(f"--file-extension must be {or_list} (had {ext!r})\n")
        return 123

    if (rc := parse_port_(serr, vals, _port, foz)):
        return rc

    do_preview = vals.pop('preview', False)
    dir_path = vals.pop('dir')
    port = vals.pop('port')
    be_verbose = vals.pop('verbose', False)
    assert not vals

    mon = efx.produce_monitor()

    from importlib import import_module as func
    ada = func(f"pho.file_watch_adapters_.{which}.run")  # see [#407.C]

    # Check version
    if not ada.CHECK_VERSION(mon.listener):
        return mon.returncode

    # Money
    argv = ada.ARGV_VIA_DIRECTORY(dir_path, ext, port, be_verbose)

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


# == BEGIN history (not quite long enough for its own file, even tho a branch)

def _history_commands():
    yield 'update', lambda: _history_update_command


def _history_command(sin, sout, serr, argv, efx):
    """Interface to "document history" data warehousing (sqlite3 database)

    Hopefully you won't need to interface with this direcly except during
    development and when something goes wrong
    """

    cx = _history_commands()
    def descrs(): return _history_command.__doc__
    return _cheap_arg_parse_branch(sin, sout, serr, argv, cx, descrs, efx)


def _formals_for_history_update(efx):
    yield efx.collection_path_option_definition
    yield '-h', '--help', 'this screen'


def _history_update_command(sin, sout, serr, argv, efx):
    """Create or update the sqlite3 database as necessary, for generating

    document history. Ideally the plugin will just do this and you won't
    have to interface with it directly.
    """

    bash_argv = list(reversed(argv))
    long_prog_name = bash_argv.pop()

    def prog_name():
        from script_lib.cheap_arg_parse import shorten_long_program_name as fun
        return fun(long_prog_name)

    foz = _foz_via(_formals_for_history_update(efx), prog_name)

    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        serr.writelines(foz.help_lines(doc=_history_update_command.__doc__))
        return 0

    mon = efx.produce_monitor()
    listener = mon.listener

    coll_path, rc = efx.require_collection_path(listener, vals)
    if not coll_path:
        return rc

    assert not vals

    from pho.document_history_ import func
    res = func(coll_path, listener)
    assert res is None

    return mon.returncode

# == END history


def _formals_for_static_webserver():
    yield '-t', '--target=TARGET', '(pass thru to livereload)'
    yield '-p', '--port=PORT', 'port to listen on for http. there is a default'
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

    if (rc := parse_port_(serr, vals, 35729, foz)):
        return rc

    path = vals.pop('document_root')
    target = vals.pop('target', None)
    port = vals.pop('port')
    assert not vals

    kw = {}
    if target:
        kw['target'] = target
    mon = efx.produce_monitor()
    from pho.web_adapters_.livereload import func
    func(path, mon.listener, port, **kw)
    return mon.returncode


def _require_collection_path(listener, vals, efx, tools):

    # If it was passed as an argument, use that
    val = vals.pop('collection_path', None)
    if val is not None:
        return val, None

    # If it's set in the environment, use than
    env_var_name = tools['coll_path_env_var_name']
    env = efx.produce_environ()
    collection_path = env.get(env_var_name)
    if collection_path is not None:
        return collection_path, None

    # Whine about how you didn't find it
    tools['whine_about'](listener)
    return None, 134


def parse_port_(serr, vals, default_port, foz):
    if (s := vals.get('port', None)) is None:  # param key ..
        vals['port'] = default_port
        return 0
    import re
    if re.match(r'[0-9]+\Z', s):
        port = int(s)
        if port < 1024:
            serr.write("heads up: port probably can't be lower than 1024..\n")
        vals['port'] = port
        return 0
    serr.write(f"--port must be an integer. Had {s!r}")  # opt name ..
    serr.write(foz.invite_line)  # or not, but we think yes
    return 10_006  # being super cute


def parse_positionals_(positionals, monikers, cmd_phrase):
    # as seen elsewhere

    act_len, req_len = len(positionals), len(monikers)

    if act_len < req_len:
        arg_name = monikers[act_len]
        reason = f"Expecting argument for {cmd_phrase}: {arg_name}\n"
        return iter((7, reason))

    if req_len < act_len:
        token = positionals[req_len]
        reason = f"Unexpected argument for {cmd_phrase}: {token!r}\n"
        return iter((8, reason))

    assert req_len == act_len


def _cheap_arg_parse_branch(sin, sout, serr, argv, cx, doc, efx):
    from script_lib.cheap_arg_parse import cheap_arg_parse_branch as func
    return func(sin, sout, serr, argv, cx, doc, efx)


def _foz_via(defs, pner, x=None):
    from script_lib.cheap_arg_parse import formals_via_definitions as func
    return func(defs, pner, x)


_port = 10_007  # purely arbitrary historical reasons

# #history-B.4
# #history-A.1 rewrite during cheap arg parse not click
# #born.
