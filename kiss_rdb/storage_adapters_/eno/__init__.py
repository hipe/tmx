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


def list_lines(var_name, tup):
    assert(len(tup))
    yield f'{var_name}:\n'
    for item in tup:
        assert(isinstance(item, str))
        assert(len(item))  # or cover
        assert('\n' not in item)  # idk, something like this
        yield f'- {item}\n'


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


def CREATE_COLLECTION(collection_path, listener, is_dry):
    from ._create_collection import CreateCollection
    return CreateCollection().execute(collection_path, listener, is_dry)


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

    return eno_collection_via_(
            collection_identity.collection_path,
            random_number_generator)


def eno_collection_via_(directory, rng=None):  # #testpoint

    class StatelessCollectionImplementation:  # #class-as-namespace

        # -- the big collection API operations (or experimental similar)

        def create_entity_as_storage_adapter_collection(attr_vals, listener):
            # (not used by our main application client but here for developmen)
            eidr = self.RESERVE_NEW_ENTITY_IDENTIFIER(listener)
            if eidr is None:
                return  # maybe full

            euow = []
            eid = eidr.identifier_string
            for k, v in attr_vals.items():
                euow.append(('create_entity', eid, 'create_attribute', k, v))

            eidr = eidr.to_dictionary()
            order = tuple(attr_vals.keys())
            ok = self.BATCH_UPDATE(eidr, euow, True, False, order, listener)
            if not ok:
                return

            def _to_line_stream():
                ent = {'identifier_string': eid, 'core_attributes': attr_vals}
                import json
                big_s = json.dumps(ent, indent=2)
                import re
                lines = [md[0] for md in re.finditer('[^\n]*\n|[^\n]+', big_s)]
                lines[-1] = f"{lines[-1]}\n"
                return tuple(lines)

            class doc_ent:  # #class-as-namespace
                def to_line_stream():
                    return _to_line_stream()
            return doc_ent

        def BATCH_UPDATE(
                EID_reservation, entities_units_of_work,
                main_business_entity, is_dry, order, listener):

            bpf = self._build_big_patchfile(
                EID_reservation, entities_units_of_work, order, listener)

            if bpf is None:
                return
            if not bpf.APPLY_PATCHES(listener, is_dry=is_dry):
                return
            return main_business_entity

        def _build_big_patchfile(eidr, entities_uows, order, listener):  # noqa: E501 #testpoint
            from ._big_patchfile_via_entities_uows import build_big_patchfile__
            return build_big_patchfile__(
                    eidr, entities_uows, order, self, listener)

        def RESERVE_NEW_ENTITY_IDENTIFIER(listener):
            from kiss_rdb.magnetics_.provision_ID_randomly_via_identifiers \
                import RESERVE_NEW_ENTITY_IDENTIFIER_
            return RESERVE_NEW_ENTITY_IDENTIFIER_(
                    directory, rng, _THREE, listener)

        def retrieve_entity_as_storage_adapter_collection(iden, listener):
            mon = _monitor_via_listener(listener)
            path = self.path_via_identifier_(iden, listener)
            if path is None:
                return
            sect_el = _retrieve_entity_section_element(
                    iden, path, injection, self, mon)
            if sect_el is None:
                return
            return self.read_only_entity_via_section_(sect_el, iden, mon)

        def to_identifier_stream_as_storage_adapter_collection(listener):
            mon = self.monitor_via_listener_(listener)
            listener = mon.listener  # overwrite argument
            for path in self.to_file_paths_():
                docu = self.eno_document_via_(path=path, listener=listener)
                if docu is None:
                    return
                _ = self._entity_section_els_via_document(docu, path, mon)
                for eid, __ in _:
                    iden = self.identifier_via_string_(eid, listener)  # #here4
                    if iden is None:
                        return
                    yield iden

        # -- protected magnetics

        read_only_entity_via_section_ = _read_only_entity

        def _entity_section_els_via_document(document, path, mon):
            itr = self.document_sections_(document, path, mon)
            for typ, eid, sect_el in itr:
                if 'entity_section' == typ:
                    yield eid, sect_el
                    continue
                break
            assert('document_meta' == typ)
            for _ in itr:
                assert()

        document_sections_ = _document_sections

        def eno_document_via_(listener=None, **body_of_text):
            body_of_text = _body_of_text(**body_of_text)
            return injection.eno_document_via_(
                    listener=listener, body_of_text=body_of_text)

        def path_via_identifier_(iden, listener):
            return _path_via_identifier(iden, directory, listener)

        identifier_via_string_ = _identifier_via_string

        body_of_text_via_ = _body_of_text

        monitor_via_listener_ = _monitor_via_listener

        # -- protected properties & similar

        def to_file_paths_():
            _ = _file_posix_paths_in_collection_directory(directory, _THREE)
            return (str(pp) for pp in _)

    class injection:
        def eno_document_via_(_, listener=None, **body_of_text):
            return eno_document_via_(listener=listener, **body_of_text)

        @property
        def directory(_):
            return directory

    injection = injection()

    return (self := StatelessCollectionImplementation)


def _read_only_entity(sect_el, ID, mon):
    section = sect_el.to_section()  # #here3
    dct = {k: v for k, v in _attribute_keys_and_values(section, mon)}
    if not mon.OK:
        return

    class ReadOnlyEntity:  # #class-as-namespace

        def to_dictionary_two_deep_as_storage_adapter_entity():
            return {'identifier_string': ID.to_string(),
                    'core_attributes': dct}

        core_attributes_dictionary_as_storage_adapter_entity = dct
        identifier = ID

        VENDOR_SECTION_ = section

    return ReadOnlyEntity


def _attribute_keys_and_values(section, mon):
    for el in section.elements():  # #here2
        use_key, value, _ = key_value_vendor_type_via_attribute_element_(el)
        yield use_key, value


def key_value_vendor_type_via_attribute_element_(el):
    typ = el._instruction['type']
    if el.yields_list():
        key, value = _key_and_value_via_list_attribute_element(el)
        value = tuple(value)  # ..
    else:
        key, value = _key_and_value_for_atomic_attribute_element(el)
        if ('Field' != typ):
            assert('Multiline Field Begin' == typ)

    # this is not specified anywhere, it's just an experimental sketch
    import re
    if not re.match('[a-z0-9_A-Z]+$', key):
        msg = f"field key is not up to current spec - '{key}'"
        raise AssertionError(msg)

    return key, value, typ


def _key_and_value_via_list_attribute_element(el):
    return el.string_key(), el.to_list().required_values(None)


def _key_and_value_for_atomic_attribute_element(el):
    if True:
        # change these to whatever whenever. they're just curb-checks
        assert(not el.yields_section())
        assert(not el.yields_fieldset())
        assert(not el.yields_list())
        assert(not el.yields_empty())
        assert(el.yields_field())
        field = el.to_field()
    return field.string_key(), field.required_string_value()


def _path_via_identifier(iden, directory, listener):

    if _THREE != iden.number_of_digits:  # ..
        _when_identifier_is_wrong_depth(listener, iden, _THREE, 'retrieve')
        return

    # == BEGIN duplicate logic (softly) from elsewhere

    (*these, penult_digit, last_digit) = iden.native_digits
    _intermediate_dirs = tuple(o.character for o in these)
    _filename = f'{penult_digit.character}.eno'
    from os import path as os_path
    path = os_path.join(directory, _entites_fn, *_intermediate_dirs, _filename)

    # == END
    return path


def _retrieve_entity_section_element(ID, path, injection, coll, mon):
    try:
        docu = injection.eno_document_via_(path=path)
    except FileNotFoundError as e:
        _when_entity_not_found_because_no_file(mon.listener, e, path, ID)
        return

    target_ID_s = ID.to_string()
    count = 0

    _ = coll._entity_section_els_via_document(docu, path, mon)
    for ID_s, sect_el in _:
        if target_ID_s == ID_s:
            return sect_el
        count += 1

    if not mon.OK:
        return

    _when_section_not_found(mon.listener, count, target_ID_s, path)


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
        pass  # #cover-me (tested visually lol)

    assert(3 == depth)

    # empty dirs ok

    for dir_pp in dirs:
        for file_pp in sorted_entries_of(dir_pp):
            yield file_pp


def _document_sections(document, path, mon):

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
        yield_this_section_next()

    def yield_this_section_next():
        assert(not state.has_thing_to_yield)
        state.has_thing_to_yield = True
        state.yield_me = typ, ID_s, sect_el

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


def eno_document_via_(listener=None, **body_of_text):
    body_of_text = _body_of_text(**body_of_text)
    if listener:
        try:
            big_string = body_of_text.big_string
        except FileNotFoundError as e:
            xx(str(e))
    else:
        big_string = body_of_text.big_string

    from enolib import parse as enolib_parse
    return enolib_parse(big_string)


def _body_of_text(body_of_text=None, big_string=None, lines=None, path=None):
    if body_of_text:
        return body_of_text
    return _BodyOfText(big_string, lines, path)


class _BodyOfText:  # catch FileNotFound error

    def __init__(self, big_string=None, lines=None, path=None):
        self._big_string = big_string
        self._lines = lines
        self.path = path

    @property
    def big_string(self):
        if self._big_string is None:
            if self._lines is None:
                with open(self.path) as fh:
                    self._big_string = fh.read()
            else:
                self._big_string = ''.join(self._lines)

        return self._big_string

    @property
    def lines(self):
        if self._lines is None:
            if self._big_string is None:
                with open(self.path) as lines:
                    self._lines = tuple(lines)
            else:
                import re
                self._lines = tuple(re.split(r'(?<=\n)(?!\Z)', self._big_string))  # noqa: E501
        return self._lines


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


def _identifier_via_string(s, listener):
    from kiss_rdb.magnetics_.identifier_via_string\
            import identifier_via_string_
    return identifier_via_string_(s, listener)


def _monitor_via_listener(listener):
    from modality_agnostic import ModalityAgnosticErrorMonitor
    return ModalityAgnosticErrorMonitor(listener)


def xx(msg=None):
    raise RuntimeError(f"write me{f': {msg}' if msg else ''}")


class _Stop(RuntimeError):
    pass


_THREE = 3  # hardcoded depth for now
_entites_fn = 'entities'


# :#here5: at #history-A.1 we started using the new ':=' NAMEDEXPR feature
# but pyflakes (used by flake8)'s latest stable release does not yet
# recognize this (but its master does at writing). we wrestled with trying to
# get poetry to let us use the github url for pyflakes AND have flake8 use
# that, but it became a huge timesink.. #todo

# #history-A.1 spike first sketch of read-only
# #born as nonworking stub
