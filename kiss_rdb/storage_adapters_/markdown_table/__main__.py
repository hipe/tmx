def cli_for_production():
    from sys import stdin, stdout, stderr, argv
    exit(_CLI(stdin, stdout, stderr, argv, None))


def _CLI(sin, sout, serr, argv, enver):
    bash_argv = list(reversed(argv))
    prog_name = _clean_up_program_name(bash_argv.pop())
    commands = ('tagged_lines_via_lines',)
    if not len(bash_argv):
        es, reason = 2, None
    elif bash_argv[-1] in commands:
        es = None
    elif _looks_like_help(bash_argv[-1]):
        es, reason = 0, None
    else:
        es, reason = 2, f"unrecognized command/option '{bash_argv[-1]}'\n"
    if es is not None:
        if reason:
            serr.write(reason)
        serr.write(f"usage: {prog_name} {{{ ' | '.join(commands) }}} ...\n")
        return es

    from sys import modules
    command_name = bash_argv[-1]
    bash_argv[-1] = f"{prog_name} {command_name}"
    command_function = getattr(modules[__name__], command_name)
    return command_function(sin, sout, serr, bash_argv, enver)


def tagged_lines_via_lines(sin, sout, serr, bash_argv, enver):
    bash_argv.pop()  # prog_name
    path = bash_argv.pop()  # ..
    assert(not len(bash_argv))  # ..

    from . import _tagged_lines_via_lines
    with open(path) as lines:
        for tag, line in _tagged_lines_via_lines(lines):
            sout.write(repr((tag, line)))
            sout.write('\n')
    return 0


def _clean_up_program_name(prog_name):
    import kiss_rdb  # FROM
    from os.path import dirname, sep
    head, = kiss_rdb.__path__
    head = dirname(head)
    leng = len(head)
    if head != prog_name[0:leng]:
        return prog_name
    prog_name = prog_name[leng+1:]
    return dirname(prog_name).replace(sep, '.')


def _looks_like_help(tok):
    from re import match
    return match('--?h(?:e(?:lp?)?)?$', tok)


cli_for_production()

# #born
