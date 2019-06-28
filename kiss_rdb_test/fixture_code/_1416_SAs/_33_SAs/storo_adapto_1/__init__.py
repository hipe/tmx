STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = True
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = False
STORAGE_ADAPTER_IS_AVAILABLE = True


def RESOLVE_SCHEMA_BASED_COLLECTION_AS_STORAGE_ADAPTER(
        schema_file_scanner, collection_path,
        random_number_generator, filesystem, listener):

    # this below line is kind of a "make a lot of contact" sort of integration
    # test. If we don't do it, we are fine (it is well covered in our previous
    # test module) so for now we're just doing it for fun and as an example

    dct = schema_file_scanner.flush_to_config(
            listener,
            valley_for_storo_1='required',
            valley_for_storo_1_B='required')
    return {
            'message for the test': 'hello from storage adapter 1',
            'also this': dct['valley_for_storo_1']}

# #born.
