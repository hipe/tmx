STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = False
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = True
STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS = '.xtc', '.qkr'
STORAGE_ADAPTER_IS_AVAILABLE = True


# == As Functionser (experimental)

def FUNCTIONSER_FOR_SINGLE_FILES():

    class edit_ns:  # #class-as-namespace
        def CREATE_NEW_WAY(fp, iden_via, dct, listener):
            msg, _path = fp
            assert "we assume you aren't actually writing.." == msg
            return _do_create(iden_via, dct, listener)

    class read_ns:  # #class-as-namespace
        def schema_and_entities_via_lines(fp, listener):

            do_populate_dict = True

            if len(dict_as_datastore):
                # hackishly, for a different test, when we see that the
                # dict has been written to at all, blank slate assume
                # only the dict is it the guy, and not the fp
                do_populate_dict = False

            if do_populate_dict:
                for line in fp:
                    name_from_line = line[:-1]
                    dct = {'my_name_from_line': name_from_line}
                    _do_create(_string_based_idens, dct, listener)

            def ents():
                for k, v in dict_as_datastore.items():
                    yield _MinimalEntity(k, v)
            return None, ents()

    def _do_create(iden_via_EID, x, listener):
        d = len(dict_as_datastore) + 1
        k = ''.join(('felloo', str(d)))
        assert iden_via_EID(k, listener)
        dict_as_datastore[k] = x
        return 'ohai_i_am_adapto_2_who_created_this_guy', k, x

    def _SOON_retrieve(iden, listener):
        assert iden in dict_as_datastore
        return 'this_is_supposed_to_be_wrapped', dict_as_datastore[iden]

    print("ONCE.")
    dict_as_datastore = {}

    def lambdize(x):  # gets around warning 😢
        return lambda: x

    class fxr:  # #class-as-namespace
        PRODUCE_EDIT_FUNCTIONS_FOR_SINGLE_FILE = lambdize(edit_ns)
        PRODUCE_READ_ONLY_FUNCTIONS_FOR_SINGLE_FILE = lambdize(read_ns)
        PRODUCE_IDENTIFIER_FUNCTION = lambdize(_string_based_idens)
        COLL_IMPL_YUCK_ = None
    return fxr


def _string_based_idens(x, _listener):
    assert isinstance(x, str)
    assert len(x)
    return x


class _MinimalEntity:
    def __init__(self, k, adct):
        self._key = k
        self._dct = adct

    def say_hello_as_entity(self):
        return f"Hi I'm '{self.ent_name}'"

    @property
    def ent_name(self):
        return self._dct['my_name_from_line']

    @property
    def identifier(self):
        return self._key

    @property
    def core_attributes_dictionary_as_storage_adapter_entity(self):
        return self._dct


# got rid of stuff at #history-A.4

OHAI = 'hello from storo adapto 2'

# #history-A.4
# #born.
