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

def execute_command_(comp, cmd, listener, stylesheet=None):
    from .execute_command_via_command_and_component import func
    return func(comp, cmd, listener, stylesheet)


def varname_via_placeholder_(piece):
    if '[' == piece[0] and ']' == piece[-1]:
        return piece[1:-1].replace(' ', '_')


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
