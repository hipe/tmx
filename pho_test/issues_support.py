from collections import namedtuple


def build_end_state_for(tc, run):

    # One day it would be nice..
    def opn(path, mode=None):
        assert readme == path
        if mode:
            assert 'r' == mode[0]
        return fh

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

    expect_num_rewinds = tc.expected_num_rewinds()
    assert -1 < expect_num_rewinds

    pw = True  # might become a per-case option

    import modality_agnostic.test_support.mock_filehandle as lib
    if expect_num_rewinds:
        fh, mc = lib.mock_filehandle_and_mutable_controller_via(
                expect_num_rewinds, lines, pretend_path=readme,
                pretend_writable=pw)
    else:
        fh = lib.mock_filehandle(lines, readme, pretend_writable=pw)
        mc = None

    # Prepare emission handling
    emis = tc.expected_emissions()
    import modality_agnostic.test_support.common as em
    listener, done = em.listener_and_done_via(emis, tc)

    # Execute the performance under test
    x = run(readme, opn, listener)
    dct = done()
    if mc:
        mc.done(tc)
    return _EndState(dct, memo.value, x)


_EndState = namedtuple('EndState', ('emissions', 'diff_lines', 'end_result'))


# #abstracted
