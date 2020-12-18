from . import varname_via_placeholder_ as _parse_as_thing


class __PathWithForwardReferences__:

    def __init__(self, pieces):
        self._pieces, self._these = _path_with_forward_refs(pieces)

    def finish_via_resolved_forward_references(self, comps):
        return _resolve_path_with_forward_references(
                comps, self._pieces, self._these)

    @property
    def forward_references(self):
        return (tup[0] for tup in self._these)


func = __PathWithForwardReferences__


def _resolve_path_with_forward_references(comps, pieces, these):
    rang = range(0, len(pieces))
    result = [None for i in rang]
    pool = {i: None for i in rang}

    for varname, offset in these:
        comp = comps[varname]
        assert isinstance(comp, str)
        pool.pop(offset)
        result[offset] = comp

    for i in pool.keys():
        result[i] = pieces[i]

    from os.path import join as os_path_join
    return os_path_join(*result)


def _path_with_forward_refs(pieces):

    result_pieces, forward_ref_plus_offsets = [], []

    def process_variable(pc):
        varname = _parse_as_thing(pc)
        if not varname:
            xx(f"expected variable: {pc!r}")
        do_process_variable(varname)

    def process_not_variable(pc):
        varname = _parse_as_thing(pc)
        if varname:
            xx(f"expected not variable: {pc!r}")
        do_process_not_variable(pc)

    def do_process_variable(varname):
        offset = len(result_pieces)
        forward_ref_plus_offsets.append((varname, offset))
        result_pieces.append(varname)

    def do_process_not_variable(pc):
        result_pieces.append(pc)

    itr = iter(pieces)
    first = next(itr)
    varname = _parse_as_thing(first)
    if varname:
        use_next = process_not_variable
        use_next_next = process_variable
        do_process_variable(varname)
    else:
        use_next = process_variable
        use_next_next = process_not_variable
        do_process_not_variable(first)

    for pc in itr:
        use = use_next
        use_next = use_next_next
        use_next_next = use
        use(pc)

    return tuple(result_pieces), tuple(forward_ref_plus_offsets)


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
