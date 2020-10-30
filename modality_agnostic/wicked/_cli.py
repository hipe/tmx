def _foz():
    yield _help_option
    yield 'command [..]', 'One of the below'


def _subs(h):
    yield 'list', lambda: _dispatch(_list_foz, _list, h)
    yield 'update', lambda: _dispatch(_update_foz, _update, h)
    yield 'viztest1', lambda: _dispatch(_viztest1_foz, _viztest1, h)


def build_CLI_(definition):

    def cli(sin, sout, serr, argv, rscser):
        (bash_argv := list(reversed(argv))).pop()
        prog_name = '<this>'
        foz = _foz_via(_foz(), lambda: prog_name, lambda: _subs(hub))
        vals, es = foz.nonterminal_parse(serr, bash_argv)
        if vals is None:
            return es
        if vals.get('help'):
            return foz.write_help_into(serr, hub.to_doc_bigstring())
        cmd_tup = vals.pop('command')
        cmd_name, cmd_funcer, es = foz.parse_alternation_fuzzily(serr, cmd_tup[0])  # noqa: E501
        if not cmd_name:
            return es
        ch_pn = ' '.join((prog_name, cmd_name))  # we don't love it, but later
        ch_argv = (ch_pn, * cmd_tup[1:])
        return cmd_funcer()(sin, sout, serr, ch_argv, None)

    from . import hub_via_defininition_ as func
    hub = func(definition)
    return cli


def _dispatch(fozzer, busi_func, hub):
    def CLI(sin, sout, serr, argv, rscser):
        prog_name = (bash_argv := list(reversed(argv))).pop()
        foz = _foz_via(fozzer(), lambda: prog_name)
        vals, es = foz.terminal_parse(serr, bash_argv)
        if vals is None:
            return es
        if vals.get('help'):
            return foz.write_help_into(serr, busi_func.__doc__)
        a, b = foz.sparse_tuples_in_grammar_order_via_consume_values(vals)
        return busi_func(sin, sout, serr, hub, *a, *b)

    CLI.__doc__ = busi_func.__doc__
    return CLI


def _list_foz():
    yield _help_option


def _list(sin, sout, serr, hub):
    """list the managed test files and their templates under this hub"""

    from script_lib import build_path_relativizer as func
    relativize_path = func()

    current_template = None

    for fil in hub.file_units_of_work:
        tfile = fil.template_path
        if current_template != tfile:
            current_template = tfile
            sout.write(''.join(('template: ', relativize_path(tfile), '\n')))
        use = relativize_path(fil.absolute_path)
        sout.write(''.join(('file: ', use, '\n')))


def _update_foz():
    yield '-i', '--edit-in-place=EXT', 'See the same option under `man sed`'
    yield '-n', '--dry-run', 'You know it'
    yield _help_option
    yield '[<file> […]]', 'Only these files from `list`. Partial match ok.'


def _update(sin, sout, serr, hub, eip, is_dry, files):
    """Do the do. The main thing."""

    mon = _error_monitor_via_stdin(serr)

    lines_yikes = hub.update_files(
        files, mon.listener, is_dry=is_dry, edit_in_place_extension=eip)

    for line in lines_yikes:
        sout.write(line)

    return mon.exitstatus


def _viztest1_foz():
    yield _help_option
    yield '<file>', 'the client file'


def _viztest1(sin, sout, serr, hub, path):
    """viztest1: see how a file parses"""

    for line in hub.viztest1_see_how_file_parses(path):
        serr.write(line)
    return 0


_help_option = '-h', '--help', 'This screen'


# ==

def _error_monitor_via_stdin(sin):
    from script_lib.magnetics.error_monitor_via_stderr import func
    return func(sin)


def _foz_via(*a):
    from script_lib.cheap_arg_parse import formals_via_definitions as func
    return func(*a)


def xx(msg=None):
    raise RuntimeError(msg or "wee")

# #born
