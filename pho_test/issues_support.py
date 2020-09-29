from collections import namedtuple


def build_end_state_for(tc, run, allow_rewind=False):

    def opn(path, *mode):
        assert readme == path
        if len(mode):
            mode, = mode
            assert 'r' == mode
            assert allow_rewind
        else:
            assert not allow_rewind
        return pfile

    def recv_diff_lines(lines):
        assert memo.value is None
        memo.value = tuple(lines)
        return True  # tell it you succeeded

    memo = recv_diff_lines
    memo.value = None

    opn.RECEIVE_DIFF_LINES = recv_diff_lines

    # Prepare file
    readme = 'my-fake/readme'
    lines = tc.given_lines()
    if allow_rewind:
        pfile = _pretend_file_rewindable(readme, lines)
    else:
        pfile = _pretend_file_classic(readme, lines)

    # Prepare emission handling
    emis = tc.expected_emissions()
    import modality_agnostic.test_support.common as em
    listener, done = em.listener_and_done_via(emis, tc)

    # Execute the performance under test
    x = run(readme, opn, listener)
    dct = done()
    return _EndState(dct, memo.value, x)


class _pretend_file_rewindable:  # #[#508.4]

    def __init__(self, path, lines):
        self._read_OK = True
        self._frozen_lines = tuple(lines)
        self.name = path

    def __iter__(self):
        assert self._read_OK
        self._read_OK = False
        return iter(self._frozen_lines)

    def seek(self, offset):
        assert 0 == offset
        assert not self._read_OK
        self._read_OK = True

    def close(self):
        del self._frozen_lines

    @property
    def fileno(_):
        pass  # necesasry to look like open filehandle

    mode = 'r'


class _pretend_file_classic:  # #[#508.4]

    def __init__(self, path, lines):
        self._lines = lines
        self.path = path

    def __enter__(self):
        x = self._lines
        del self._lines
        return x

    def __exit__(self, typ, err, stack):
        pass


_EndState = namedtuple('EndState', ('emissions', 'diff_lines', 'end_result'))


# #abstracted
