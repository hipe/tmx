def blame_index_via_path(path, listener=None, opn=None):
    # Read all lines of a `git blame` in to memory. Lazily, on-demand,
    # give random-access to the commit metadata of any line in the file
    # (by line number), caching the metadata for each commit as you parse it.

    try:
        sha_w, contrib_w, lineno_w, lines = _metrics_and_line_cache(path, opn)
        return _build_lazy_blame_index(sha_w, contrib_w, lineno_w, lines)
    except _Stop as stop:
        def details():
            return {'reason': msg, 'exitstatus': es}
        cat, msg, es = stop.args
        listener('error', 'structure', cat, details)


def _build_lazy_blame_index(sha_w, contrib_w, lineno_w, lines):

    def datetime_via_lineno(lineno):
        ci = commit_via_lineno(lineno)
        return ci.datetime

    def commit_via_lineno(lineno):
        if lineno not in commit_offset_via_lineno:
            commit_offset_via_lineno[lineno] = commit_offset_for(lineno)
        return commit_via_commit_offset[commit_offset_via_lineno[lineno]]

    def commit_offset_for(lineno):
        assert 0 < lineno  # very important
        line = lines[lineno - 1]
        sha, confirm_lineno = first_parse(line)
        assert lineno == confirm_lineno
        if sha not in commit_offset_via_SHA:
            commit = second_parse(line)
            commit_offset = len(commit_via_commit_offset)
            commit_via_commit_offset.append(commit)
            commit_offset_via_SHA[sha] = commit_offset
        return commit_offset_via_SHA[sha]

    def second_parse(line):
        datetime_s = line[datetime_begin:datetime_end]
        dt = strptime(datetime_s, DATETIME_FORMAT)
        return _Commit(dt)

    def first_parse(line):
        sha = line[sha_begin:sha_end]
        lineno_s = line[lineno_begin:lineno_end]
        return sha, int(lineno_s)

    commit_offset_via_lineno = {}
    commit_offset_via_SHA = {}
    commit_via_commit_offset = []

    # SHA (contrib_first contrib_last yyyy-mm-dd hh:mm:ss -zzzz lineno) code
    # ???__??????????????????????????___________________________??????

    sha_begin, sha_end = 0, sha_w
    contrib_begin = sha_end + 2
    contrib_end = contrib_begin + contrib_w
    datetime_begin = contrib_end + 1
    datetime_end = datetime_begin + 25  # len('yyyy-mm-dd hh:mm:ss -zzzz') 25
    lineno_begin = datetime_end + 1
    lineno_end = lineno_begin + lineno_w

    from datetime import datetime
    strptime = datetime.strptime

    # --

    class lazy_blame_index:  # #class-as-namespace
        datetime_for_lineno = datetime_via_lineno

    return lazy_blame_index


class _Commit:
    def __init__(self, dt):
        self.datetime = dt


def _metrics_and_line_cache(path, opn):

    def main():
        line = first_line()
        sha_w, contrib_w, lineno_w = _metrics_via_first_line(line)
        line_cache = [line]
        for typ, data in itr:
            if 'sout' == typ:
                line_cache.append(data)
                continue
            assert 'returncode' == typ
            assert 0 == data
            for _ in itr:
                assert()
            break

        return sha_w, contrib_w, lineno_w, tuple(line_cache)

    def first_line():
        for typ, data in itr:
            break
        # no parts at all is very strange
        if 'sout' == typ:
            return data
        # what would we have to do to get no output or errput?
        assert 'serr' == typ
        rest = tuple(itr)
        part, = rest  # ..
        typ, returncode = part
        assert 'returncode' == typ
        raise _Stop('issue_from_subprocess', data, returncode)

    itr = (opn or _tagged_items)(path)
    return main()


def _tagged_items(path):
    cwd, entry = _split_path(path)
    args = (_GIT_EXE, 'blame', entry)

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


def _metrics_via_first_line(line):
    import re

    # Match the SHA part and the parenthesis part
    md = re.match(r'^(\^?[a-f0-9]+)[ ]\(([^\)]+)\)[ ]', line)
    sha_w = _width(* md.span(1))
    beg, end = md.span(2)
    backwards = ''.join(reversed(line[beg:end]))

    # Anchored to the tail b.c it's easier, figure out widths
    md = re.match(
        r'^(1[ ]*)[ ]\d{4}[-+][ ][0-9:]{8}[ ][-0-9]{10}[ ](.+)',
        backwards)

    line_number_w = _width(* md.span(1))
    contributor_w = _width(* md.span(2))

    # SHA (contrib_first contrib_last yyyy-mm-dd hh:mm:ss -zzzz lineno) code
    # ???__??????????????????????????___________________________??????

    return sha_w, contributor_w, line_number_w


def _width(beg, end):
    return end - beg


def _split_path(path):
    # hackishly use git's ability to search upwards for the base dir

    from os.path import dirname, basename
    cwd = dirname(path)
    if '' == cwd:
        return '.', path
    return cwd, basename(path)


class _Stop(RuntimeError):
    pass


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))


DATETIME_FORMAT = '%Y-%m-%d %H:%M:%S %z'  # pho
_GIT_EXE = 'git'

# #born
