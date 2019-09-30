STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = True
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = False
STORAGE_ADAPTER_IS_AVAILABLE = True


def RESOLVE_SCHEMA_BASED_COLLECTION_AS_STORAGE_ADAPTER(
        schema_file_scanner,
        collection_identity,
        random_number_generator,
        filesystem,
        listener,
        ):

    schema = __schema_via(schema_file_scanner, listener)
    if schema is None:
        return

    from .collection_via_directory import (
            collection_via_directory_and_schema)

    return collection_via_directory_and_schema(
            collection_identity=collection_identity,
            collection_schema=schema,
            random_number_generator=random_number_generator,
            filesystem=filesystem)


def __schema_via(schema_file_scanner, listener):

    # parse the schema file using our own .. meta-schema we define here:
    dct = schema_file_scanner.flush_to_config(
            listener,
            storage_schema='required')
    if dct is None:
        return

    # ok good job
    from .schema_via_file_lines import Schema_
    schema = Schema_(**dct)
    # something about above being null (Case5918)

    return schema


# #born late
