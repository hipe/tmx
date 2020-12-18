def execute_command_via_command_and_component(
        comp, cmd, listener, stylesheet=None):

    ss = stylesheet or _default_stylesheet()

    is_terminal, k, rest = _parse_config_command(cmd)

    if is_terminal:
        return _execute_terminal_command(comp, k, rest, ss, listener)
    return _execute_child_command(comp, k, rest, ss, listener)


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

        if 'list' == k:
            return (''.join((say(), '\n')),)

        assert 'show' == k
        return self.execute_show_(stylesheet, listener)

    def execute_show_(self, ss, listener):
        x = self._mixed
        if isinstance(x, str) and ' ' not in x:
            use = x  # eek
        else:
            use = repr(x)
        return (''.join((use, '\n')),)  # ..


# == Execute Child Command

def _execute_child_command(comp, k, rest, ss, listener):

    ch = comp.component_dictionary_.get(k, None)
    if ch is None:
        return _bad_command_or_component(comp, listener, 'component', k)

    if not rest:
        xx(f"expecting dot-something for child {k!r}")

    return _do_execute_child_command(comp, ch, rest, ss, listener)


def _do_execute_child_command(comp, ch, rest, ss, listener):
    ch = _proxy_if_necessary(ch)
    for line in ch.EXECUTE_COMMAND(rest, listener, stylesheet=ss):
        yield ''.join((ss.tab, line))


# == Execute Terminal Command

def _execute_terminal_command(comp, k, rest, ss, listener):

    if 'show' == k:
        assert not rest
        return _execute_show(comp, ss, listener)

    if 'list' == k:
        assert not rest
        return (f'{s}\n' for s in _to_splay_lines(comp))

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
    components = comp.component_dictionary_

    yield ''.join(('(', label, ')', ss.colon, '\n'))
    for k, c in components.items():
        for line in _lines_for_component(k, c, ss, listener):
            yield line


def _lines_for_component(k, c, ss, listener):
    c = _proxy_if_necessary(c)

    lines = iter(_execute_show(c, ss, listener))

    # Determine if the component only produces one line (by peeking)
    first_line, only_one_line = next(lines), True
    for line in lines:
        only_one_line = False
        second_line = line
        break

    # If it's only one line, be done with it
    if only_one_line:
        yield ''.join((ss.tab, k, ': ', first_line))
        return

    # Because it's multiple lines, stream the results

    # (combine name and "type" into one line hackily):
    yield ''.join((ss.tab, k, ' ', first_line))

    def rewind():
        yield second_line
        for line in lines:
            yield line

    for line in rewind():
        yield ''.join((ss.tab, line))


# == Support (small)

def _bad_command_or_component(comp, listener, *rest):
    def lines():
        return _to_splay_lines(comp, *rest)
    listener('error', 'expression', 'noent', lines)
    return ()


def _to_splay_lines(comp, *rest):
    which, k = rest if rest else (None, None)
    if which:
        yield f"No such {which}: {k!r}"

    splay = repr(tuple(_to_command_keys(comp)))
    yield f"Commands: {splay}"

    if (dct := comp.component_dictionary_) is None:
        return
    splay = repr(tuple(dct.keys()))
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


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born.
