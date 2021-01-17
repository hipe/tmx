# it's all a visual test for parsing eno files by hand


def cli_for_production():
    from sys import stdout, stderr, argv
    exit(_CLI(None, stdout, stderr, argv))


def _CLI(sin, sout, serr, argv):
    bash_argv = list(reversed(argv))
    pname = bash_argv.pop()

    def invite():
        serr.write(f"use \"{pnamer()} -h\" for help\n")
        return 123

    def pnamer():
        return pname  # meh

    if 0 == len(bash_argv):
        serr.write("expecting '-h' or 'list' or 'file' or 'all'\n")
        return invite()

    tok = bash_argv.pop()

    if 'file' == tok:
        arg = bash_argv.pop()  # ..
        mode = 'file'
    elif 'all' == tok:
        mode = 'all'
    elif 'list' == tok:
        mode = 'list'
    else:
        import re
        if re.match(r'--?h(?:e(?:lp?)?)?\Z', tok):  # noqa: E501
            mode = 'help'
        else:
            serr.write(f"unrecognized token {tok!r}\n")
            return invite()

    if len(bash_argv):
        tok = bash_argv[0]
        serr.write(f"'{mode}' expecting no futher arguments {tok!r}\n")
        return invite()

    if 'help' == mode:
        return _execute_help(sout, pnamer)

    if 'list' == tok:
        return _execute_list(sout)

    if 'all' == tok:
        return _execute_all(sout, serr)

    assert 'file' == tok
    return _execute_file(sout, serr, arg)


def _execute_help(sout, pname):
    w = sout.write
    for line in _help_lines(pname):
        w(line)
        w("\n")
    return 0


def _help_lines(pnamer):
    pname = pnamer()
    yield f"usage: {pname} -h"
    yield f"       {pname} list"
    yield f"       {pname} all"
    yield f"       {pname} file FILE"
    yield ''
    yield "synopsis: tooling for schooling, for parsing eno by hand"


def _execute_all(sout, serr):
    for path in _do_list():
        rc = _execute_file(sout, serr, path)
        if rc:
            return rc
    return 0


def _execute_file(sout, serr, path):
    xx()


def _execute_list(sout):
    w = sout.write
    for path in _do_list():
        w(path)


def _do_list():
    path = _build_dir()
    path = _humanize_path(path)
    cmd = 'find', path, '-type', 'f', '-name', '*.eno'

    import subprocess as sp
    opened = sp.Popen(args=cmd, stdout=sp.PIPE, stderr=sp.PIPE, text=True)
    errs = []
    with opened as proc:
        for line in proc.stdout:
            yield line

        for line in proc.stderr:
            errs.append(line)

        proc.wait()  # not terminate. timeout maybe one day
        rc = proc.returncode
    if errs or rc:
        xx()


def _humanize_path(path):
    from os import getcwd as func
    cwd = func()

    from os.path import join
    needle = join(cwd, '')

    needle_len = len(needle)

    if needle == path[:needle_len]:
        if needle_len == len(path):
            xx("return ''?")
        return path[needle_len:]  # yikes

    return path


def _build_dir():
    from os.path import dirname as dn, join, realpath
    mono_repo_dir = dn(dn(dn(realpath(__file__))))
    return join(mono_repo_dir, 'pho-doc', 'notecards', 'entities')


def xx(*_):
    raise RuntimeError('sure you betcha')


if '__main__' == __name__:
    cli_for_production()

# #born
