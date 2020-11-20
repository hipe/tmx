def cli_for_production():
    class efx:  # #class-as-namespace
        def produce_monitor():
            from script_lib.magnetics.error_monitor_via_stderr import func
            return func(stderr, default_error_exitstatus=5678)
    from sys import stdin, stdout, stderr, argv
    exit(_CLI(stdin, stdout, stderr, argv, efx))


def _CLI(sin, sout, serr, argv, efx):  # efx = external functions
    def line_contents():
        yield 'experiments in generating documents from "notecards"'
    from script_lib.cheap_arg_parse import cheap_arg_parse_branch as func
    return func(sin, sout, serr, argv, _big_flex(), line_contents, efx)


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


def _big_flex():

    these = ('cli', 'commands')

    from os import path as o
    _pho_project_dir = o.abspath(o.join(__file__, '..', '..'))
    _commands_dir = o.join(_pho_project_dir, *these)

    mod_head = '.'.join(('pho', *these))
    from importlib import import_module

    def build_loader(mod_tail):
        def load_CLI_function():
            _mod_name = '.'.join((mod_head, mod_tail))
            _mod = import_module(_mod_name)
            return _mod.CLI

        return load_CLI_function

    from os import listdir
    for fn in listdir(_commands_dir):
        if not fn.endswith('.py'):
            continue
        if fn.startswith('_'):
            continue
        module_tail = fn[0:-3]
        _slug = module_tail.replace('_', '-')
        yield _slug, build_loader(module_tail)

    yield 'listen', lambda: _listen_command
    yield 'connect', lambda: _connect_command
    yield 'static-webserver', lambda: _static_webserver_command


def _formals_for_listen():
    yield '-h', '--help', 'this screen'
    yield 'config-path?', 'xx xx xx'


def _listen_command(sin, sout, serr, argv, efx):
    "xx xx xx"

    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = _foz_via(_formals_for_listen(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es
    if vals.get('help'):
        _ = _listen_command.__doc__
        return foz.write_help_into(sout, _)

    config_path = vals.pop('config_path', None)
    assert not vals
    kw = {}
    if config_path:
        kw['config_path'] = config_path

    mon = efx.produce_monitor()

    assert 'config_path' not in kw  # ..
    from pho.magnetics_.run_message_broker_via_config import func
    func(mon.listener, _port)  # run forever or until interrupt
    return mon.returncode


def _formals_for_connect():
    yield '-p', '--port=PORT', f'port (default: {_port})'
    yield '-h', '--help', 'this screen'


def _connect_command(sin, sout, serr, argv, efx):
    "xx xx xx"

    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = _foz_via(_formals_for_connect(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es
    if vals.get('help'):
        _ = _connect_command.__doc__
        return foz.write_help_into(sout, _)

    port = vals.pop('port', _port)
    assert not vals

    mon = efx.produce_monitor()
    from pho.magnetics_.open_emitter_via_listener import func
    with func(mon.listener, port=port) as client:
        while True:
            serr.write("(press enter then Ctrl-D to enter, Ctrl-C to cancel)\n")  # noqa: E501
            serr.write("enter something:\n")

            try:
                entered = sin.read()
            except KeyboardInterrupt:
                serr.write("\nreceived keyboard interrupt. goodbye.\n")
                break

            entered = entered[0:-1]
            wat = client.send_string(entered)
            serr.write(f"received: {wat!r}\n")
    return mon.returncode


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

# #history-A.1 rewrite during cheap arg parse not click
# #born.
