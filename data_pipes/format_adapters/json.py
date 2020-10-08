STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = False
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = True
STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS = ('.json',)
STORAGE_ADAPTER_IS_AVAILABLE = True


def COLLECTION_IMPLEMENTATION_VIA_SINGLE_FILE(io, listener):

    # == B
    assert hasattr(io, 'fileno')  # in the future support path (strings)
    assert 'w' == io.mode  # in the future support read from stdin
    # == E

    class Cha_Cha:
        pass

    return Cha_Cha()


# #born as nonworking stub
