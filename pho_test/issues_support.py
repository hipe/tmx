from collections import namedtuple


def build_end_state_for(tc, run):

    # One day it would be nice..
    def opn(path, mode=None):
        assert readme == path
        if mode:
            assert 'r' == mode[0]
        return fh

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

    # Hackily, we use this to call provision iden and also CUD verbs
    diff_lines = None
    if hasattr(x, '_asdict'):  # is it not just a tuple but a named tuple
        dct = x._asdict()
        diff_lines = tuple(dct.pop('diff_lines'))
        emit_edited = dct.pop('emit_edited')
        typ = x.__class__.__name__
        if 'CreateResult' == typ:
            emit_edited(* dct.values())
        elif 'UpdateResult' == typ:
            assert not emit_edited  # hrm..
        else:
            raise RuntimeError(f"wahoo: '{typ}'")

    dct = done()
    if mc:
        mc.done(tc)

    return _EndState(dct, diff_lines, x)


_EndState = namedtuple('EndState', ('emissions', 'diff_lines', 'end_result'))


# #abstracted
