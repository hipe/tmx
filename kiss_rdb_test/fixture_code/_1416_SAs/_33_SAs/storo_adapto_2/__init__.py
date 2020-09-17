STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = False
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = True
STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS = ('.xtc', '.qkr')
STORAGE_ADAPTER_IS_AVAILABLE = True


def COLLECTION_IMPLEMENTATION_VIA_SINGLE_FILE(
        collection_path, listener=None, opn=None, rng=None):

    listener('info', 'structure', 'hi_from_SA_2', lambda: {'message': 'SA2'})

    return ("hello from storo adapto 2. "
            f"you know you want this - {collection_path}")

# #born.
