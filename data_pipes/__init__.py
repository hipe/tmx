# (at #history-A.3 got rid of some indirection/hops thing)


def meta_collection_():
    if (memo := meta_collection_).value is None:
        memo.value = _build_meta_collection()
    return memo.value


meta_collection_.value = None


def _build_meta_collection():
    from kiss_rdb import hub_mod_name_and_mod_dir as func
    mod_name_1, mod_dir_1 = func()

    pcs = 'data_pipes', 'format_adapters'
    from os.path import join as path_join, dirname as dn
    mod_name, mod_dir = '.'.join(pcs), path_join(dn(dn(__file__)), *pcs)

    from kiss_rdb.magnetics_.collection_via_path import \
        collectioner_via_storage_adapters_module as func
    return func(mod_name_1, mod_dir_1, mod_name, mod_dir)


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


# #history-A.3: rewrite: gain context managers, lose indirection hubs
# #history-A.2: sunset header filter
# #history-A.1 (as referenced, can be temporary)
# #abstracted.
