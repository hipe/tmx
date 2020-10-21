STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = True
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = False
STORAGE_ADAPTER_IS_AVAILABLE = True


OHAI = "hello from storo adapto 1"


def ADAPTER_OPTIONS_VIA_SCHEMA_FILE_SCANNER(schema_file_scanner, listener):
    # get way more complicated at #history-B.4 for magnetics fields
    # but then simpler at #history-B.5

    dct = schema_file_scanner.flush_to_config(
            listener,
            idens_must_start_with_letter='required',
            number_of_digits_in_idens='required')
    return dct


def FUNCTIONSER_VIA_DIRECTORY_AND_ADAPTER_OPTIONS(
        path, listener, opn,
        idens_must_start_with_letter, number_of_digits_in_idens):

    def create(parse_EID, x, listener):
        num = len(dict_as_datastore) + 1
        fmt = f'%0{number_of_digits_in_idens}d'
        pcs = (idens_must_start_with_letter, (fmt % num))
        parse_me = ''.join(pcs)
        d = parse_EID(parse_me, listener)
        assert(d)
        assert d not in dict_as_datastore
        dict_as_datastore[d] = x
        return 'ohai_i_am_adapto_2_who_created_this_guy', parse_me, x

    def retrieve(iden, listener):
        assert iden in dict_as_datastore
        return 'this_is_supposed_to_be_wrapped', dict_as_datastore[iden]

    class edit_ns:  # #class-as-namespace
        create_entity_as_storage_adapter_collection = create

    class read_ns:  # #class-as-namespace
        retrieve_entity_as_storage_adapter_collection = retrieve

    def produce_iden_func():
        def iden_via_EID(eid, listener):
            if (md := rx.match(eid)) is None:
                raise RuntimeError(f"have fun covering this: {eid!r}")
            return int(md[1])
        import re
        char = re.match('([A-Z])$', idens_must_start_with_letter)[0]
        num = int(number_of_digits_in_idens)
        rx = re.compile(''.join((char, '([0-9]{', str(num), '})$')))
        return iden_via_EID

    def lambdize(x):
        return lambda: x

    dict_as_datastore = {}

    class fxr:  # #class-as-namespace
        PRODUCE_EDIT_FUNCTIONS_FOR_DIRECTORY = lambdize(edit_ns)
        PRODUCE_READ_ONLY_FUNCTIONS_FOR_DIRECTORY = lambdize(read_ns)
        PRODUCE_IDENTIFIER_FUNCTION = produce_iden_func
        COLL_IMPL_YUCK_ = __file__
    return fxr

# #history-B.5
# #history-B.4
# #born.
