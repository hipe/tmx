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

# fsr = filesystem reader

def EXPERIMENTAL_caching_collection(
        directory, max_num_lines_to_cache=None, listener=None,
        do_load_schema_from_filesystem=True, opn=None):

    def fsr(ci):
        return FS_reader_class(ci, max_num_lines_to_cache, opn=opn)

    from ._caching_layer import Caching_FS_Reader_ as FS_reader_class, \
        ReadOnlyCollectionLayer_ as collection_class

    real_coll = mutable_eno_collection_via(
        directory, fsr=fsr, listener=listener,
        do_load_schema_from_filesystem=do_load_schema_from_filesystem)

    return real_coll and collection_class(real_coll)


def mutable_eno_collection_via(
        directory, listener=None,
        rng=None, fsr=None,
        do_load_schema_from_filesystem=True  # 👀
        ):

    import sys
    sa_mod = sys.modules[__name__]
    from kiss_rdb import collection_via_storage_adapter_and_path as func
    return func(
            sa_mod, directory, listener,
            rng=rng, fsr=fsr,
            do_load_schema_from_filesystem=do_load_schema_from_filesystem)


def CREATE_COLLECTION(collection_path, listener, is_dry):
    from ._create_collection import CreateCollection
    return CreateCollection().execute(collection_path, listener, is_dry)


def ADAPTER_OPTIONS_VIA_SCHEMA_FILE_SCANNER(schema_file_scanner, listener):
    # #open [#873.S] at birth of this storage adapter, we are hard-coding it
    # to support only one storage schema. but when the day comes, abstract
    # the things out of the sibling spot in the toml adapter

    kw = {k: 'multiple' for k in _plural_via_singular.keys()}
    kw['storage_schema'] = 'allowed'

    dct = schema_file_scanner.flush_to_config(listener, **kw)
    if dct is None:
        return

    if 'storage_schema' in dct:
        assert '32x32x32' == dct['storage_schema']

    # Pluralize the names:
    for sing, plur in _plural_via_singular.items():
        if (x := dct.pop(sing, None)):
            dct[plur] = x

    return dct


_plural_via_singular = {
    'value_function': 'value_functions',
    'value_function_variable': 'value_function_variables'
}


def FUNCTIONSER_VIA_DIRECTORY_AND_ADAPTER_OPTIONS(
        directory, listener, storage_schema=None,
        custom_functions=None,
        custom_variables=None,
        rng=None, fsr=None, opn=None):

    del storage_schema
    ci = _collection_implementation(directory, rng=rng, fsr=fsr, opn=opn)

    class fxr:  # #class-as-namespace
        def PRODUCE_EDIT_FUNCTIONS_FOR_DIRECTORY():
            return ci

        def PRODUCE_READ_ONLY_FUNCTIONS_FOR_DIRECTORY():
            return ci

        def PRODUCE_IDENTIFIER_FUNCTIONER():
            return ci.build_identifier_function_

        CUSTOM_FUNCTIONS_OLD_WAY = ci  # #open [#877.B] (Case1476)
    return fxr


def _collection_implementation(directory, fsr=None, rng=None, opn=None):

    class collection_implementation:  # #class-as-namespace

        # -- the big collection API operations (or experimental similar)

        def create_entity_via_identifier(
                eid, _, attr_vals, listener, is_dry=False):
            # (not used by our main application client but here for developmen)

            bpf = self._big_patchfile_for_create_entity(
                eid, attr_vals, listener)
            if bpf is None:
                return
            return bpf.APPLY_PATCHES(listener, is_dry=is_dry)

        def _big_patchfile_for_create_entity(eid, attr_vals, listener):

            # Reserve the new entity identifier
            eidr = self.RESERVE_NEW_ENTITY_IDENTIFIER(listener, eid=eid)
            if eidr is None:
                return  # maybe full
            eid = eidr.identifier_string

            # Flatten the creation dictionary into CUD units of work
            def p(k, v):
                return ('create_entity', eid, 'create_attribute', k, v)
            euow = tuple(p(k, v) for k, v in attr_vals.items())

            # Define the result document entity (just what is needed)

            def reser():  # implement exactly [#857.10] custom structure for cr
                class result_for_created:  # #class-as-namespace
                    created_entity = doc_ent
                    emit_edited = None
                return result_for_created

            class doc_ent:  # #class-as-namespace
                def to_line_stream():
                    return _to_line_stream()

            def _to_line_stream():
                ent = {'identifier_string': eid, 'core_attributes': attr_vals}
                import json
                big_s = json.dumps(ent, indent=2)
                import re
                # #[#610] lines via big string, two ways:
                # this might work too: re.split(r'(?<=\n)(?!\Z)', big_s)
                lines = [md[0] for md in re.finditer('[^\n]*\n|[^\n]+', big_s)]
                lines[-1] = f"{lines[-1]}\n"
                return tuple(lines)

            # Prepare small args and call
            eidr = eidr.to_dictionary()
            order = tuple(attr_vals.keys())

            return self.BIG_PATCHFILE_FOR_BATCH_UPDATE(
                    eidr, euow, reser, order, listener)

        def BIG_PATCHFILE_FOR_BATCH_UPDATE(  # #testpoint (incl. param names)
                index_file_change, entities_units_of_work,
                result_document_entityer, order, listener):
            from ._big_patchfile_via_entities_uows import build_big_patchfile__
            return build_big_patchfile__(
                index_file_change, entities_units_of_work,
                result_document_entityer, self, order, listener)

        def RESERVE_NEW_ENTITY_IDENTIFIER(listener, eid=None):
            from kiss_rdb.magnetics_.provision_ID_randomly_via_identifiers \
                import reserve_new_entity_identifier_ as func
            return func(eid, directory, rng, _THREE, listener)

        def REMOVE_IDENTIFIER_FROM_INDEX(eid, listener):
            from kiss_rdb.magnetics_.provision_ID_randomly_via_identifiers \
                import REMOVE_IDENTIFIER_FROM_INDEX_
            return REMOVE_IDENTIFIER_FROM_INDEX_(
                    eid, directory, _THREE, listener)

        def AUDIT_TRAIL_FOR(eid, mon, opn=None):
            from ._audit_trail import func
            return func(eid, self, mon, opn=opn)

        def retrieve_entity_via_identifier(iden, listener):
            with self.open_entities_via_identifiers((iden,), listener) as ents:
                res, = ents
            return res

        def open_entities_via_identifiers(idens, listener):
            mon = _monitor_via_listener(listener)
            itr = fs_reader().entities_via_identifiers(idens, mon)
            from contextlib import nullcontext as func
            return func(itr)

        def entity_retrievals(idens, mon):  # low-level access to all
            return fs_reader().entity_retrievals_via_identifiers(idens, mon)

        def open_identifier_traversal(listener):
            from contextlib import nullcontext
            idens = (o for fr in to_FRs(listener) for o in fr.to_identifiers())
            return nullcontext(idens)

        def open_EID_traversal_EXPERIMENTAL(listener):
            from contextlib import nullcontext
            eids = (o for fr in to_FRs(listener) for o in fr.to_EIDs_in_file())
            return nullcontext(eids)

        def open_schema_and_entity_traversal(listener):
            # (There are never files to close. there are no resources to manage

            from contextlib import contextmanager as cm

            @cm
            def cm():
                yield None, each_entity()  # ..

            def each_entity():
                return (e for fr in to_FRs(listener) for e in fr.to_entities())

            return cm()

        def path_via_identifier_(iden, listener):
            return _path_via_identifier(iden, directory, listener)

        def build_identifier_function_(listener):
            def iden_via(eid):
                return use(eid, listener)
            from kiss_rdb.magnetics_.identifier_via_string import \
                identifier_via_string_ as use
            return iden_via

        monitor_via_listener_ = _monitor_via_listener  # the ONLY conv. func

        # -- protected properties & similar

        def to_file_paths_():
            _ = _file_posix_paths_in_collection_directory(directory, _THREE)
            return (str(pp) for pp in _)

        number_of_digits_ = _THREE

    def to_FRs(listener):
        mon = _monitor_via_listener(listener)
        return fs_reader().file_readers_via_monitor(mon)

    if fsr:
        def fs_reader():
            o = fs_reader
            if o.x is None:
                o.x = fsr(self)  # stateful (long-running) but hidden for now
            return o.x

        fs_reader.x = None  # [#510.4]
    else:
        def fs_reader():
            return _FS_Reader(self)

    self = collection_implementation
    self.eno_document_via_ = eno_document_via_
    return self


class _FS_Reader:

    def __init__(self, ci):
        self._back = ci

    def entities_via_identifiers(self, idens, mon):
        works = self.entity_retrievals_via_identifiers(idens, mon)
        return (w.entity for w in works)

    def entity_retrievals_via_identifiers(self, idens, mon):
        for iden in idens:
            work = RetrieveEntity_(iden, mon, self._back)
            if iden is None:  # [#877.C]
                work.entity = None
                yield work
                continue
            work.execute()
            yield work

    def file_readers_via_monitor(self, mon):
        paths = self._back.to_file_paths_()
        return file_readers_via_paths_(paths, self._back, mon)


class RetrieveEntity_:

    def __init__(self, iden, mon, ci, opn=None):
        self.identifier, self._monitor, self._back = iden, mon, ci
        self._opn = opn

    def execute(o):
        def main():
            o.resolve_path_given_identifier()
            o.resolve_file_reader_given_path()
            o.resolve_entity_given_file_reader()
            return o.entity
        return o.do(main)

    def do(self, main):
        try:
            return main()
        except _Stop:
            pass

    def resolve_entity_given_file_reader(self):
        self.resolve_entity_section_given_file_reader()
        self._resolve_entity_given_entity_section()

    def _resolve_entity_given_entity_section(self):
        self.entity = read_only_entity_via_section_(
            self.entity_section, self.identifier, self._monitor)

    def resolve_entity_section_given_file_reader(self):
        self.entity_section = self.procure_entity_section_given_file_reader()

    def procure_entity_section_given_file_reader(self):
        # Maybe the file doesn't have the entity
        target_eid = self.identifier.to_string()
        count = 0
        for (eid, sect) in self.file_reader.to_entity_sections():
            if target_eid == eid:
                return sect
            count += 1

        # (If we encountered some error during section traversal, emitted)
        if self._monitor.OK:
            _when_section_not_found(
                self._listener, count, target_eid, self.path)
        raise _Stop()

    def resolve_file_reader_given_path(self):
        # Maybe there is no such file
        itr = file_readers_via_paths_(
                (self.path,), self._back, self._monitor, opn=self._opn)
        self.file_reader = None
        try:
            self.file_reader, = itr
            return
        except FileNotFoundError as e:
            exc = e
        _when_entity_not_found_because_no_file(
            self._listener, exc, exc.filename, self.identifier)
        raise _Stop()

    def resolve_path_given_identifier(self):
        # Maybe the identifier is too shallow/deep
        path = self._back.path_via_identifier_(
                self.identifier, self._listener)
        if path is None:
            raise _Stop()
        self.path = path

    @property
    def body_of_text(self):
        return self.file_reader.body_of_text

    @property
    def _listener(self):
        mon = self._monitor
        return mon and mon.listener

    entity = None  # in case it fails, ensure property exists


def file_readers_via_paths_(paths, back, mon, opn=None):

    def bot_kwargs_via_path(path): return {'path': path}

    if opn:  # for (Case4857_250)
        if (func := opn.body_of_text_keyword_args_via_path):
            bot_kwargs_via_path = func  # noqa: F811  (this is erroneous)

    docu_via = back.eno_document_via_
    for path in paths:
        bot_kwargs = bot_kwargs_via_path(path)
        bot = body_of_text_(**bot_kwargs)
        docu = docu_via(body_of_text=bot)  # throw for now, since #history-B.5
        yield _file_reader_via(docu, bot, back, mon)


def _file_reader_via(docu, body_of_text, back, mon):

    class file_reader:

        def __init__(self):
            self._idener = None
            self.body_of_text = body_of_text  # used elsewhere

        def to_entities(self):
            idener = self.identifier_builder_
            for (eid, sect) in self.to_entity_sections():
                iden = idener(eid)
                if iden is None:
                    return
                ent = read_only_entity_via_section_(sect, iden, mon)
                if ent is None:
                    return
                yield ent

        def to_identifiers(self):
            idener = self.identifier_builder_
            for (eid, sect) in self.to_entity_sections():
                iden = idener(eid)  # #here4
                if iden is None:
                    return
                yield iden

        def to_entity_sections(self):
            itr = self.to_section_elements()
            for typ, eid, sect_el in itr:
                if 'entity_section' == typ:
                    yield eid, sect_el
                    continue
                break
            assert 'document_meta' == typ
            for _ in itr:
                assert()

        def to_section_elements(self):
            return document_sections_of_(docu, body_of_text, mon)

        @property
        def identifier_builder_(self):
            # (we can't memo this in the CI because it's bound to a listener)
            if self._idener is None:
                self._idener = back.build_identifier_function_(listener)
            return self._idener

    listener = mon and mon.listener
    return file_reader()


def read_only_entity_via_section_(sect_el, identifier, monitor):
    section = sect_el.to_section()  # #here3
    dct = {k: v for k, v in _attribute_keys_and_values(section, monitor)}
    if not monitor.OK:
        return

    class read_only_entity:  # #class-as-namespace
        def to_dictionary_two_deep():
            return {'identifier_string': identifier.to_string(),
                    'core_attributes': dct}

        core_attributes = dct
        VENDOR_SECTION_ = section

    read_only_entity.identifier = identifier
    return read_only_entity


def _attribute_keys_and_values(section, mon):
    for el in section.elements():  # #here2
        yield classify_attribute_element_(el)[:2]


def classify_attribute_element_(el):
    cx = _do_classified_attribute_element(el)

    # (not specified anywhere, it's just an experimental sketch)
    import re
    if re.match('[a-z0-9_A-Z]+$', cx.key):
        return cx

    reason = f"field key is not up to current spec - {cx.key!r}"
    raise AssertionError(reason)


def _do_classified_attribute_element(el):
    o = _do_classified_attribute_element
    if o.x is None:
        from collections import namedtuple
        o.x = namedtuple('AttributeElementClassification',
                         ('key', 'value', 'type'))

    typ = el._instruction['type']
    if el.yields_list():
        key, value = _key_and_value_via_list_attribute_element(el)
        value = tuple(value)  # ..
        return o.x(key, tuple(value), typ)

    key, value = _key_and_value_for_atomic_attribute_element(el)
    assert typ in ('Field', 'Multiline Field Begin')
    return o.x(key, value, typ)


_do_classified_attribute_element.x = None


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


def document_sections_of_(document, body_of_text, mon):
    bot = body_of_text
    state_machine = {  # [#008.2] custom state machine
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
        state.length_of_first_identifier = len(eid)
        state.first_identifier_string = eid
        state.previous_identifier_string = eid
        yield_this_section_next()

    def see_nonfirst_section():
        # NOTE EXPERIMENTAL crude cheap check on integrity. we are not parsing
        # the traversed identifiers fully, so invalid chars could get thru.
        # in other adaptations we do no such checks on RETRIEVE at all, but
        # here it feels too easy (and fast) not to. but see #here4

        if len(eid) != state.length_of_first_identifier:
            _when_inconsistent_depth(mon.listener, eid, sect_el, state, bot)
            return

        if not (state.previous_identifier_string < eid):
            _when_out_of_order(mon.listener, eid, sect_el, state, bot)
            return

        state.previous_identifier_string = eid
        yield_this_section_next()

    def on_doc_meta():
        be_in_state('doc_meta')
        yield_this_section_next()

    def yield_this_section_next():
        assert(not state.has_thing_to_yield)
        state.has_thing_to_yield = True
        state.yield_me = typ, eid, sect_el

    def be_in_state(typ):
        state.current_state = state_machine[typ]
        state.current_state_name = typ

    def try_to_transition_to(typ):
        call_me = state.current_state.get(typ)
        if call_me is None:
            _when_no_state_transition(mon.listener, typ, sect_el, state, bot)
            return
        call_me()

    def release_thing_to_yield():
        x = state.yield_me
        del state.yield_me
        state.has_thing_to_yield = False
        return x

    for typ, eid, sect_el in tokenized_sections_(document, bot, mon.listener):
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


def tokenized_sections_(document, body_of_text, listener):
    # the only allowed sections in the document look like this

    o = tokenized_sections_
    if getattr(o, 'x', None) is None:
        o.x = _build_tokenized_sections_via()
    return o.x(document, body_of_text, listener)


def _build_tokenized_sections_via():

    def tokenized_sections_via(docu, body_of_text, listener):
        throwing_listener = build_throwing_listener(listener, stop)
        sect_els = _section_elements(docu, body_of_text, listener)
        for section_el in sect_els:
            key = section_el.string_key()
            scn = StringScanner(key, throwing_listener)
            try:
                yield sexp_via_parse_section_key(scn, section_el)
            except stop:
                break

    def sexp_via_parse_section_key(scn, section_el):
        s = scn.scan_required(first_word)
        if 'document-meta' == s:
            scn.skip_required(eos)
            return 'document_meta', None, section_el
        scn.skip_required(colon)
        eid = scn.scan_required(identifier)
        scn.skip_required(colon)
        scn.skip_required(attributes)
        scn.skip_required(eos)
        return 'entity_section', eid, section_el

    from text_lib.magnetics.string_scanner_via_string import \
        StringScanner, pattern_via_description_and_regex_string as o, \
        build_throwing_listener

    first_word = o('entity|document-meta', r'(entity|document-meta)\b')
    eos = o('end of string', '$')
    colon = o("colon (':') and space", ': ')  # or make space optional
    identifier = o('identifier', '[A-Z0-9]{3}')  # ..
    attributes = o("'attributes' keyword", r'attributes\b')

    class stop(RuntimeError):
        pass  # make our own even thos there's one out there. safer

    return tokenized_sections_via


def _section_elements(document, body_of_text, listener):
    # the only allowed element at the top level of the document is sections

    for el in document.elements():  # #here2
        typ = _vendor_type_of(el)
        if 'Section' == typ:
            yield el  # #here3
            continue
        _when_not_section(listener, typ, el, body_of_text)
        return


def eno_document_via_(**body_of_text):
    # (At #history-B.5 we took NOENT exception handling out)
    body_of_text = body_of_text_(**body_of_text)
    big_string = body_of_text.big_string  # throws e.g FileNotFoundError
    from enolib import parse as enolib_parse
    return enolib_parse(big_string)


def body_of_text_(body_of_text=None, big_string=None, lines=None, path=None):
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
                self._lines = self._big_string.splitlines(keepends=True)
        return self._lines


def _when_section_not_found(listener, count, target_ID_s, path):
    def deets():
        _ = f"'{target_ID_s}' ({count} entities in file)"
        yield 'reason_tail', _
        yield 'path', path

    listener('error', 'structure', 'entity_not_found', _details(deets))


def _when_out_of_order(listener, eid, section, state, body_of_text):
    def deets():
        _ = state.previous_identifier_string
        _ = f"entities are out of order. '{eid}' can't come after '{_}'."
        yield 'reason_tail', _
        yield 'lineno', _start_lineno_via_vendor_element(section)
        for k, v in _contextualize_body_of_text_for_detail(body_of_text):
            yield k, v

    listener('error', 'structure', 'eno_file_integrity_error', _details(deets))


def _when_inconsistent_depth(listener, eid, section, state, body_of_text):
    def deets():
        yield 'reason_tail', ''.join(reason_pieces())
        yield 'lineno', _start_lineno_via_vendor_element(section)
        for k, v in _contextualize_body_of_text_for_detail(body_of_text):
            yield k, v

    def reason_pieces():
        yield f"first identifier ('{state.first_identifier_string}') "
        yield "establishes an identifier depth of "
        yield str(state.length_of_first_identifier)
        yield f". This section ('{eid}') has a depth of {len(eid)}."

    listener('error', 'structure', 'eno_file_integrity_error', _details(deets))


def _when_no_state_transition(listener, typ, section, state, body_of_text):
    def deets():
        yield 'reason_tail', ''.join(reason_pieces())
        yield 'lineno', _start_lineno_via_vendor_element(section)
        for k, v in _contextualize_body_of_text_for_detail(body_of_text):
            yield k, v

    def reason_pieces():
        yield f"did not expect to encounter '{typ}' "
        yield f"while in '{state.current_state_name}' state. "
        yield '(expecting '
        _these = tuple(f"'{s}'" for s in state.current_state.keys())
        yield ' or '.join(_these)
        yield '.)'

    listener('error', 'structure', 'parse_error', _details(deets))


def _when_not_section(listener, typ, el, body_of_text):
    @_details
    def deets():
        yield 'reason_tail', f"had '{typ}'"
        # yield 'position', o['ranges']][
        yield 'lineno', lineno
        for k, v in _contextualize_body_of_text_for_detail(body_of_text):
            yield k, v

    lineno = _start_lineno_via_vendor_element(el)
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
        kw = {k: v for k, v in orig_function()}
        if 'lineno' in kw and 'line' not in kw and 'body_of_text' in kw:
            _add_line_to_context_via_body_of_text(kw)
        return kw
    return use_function


def _add_line_to_context_via_body_of_text(kw):
    stop = kw['lineno']
    count = 0
    line = None
    if True:  # (used to be open(path) lol)
        for line in kw['body_of_text'].lines:
            count += 1
            if stop == count:
                break
    if count != stop:
        line = "(line content unknown)\n"
    kw['line'] = line


def _contextualize_body_of_text_for_detail(bot):
    if (path := bot.path):
        yield 'path', path
    yield 'body_of_text', bot  # experimental


def _start_lineno_via_vendor_element(el):
    return start_line_offset_via_vendor_element_(el) + 1


def start_line_offset_via_vendor_element_(el):
    return el._instruction['line']


def _vendor_type_of(el):
    return el._instruction['type']


def _monitor_via_listener(listener):
    from modality_agnostic import ModalityAgnosticErrorMonitor
    return ModalityAgnosticErrorMonitor(listener)


def xx(msg=None):
    raise RuntimeError(f"write me{f': {msg}' if msg else ''}")


class _Stop(RuntimeError):
    pass


_THREE = 3  # hardcoded depth for now
_entites_fn = 'entities'


""" :#here5:
At #history-B.4 the world changed to using context managers for transacting
with collections. For this particular storage adapter, the impact was only
superficial (we eventually discovered):

We rely on a vendor lib to parse eno documents, and that vendor lib parses
each eno document into one big tree (memory-hog-not-streaming, DOM-like)
"all at once" so we don't have to think about resource management the same way
we do when we stream over the lines of each file ourselves.
"""

# #history-B.5
# #history-B.4
# #history-A.1 spike first sketch of read-only
# #born as nonworking stub
