def _CLI(sin, sout, serr, argv):
    """This is crazy: pass it a USAGE_LINE (be sure to surround it in

    single quotes, probably) and more args, it will create a parser from
    the usage line and parse the remaining args. SO META
    """

    def usage_lines():
        yield "usage: {{prog_name}} USAGE_LINE [args for parser..]\n"

    from script_lib.via_usage_line import build_invocation
    invo = build_invocation(
        sin, sout, serr, argv,
        usage_lines=tuple(usage_lines()),
        docstring_for_help_description=_CLI.__doc__)
    rc, pt = invo.returncode_or_parse_tree()
    if rc is not None:
        return rc
    dct = pt.values
    usage_line = dct.pop('usage_line')
    if '\n' not in usage_line:  # likelyy
        usage_line = f"{usage_line}\n"
    assert not dct
    # ===

    use_argv = ('wahoo', * reversed(invo.argv_stack))
    invo = build_invocation(
        sin, sout, serr, use_argv,
        usage_lines=(usage_line,),
        docstring_for_help_description="This is so insanely generated")
    rc, pt = invo.returncode_or_parse_tree()
    if rc is not None:
        return rc
    w = stdout.write
    w("GOOD JOB:\n")
    w("  PARSE TREE VALUES:")
    if pt.values:
        w('\n')
        for k, v in pt.values.items():
            w(f"    {k}: {v!r}\n")
    else:
        w(" (none.)\n")
    if pt.subcommands:
        w(f"  SUBCOMMAND: {pt.subcommands!r}\n")
    return 0


if '__main__' == __name__:
    from sys import stdin, stdout, stderr, argv
    exit(_CLI(stdin, stdout, stderr, argv))
else:
    raise RuntimeError("whoops how? this is an entrypoint script")

# #born
