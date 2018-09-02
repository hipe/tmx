def YIKES_SKIP_HEADERS(far_dct):
    """
    so:
      - #coverpoint13.3
      - TEMPORARY LOCATION POSSIBLY, came as a byproduct of #history-A.1
      - probabably a `_is_section_separator` would be in order, but for
        now we are making this work with legacy fellows
    """

    return 'header_level' not in far_dct


class _MyContextlib:

    def __init__(self):
        self._eicm = None
        self._nocm = None

    def context_manager_via_iterator__(self, itr):
        import contextlib

        @contextlib.contextmanager
        def f():
            yield itr
        return f()

    def empty_iterator_context_manager(self):
        if self._eicm is None:
            self._eicm = _EmptyIteratorCM()
        return self._eicm

    def not_OK_context_manager(self):
        if self._nocm is None:
            self._nocm = _NotOKCM()  # must be obect can't be class
        return self._nocm


my_contextlib = _MyContextlib()


class _EmptyIteratorCM:

    def __enter__(self):
        return iter(())

    def __exit__(self, *_):
        return False


class _NotOKCM:

    def __enter__(self):
        return _not_OK

    def __exit__(self, *_):
        return False


class _not_OK:
    OK = False


def pop_property(self, var):
    x = getattr(self, var)
    delattr(self, var)
    return x


def cover_me(msg=None):
    _use_msg = 'cover me' if msg is None else ('cover me - %s' % msg)
    raise _exe(_use_msg)


def sanity(s=None):
    _msg = 'sanity' if s is None else 'sanity: %s' % s
    raise _exe(_msg)


_exe = Exception

# #history-A.1 (as referenced, can be temporary)
# #abstracted.
