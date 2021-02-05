def build_collection(dir_path, schema, inj):
    kw = {_short_name_via_long_name[k]: v for k, v in inj.items()}
    kw['toml_schema'] = schema  # let's go
    kw['do_load_schema_from_filesystem'] = False

    sa_mod = _subject_module()

    lib = _lib_module()
    return lib.collection_via_storage_adapter_and_path(
        sa_mod, dir_path, _throwing_listener, **kw)


_short_name_via_long_name = {
    'filesystem': 'fs',
    'random_number_generator': 'rng',
}


def _throwing_listener(*x):
    raise RuntimeError(f"Unexpected emission: {x[:-1]!r}")


def _lib_module():
    import kiss_rdb as module
    return module


def _subject_module():
    import kiss_rdb.storage_adapters_.toml as module
    return module

# #born 21 months later
