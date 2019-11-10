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

from modality_agnostic.memoization import (
        OneShotMutex,
        lazy)


@lazy
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

    def open(self, path, mode):
        # below used to be _FakeWriteSession before #history-A.1

        if mode not in ('w', 'x'):
            raise Exception(f'cover me: {repr(mode)}')

        buff = []
        mutex = OneShotMutex()

        def on_OK_exit():
            mutex.shoot()
            self._receive_writes(buff, path)

        from modality_agnostic import write_only_IO_proxy
        return write_only_IO_proxy(
                write=lambda s: buff.append(s),  # #hi.
                on_OK_exit=on_OK_exit)

    def _receive_writes(self, writes, path):
        if path not in self._order:
            self._order.append(path)
        self._string_via_path[path] = ''.join(writes)

    def file_exists(self, path):
        return (path in self._string_via_path)

    @lazy
    def the_empty_filesystem():
        return FakeFilesystem()


class _FakeReadOnlyIO:

    def __init__(self, content):
        self._content = content

    def read(self):
        return self._content

# #history-A.1
# #born.
