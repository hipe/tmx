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
        vals, es = foz.terminal_parse(serr, bash_argv)
        if vals is None:
            return es
        if vals.get('help'):
            _ = CLI.__doc__
            return foz.write_help_into(sout, _)

        do_ping = vals.pop('ping', False)
        do_interactive = vals.pop('interactive', False)
        positionals = vals.pop('arg', ())
        has_positionals = len(positionals)

        port = vals.pop('port', default_port)
        be_verbose = vals.pop('verbose', False)
        assert not vals

        def hehe(do_ping, do_interactive, has_positionals):
            if do_ping:
                yield 'ping'
            if do_interactive:
                yield 'interactive'
            if has_positionals and not do_ping:  # for now use args in ping
                yield 'ordinary connect'

        def vw():
            from text_lib.magnetics import via_words as vw
            return vw

        these = tuple(hehe(do_ping, do_interactive, has_positionals))
        leng = len(these)
        if 0 == leng:
            these = tuple(hehe(True, True, True))
            or_list = vw().oxford_OR(these)
            serr.write("Supplied arguments indicated no invocation mode.\n")
            serr.write(f"Indicate {or_list} with options/arguments\n")
            serr.write(foz.invite_line)
            return 3

        if 1 < leng:
            both = 'both' if 2 == leng else 'all of'
            and_list = vw().oxford_AND(these)
            serr.write("Supplied arguments indicate mutually exclusive invocation modes:\n")  # noqa: E501
            serr.write(f"Can't do {both} {and_list}.\n")
            serr.write(foz.invite_line)
            return 3

        def listener(*emi):
            sev = emi[0]
            if 'error' != sev:
                if 'info' == sev:
                    if not be_verbose:
                        return
                else:
                    xx(repr(sev))
            mon.listener(*emi)

        mon = efx.produce_monitor()

        if do_interactive:
            _interactive(sin, serr, port, listener)
            return mon.returncode

        def open_connection():
            return _open_connection(listener, port)

        if do_ping:
            with open_connection() as client:
                resp = client.send_API_call('ping', args=positionals)
            assert 0 == resp.pop('status')
            msgs = resp.pop('messages')
            assert not resp
            for msg in msgs:
                sout.write(msg)
                sout.write('\n')
            return 0

        assert has_positionals
        with open_connection() as client:
            xx()
        xx()

    return CLI


# == Go Money


# == Ping


# == Interactive

def _interactive(sin, serr, port, listener):
    with _open_connection(listener, port=port) as client:

        # (One we might try to have this input loop inside the curses
        # interface but today is not that day.
        # It's really difficult to develop w/o interactive debugging.)

        import re
        rx = re.compile(r'q(?:u(?:it?)?)?\Z', re.IGNORECASE)

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


# == Support

def _open_connection(listener, port):
    from pho.magnetics_.open_emitter_via_listener import func
    return func(listener, port=port)


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #broke-out
