# == Specific components (small)

class filesystem_path_:

    def __init__(self, s):
        eek = varname_via_placeholder_(s)
        if eek:
            xx(f"not like this {s!r}")
        self._string = s

    def finish_via_resolved_forward_references(self, fr):
        assert fr is None
        return self._string

    forward_references = ()


# == Component Support (small)

def result_is_output_lines_(orig_f):  # #decorator
    # At #history-B.4 we changed the internal API so that commands result in
    # return codes and send output lines into the listener, rather than
    # just yielding output lines and ?? about succeed/fail.
    #
    # Use this decorator if you're sure your command can't fail (gracefully)
    # and you want the convenience of yielding output lines.

    def use_f(*args):
        itr = orig_f(*args)
        lines = tuple(itr)  # meh
        args[-1]('output', 'expression', lambda: lines)
        return 0
    return use_f


def execute_command_(comp, cmd, listener, stylesheet=None):
    from .execute_command_via_command_and_component import func
    return func(comp, cmd, listener, stylesheet)


def capture_output_lines_(when_oline, when_other):
    def listener(sev, shape, *rest):
        if 'output' != sev:
            when_other(sev, shape, *rest)
            return
        assert 'expression' == shape
        lineser, = rest
        for line in lineser():
            when_oline(line)
    return listener


def varname_via_placeholder_(piece):
    if '[' == piece[0] and ']' == piece[-1]:
        return piece[1:-1].replace(' ', '_')


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #history-B.4
# #born
