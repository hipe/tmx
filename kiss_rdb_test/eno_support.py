def coll_via_path(dir_path, **kw):

    if len(kw):
        strange = set(kw.keys()) - _OK_williams
        if strange:
            raise RuntimeError(f"oops: {strange!r}")

    func = _subject_module().mutable_eno_collection_via
    return func(dir_path, **kw)


def import_sub_module(entry):
    use_mod_name = '.'.join((_subject_module_name, entry))
    from importlib import import_module as func
    return func(use_mod_name)


def _subject_module():
    from importlib import import_module as func
    return func(_subject_module_name)


_OK_williams = set(('rng', 'do_load_schema_from_filesystem'))

_subject_module_name = 'kiss_rdb.storage_adapters_.eno'  # experiment

# #born 16 months later
