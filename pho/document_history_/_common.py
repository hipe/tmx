from dataclasses import dataclass as _dataclass
from collections import namedtuple as _nt


def GIT_LOG_NUMSTAT_(coll_path, stop_SHA, cmd):

    act = cmd[:len(_confirm_cmd_head)]
    assert _confirm_cmd_head == act
    use_cmd = cmd[1:]  # exclude the 'git' part, it's just there for show

    # Start the git-log subprocess
    sout_lines = _STDOUT_lines_via_git_subprocess(use_cmd, cwd=coll_path)
    proc = next(sout_lines)
    yield proc  # HERE1 yield out the proc first

    # There should always be at least one commit in the git log
    scn = _scanner_via_iterator(sout_lines)
    assert scn.more

    # Here is how we determine when to stop walking the git log
    if stop_SHA is None:
        def this_commit_is_already_in_the_commit_table():
            return False
    else:
        def this_commit_is_already_in_the_commit_table():
            assert stop_SHA_leng == len(hdr.SHA)  # every time meh
            return stop_SHA == hdr.SHA
        stop_SHA_leng = len(stop_SHA)

    import re as _re

    def file_paths_via_records(file_path_recs):
        for file_path in (o.file_path for o in file_path_recs):

            # If it's an ordinary file path, just output it
            i = file_path.find(' => ')
            if -1 == i:
                yield file_path
                continue

            # Otherwise (and it's a rename) output BOTH sides of it indifferent
            left = file_path[:i]
            right = file_path[i+4:]

            # If it's of the "before/path.ext => after/path.ext2" format
            i = left.find('{')
            ii = right.find('}')
            if -1 == i:
                assert -1 == ii
                yield left
                yield right
                continue

            # When it's the "some/path/{foo => bar}.ext" format
            assert -1 != ii
            head = left[:i]
            before = left[i+1:]
            after = right[:ii]
            tail = right[ii+1:]
            yield ''.join((head, before, tail))
            yield ''.join((head, after, tail))

    # Here is how we parse out the file paths (will happen 2x meh #here2)
    rx = _re.compile(r"""
        (?P<before_num_lines>(?:\d+|-))
        \t
        (?P<after_num_lines>(?:\d+|-))
        \t
        (?P<file_path>[^\n]+)
        \n\Z
    """, _re.VERBOSE)

    def parse_file_path_records():
        while scn.more:

            # If the current line matches a file, this is normal
            md = rx.match(scn.peek)
            if md:
                scn.advance()
                before_num_lines, after_num_lines = (
                    (None if '-' == s else int(s)) for s in
                    (md[k] for k in ('before_num_lines', 'after_num_lines')))
                yield _FilePathRecord(
                    before_num_lines, after_num_lines, md['file_path'])
                continue

            # Otherwise, it must be a separator between this commit and the
            # next one:
            if '\n' != scn.peek:
                xx(f"OOPS: expecting newline ({hdr.SHA}): {scn.peek!r}")
            scn.advance()
            break

    # Money
    parse_header_lines = _produce_git_patch_header_parser()
    while scn.more:
        hdr = parse_header_lines(scn)
        yn = this_commit_is_already_in_the_commit_table()
        if yn:
            proc.terminate()
            break

        file_path_records = tuple(parse_file_path_records())
        file_paths = tuple(file_paths_via_records(file_path_records))

        yield _RealCommit(hdr, file_paths, file_path_records)


_confirm_cmd_head = 'git', 'log', '--numstat'


_FilePathRecord = _nt(
    '_FilePathRecord',
    ('before_num_lines', 'after_num_lines', 'file_path'))


def _produce_git_patch_header_parser():
    o = _produce_git_patch_header_parser
    if not hasattr(o, 'x'):  # [#510.4] custom memoizer
        from text_lib.diff_and_patch.parse import \
            produce_git_patch_header_parser as func
        o.x = func()
    return o.x


@_dataclass
class _RealCommit:
    header: object
    file_paths: tuple
    file_path_records: tuple

    @property
    def SHA(self):
        return self.header.SHA


def normalize_datetime_from_git_(string_from_git):
    """NORMALIZE datetime

    We want to store the commit datetime in a way that sqlite can work
    with with its datetime functions, so we're trying to follow [here][1]

    We're parsing the datetimes exactly as we got them from git-log, which
    formats them locale-specifically so this will break in production:
    The below is hard-coded to parse dates as git produces them in
    our locale, e.g.: 'Sun Feb 28 15:20:56 2021 -0500'

    Also we don't know how we want to handle timezone stuff so we're
    just throwing a string into a cell for now

    [1]: https://sqlite.org/quirks.html#no_separate_datetime_datatype
    """

    o = normalize_datetime_from_git_
    if not hasattr(o, 'x'):
        o.x = _build_normalize_datetime()
    return o.x(string_from_git)


def _build_normalize_datetime():
    def normalize_datetime(string_from_git):
        dt = strptime(string_from_git, '%a %b %d %H:%M:%S %Y %z')
        norm_dt_s = dt.strftime('%Y-%m-%d %H:%M:%S')
        tzinfo = str(dt.tzinfo)
        return norm_dt_s, tzinfo

    from datetime import datetime as lib
    strptime = lib.strptime
    return normalize_datetime


def _STDOUT_lines_via_git_subprocess(cmd_tail, cwd=None):
    itr = open_git_subprocess_(cmd_tail, cwd)
    yield next(itr)  # #HERE1 yield out the proc first

    for typ, val in itr:
        if 'sout' == typ:
            yield val
            continue

        if 'serr' == typ:
            xx(f"Oops handle failure here: {val!r}")

        assert 'done' == typ
        break


def open_git_subprocess_(cmd_tail, cwd=None):
    # (this is supposed to be in [kiss] but we hack some things)

    cmd = 'git', *cmd_tail
    with _open_subprocess(cmd, cwd=cwd) as proc:

        yield proc  # :#HERE1: yield out the proc first

        for line in proc.stdout:
            yield 'sout', line

        for line in proc.stderr:
            yield 'serr', line

        yield 'done', None


def _open_subprocess(cmd, cwd=None):  # c/p
    import subprocess as sp
    return sp.Popen(
        args=cmd, stdin=sp.DEVNULL, stdout=sp.PIPE, stderr=sp.PIPE,
        text=True,  # don't give me binary, give me utf-8 strings
        cwd=cwd)  # None means pwd


def _scanner_via_iterator(itr):
    assert hasattr(itr, '__next__')
    from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    return func(itr)


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #abstracted
