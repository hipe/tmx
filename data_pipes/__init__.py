# (at #history-A.3 got rid of some indirection/hops thing)


class The_Not_OK_Context_Manager:

    def __enter__(self):
        return _not_OK

    def __exit__(self, *_):
        return False


class _not_OK:  # #class-as-namespace
    OK = False


class TheEmptyIteratorContextManager:  # :[#510.11] the empty iterator CM

    def __init__(self):
        self._mutex = None

    def __enter__(self):
        del self._mutex
        return ()

    def __exit__(self, *_3):
        return False


class ThePassThruContextManager:  # :[#510.12] the pass-thru context manager

    def __init__(self, x):
        self._mixed = x

    def __enter__(self):
        x = self._mixed
        del self._mixed
        return x

    def __exit__(self, *_3):
        return False

# #history-A.3: rewrite: gain context managers, lose indirection hubs
# #history-A.2: sunset header filter
# #history-A.1 (as referenced, can be temporary)
# #abstracted.
