def cli_for_production():
    from sys import stdin, stdout, stderr, argv
    return _CLI(stdin, stdout, stderr, argv)


def _CLI(sin, sout, serr, argv):  # #testpoint
    """Experimental thing"""

    def usage_lines():
        yield "usage: {{prog_name}} check MAIN_RECFILE\n"
        yield "usage: {{prog_name}} viz MAIN_RECFILE\n"

    usage_lines = tuple(usage_lines())

    def docstring_for_help(invo):
        for line in invo.description_lines_via_docstring(_CLI.__doc__):
            yield line

        # massive hack
        import re
        for usage_line in usage_lines:
            k = re.match(r'^usage: \{\{prog_name\}\} ([-a-z_]+) ', usage_line)[1]
            s = _subcommands[k].__doc__
            itr = invo.description_lines_via_docstring(s)
            assert '\n' == next(itr)
            yield '\n'
            yield '\n'
            yield f'# Subcommand {k!r}:\n'
            for line in itr:
                yield line

    from script_lib.via_usage_line import build_invocation
    invo = build_invocation(
            sin, sout, serr, argv, usage_lines=usage_lines,
            docstring_for_help_description=docstring_for_help)
    rc, pt = invo.returncode_or_parse_tree()
    if rc is not None:
        return rc

    subcommand_name, = pt.subcommands
    return _subcommands[subcommand_name](sin, sout, serr, **pt.values)


def subcommand(subcommand_name):
    def decorator(func):
        _subcommands[subcommand_name] = func
    return decorator


_subcommands = {}


@subcommand('viz')
def _(sin, sout, serr, main_recfile):
    """Use GraphViz to create a visualization of the app flow"""

    listener = _listener_via_outstream(serr)
    from app_flow import app_design_via_recfile as func
    ad = func(main_recfile, listener)
    if not ad:
        return listener.returncode or 123
    w = sout.write
    for line in ad.to_graph_viz_lines_(listener):
        w(line)
    return listener.returncode


@subcommand('check')
def _(sin, sout, serr, main_recfile):
    """Check that references (node names) resolve"""

    listener = _listener_via_outstream(sout)
    from app_flow import app_design_via_recfile as func
    ad = func(main_recfile, listener)
    if not ad:
        return listener.returncode or 123
    ad.check_app_design(listener)  # result of T/F ignored b.c same as listener
    return listener.returncode


def _listener_via_outstream(serr):
    def listener(*emi):
        assert 'expression' == emi[1]
        if 'error' == emi[0]:
            listener.returncode = 123
            listener.did_error_ = True
        for line in emi[-1]():
            if not (len(line) and '\n' == line[-1]):
                # (when spying on stdput in tests, we need whole lines)
                line = f"{line}\n"
            serr.write(line)
    listener.returncode = 0
    listener.did_error_ = False
    return listener

# #born
