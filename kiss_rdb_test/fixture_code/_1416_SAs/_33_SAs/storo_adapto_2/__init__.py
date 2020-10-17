STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = False
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = True
STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS = '.xtc', '.qkr'
STORAGE_ADAPTER_IS_AVAILABLE = True


# == As Functionser (experimental)

def FUNCTIONSER_VIA_COLLECTION_ARGS(coll_path, _listener, opn=None):
    assert isinstance(coll_path, str)  # #[#022]
    del coll_path  # here it's just a formality

    def create(iden_via_EID, x, listener):
        d = len(dict_as_datastore) + 1
        k = ''.join(('felloo', str(d)))
        assert iden_via_EID(k, listener)
        dict_as_datastore[k] = x
        return 'ohai_i_am_adapto_2_who_created_this_guy', k, x

    def retrieve(iden, listener):
        assert iden in dict_as_datastore
        return 'this_is_supposed_to_be_wrapped', dict_as_datastore[iden]

    def produce_edit_functions():
        return edit_ns

    def produce_read_functions():
        return read_ns

    class edit_ns:  # #class-as-namespace
        create_entity_as_storage_adapter_collection = create

    class read_ns:  # #class-as-namespace
        retrieve_entity_as_storage_adapter_collection = retrieve

    def produce_iden_func():
        return _string_based_idens

    dict_as_datastore = {}

    class ns:  # #class-as-namespace
        EDIT_FUNCTIONS_ARE_AVAILABLE = True
        READ_ONLY_FUNCTIONS_ARE_AVAILABLE = True
        PRODUCE_EDIT_FUNCTIONS = produce_edit_functions
        PRODUCE_READ_ONLY_FUNCTIONS = produce_read_functions
        PRODUCE_IDENTIFIER_FUNCTION = produce_iden_func
        COLL_IMPL_YUCK_ = __file__
    return ns


def _string_based_idens(x, _listener):
    assert isinstance(x, str)
    assert len(x)
    return x


# got rid of stuff at #history-A.4

OHAI = 'hello from storo adapto 2'

# #history-A.4
# #born.
