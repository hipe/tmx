from modality_agnostic.memoization import memoize


@memoize
def filesystem_expecting_no_rewrites():

    def inj(*_):
        assert(False)

    def finish():
        return 'hi there were no file rewrites'

    return _build_filesystem_via_two_funcs(inj, finish)


def build_filesystem_expecting_num_file_rewrites(expected_num):

    recs = []

    def INJECTED_FELLOW(from_fh, to_fh):

        if len(recs) == expected_num:
            raise Exception('too many doo-hahs')

        from_fh.seek(0)  # necessary
        _new_lines = tuple(iter(from_fh))

        recs.append(_RecordOfFileRewrite(
            path=to_fh.name,
            lines=_new_lines,))

    def finish():

        nonlocal recs
        if len(recs) != expected_num:
            _msg = ('expected there to be more file rewrites '
                    f'(needed {expected_num}, had {len(recs)})')
            raise Exception(_msg)

        res = tuple(recs)
        del(recs)  # works! (as a safety measure)
        return res

    return _build_filesystem_via_two_funcs(INJECTED_FELLOW, finish)


def _build_filesystem_via_two_funcs(INJECTED_FELLOW, finish):
    from kiss_rdb.magnetics_ import filesystem as _

    fs = _.Filesystem_EXPERIMENTAL(INJECTED_FELLOW)

    fs.FINISH_AS_HACKY_SPY = finish

    return fs


# ==

class _RecordOfFileRewrite:

    def __init__(self, path, lines):
        self.path = path
        self.lines = lines

# #abstracted.
