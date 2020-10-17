def build_collection(dir_path, schema, inj):
    if len(inj):
        inj = {_short_name_via_long_name[k]: v for k, v in inj.items()}
    func = subject_module().collection_implementation_via_directory_and_schema
    ci = func(dir_path, schema, **inj)
    from kiss_rdb.magnetics_.collection_via_path import \
        NEW_COLLECTION_VIA_OLD_COLLECTION_IMPLEMENTATION_ as func
    return func(ci)


_short_name_via_long_name = {
    'filesystem': 'fs',
    'random_number_generator': 'rng',
}


def subject_module():
    from kiss_rdb.storage_adapters_.toml import collection_via_directory as mod
    return mod

# #born 21 months later
