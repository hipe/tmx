STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = True
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = False
STORAGE_ADAPTER_IS_AVAILABLE = True
# STORAGE_ADAPTER_UNAVAILABLE_REASON = "it's a placeholder stub"


"""
NOTE when we say `directory` we mean the collection path. when we say `path`
we mean the path to the particular file in the multi-file collection.
"""


# == BEGIN

def section_line(label, depth=1):
    assert(1 == depth)
    return f'# {label}\n'


def multiline_field_lines(var_name, lines, yes_trailing_newline=True):
    delim = f'-- {var_name}\n'  # _eol
    yield delim
    for line in lines:
        assert('--' != line[0:2])
        yield line
    if yes_trailing_newline:
        yield '\n'  # _eol - without this, no trailing newline in decoded str
    yield delim


def field_line(var_name, string_value):
    return f'{var_name}: {string_value}\n'

# == END


def COLLECTION_IMPLEMENTATION_VIA_SCHEMA(
        schema_file_scanner, collection_identity,
        random_number_generator, filesystem, listener):

    # #open [#873.S] at birth of this storage adapter, we are hard-coding it
    # to support only one storage schema. but when the day comes, abstract
    # the things out of the sibling spot in the toml adapter

    dct = schema_file_scanner.flush_to_config(
            listener,
            storage_schema='allowed')

    if 'storage_schema' in dct:
        assert('32x32x32' == dct['storage_schema'])

    return _stateless_collection_implementation_via_directory(
            collection_identity.collection_path)


def _stateless_collection_implementation_via_directory(directory):

    class StatelessCollectionImplementation:  # #class-as-namespace

        def retrieve_entity_as_storage_adapter_collection(ID, listener):
            return _retrieve_entity(ID, directory, listener)

        def to_identifier_stream_as_storage_adapter_collection(listener):
            return _traverse_IDs(directory, 3, listener)

    return StatelessCollectionImplementation


def _retrieve_entity(ID, directory, listener):

    mon = _monitor_via_listener(listener)

    sect_el = _retrieve_entity_section_element(ID, directory, mon)
    if sect_el is None:
        return
    return _read_only_entity(sect_el, ID, mon)


def _read_only_entity(sect_el, ID, mon):

    dct = {k: v for k, v in _attribute_keys_and_values(sect_el, mon)}
    if not mon.OK:
        return

    class ReadOnlyEntity:  # #class-as-namespace

        def to_dictionary_two_deep_as_storage_adapter_entity():
            return {'identifier_string': ID.to_string(),
                    'core_attributes': dct}

        core_attributes_dictionary_as_storage_adapter_entity = dct
        identifier = ID

    return ReadOnlyEntity


def _attribute_keys_and_values(sect_el, mon):

    def assert_key(use_key):
        if rx.match(use_key):
            return
        msg = f"field key is not up to current spec - '{use_key}'"
        raise AssertionError(msg)

    import re
    rx = re.compile('[a-z0-9_A-Z]+$')

    section = sect_el.to_section()  # #here3
    for el in section.elements():  # #here2

        if el.yields_list():
            use_key = el.string_key()
            li = el.to_list()
            values = li.required_values(None)
            assert_key(use_key)
            yield use_key, values
            continue

        # change these to whatever whenever. they're just curb-checks
        assert(not el.yields_section())
        assert(not el.yields_fieldset())
        assert(not el.yields_list())
        assert(not el.yields_empty())
        assert(el.yields_field())

        field = el.to_field()

        # we haven't formally specified this anywhere yet. just a sketch..
        use_key = field.string_key()
        assert_key(use_key)

        yield use_key, field.required_string_value()


def _retrieve_entity_section_element(ID, directory, mon):

    if 3 != ID.number_of_digits:  # ..
        _when_identifier_is_wrong_depth(mon.listener, ID, 3, 'retrieve')
        return

    # == BEGIN duplicate logic (softly) from elsewhere

    (*these, penult_digit, last_digit) = ID.native_digits
    _intermediate_dirs = tuple(o.character for o in these)
    _filename = f'{penult_digit.character}.eno'
    from os import path as os_path
    path = os_path.join(directory, _entites_fn, *_intermediate_dirs, _filename)

    # == END

    document, e = _eno_document_via_path(path, mon.listener)
    if document is None:
        _when_entity_not_found_because_no_file(mon.listener, e, path, ID)
        return

    target_ID_s = ID.to_string()
    count = 0

    for ID_s, sect_el in _entity_section_elements(document, path, mon):
        if target_ID_s == ID_s:
            return sect_el
        count += 1

    if not mon.OK:
        return

    _when_section_not_found(mon.listener, count, target_ID_s, path)


def _traverse_IDs(directory, depth, listener):

    mon = _monitor_via_listener(listener)
    listener = mon.listener  # overwrite argument

    from kiss_rdb.magnetics_.identifier_via_string import \
        identifier_via_string_

    file_pps = _file_posix_paths_in_collection_directory(directory, depth)
    # ..
    for file_pp in file_pps:

        path = str(file_pp)
        document, e = _eno_document_via_path(path, mon.listener)
        if document is None:
            xx()
            return

        for ID_s, _sect_el in _entity_section_elements(document, path, mon):
            ID = identifier_via_string_(ID_s, listener)  # #here4
            if ID is None:
                return
            yield ID

        if not mon.OK:
            return  # if one file is bad, stop on the whole batch


def _file_posix_paths_in_collection_directory(directory, depth):

    def sorted_entries_of(posix_path):  # #cp never rely on filesystem order
        _generator = posix_path.glob('*')  # ..
        _entries = list(_generator)
        return sorted(_entries, key=lambda pp: pp.as_posix())

    from os import path as os_path
    _entities_dir = os_path.join(directory, _entites_fn)

    from pathlib import Path
    entities_dir_pp = Path(_entities_dir)

    dirs = sorted_entries_of(entities_dir_pp)

    if not len(dirs):
        xx()  # empty entities dir. does it really need its own case?

    assert(3 == depth)

    for dir_pp in dirs:
        for file_pp in sorted_entries_of(dir_pp):
            yield file_pp


def _entity_section_elements(document, path, mon):

    state_machine = {
            'start': {
                'entity_section': lambda: change_from_start_to_main(),
                'document_meta': lambda: on_doc_meta(),
                },
            'main': {
                'entity_section': lambda: see_nonfirst_section(),
                'document_meta': lambda: on_doc_meta(),
                },
            'doc_meta': {
                'end': lambda: None
                }}

    class State:
        pass
    state = State()
    state.current_state_name = 'start'
    state.current_state = state_machine[state.current_state_name]
    state.has_thing_to_yield = False

    def change_from_start_to_main():
        be_in_state('main')
        state.length_of_first_identifier = len(ID_s)
        state.first_identifier_string = ID_s
        state.previous_identifier_string = ID_s
        yield_this_section_next()

    def see_nonfirst_section():
        # NOTE EXPERIMENTAL crude cheap check on integrity. we are not parsing
        # the traversed identifiers fully, so invalid chars could get thru.
        # in other adaptations we do no such checks on RETRIEVE at all, but
        # here it feels too easy (and fast) not to. but see #here4

        if len(ID_s) != state.length_of_first_identifier:
            _when_inconsistent_depth(mon.listener, ID_s, sect_el, state, path)
            return

        if not (state.previous_identifier_string < ID_s):
            _when_out_of_order(mon.listener, ID_s, sect_el, state, path)
            return

        state.previous_identifier_string = ID_s
        yield_this_section_next()

    def on_doc_meta():
        be_in_state('doc_meta')

    def yield_this_section_next():
        assert(not state.has_thing_to_yield)
        state.has_thing_to_yield = True
        state.yield_me = ID_s, sect_el

    def be_in_state(typ):
        state.current_state = state_machine[typ]
        state.current_state_name = typ

    def try_to_transition_to(typ):
        call_me = state.current_state.get(typ)
        if call_me is None:
            _when_no_state_transition(mon.listener, typ, sect_el, state, path)
            return
        call_me()

    def release_thing_to_yield():
        x = state.yield_me
        del state.yield_me
        state.has_thing_to_yield = False
        return x

    for typ, ID_s, sect_el in _tokenized_sections(document, path, mon.listener):  # noqa: E501
        try_to_transition_to(typ)

        if not mon.OK:
            break

        if state.has_thing_to_yield:
            yield release_thing_to_yield()

    if not mon.OK:
        return

    try_to_transition_to('end')

    if state.has_thing_to_yield:
        yield release_thing_to_yield()


def _tokenized_sections(document, path, listener):
    # the only allowed sections in the document look like this

    from kiss_rdb.magnetics.string_scanner_via_string import StringScanner, \
            pattern_via_description_and_regex_string as o

    first_word = o('entity|document-meta', r'(entity|document-meta)\b')
    eos = o('end of string', '$')
    colon = o("colon (':') and space", ': ')  # or make space optional
    identifier = o('identifier', '[A-Z0-9]{3}')  # ..
    attributes = o("'attributes' keyword", r'attributes\b')

    for section_el in _section_elements(document, path, listener):
        key = section_el.string_key()
        scn = StringScanner(key, listener)
        if (s := scn.scan_required(first_word)) is None:  # noqa #here5
            return
        if 'document-meta' == s:
            if scn.skip_required(eos) is None:
                return
            yield 'document_meta', None, section_el
            continue
        if not scn.skip_required(colon):
            return

        if (ID_s := scn.scan_required(identifier)) is None:  # noqa #here5
            return

        if not scn.skip_required(colon):
            return

        if not scn.skip_required(attributes):
            return

        if scn.skip_required(eos) is None:
            return

        yield 'entity_section', ID_s, section_el


def _section_elements(document, path, listener):
    # the only allowed element at the top level of the document is sections

    from enolib.constants import PRETTY_TYPES
    for el in document.elements():  # #here2
        o = el._instruction
        typ = PRETTY_TYPES[o['type']]
        if 'section' == typ:
            yield el  # #here3
            continue
        _when_not_section(listener, typ, o, path)
        return


def _eno_document_via_path(path, listener):
    # parse that eno or fail

    try:
        opened = open(path)
    except FileNotFoundError as e:
        return None, e

    with opened as fh:  # ..
        big_string = fh.read()

    from enolib import parse as enolib_parse
    return enolib_parse(big_string), None  # ..


def _when_section_not_found(listener, count, target_ID_s, path):
    def deets():
        _ = f"'{target_ID_s}' ({count} entities in file)"
        yield 'reason_tail', _
        yield 'path', path

    listener('error', 'structure', 'entity_not_found', _details(deets))


def _when_out_of_order(listener, ID_s, section, state, path):
    def deets():
        _ = state.previous_identifier_string
        _ = f"entities are out of order. '{ID_s}' can't come after '{_}'."
        yield 'reason_tail', _
        yield 'lineno', section._instruction['line'] + 1  # #here1
        yield 'path', path

    listener('error', 'structure', 'eno_file_integrity_error', _details(deets))


def _when_inconsistent_depth(listener, ID_s, section, state, path):
    def deets():
        yield 'reason_tail', ''.join(reason_pieces())
        yield 'lineno', section._instruction['line'] + 1  # #here1
        yield 'path', path

    def reason_pieces():
        yield f"first identifier ('{state.first_identifier_string}') "
        yield "establishes an identifier depth of "
        yield str(state.length_of_first_identifier)
        yield f". This section ('{ID_s}') has a depth of {len(ID_s)}."

    listener('error', 'structure', 'eno_file_integrity_error', _details(deets))


def _when_no_state_transition(listener, typ, section, state, path):
    def deets():
        yield 'reason_tail', ''.join(reason_pieces())
        yield 'lineno', section._instruction['line'] + 1  # #here1
        yield 'path', path

    def reason_pieces():
        yield f"did not expect to encounter '{typ}' "
        yield f"while in '{state.current_state_name}' state. "
        yield '(expecting '
        _these = tuple(f"'{s}'" for s in state.current_state.keys())
        yield ' or '.join(_these)
        yield '.)'

    listener('error', 'structure', 'parse_error', _details(deets))


def _when_not_section(listener, typ, o, path):
    @_details
    def deets():
        yield 'reason_tail', f"had '{typ}'"
        # yield 'position', o['ranges']][
        yield 'lineno', o['line'] + 1  # #here1
        yield 'path', path
    listener('error', 'structure', 'parse_error', 'expecting_section', deets)


def _when_entity_not_found_because_no_file(listener, e, path, ID):
    def details():
        yield 'reason_tail', f"'{ID.to_string()}' ({e.strerror})"
        yield 'path', path
    listener('error', 'structure', 'entity_not_found', _details(details))


def _when_identifier_is_wrong_depth(listener, ID, depth, verb_string):
    def details():
        yield 'reason_tail', ''.join(reason_pieces())

    def reason_pieces():
        ID.number_of_digits
        yield f"can't {verb_string} because identifier '{ID.to_string()}' "
        yield 'has wrong number of digits '
        yield f"(needed {depth}, had {ID.number_of_digits})"

    listener('error', 'structure', 'entity_not_found', _details(details))


def _details(orig_function):
    def use_function():
        return {k: v for k, v in orig_function()}
    return use_function


def _monitor_via_listener(listener):
    from modality_agnostic import ModalityAgnosticErrorMonitor
    return ModalityAgnosticErrorMonitor(listener)


def xx():
    raise Exception('xx')


_entites_fn = 'entities'


# :#here5: at #history-A.1 we started using the new ':=' NAMEDEXPR feature
# but pyflakes (used by flake8)'s latest stable release does not yet
# recognize this (but its master does at writing). we wrestled with trying to
# get poetry to let us use the github url for pyflakes AND have flake8 use
# that, but it became a huge timesink.. #todo

# #history-A.1 spike first sketch of read-only
# #born as nonworking stub
