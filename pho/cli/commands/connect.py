def build_CLI_command_(default_port, foz_via):

    def formals_for_connect():
        yield '-p', '--port=PORT', f'port (default: {default_port})'
        yield '-h', '--help', 'this screen'

    def CLI(sin, sout, serr, argv, efx):
        "xx xx xx"

        prog_name = (bash_argv := list(reversed(argv))).pop()
        foz = foz_via(formals_for_connect(), lambda: prog_name)
        vals, es = foz.terminal_parse(serr, bash_argv)
        if vals is None:
            return es
        if vals.get('help'):
            _ = CLI.__doc__
            return foz.write_help_into(sout, _)

        port = vals.pop('port', default_port)
        assert not vals

        mon = efx.produce_monitor()
        listener = mon.listener

        _main(sin, serr, port, listener)

        return mon.returncode
    return CLI


def _main(sin, serr, port, listener):
    from pho.magnetics_.open_emitter_via_listener import func
    with func(listener, port=port) as client:

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

# #broke-out
