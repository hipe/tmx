def CLI(sin, sout, serr, argv, enver=None):
    from script_lib.cheap_arg_parse import cheap_arg_parse
    return cheap_arg_parse(
            _do_CLI, sin, sout, serr, argv, tuple(_params()), enver=enver)


def _params():
    from pho.cli import CP_

    yield ('-c', '--collection-path=PATH', * CP_().descs)


def _do_CLI(monitor, sin, sout, serr, enver, collection_path):
    """Show every relationship between every fragment in the collection.

    short_help='Output a graph-viz digraph of the whole collection.
    """

    listener = monitor.listener

    if collection_path is None:
        from pho.cli import CP_
        collection_path = CP_().require_collection_path(enver, listener)
        if collection_path is None:
            return monitor.exitstatus

    from pho.magnetics_.graph_via_collection import \
        output_lines_via_collection_path

    write = sout.write
    for line in output_lines_via_collection_path(collection_path, listener):
        write(f'{line}\n')  # _eol

    return monitor.exitstatus

# #history-A.1 rewrite during cheap arg parse not click
# #born.
