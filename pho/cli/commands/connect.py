def build_CLI_command_(default_port, foz_via):

    def formals_for_connect():
        yield '--ping', 'see if you can connect to the server then done'
        yield '-i', '--interactive', 'experimental janky curses-based'
        yield '-p', '--port=PORT', f'port (default: {default_port})'
        yield '-v', '--verbose', 'show tcp/ip connection details'
        yield '-h', '--help', 'this screen'
        yield ('[arg [arg […]]]', 'Three args: adapter name, verb, path '
               '(NOTE: seems likely to change to something more structured)')

    def CLI(sin, sout, serr, argv, efx):
        "Connect to the generation service (usually not for very long)"

        prog_name = (bash_argv := list(reversed(argv))).pop()
        foz = foz_via(formals_for_connect(), lambda: prog_name)

        # Does it parse OK?
        vals, es = foz.terminal_parse(serr, bash_argv)
        if vals is None:
            return es

        # Was help requested?
        if vals.get('help'):
            _ = CLI.__doc__
            return foz.write_help_into(sout, _)

        # Pretend our argparse is like stdlib argarse
        from pho.cli import parse_port_ as func
        if (rc := func(serr, vals, default_port, foz)):
            return rc

        # Attempt to find invocation mode and invoke
        return _do_CLI(sin, sout, serr, vals, foz, efx)

    return CLI


# == Parse CLI

def _do_CLI(sin, sout, serr, vals, foz, efx):

    # The combination of args/options must imply exactly one invocation mode
    rc, one_mode, args = _resolve_one_invocation_mode(serr, vals, foz)
    if rc is not None:
        return rc

    # Turn all remaining parsed parameters into local variables
    port = vals.pop('port')

    be_verbose = vals.pop('verbose', False)
    assert not vals

    # Each of the three invocation modes opens a connection
    def open_connection():
        return _open_connection(listener, port)

    mon = efx.produce_monitor()
    listener = _verbose_aware_listener_via_listener(be_verbose, mon.listener)

    # Do interactive mode if interactive mode
    if 'interactive' == one_mode:
        _interactive(sin, serr, open_connection, listener)
        return mon.returncode

    if 'ordinary_connect' == one_mode:
        formals = None, 'ADAPTER_EVENT_TYPE', 'WATCHED_DIR'
        from pho.cli import parse_positionals_ as func
        if (itr := func(args, formals, 'ordinary connect')):
            rc = next(itr)
            for line in itr:
                serr.write(line)
            serr.write(foz.invite_line)
            return rc
        return _do_ordinary_connect(
            sout, serr, args, open_connection, efx, mon)

    assert 'ping' == one_mode
    return _do_ping(sout, serr, args, open_connection)


# ==

def _do_ordinary_connect(sout, serr, args, open_connection, efx, mon):
    which_adapter, adapter_event_type, watched_dir = args
    li = mon.listener

    ada = _load_module(li, 'pho.file_watch_adapters_', which_adapter, 'notify')
    if ada is None:
        return mon.returncode

    env = efx.produce_environ()
    dct = ada.ARGS_FOR_FILE_CHANGED(adapter_event_type, watched_dir, env, li)
    if dct is None:
        return mon.returncode

    with open_connection() as client:
        resp = client.file_changed(**dct)

    # Both ping and regular mode, let's have them both process response same
    express_response = _response_expresser(sout, serr)
    return express_response(resp)


def _do_ping(sout, serr, positionals, open_connection):

    # Both ping and regular mode, let's have them both process response same
    express_response = _response_expresser(sout, serr)

    with open_connection() as client:
        resp = client.ping(positionals)
    return express_response(resp)


# ==

def _resolve_one_invocation_mode(serr, vals, foz):

    positionals = vals.pop('arg', ())

    def invocation_modes():
        # What are all the names of the invocation modes?
        # for each mode, yes/no was it invoked?

        ping_requested = vals.pop('ping', False)
        yield 'ping', ping_requested

        yield 'interactive', vals.pop('interactive', False)

        yield 'ordinary_connect', (not ping_requested and len(positionals))
        # (args are used in both ping and ordinary)

    kv = {k: v for k, v in invocation_modes()}
    invoked = tuple(k for k, v in kv.items() if v)
    leng = len(invoked)
    if 0 == leng:
        return _when_zero_invocation_modes_invoked(serr, kv, foz)
    if 1 < leng:
        return _when_more_than_one_invocation_modes_invoked(serr, invoked, foz)
    one_mode, = invoked
    return None, one_mode, positionals  # #here1


def _when(orig_f):  # #decorator
    def use_f(serr, x, foz):
        for line in orig_f(x):
            serr.write(line)
        serr.write(foz.invite_line)
        return 3, None, None  # #here1
    return use_f


@_when
def _when_more_than_one_invocation_modes_invoked(invoked):
    both = 'both' if 2 == len(invoked) else 'all of'
    and_list = _vw().oxford_AND(s.replace('_', ' ') for s in invoked)
    yield "Supplied arguments indicate mutually exclusive invocation modes:\n"
    yield f"Can't do {both} {and_list}.\n"


@_when
def _when_zero_invocation_modes_invoked(kv):
    or_list = _vw().oxford_OR(s.replace('_', ' ') for s in kv.keys())
    yield "Supplied arguments indicated no invocation mode.\n"
    yield f"Indicate {or_list} with options/arguments\n"


# == Interactive

def _interactive(sin, serr, open_connection, listener):
    with open_connection() as client:

        # (One we might try to have this input loop inside the curses
        # interface but today is not that day.
        # It's really difficult to develop w/o interactive debugging.)

        import re as _re
        rx = _re.compile(r'q(?:u(?:it?)?)?\Z', _re.IGNORECASE)

        while True:
            fv = _form_values_via_curses_yikes(serr, listener)
            rd = _request_dict_via_form_values(fv, listener)
            if not rd:
                continue  # e.g duplicate name. assume emitted

            dct = client.send_dictionary(rd)
            serr.write(f"received: {dct!r}\n")

            serr.write("Enter anything then enter then Ctrl-D. 'q' to quit: ")
            serr.flush()
            try:
                entered = sin.read()
            except KeyboardInterrupt:
                break
            if rx.match(entered):
                break


def _form_values_via_curses_yikes(serr, listener):
    from script_lib.curses_yikes.curses_adapter import \
            run_compound_area_via_definition as func

    res = func(_define_compound_area())
    emis = res.pop('unexpressed_emissions')
    fv = res.pop('form_values')
    assert not res

    for emi in (emis or ()):
        listener(emi.severity, 'expression', emi.category, emi.to_messages)

    return fv


def _request_dict_via_form_values(fv, listener):
    dct = {}  # dict comp meh
    nv = fv.pop('name_val_pairs')
    assert not fv
    for k, v in nv:
        if k in dct:
            reason = f"duplicate key, please don't: {k!r}"
            listener('error', 'expression', 'dup_key', lambda: (reason,))
            return
        dct[k] = v
    return dct


def _define_compound_area():
    yield 'nav_area', ('TING', "TANG")
    yield 'orderable_list', 'name_val_pairs', \
          'item_class', 'poly_option', \
          'label', "Name value pairs"
    yield 'flash_area'
    yield 'buttons', _buttons_def()


def _buttons_def():
    yield 'static_buttons_area', lambda: (('[q]uit',),)


# == CLI Support (maaaayyybee for both iCLI and niCLI)

def _response_expresser(sout, serr):

    def express_response(resp):
        if resp is None:
            serr.write("(got empty response from server. error probably.)\n")
            return 123

        rc = resp.pop('status')
        if 0 == rc:
            return express_success_response(resp)

        serr.write(f"got status code {rc!r} from server\n")
        reason = resp.pop('reason', None)
        if reason:
            serr.write(f"got reason from server: {reason}\n")

        if len(resp):
            these = ', '.join(resp.keys())
            serr.write(f"(unexpected keys in response: {these})\n")
        return rc

    def express_success_response(resp):
        msgs = resp.pop('messages')
        assert not resp

        if 0 == len(msgs):
            serr.write("(Strange: got success returncode but zero messages from server.)\n")  # noqa: E501
            serr.write("(Something probably failed on the server side.)\n")
            return 0

        for msg in msgs:
            sout.write(msg)
            sout.write('\n')
        return 0
    return express_response


def _verbose_aware_listener_via_listener(be_verbose, listener):
    if be_verbose:
        return listener

    def use_listener(*emi):
        sev = emi[0]
        if 'error' == sev:
            return listener(*emi)
        if 'info' == sev:
            return
        xx(repr(sev))
    return use_listener


# == Load Module (abstraction candidate (see kiss) (should be in [ma]))

def _load_module(listener, before, middle, after=None):  # :[#407.C]

    import re as _re
    if not _re.match(r'', middle):
        def lines():
            yield f"Doesn't look like module name: {middle!r}"
        listener('error', 'expression', 'module_not_found_error', lines)
        return

    mname = '.'.join(s for s in (before, middle, after) if s)
    from importlib import import_module as func
    try:
        return func(mname)
    except ModuleNotFoundError as exce:
        e = exce

    listener('error', 'expression', 'module_not_found_error', lambda: (str(e),))  # noqa: E501


# == Support

def _vw():
    from text_lib.magnetics import via_words as result
    return result


def _open_connection(listener, port):
    from pho.generation_service_.open_emitter_via_listener import func
    return func(listener, port=port)


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #broke-out
