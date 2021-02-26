"""ABOUT THIS MODULE:
it's a blind rewrite we wrote in about a day of something that took us
several weeks several years ago, over in the other hemisphere. Ideally etc.
"""


def real_system_response_via_story_source_path_(source_path, listener):
    from ._creation_directives_via_lines import func
    from os.path import join as path_join
    path = path_join(source_path, 'how-to-create-the-responses.rec')
    with open(path) as fh:
        directives = tuple(func(fh, listener))

    direc, = directives  # for now
    typ = direc[0]
    assert 'compound_directive' == typ
    cd, = direc[1:]

    return cd.RUN_THE_TRACK(source_path, listener)


class StrictDict_(dict):
    def __setitem__(self, k, v):
        assert k not in self
        return super().__setitem__(k, v)


def xx(msg=None):
    raise RuntimeError(''.join(('write me', *((': ', msg) if msg else ()))))

# #born
