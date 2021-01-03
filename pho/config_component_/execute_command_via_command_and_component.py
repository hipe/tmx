from . import result_is_output_lines_ as _result_is_output_lines


def execute_command_via_command_and_component(
        comp, cmd, listener, stylesheet=None):

    ss = stylesheet or _default_stylesheet()

    is_terminal, k, rest = _parse_config_command(cmd)

    if is_terminal:
        return _execute_terminal_command(comp, k, rest, ss, listener)

    if not comp.has_components_:
        return _when_not_has_components(listener, k, comp)

    return _execute_child_command(comp, k, rest, ss, listener)


def _when_not_has_components(listener, k, comp):
    def lines():
        yield f"can't access {k!r} of {comp.__class__.__name__}, no components"
    listener('error', 'expression', 'no_components', lines)
    return 123


func = execute_command_via_command_and_component


# == Proxy

def _proxy_if_necessary(c):
    if hasattr(c, 'EXECUTE_COMMAND'):
        return c
    return _ProxyForPrimitive(c)


class _ProxyForPrimitive:

    def __init__(self, x):
        self._mixed = x

    def EXECUTE_COMMAND(self, cmd, listener, stylesheet=None):
        is_terminal, k, rest = _parse_config_command(cmd)
        if not is_terminal:
            typ = type(self._mixed).__name__
            reason = f"'{typ}' type does not have components"
            return _whine(listener, reason)

        def say():
            return f'Commands: {avail!r}'

        avail = 'show', 'list'

        if k not in avail:
            reason = f"No command {k!r}. {say()}"
            return _whine(listener, reason)

        xx("DEMARK")

        if 'list' == k:
            listener('output', 'expression', lambda: (say(),))
            return 0

        assert 'show' == k
        return self.execute_show_(stylesheet, listener)

    @_result_is_output_lines
    def execute_show_(self, ss, listener):
        x = self._mixed
        if isinstance(x, str) and ' ' not in x:
            use = x  # eek
        else:
            use = repr(x)
        return (''.join((use, '\n')),)  # ..


# == Execute Child Command

def _execute_child_command(comp, k, rest, ss, listener):

    ch = comp.get_component_(k)
    if ch is None:
        return _bad_command_or_component(comp, listener, 'component', k)

    if not rest:
        xx(f"expecting dot-something for child {k!r}")

    return _do_execute_child_command(comp, ch, rest, ss, listener)


def _do_execute_child_command(comp, ch, rest, ss, listener):
    ch = _proxy_if_necessary(ch)
    return ch.EXECUTE_COMMAND(rest, listener, stylesheet=ss)


# == Execute Terminal Command

def _execute_terminal_command(comp, k, rest, ss, listener):

    if 'show' == k:
        assert not rest
        return _execute_show(comp, ss, listener)

    if 'list' == k:
        assert not rest
        listener('output', 'expression', lambda: _to_splay_lines(comp))
        return 0

    for kk, func in _to_additional_commands(comp):
        if k != kk:
            continue
        kw = {}
        kw.update(command_name=k, rest=rest)
        kw.update(stylesheet=ss, listener=listener)
        return func(kw)

    return _bad_command_or_component(comp, listener, 'command', k)


def _execute_show(comp, ss, listener):
    if hasattr(comp, 'execute_show_'):
        return comp.execute_show_(ss, listener)
    return _execute_show_assuming_compound_component(comp, ss, listener)


def _execute_show_assuming_compound_component(comp, ss, listener):
    label = comp.label_for_show_

    line = ''.join(('(', label, ')', ss.colon))
    listener('output', 'expression', lambda: (line,))

    for k, c in comp.to_component_keys_and_values_():
        rc = _execute_show_for_component(k, c, ss, listener)
        assert isinstance(rc, int)  # #todo
        if rc:
            return rc
    return 0


def _execute_show_for_component(k, c, ss, listener):
    c = _proxy_if_necessary(c)

    lines = []
    from . import capture_output_lines_ as func
    rc = _execute_show(c, ss, func(lines.append, listener))
    assert isinstance(rc, int)  # #todo
    if rc:
        return rc
    from text_lib.magnetics.scanner_via import scanner_via_iterator as func

    def output_lineser():
        scn = func(iter(lines))
        first_line = scn.next()  # ..
        # If the component only produced one line, make it look like this
        if scn.empty:
            yield ''.join((ss.tab, k, ': ', first_line))
        else:
            yield ''.join((ss.tab, k, ' ', first_line))
        while scn.more:
            yield ''.join((ss.tab, scn.next()))

    listener('output', 'expression', output_lineser)
    return 0


# == Support (small)

def _bad_command_or_component(comp, listener, *rest):
    def lines():
        return _to_splay_lines(comp, *rest)
    listener('error', 'expression', 'noent', lines)
    return 123


def _to_splay_lines(comp, *rest):
    which, k = rest if rest else (None, None)
    if which:
        yield f"No such {which}: {k!r}"

    splay = repr(tuple(_to_command_keys(comp)))
    yield f"Commands: {splay}"

    if not comp.has_components_:
        return
    splay = repr(tuple(comp.to_component_keys_()))
    yield f"Components: {splay}"


def _to_command_keys(comp):
    for k, _ in _to_additional_commands(comp):
        yield k
    yield 'show'
    yield 'list'


def _to_additional_commands(comp):
    if not hasattr(comp, 'to_additional_commands_'):
        return ()
    return comp.to_additional_commands_()


def _parse_config_command(cmd):
    import re
    md = re.match(r'([a-zA-Z_]+)(?:\.(.+)|\((.*)\))?\Z', cmd)
    if not md:
        xx(f"command is malformed and/or has invalid characters: {cmd!r}")
    k, rest, args = md.groups()
    # If there is no "rest", this is the terminal
    if rest is None:
        return True, k, args
    return False, k, rest


class _default_stylesheet:
    def __init__(self):
        self.colon = ':'
        self.tab = '  '
        self._double_tab = self.tab * 2


def _whine(listener, reason):
    listener('error', 'expression', 'error', lambda: (reason,))
    return 123


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born.
