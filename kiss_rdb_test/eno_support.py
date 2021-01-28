def coll_via_path(dir_path, **kw):
    if len(kw):
        assert ('rng',) == tuple(kw.keys())  # just saying hello
    func = _subject_module().mutable_eno_collection_via
    return func(dir_path, **kw)


def import_sub_module(entry):
    use_mod_name = '.'.join((_subject_module_name, entry))
    from importlib import import_module as func
    return func(use_mod_name)


def _subject_module():
    from importlib import import_module as func
    return func(_subject_module_name)


_subject_module_name = 'kiss_rdb.storage_adapters_.eno'  # experiment

# #born 16 months later
