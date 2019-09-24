class common_producer_script:  # #as-namespace-only

    def common_CLI_library():
        import kiss_rdb.cli.LEGACY_stream as mod
        return mod

    # we want these to go away soon

    def _key_simp(tail):
        return '.'.join((common_producer_script._this_module, tail))

    def LEGACY_markdown_lib():
        from kiss_rdb.storage_adapters_.markdown_table import (  # same as belo
                LEGACY_markdown_document_via_json_stream as mod)
        return mod

    def TEMPORARY_LEGACY_USE_OF_SYNC_LIB():
        from data_pipes.cli import sync as mod
        return mod

    _this_module = 'kiss_rdb.storage_adapters_.markdown_table.LEGACY_markdown_document_via_json_stream'  # noqa: E501


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

# #history-A.2: sunset header filter
# #history-A.1 (as referenced, can be temporary)
# #abstracted.
