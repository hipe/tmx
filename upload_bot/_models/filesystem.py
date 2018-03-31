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

    def open_if_exists(self, path, f):
        x = None
        try:
            with open(path, 'r') as fh:
                x = f(fh)
        except FileNotFoundError:
            pass
        return x


class FakeFilesystem:
    """cha cha.

    """

    def __init__(self):
        self._order = []
        self._string_via_path = {}

    def open_if_exists(self, path, f):
        content = self._string_via_path.get(path)
        if content is not None:
            return f(_FakeReadOnlyIO(content))

    def _receive_writes(self, writes, path):
        if path not in self._order:
            self._order.append(path)
        self._string_via_path[path] = ''.join(writes)

    def open(self, path, mode):
        if 'x' == mode:
            ok = True
        elif 'w' == mode:
            ok = True
        if ok:
            return _FakeWriteSession(path, self)
        else:
            raise Exception('cover me: {}'.format(repr(mode)))

    def file_exists(self, path):
        return (path in self._string_via_path)

    @memoize
    def the_empty_filesystem():
        return FakeFilesystem()


class _FakeWriteSession:

    def __init__(self, path, parent):
        self._writes = []
        self._path = path
        self._parent = parent

    def __enter__(self):
        return self

    def __exit__(self, xa, xb, xd):
        if xa is None:
            a = self._writes
            del self._writes
            self._parent._receive_writes(a, self._path)
        else:
            raise Exception('cover me')

    def write(self, s):
        self._writes.append(s)
        return len(s)


class _FakeReadOnlyIO:

    def __init__(self, content):
        self._content = content

    def read(self):
        return self._content


# #born.
