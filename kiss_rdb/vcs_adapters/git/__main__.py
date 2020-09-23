def cli_for_production():
    from sys import stdout, stderr, argv
    exit(_CLI(None, stdout, stderr, argv))


def _CLI(sin, sout, serr, argv):
    from script_lib.cheap_arg_parse_branch import cheap_arg_parse_branch as br
    return br(sin, sout, serr, argv, _children())


def _children():
    yield 'build-versioned-file-one', lambda: _CLI_for_child_1
    yield 'build-when-not-versioned', lambda: _CLI_for_child_2


def _CLI_for_child_2(sin, sout, serr, argv, en=None):
    from script_lib.cheap_arg_parse import cheap_arg_parse
    return cheap_arg_parse(
        _do_CLI_for_child_2, sin, sout, serr, argv, _foz_for_child_2, None, en)


def _CLI_for_child_1(sin, sout, serr, argv, en=None):
    from script_lib.cheap_arg_parse import cheap_arg_parse
    return cheap_arg_parse(
        _do_CLI_for_child_1, sin, sout, serr, argv, _foz_for_child_1, None, en)


_foz_for_child_2 = (
    ('-h', '--help', 'this screen'),
)


def _do_CLI_for_child_2(mon, sin, sout, serr):

    exe_path = _this_path('zomg-build-two')
    itr = _parts_from_execute((exe_path,), '.')
    is_first = True
    for typ, data in itr:
        if is_first:
            is_first = False
        else:
            sout.write(",\n")
        sout.write(repr((typ, data)))
    sout.write("\n")
    return 0


_foz_for_child_1 = (
    ('-h', '--help', 'this screen'),
)


def _do_CLI_for_child_1(mon, sin, sout, serr):
    "outputs inline fixture data (python code-ish) for a git blame"

    exe_path = _this_path('zomg-build-one')
    found, count, returncode = False, 0, None
    itr = _parts_from_execute((exe_path,), '.')
    for typ, data in itr:
        if 'returncode' == typ:
            returncode = data
            for _ in itr:
                assert()
            break
        if 'sout' != typ:
            assert 'serr' == typ
            serr.write(f"oops: from build script: {data}")
            continue
        count += 1
        serr.write('.')
        serr.flush()
        if '⬇' != data[0]:
            continue
        assert "here's the git blame:\n" == data[3:]
        found = True
        break

    serr.write('\n')

    if returncode:
        return returncode

    assert found

    for typ, data in itr:
        if 'returncode' == typ:
            returncode = data
            serr.write(repr(('returncode', data)))
            for _ in itr:
                assert()
            break
        if 'serr' == typ:
            serr.write(data)  # probably a message from us
            continue
        assert 'sout' == typ
        serr.write(repr(('sout', data)))
        serr.write('\n')

    assert returncode is not None
    return returncode


def _this_path(tail):
    from os.path import join
    here = 'fixture_executables', '4975-git'
    return join(_test_dir(), *here, tail)


def _test_dir():
    from kiss_rdb_test import __path__ as yikes
    test_dir, _ = yikes._path
    return test_dir


def _parts_from_execute(args, cwd=None):
    import subprocess as sp
    opened = sp.Popen(
        args=args, stdin=sp.DEVNULL, stdout=sp.PIPE, stderr=sp.PIPE,
        text=True,  # don't give me binary, give me utf-8 strings
        cwd=cwd)  # None means pwd
    with opened as proc:
        for line in proc.stdout:
            yield 'sout', line
        for line in proc.stderr:
            yield 'serr', line
        proc.wait()  # not terminate. timeout maybe one day
        yield 'returncode', proc.returncode


if '__main__' == __name__:
    cli_for_production()

# #born
