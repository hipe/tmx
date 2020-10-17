def _listener(*args):  # used as default argument
    from modality_agnostic import listening
    return listening.throwing_listener(*args)


def collectioner_via_storage_adapters_module(mod_name, mod_dir, *more):
    class collectioner:  # #class-as-namespace
        def collection_via_path(collection_path, listener=_listener, **kw):
            return _COLLECTION_VIA_PATH(collection_path, listener, saidx, **kw)

        def OPEN_FOR_WRITING_THE_NEW_WAY(fmt, x, listener):
            return _OPEN_FOR_WRITING_THE_NEW_WAY(fmt, x, saidx, listener)

        def OPEN_FOR_READING_THE_NEW_WAY(fmt, x, listener):
            return _OPEN_FOR_READING_THE_NEW_WAY(fmt, x, saidx, listener)

        def SPLAY_STORAGE_ADAPTERS():
            return saidx._splay_storage_adapters()

    pairs = ((more[i], more[i+1]) for i in range(0, len(more), 2))
    saidx = _storage_adapter_index(((mod_name, mod_dir), *pairs))
    return collectioner


def NEW_COLLECTION_VIA_OLD_COLLECTION_IMPLEMENTATION_(ci):
    # temporrary bridge

    fxer = NEW_FUNCTIONSER_VIA_OLD_COLLECTION_IMPLEMENTATION_(ci)
    coll = COLLECTION_VIA_FUNCTIONSER(fxer)
    return coll


def NEW_FUNCTIONSER_VIA_OLD_COLLECTION_IMPLEMENTATION_(ci):
    class ns:  # #class-as-namespace
        def PRODUCE_EDIT_FUNCTIONS():
            return ci

        def PRODUCE_READ_ONLY_FUNCTIONS():
            return ci

        def PRODUCE_IDENTIFIER_FUNCTION():
            return ci.PRODUCE_IDENTIFIER_FUNCTION_OLD_TO_NEW_()
        EDIT_FUNCTIONS_ARE_AVAILABLE = True
        READ_ONLY_FUNCTIONS_ARE_AVAILABLE = True
        COLL_IMPL_YUCK_ = ci
    return ns


def _COLLECTION_VIA_PATH(
        x, listener, saidx,
        format_name=None, rng=None, opn=None, adapter_variant=None):

    cci = _classify_collection_identifier_for_NEW_WAY(x)
    sa = _resolve_storage_adapter(cci, format_name, saidx, listener, opn)
    if sa is None:
        return

    # Re-pack keywords idk
    kw = {'rng': rng, 'opn': opn, 'adapter_variant': adapter_variant}

    return _collection_via(sa, cci, listener, kw)


def _single_file_collection_via_storage_adapter_and_path(sa, x, listener, kw):
    cci = _classify_collection_identifier_for_NEW_WAY(x)
    key = _key_via_storage_adapter_module(sa)
    sa = _StorageAdapter(sa, key)
    return _collection_via(sa, cci, listener, kw)


def _collection_via(sa, cci, listener, kw):
    fxerer, sa = sa._shhh_split_into_two()
    if fxerer is None:
        fxerer = sa.module  # (Case1422)

    # Let SA's that don't participate in the thing not see it (defaults 👀)
    kw = {k: v for k, v in kw.items() if v is not None}

    if hasattr(fxerer, 'FUNCTIONSER_VIA_CCI'):  # experiment
        fxer = fxerer.FUNCTIONSER_VIA_CCI(cci, listener, **kw)
    else:
        x = cci.mixed_collection_identifier
        fxer = fxerer.FUNCTIONSER_VIA_COLLECTION_ARGS(x, listener, **kw)

    if fxer is None:
        return  # (Case2823DP)
    return COLLECTION_VIA_FUNCTIONSER(fxer, sa)


def COLLECTION_VIA_FUNCTIONSER(fxer, sa=None):  # data-pipes

    if (can_edit := fxer.EDIT_FUNCTIONS_ARE_AVAILABLE):
        edit_funcs = fxer.PRODUCE_EDIT_FUNCTIONS()

    if (can_read := fxer.READ_ONLY_FUNCTIONS_ARE_AVAILABLE):
        read_funcs = fxer.PRODUCE_READ_ONLY_FUNCTIONS()

    def parse_identifier(orig_f):  # #decorator
        def use_f(eid, *rest):
            if (iden := parse_EID(eid, rest[-1])) is None:
                return
            return orig_f(iden, *rest)
        return use_f

    class collection_NEW_WAY:  # #class-as-namespace
        if can_edit:
            @parse_identifier
            def update_entity(iden, x, listener):
                return edit_funcs.update_entity_as_storage_adapter_collection(
                    iden, x, listener)

            def create_entity(x, listener):
                return edit_funcs.create_entity_as_storage_adapter_collection(
                    parse_EID, x, listener)

            @parse_identifier
            def delete_entity(iden, listener):
                return edit_funcs.delete_entity_as_storage_adapter_collection(
                    iden, listener)

        if can_read:
            @parse_identifier
            def retrieve_entity(iden, listener):
                return read_funcs.\
                  retrieve_entity_as_storage_adapter_collection(iden, listener)

            def TO_IDENTIFIER_STREAM(listener):
                return read_funcs.\
                  to_identifier_stream_as_storage_adapter_collection(listener)

            def TO_ENTITY_STREAM(listener):
                return read_funcs.\
                  to_entity_stream_as_storage_adapter_collection(listener)

        def to_noun_phrase():
            ci = collection_NEW_WAY.COLLECTION_IMPLEMENTATION
            return _noun_phrase_via_collection_implementation(ci)

        COLLECTION_IMPLEMENTATION = fxer.COLL_IMPL_YUCK_
        storage_adapter = sa

    parse_EID = (f := fxer.PRODUCE_IDENTIFIER_FUNCTION) and f()
    return collection_NEW_WAY


# == NEW WAY
#    NOTE lots of redundancies with #here4 during transition to magnetic field
#    collection overhaul. Also this has lots holes the other doesn't for now.
#    Eventually hook-ins so SA can totally circumvent all of this up front


def _OPEN_FOR_WRITING_THE_NEW_WAY(fmt, x, saidx, listener):
    def main():
        sa = resolve_storage_adapter()
        lines_via_two = sa.module.LINES_VIA_SCHEMA_AND_ENTITIES
        lines_via_two
        from contextlib import contextmanager

        @contextmanager
        def build_cm():
            build_receiver, close = resolve_receiver_and_closer()
            recv = build_receiver(lines_via_two)
            ok = False
            try:
                yield recv
                ok = True
            finally:
                close(ok)
        return build_cm()

    def resolve_receiver_and_closer():
        if cci.arg_looks_like_file_handle:
            if cci.arg_looks_like_writable_file_handle:
                return receiver_and_closer_when_writable_file_handle()
            raise stop_because_not_open_for_writing()
        if cci.arg_looks_like_string:
            return receiver_and_closer_by_open_and_close_file()
        raise stop_because_unrecognized_identifier_shape()

    def receiver_and_closer_by_open_and_close_file():
        def close(was_OK):
            if was_OK:
                fp.close()
                return
            fp.seek(0)  # OCD
            fp.truncate(0)  # WHY
            os_unlink(x)  # YIKES
        fp = open(x, 'x')  # crazy experiment
        build_receiver = build_build_receiver(fp)
        from os import unlink as os_unlink
        return build_receiver, close

    def receiver_and_closer_when_writable_file_handle():
        build_receiver = build_build_receiver(x)
        return build_receiver, lambda _: None

    def build_build_receiver(writable_fp):
        def build_receiver(lines_via_two):
            return _build_receiver_NEW_WAY(writable_fp, lines_via_two)
        return build_receiver

    def stop_because_not_open_for_writing():
        xx()

    def stop_because_unrecognized_identifier_shape():
        xx()

    def resolve_storage_adapter():
        return _resolve_storage_adapter(cci, fmt, saidx, throwing_listener)

    cci = _classify_collection_identifier_for_NEW_WAY(x)
    throwing_listener, stop = _throwing_listener_and_stop(listener)
    try:
        return main()
    except stop:
        pass


def _build_receiver_NEW_WAY(writable_fp, lines_via_schema_and_entities):
    def receive_schema_and_entities(schema, ents, listener):
        for line in lines_via_schema_and_entities(schema, ents, listener):
            writable_fp.write(line)

    class receiver:  # #class-as-namespace
        pass
    receiver.receive_schema_and_entities = receive_schema_and_entities
    return receiver


def _OPEN_FOR_READING_THE_NEW_WAY(fmt, x, saidx, listener):
    def main():
        sa = resolve_storage_adapter()
        two_via_lines = sa.module.SCHEMA_AND_ENTITIES_VIA_LINES  # ..
        resolve_lines_and_closer = resolve_lines_and_closer_function()
        from contextlib import contextmanager

        @contextmanager
        def build_cm():
            lines, close = resolve_lines_and_closer()
            try:
                schema, ents = two_via_lines(lines, listener)
                yield schema, ents
            finally:
                close()
        return build_cm()

    def resolve_lines_and_closer_function():
        if cci.arg_looks_like_string:
            return lines_and_closer_by_opening_and_closing_file
        if cci.arg_looks_like_file_handle:
            if cci.arg_looks_like_readable_file_handle:
                return lines_and_closer_by_pass_thru_and_no_close
            raise stop_because_not_open_for_reading()
        raise stop_because_unrecognized_identifier_shape()

    def lines_and_closer_by_opening_and_closing_file():
        if True:  # TRY/EXCEPT eventually
            fp = open(x, 'r')  # we once had `opn` but no more. now use fake fp

        return fp, fp.close

    def lines_and_closer_by_pass_thru_and_no_close():
        return x, lambda: None

    def stop_because_not_open_for_reading():
        xx()

    def stop_because_unrecognized_identifier_shape():
        xx()

    def resolve_storage_adapter():
        return _resolve_storage_adapter(cci, fmt, saidx, throwing_listener)

    # ==

    cci = _classify_collection_identifier_for_NEW_WAY(x)
    throwing_listener, stop = _throwing_listener_and_stop(listener)
    try:
        return main()
    except stop:
        pass


def _resolve_storage_adapter(cci, fmt, saidx, listener, opn=None):

    # If a format name was passed, use that
    if fmt:
        return saidx.storage_adapter_via_format_name(fmt, listener)

    if not cci.arg_looks_like_string:
        xx()

    x = cci.mixed_collection_identifier

    # If collection path looks like a file, use extension to find the SA
    from os.path import splitext, join as os_path_join
    if len(ext := splitext(x)[1]):
        def csckr():
            return ({'path': x},)
        return saidx.storage_adapter_via_extname(ext, listener, csckr)

    # Otherwise, assume it's a directory and try to open a schema file
    from kiss_rdb import SCHEMA_FILE_ENTRY_ as tail
    schema_path = os_path_join(x, tail)
    try:
        opened = (opn or open)(schema_path)
    except FileNotFoundError as e:
        return _emit_about_no_schema_file(listener, e)
    except NotADirectoryError:
        return _emit_about_no_extname(listener, x)

    def storage_adapter_by(o):
        o.resolve_first_field_line()
        o.check_that_first_field_line_has_a_particular_name()
        return o.resolve_storage_adapter_given_name()

    with opened as opened:
        reso = _crazy_schema_thing(opened, storage_adapter_by, saidx, listener)
        if reso is None:
            return
        sfs, sa = reso.schema_file_scanner, reso.storage_adapter
        frr = sa.module.FUNCTIONSERER_VIA_SCHEMA_FILE_SCANNER(sfs, listener)
    if frr is None:
        return
    return _StorageAdapterPlus(frr, sa)


def _storage_adapter_via(original_method):  # #decorator
    def use_method(self, needle, listener, cstacker=None, validate=None):
        key = original_method(self, needle, listener)
        if key is None:
            return
        return self._finish_lookup(key, listener, cstacker, validate)
    return use_method


class _storage_adapter_index:

    def __init__(self, name_and_directory_s):
        # module_name = mod.__name__
        # module_directory = mod.__path__._path[0]
        # --
        from os import listdir
        from fnmatch import fnmatch
        from os.path import splitext
        # from glob import glob
        # _glob_path = os_path.join(_dir, '[!_]*')
        # order = tuple(sorted(glob(_glob_path)))  # gives you full paths

        adapters, hubs = {}, []

        for mod_name, mod_dir in name_and_directory_s:
            hub_offset = len(hubs)
            hubs.append(mod_name)  # #here3
            for entry in listdir(mod_dir):
                if not fnmatch(entry, '[!_]*'):
                    continue
                key, _ = splitext(entry)
                if key in adapters:
                    raise RuntimeError(f"collision: '{key}'")
                adapters[key] = 'reference', hub_offset  # #here2

        self._order = tuple(sorted(adapters.keys()))
        self._reference_via_key = adapters
        self._hubs = tuple(hubs)
        self._key_via_extname = None
        self._key_via_format_name = None

    @_storage_adapter_via
    def storage_adapter_via_extname(self, extname, listener):

        if self._key_via_extname is None:
            self.__init_extname_index()

        if extname not in self._key_via_extname:
            _emit_about_extname(listener, extname, self._key_via_extname)
            return

        return self._key_via_extname[extname]

    @_storage_adapter_via
    def storage_adapter_via_format_name(self, format_name, listener):

        if self._key_via_format_name is None:
            self._key_via_format_name = {k.replace('_', '-'): k for k in self._order}  # noqa: E501

        if format_name not in self._key_via_format_name:
            _emit_about_format_name(
                    listener, format_name, self._key_via_format_name)
            return

        return self._key_via_format_name[format_name]

    def storage_adapter_via_key(
            self, key, listener, cstacker=None, validate=None):

        if key not in self._reference_via_key:
            _emit_about_SA_key(listener, key, self._order, cstacker)
            return

        return self._finish_lookup(key, listener, cstacker, validate)

    def _finish_lookup(self, key, listener, cstacker, validate):

        sa = self._dereference(key)

        # (ad-hoc validation before more general validation = better UI msgs)
        if validate is not None:
            if not validate(sa):
                return

        if not sa.module.STORAGE_ADAPTER_IS_AVAILABLE:
            return _emit_about_nonworking_stub(listener, sa, cstacker)

        return sa

    def __init_extname_index(self):
        self._key_via_extname = False  # lock it for safety
        dct = {}
        for key in self._order:
            sa = self._dereference(key)
            if not sa.module.STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES:
                continue
            for en in sa.module.STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS:
                if en in dct:
                    # #not-covered
                    raise Exception(_say_extname_collision(en, dct[en], key))
                dct[en] = key
        self._key_via_extname = dct

    def _splay_storage_adapters(self):
        def build_dereferencer(key):  # (Case3498DP)
            def f():
                return self._dereference(key)
            return f

        for key in self._reference_via_key:
            yield (key, build_dereferencer(key))

    def _dereference(self, key):
        sx = self._reference_via_key[key]
        if 'loaded' == sx[0]:  # #here2
            return sx[1]
        self._reference_via_key[key] = False  # lock it for safety
        typ, hub_offset = sx
        assert 'reference' == typ
        hub_mod_name = self._hubs[hub_offset]  # #here3
        mod_name = '.'.join((hub_mod_name, key))
        from importlib import import_module as func
        module = func(mod_name)
        sa = _StorageAdapter(module, key)
        self._reference_via_key[key] = 'loaded', sa  # #here2
        return sa


def _crazy_schema_thing(opened, main, saidx, listener):

    def resolve_storage_adapter_given_name():
        def cstacker():
            return (scanner.contextualize_about_field_value({}, reso.field),)

        def validate(sa):
            if sa.module.STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES:
                return True
            return _emit_about_not_directory_based(listener, sa, cstacker)

        sa = saidx.storage_adapter_via_key(
            reso.field.field_value_string, listener, cstacker, validate)
        if sa is None:
            raise stop()
        reso.storage_adapter = sa
        return reso

    def check_that_first_field_line_has_a_particular_name():
        if 'storage_adapter' == reso.field.field_name:
            return

        def cstacker():
            return (scanner.contextualize_about_field_name({}, reso.field),)
        _emit_about_first_field_name(listener, cstacker)
        raise stop()

    def resolve_first_field_line():
        if there_is_another_block():
            if its_a_separator_block():
                if there_is_another_block():
                    if its_a_field_line():
                        found_it()  # (Case1418)
                    else:
                        assert_and_whine_about_effectively_empty_file()
            elif its_a_field_line():
                found_it()
            else:
                assert_and_whine_about_literally_empty_file()

    def found_it():
        reso.field = reso.block
        del reso.block

    def its_a_field_line():
        return reso.block.is_field_line

    def its_a_separator_block():
        return reso.block.is_separator_block

    def there_is_another_block():
        block = scn.next_block(listener)
        if block is None:
            raise stop()  # (Case1414)
        reso.block = block
        return True

    def assert_and_whine_about_effectively_empty_file():
        assert reso.block.is_end_of_file
        whine_empty('effectively_empty_file')  # (Case1417)

    def assert_and_whine_about_literally_empty_file():
        assert reso.block.is_end_of_file
        whine_empty('literally_empty_file')  # (Case1415)

    def whine_empty(which):
        _emit_about_empty_schema_file(listener, which, scn)
        raise stop()

    class reso:
        pass

    from kiss_rdb.storage_adapters_.rec import ErsatzScanner
    scn = ErsatzScanner(opened)
    from kiss_rdb.magnetics_.schema_file_scanner_via_recfile_scanner import (
            schema_file_scanner_via_recfile_scanner)
    scanner = schema_file_scanner_via_recfile_scanner(scn)
    reso.schema_file_scanner = scanner

    class controls:
        pass
    controls.resolve_first_field_line = resolve_first_field_line
    controls.check_that_first_field_line_has_a_particular_name = check_that_first_field_line_has_a_particular_name  # noqa: E501
    controls.resolve_storage_adapter_given_name = resolve_storage_adapter_given_name  # noqa: E501

    class stop(RuntimeError):
        pass
    try:
        return main(controls)
    except stop:
        pass


def _classify_collection_identifier_for_NEW_WAY(x):
    # exists only to DRY up any logic to be shared between the two new ways

    def these():
        def arg_looks_like_writable_file_handle():  # assume ..
            return x.writable()

        def arg_looks_like_readable_file_handle():  # assume below
            return x.readable()

        def arg_looks_like_file_handle():
            return hasattr(x, 'fileno')

        def arg_looks_like_string():
            return hasattr(x, 'isalnum')

        return locals()

    class lazy_classifier:
        mixed_collection_identifier = x

    def build_method(f):
        return property(lambda _: f())

    for attr, f in these().items():
        setattr(lazy_classifier, attr, build_method(f))
    return lazy_classifier()


# == models

class _StorageAdapterPlus:

    def __init__(self, functionserer, sa):
        self._two = functionserer, sa

    def _shhh_split_into_two(self):
        return self._two


class _StorageAdapter:  # move this to its own file if it gets big

    def __init__(self, module, key):
        self.module = module
        self.key = key

    def CREATE_COLLECTION(self, collection_path, listener, is_dry):
        coll = self.module.CREATE_COLLECTION(collection_path, listener, is_dry)
        if coll is None:
            return
        return _wrap_collection(coll)

    def _shhh_split_into_two(self):
        return None, self

    is_loaded = True


def _wrap_collection(impl):
    if impl is None:
        return
    raise RuntimeError('xx')
    # return _Collection(impl)


class _NOT_YET_LOADED:  # #as-namespace-only
    is_loaded = False


# == whiners

def _emit_about_nonworking_stub(listener, sa, cstacker=None):
    def structurer():  # #not-covered, kind of crazy
        dct = _flatten_context_stack(cstacker()) if cstacker else {}
        mod = sa.module
        moniker = repr(sa.key)
        if hasattr(mod, 'STORAGE_ADAPTER_UNAVAILABLE_REASON'):
            def f(s):
                return f"the {moniker} storage adapter is"
            msg = mod.STORAGE_ADAPTER_UNAVAILABLE_REASON
            use_msg = re_lib().sub(r"^[Ii]t( is|'s)\b", f, msg)
            dct['reason_tail'] = use_msg
        else:
            dct['reason_tail'] = repr(sa.key)
        return dct
    listener(*_EC_for_cannot_load,
             'storage_adapter_is_not_available', structurer)


def _emit_about_not_directory_based(listener, sa, cstacker):
    def structurer():  # (Case1421)
        dct = _flatten_context_stack(cstacker())
        dct['reason'] = ''.join(__pieces_for_not_dir_based(sa))
        return dct
    listener(*_EC_for_cannot_load,
             'storage_adapter_is_not_directory_based', structurer)


def __pieces_for_not_dir_based(sa):
    mod = sa.module
    can_single = mod.STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES
    if can_single:
        extensions = mod.STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS
    is_available = mod.STORAGE_ADAPTER_IS_AVAILABLE
    if can_single:
        yield f"the '{sa.key}' storage adapter is single-file only, "
        yield "so the collection cannot have a directory and a schema file"
        if len(extensions):
            _these = ' or '.join(repr(s) for s in extensions)
            yield f". the collection should be in a file ending in {_these}"
        else:
            yield ", however there are no file extensions associated with "
            yield "the storage adapter, so nothing makes any sense"
    elif is_available:
        yield f"the '{sa.key}' storage adapter "
        yield "has no relationship to the filesystem"
    else:
        yield f"the '{sa.key} storage adapter is not available"


def _emit_about_first_field_name(listener, cstacker):
    def structurer():  # (Case1418)
        dct = _flatten_context_stack(cstacker())
        dct['expecting'] = '"storage_adapter" as field name'
        return dct
    listener(*_EC_for_cannot_load,
             'unexpected_first_field_of_schema_file', structurer)


def _emit_about_empty_schema_file(listener, reason_head, parse_state):
    def structurer():
        if 'effectively_empty_file' == reason_head:
            use_head = "schema file is effectively empty"
        elif 'literally_empty_file' == reason_head:
            use_head = "schema file is literally empty"
        else:
            assert(False)
        path = parse_state.path
        _reason = f"{use_head} - {path}"
        return {'reason': _reason, 'path': path}
    listener(*_EC_for_cannot_load,
             'first_field_of_schema_file_not_found', structurer)


def _emit_about_no_schema_file(listener, file_not_found):
    def structurer():  # (Case1413)
        return func(file_not_found)
    from modality_agnostic import \
        emission_details_via_file_not_found_error as func
    listener(*_EC_for_cannot_load, 'no_schema_file', structurer)


def _emit_about_no_extname(listener, path):
    def structurer():  # (Case1411)
        _reason = (
            f"cannot infer storage adapter from file with no extension - "
            f"{path}")
        return {'reason': _reason}
    listener(*_EC_for_cannot_load, 'file_has_no_extname', structurer)


def _emit_about_extname(listener, extname, key_via_extname):
    def structurer():  # (Case1410)
        return _same_splay_reason('extension', extname, key_via_extname)
    listener(*_EC_for_cannot_load, 'unrecognized_extname', structurer)


def _emit_about_format_name(listener, format_name, key_via_format_name):
    def structurer():
        return _same_splay_reason('format name', format_name, key_via_format_name)  # noqa: E501
    listener(*_EC_for_cannot_load, 'unrecognized_format_name', structurer)


def _same_splay_reason(noun_singular, wrong, key_via_what):
    _head = f"unrecognized {noun_singular} '{wrong}'"
    _these = ', '.join(f"'{s}'" for s in sorted(key_via_what.keys()))
    _tail = f"known {noun_singular}(s): ({_these})"
    _reason = f'{_head}. {_tail}'
    return {'reason': _reason}


def _emit_about_SA_key(listener, key, order, cstacker):
    def structurer():  # (Case1419)
        dct = _flatten_context_stack(cstacker())
        _these = ', '.join(repr(s) for s in order)
        dct['reason'] = (f"unknown storage adapter {repr(key)}. "
                         f"known storage adapters: ({_these})")
        return dct
    listener(*_EC_for_cannot_load, 'unknown_storage_adapter', structurer)


def _say_extname_collision(en, first_key, second_key):
    if True:
        _reason = (f"Extname collison: '{en}' associated with both"
                   f"'{first_key}' and '{first_key}'. There can only be one.")
        return _reason


def _noun_phrase_via_collection_implementation(ci):
    # moved here #history-B.4. bounces around a lot

    cls = ci if isinstance(ci, type) else ci.__class__
    pcs = cls.__module__.split('.')
    pcs.append(cls.__name__)

    def match(pc):
        return ('storage_adapter' in pc) or ('format_adapter' in pc)

    i = next(i for i in reversed(range(0, len(pcs))) if match(pcs[i]))
    adapter_key, variant_moniker = pcs[i+1:i+3]
    adapter_moniker = adapter_key.replace('_', '-')
    pcs = ("the '", adapter_moniker, "' format adapter")
    pcs = (*pcs, " (variant: ", variant_moniker, ')')
    return ''.join(pcs)


def _key_via_storage_adapter_module(sa_mod):
    name = sa_mod.__name__
    return name[name.rindex('.')+1:]


# == Smalls

def _throwing_listener_and_stop(listener):

    def throwing_listener(sev, *rest):
        listener(sev, *rest)
        if 'error' == sev:
            raise stop()

    class stop(RuntimeError):
        pass

    return throwing_listener, stop


def _flatten_context_stack(context_stack):  # #[#510.14]
    return {k: v for row in context_stack for k, v in row.items()}


# == Libs

def re_lib():
    import re
    return re


def xx(msg=None):
    raise RuntimeError(''.join(('write me', *((': ', msg) if msg else ()))))


_this_shape = ('error', 'structure')
_EC_for_cannot_load = (*_this_shape, 'cannot_load_collection')
_EC_for_not_found = (*_this_shape, 'cannot_load_collection')

# #history-B.4
# #history-A.2: massive refactor for clarity
# #history-A.1
# #born.
