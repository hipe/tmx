from modality_agnostic.test_support.common import lazy


# == Filesystem

@lazy
def filesystem_expecting_no_rewrites():

    def inj(*_):
        assert(False)

    def finish():
        return 'hi there were no file rewrites'

    return _build_filesystem_via_two_funcs(inj, finish)


def build_filesystem_expecting_num_file_rewrites(expected_num):

    class my_state:  # #class-as-namespace
        _records = []

    self = my_state

    def INJECTED_FELLOW(from_fh, to_fh):

        if len(self._records) == expected_num:
            raise Exception('too many doo-hahs')

        from_fh.seek(0)  # necessary
        _new_lines = tuple(iter(from_fh))

        self._records.append(_RecordOfFileRewrite(
            path=to_fh.name,
            lines=_new_lines,))

    def finish():

        if len(self._records) != expected_num:
            _msg = ('expected there to be more file rewrites '
                    f'(needed {expected_num}, had {len(self._records)})')
            raise Exception(_msg)

        res = tuple(self._records)
        del(self._records)
        return res

    return _build_filesystem_via_two_funcs(INJECTED_FELLOW, finish)


def _build_filesystem_via_two_funcs(INJECTED_FELLOW, finish):
    from kiss_rdb.magnetics_ import filesystem as _

    fs = _.Filesystem_EXPERIMENTAL(INJECTED_FELLOW)

    fs.FINISH_AS_HACKY_SPY = finish

    return fs


class build_fake_filesystem:
    # (currently separate from the recording filesystem. just for reads)

    def __init__(self, *tups):
        self._tups = tups

    def open_file_for_reading(self, path):
        rec = self._lookup(path)
        if rec is None:
            raise self._file_not_found_error(path)
        shape = rec[0]
        assert('file' == shape)  # we could cover etc but we don't plan on need

        _lines = _lines_via_strings_with_optimistic_peek(rec[2]())
        return mock_filehandle(_lines, path)

    def stat_via_path(self, path):
        rec = self._lookup(path)
        if rec is None:
            raise self._file_not_found_error(path)
        shape = rec[0]
        if 'directory' == shape:
            return _fake_dir_stat
        assert('file' == shape)
        return _fake_file_stat

    def _file_not_found_error(self, path):
        return FileNotFoundError(
                2, f"No such file or directory: '{path}'", path)

    def _lookup(self, path):
        for rec in self._tups:
            if path == rec[1]:
                return rec

    @property
    def first_path(self):
        return self._tups[0][1]


# == Mock open filehandle

def mock_filehandle_and_mutable_controller_via(
        expect_num_rewinds, lines, isatty=False, **kw):

    # HUGELY experimental, QUITE opaque right now. The way you alter the
    # behavior of the double is by hacking the state by passing a function
    # in place of the `lines` iterator argument. We implement rewind by
    # writing our own `__next__`

    these = _expect_num_rewinds(lines, expect_num_rewinds, isatty)
    do_next, do_seek, done = these

    def use_lines(state):
        state.next = do_next
        state.done = done  # my API not theirs
        memo.mc = state
        return state
    memo = use_lines  # ick/meh
    memo.mc = None
    fh = mock_filehandle(use_lines, **kw)
    assert not hasattr(fh, 'seek')
    assert memo.mc
    fh.seek = do_seek
    return fh, memo.mc


def _expect_num_rewinds(lines, expect_num_rewinds, isatty):
    if isatty:
        raise RuntimeError("can't rewind a TTY")

    if not 0 < expect_num_rewinds:
        raise RuntimeError("if you expect 0 rewinds, just don't")

    def use_next():
        return next(state.current_line_iterator)

    # Read all the lines of memory into a cache

    def check():
        check.count += 1
        if 20 < check.count:  # or whatever, some sane number
            xx('Maybe not read all these into memory at some sane limit')
        return True
    check.count = 0

    lines_cache = tuple(s for s in lines if check())

    # Add a `seek` method

    def use_seek(offset):
        assert 0 == offset
        if expect_num_rewinds == state.num_rewinds_so_far:
            msg = ("one more rewind requested when max of "
                   f"{expect_num_rewinds} already reached")
            raise RuntimeError(msg)
        state.num_rewinds_so_far += 1
        state.current_line_iterator = iter(lines_cache)
        return 0

    def done(tc):
        tc.assertEqual(state.num_rewinds_so_far, expect_num_rewinds)

    class state:  # #class-as-namespace
        current_line_iterator = None
        num_rewinds_so_far = -1  # YIKES BE CARFEUL ADvance tHe tHing NOW

    use_seek(0)
    assert 0 == state.num_rewinds_so_far
    return use_next, use_seek, done


def mock_filehandle(  # :[#507.11] the one
        lines, pretend_path=None,
        pretend_writable=False,
        isatty=False,
        ):

    if pretend_path is None and isatty:
        pretend_path = '<stdout>' if pretend_writable else '<stdin>'

    class mock_filehandle:

        # == Look like context manager

        def __enter__(self):
            return self

        def __exit__(self, typ, err, stack):
            state.close()

        # == Iterate

        def __iter__(self):
            return self

        def __next__(self):
            if state.is_closed:
                raise ValueError("I/O operation on closed file.")  # covered
            return state.next()

        # ==

        def close(_):
            return state.close()

        # == Assorted fixed properties

        name = pretend_path

        def isatty(_):
            return isatty

        def writable(_):
            return pretend_writable

        def readable(_):
            return True

        def fileno(_):
            if isatty:
                return 1 if pretend_writable else 0  # 2 is stderr but why
            return 12345

    class state:  # #class-as-namespace

        def close():
            if state.is_open:
                state.is_open, state.is_closed = False, True
                return
            raise RuntimeError("for now we whine about mutiple closes")  # covd
            # (in real life, it's okay)

        is_open, is_closed = True, False

    if hasattr(lines, '__next__'):
        def do_next():
            return next(lines)
        state.next = do_next
    elif callable(lines):
        state = lines(state)
        assert hasattr(state, 'next')
    else:
        raise TypeError(f"`lines` must be iterator or callable, had {lines!r}")

    return mock_filehandle()


# == Small model-ishes

class _RecordOfFileRewrite:

    def __init__(self, path, lines):
        self.path = path
        self.lines = lines


class _fake_dir_stat:  # #as-namespace-only
    st_mode = 16877


class _fake_file_stat:  # #as-namespace-only
    st_mode = 33188


# == support functions


def _lines_via_strings_with_optimistic_peek(lines):
    """EXPERIMENTAL: allow the client to represent a stream of lines without

    newline terminating each one *optionally*. The first line is peeked at
    and it is used to determine whether or not this behavior is desired.
    """

    assert(hasattr(lines, '__next__'))  # if not, nasty bugs below #[#022]

    empty = True
    for line in lines:  # #once
        empty = False
        break

    if empty:
        return

    if len(line) and '\n' == line[-1]:  # ..
        yield line
        for line in lines:
            yield line
        return

    yield f'{line}\n'
    for line in lines:
        yield f'{line}\n'


def xx(msg=None):
    raise RuntimeError(''.join(('write me', *((': ', msg) if msg else ()))))

# #pending-rename: "mock filehandle" (or filesystem) and move it to [ma]
# #history-A.1: introduce fake filesystem
# #abstracted.
