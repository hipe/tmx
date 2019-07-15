class common_producer_script:  # #as-namespace-only

    def common_CLI_library():
        import kiss_rdb.cli.LEGACY_stream as mod
        return mod

    # we want these to go away soon

    def far_key_simplifier():
        return common_producer_script._key_simp('COMMON_FAR_KEY_SIMPLIFIER_')

    def near_key_simplifier():
        return common_producer_script._key_simp('COMMON_NEAR_KEY_SIMPLIFIER_')

    def mapper_for(s):
        _ = common_producer_script._this_module
        return f'{_}.this_one_mapper_("{s}")'

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
    # same as above


def YIKES_SKIP_HEADERS(far_dct):
    """
    so:
      - (Case1510DP)
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


_exe = Exception

# #history-A.1 (as referenced, can be temporary)
# #abstracted.
