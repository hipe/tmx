STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = True
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = False
STORAGE_ADAPTER_IS_AVAILABLE = True


def FUNCTIONSERER_VIA_SCHEMA_FILE_SCANNER(schema_file_scanner, listener):

    dct = schema_file_scanner.flush_to_config(
            listener, storage_schema='allowed')
    if dct is None:
        return

    from .schema_via_file_lines import Schema_ as func
    schema = func(**dct)
    # something about above being null (Case5918)

    def funcser_via_coll_args(directory, listener, opn=None, rng=None):
        fs = opn.THE_WORST_HACK_EVER_FILESYSTEM_ if opn else None
        ci = _CI_via(directory, schema, fs, rng)
        from kiss_rdb.magnetics_.collection_via_path import \
            NEW_FUNCTIONSER_VIA_OLD_COLLECTION_IMPLEMENTATION_ as func
        return func(ci)

    class first_ns:  # #class-as-namespace
        FUNCTIONSER_VIA_COLLECTION_ARGS = funcser_via_coll_args
    return first_ns


def _CI_via(directory, schema, fs, rng):
    from .collection_via_directory import \
        collection_implementation_via_directory_and_schema as func
    return func(directory, schema, fs, rng)

# #history-B.4
# #born late
