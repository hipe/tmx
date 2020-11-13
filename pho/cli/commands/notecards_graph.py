def CLI(sin, sout, serr, argv, efx=None):  # efx = external functions
    from script_lib.cheap_arg_parse import cheap_arg_parse
    return cheap_arg_parse(
            _do_CLI, sin, sout, serr, argv, tuple(_params()), efx=efx)


def _params():
    from pho.cli import CP_
    yield '-c', '--collection-path=PATH', * CP_().descs
    yield '-v', '--verify', 'Check the integrity of the notecard collection'
    yield '-h', '--help', 'this screen'


def return_exitstatus(orig_f):
    def use_f(monitor, *rest):
        x = orig_f(monitor, *rest)
        if x is not None:
            assert(isinstance(x, int))
            return x
        return monitor.exitstatus
    use_f.__doc__ = orig_f.__doc__
    return use_f


@return_exitstatus
def _do_CLI(sin, sout, serr, collection_path, do_veri, resourcer):
    """Show every relationship between every notecard in the collection.

    Output a graph-viz digraph of the whole collection.
    """

    mon = resourcer().monitor
    listener = _build_CLI_enhanced_listener(mon)

    if collection_path is None:
        collection_path = _require_collection_path(efx, listener)
        if collection_path is None:
            return

    import pho as lib
    coll = lib.collection_via_path_(collection_path, listener)
    if coll is None:
        return

    big_index = lib.big_index_via_collection_(coll, listener)
    if big_index is None:
        return

    if do_veri:
        return _express_verification(sout, serr, big_index)

    # express graph
    from pho.magnetics_.graph_via_collection import output_lines_via_big_index_
    w = _line_writer(sout)
    for line in output_lines_via_big_index_(big_index, listener):
        w(line)


def _express_verification(sout, serr, big_index):
    if not len(big_index.notecard_of):
        _line_writer(serr)("empty graph!")
        return 1

    ow = _line_writer(sout)
    for line in _lines_for_express_verification(big_index):
        ow(line)


def _lines_for_express_verification(big_index):
    _cpc = len(big_index.parent_of)
    _cpn = len(big_index.previous_of)
    _cto = len(big_index.notecard_of)
    yield f'{_cpc} parent-child relationship(s) ok'
    yield f'{_cpn} prev-next relationship(s) ok'
    yield f'{_cto} notecard(s) ok'


def _require_collection_path(efx, listener):
    from pho.cli import CP_
    return CP_().require_collection_path(efx, listener)


def _build_CLI_enhanced_listener(monitor):  # #[#608.7]
    def listener(severity, shape, category, *rest):
        if 'expression' != shape:
            return monitor.listener(severity, shape, category, *rest)
        *mid, orig_lineser = rest
        lines = list(orig_lineser())
        lines[0] = f"{category.replace('_', ' ')}: {lines[0]}"
        monitor.listener(severity, shape, category, *mid, lambda: lines)
    return listener


def _line_writer(io):
    def write_line(line):
        w(line)
        w('\n')  # _eol
    w = io.write
    return write_line

# #history-A.1 rewrite during cheap arg parse not click
# #born.
