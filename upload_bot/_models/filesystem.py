"""a tiny, thin abstraction layer on top of (a tiny subset of) The Filesystem.

there are two design objectives of this, one concrete and one abstract:

abstractly, we imagine that one day we might want something resembling a
"filesystem" that is perhaps not backed by a real filesystem but by some
other datastore; but is nonetheless injected into the asset which uses it
"like" a filesystem.

imagine, for example, a microservice meant to run as an amazon lambda,
which cannot have a real filesystem under it. it might be useful to start
development of such a thing using familiar filesystem idioms which are
nonethess wrapped through this abstraction layer so we can come up with
some novel workaround for this limitation on lambda.

the more concrete inspiration for the subject is that that this makes
testing more elegant, to be able to fake the filesystem rather than set up
and tear down filesystem trees for tests.

normally to have paraphernalia concerned with testing here in the "asset"
portion of our sub-project tree would a smell, but in this case the test-
friendly ("fake") counterpart of Filesystem
"""

from game_server import (
        memoize,
        )


@memoize
def real_filesystem():
    return _RealFilesystem()


class _RealFilesystem:
    """easy-peasy. a stateless singleton representing the real filesystem.

    at writing all this does is combine some familar methods from different
    locations into one place (keeping their same names).
    """

    def __init__(self):
        import os
        self.file_exists = os.path.exists
        self.open = open


class FakeFilesystem:
    """cha cha.

    """

    def __init__(self, *paths):
        self._paths = [path for path in paths]

    def open(self, path, mode):
        if 'w' != mode:
            raise Exception('cover me: {}'.format(repr(mode)))

        if path not in self._paths:
            self._paths.append(path)

        return _MOCK_FILEHANDLE

    def file_exists(self, path):
        return (path in self._paths)

    @memoize
    def the_empty_filesystem():
        return FakeFilesystem()


class _MockFilehandle:

    def __enter__(self):
        return self  # cheating

    def __exit__(self, *_):
        pass

    def write(self, s):
        return len(s)


_MOCK_FILEHANDLE = _MockFilehandle()


# #born.
