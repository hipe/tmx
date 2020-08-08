from os import path as os_path


def _throwing_listenerer(*args):  # used as default argument
    from modality_agnostic import listening
    return listening.throwing_listener(*args)


def _encode_identifier(f):  # #decorator
    def use_f(self, identifier_string, *rest):
        from kiss_rdb.magnetics_.identifier_via_string import (
            identifier_via_string_)
        iden = identifier_via_string_(identifier_string, rest[-1])
        if iden is None:
            return
        return f(self, iden, *rest)
    return use_f


class _Collection:  # #tespoint
    """Clients don't interact with the remote collection directly, rather they

    do so through this façade that bundles common logic mostly having to do
    with decoding identifiers, so that the implementatons don't have to.
    """

    def __init__(self, impl):
        self._impl = impl  # #testpoint

    # ==

    def convert_collection_into(self, from_args, to_collection, monitor):
        opened_from = self._impl.OPEN_INITIAL_NORMAL_NODES_AS_STORAGE_ADAPTER(
                from_args, monitor)
        if opened_from is None:
            return
        with opened_from as dcts:
            _opened_to = to_collection.OPEN_PASS_THRU_RECEIVER(monitor)
            with _opened_to as receiver:
                receive = receiver.RECEIVE_PRODUCER_SCRIPT_STATEMENT
                for dct in dcts:
                    receive(dct)
                    if not monitor.OK:
                        raise Exception('cover me: in-loop failure')  # #todo

    def OPEN_PASS_THRU_RECEIVER(self, monitor):
        return self._impl.OPEN_PASS_THRU_RECEIVER_AS_STORAGE_ADAPTER(monitor)

    # ==

    @_encode_identifier
    def update_entity(self, *a):
        return self._impl.update_entity_as_storage_adapter_collection(*a)

    def create_entity(self, *a):
        return self._impl.create_entity_as_storage_adapter_collection(*a)

    @_encode_identifier
    def delete_entity(self, *a):
        return self._impl.delete_entity_as_storage_adapter_collection(*a)

    @_encode_identifier
    def retrieve_entity(self, iden, listener):
        return self.retrieve_entity_via_identifier(iden, listener)

    def retrieve_entity_via_identifier(self, iden, listener):
        # de = document entity. to remain agnostic we result in dictionaries
        de = self._impl.retrieve_entity_as_storage_adapter_collection(
                iden, listener)
        if de is None:
            return  # (Case4130)
        # (Case4292):
        return de.to_dictionary_two_deep_as_storage_adapter_entity()

    def to_identifier_stream(self, listener):
        return self._impl.to_identifier_stream_as_storage_adapter_collection(listener)  # noqa: E501

    def DIG_FOR_CAPABILITY(self, dig_path, listener):
        # (moved here from elsewhere at #history-A.1)

        impl = self._impl

        def use_dig_path():  # add this one step to the front of the path
            yield ('COLLECTION_CAPABILITIES', 'property', {'do_splay': False})
            for dig_step in dig_path:
                yield dig_step

        def say_collection():
            coll_ID = impl.collection_identity
            _ada = coll_ID.adapter_key.replace('_', '-')
            s_a = [f"the '{_ada}' format adapter"]
            adapter_variant = coll_ID.adapter_variant
            if adapter_variant is not None:
                s_a.append(f"('{adapter_variant}' variant)")
            return ' '.join(s_a)

        from kiss_rdb.magnetics.via_collection import DIGGY_DIG
        funcer = DIGGY_DIG(impl, use_dig_path(),  say_collection, listener)
        if funcer is None:
            return
        return funcer(impl)

    @property
    def COLLECTION_IMPLEMENTATION(self):  # track where we do this bad thing
        return self._impl


def _storage_adapter_via(original_method):  # #decorator
    def use_method(self, needle, listener, contextualize=None, validate=None):
        key = original_method(self, needle, listener)
        if key is None:
            return
        return self._finish_lookup(key, listener, contextualize, validate)
    return use_method


class collectioner_via_storage_adapters_module:  # "_MetaCollection"
    # this is the thing that wraps the module that holds storage adapters

    def __init__(self, module_name, module_directory):
        # module_name = mod.__name__
        # module_directory = mod.__path__._path[0]
        # --
        from os import listdir
        from fnmatch import fnmatch
        # from glob import glob
        # _glob_path = os_path.join(_dir, '[!_]*')
        # order = tuple(sorted(glob(_glob_path)))  # gives you full paths

        _ = (s for s in listdir(module_directory) if fnmatch(s, '[!_]*'))
        order = tuple(sorted(_))

        # --
        # for now using the filesystem entries as the keys but this is not guar
        references = {k: _NOT_YET_LOADED for k in order}
        # --
        self._order = order
        self._reference_via_key = references
        self._SAs_module_name = module_name
        self._key_via_extname = None
        self._key_via_format_name = None

    def collection_via_path(
            self, collection_path,
            listener=_throwing_listenerer,  # (2nd arg for tighter 2-arg calls)
            adapter_variant=None,
            format_name=None,
            random_number_generator=None, filesystem=None):

        opened = _open_storage_adapter_resolution(  # originally a method call
            collection_path, format_name, self, listener, filesystem)

        if opened is None:
            return
        with opened as reso:
            if reso is None:
                return
            _coll_ID = _CollectionIdentity(
                    collection_path=collection_path,
                    adapter_variant=adapter_variant,
                    adapter_key=reso.storage_adapter.key)
            these_N_args = {
                'collection_identity': _coll_ID,
                'random_number_generator': random_number_generator,
                'filesystem': reso.filesystem,
                'listener': listener}

            ps = reso.path_stat
            sa = reso.storage_adapter

            if ps is None:  # Assume that IFF no path stat, a storage adapter
                # was indicated explicitly by name (#here1). since #history-A.2
                # in such cases we defer entirely to the storage adapter to
                # decide what to do with a collection path.

                return sa._collection_via_file_(these_N_args)

            if ps.is_directory:
                these_N_args['schema_file_scanner'] = reso.schema_file_scanner
                return sa._collection_via_schema_(these_N_args)

            assert(ps.is_file)
            return sa._collection_via_file_(these_N_args)

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
            self, key, listener, contextualize=None, validate=None):

        if key not in self._reference_via_key:
            _emit_about_SA_key(listener, key, self._order, contextualize)
            return

        return self._finish_lookup(
                key, listener, contextualize, validate)

    def _finish_lookup(self, key, listener, contextualize, validate):

        sa = self._dereference(key)

        # (ad-hoc validation before more general validation = better UI msgs)
        if validate is not None:
            if not validate(sa):
                return

        if not sa.module.STORAGE_ADAPTER_IS_AVAILABLE:
            return _emit_about_nonworking_stub(listener, sa, contextualize)

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

    def splay_storage_adapters__(self):
        def build_dereferencer(key):  # (Case3067DP)
            def f():
                return self._dereference(key)
            return f

        for key in self._reference_via_key:
            yield (key, build_dereferencer(key))

    def _dereference(self, key):
        ref = self._reference_via_key[key]
        if ref.is_loaded:
            return ref
        self._reference_via_key[key] = False  # lock it for safety
        from importlib import import_module
        _module_name = f'{self._SAs_module_name}.{key}'
        _module = import_module(_module_name)
        sa = _StorageAdapter(_module, key)
        self._reference_via_key[key] = sa
        return sa


def _open_storage_adapter_resolution(
        collection_path, format_name, meta_collection, listener, filesystem):

    def main():
        if format_adapter_name_was_specified():
            return open_storage_adapter_from_format_name()  # #here1
        elif not path_exists():
            whine_about_path_not_existing()
        elif path_is_directory():
            return open_storage_adapter_from_directory()
        elif path_is_file():
            return open_storage_adapter_from_file_extension()
        else:
            raise Exception('cover me')  # whine about path being neither f nor

    def open_storage_adapter_from_directory():
        return __open_directory_based_storage_adapter_resolution(
                reso, meta_collection, collection_path, listener)

    def open_storage_adapter_from_file_extension():
        _head, extname = os_path.splitext(collection_path)
        if not len(extname):
            return _emit_about_no_extname(listener, collection_path)

        def contextualize(dct):
            dct['path'] = collection_path
        reso.storage_adapter = meta_collection.storage_adapter_via_extname(
                extname, listener, contextualize)
        return wrap_result_for_pass_thru()

    def open_storage_adapter_from_format_name():
        reso.storage_adapter = meta_collection.storage_adapter_via_format_name(
                format_name, listener)
        return wrap_result_for_pass_thru()

    # -- conditionals (sort of)

    def path_exists():
        reso.path_stat = _StatLexicon(collection_path, reso.filesystem)
        return reso.path_stat.path_exists

    def whine_about_path_not_existing():
        _emit_about_collection_not_found_because_noent(
                listener, reso.path_stat.exception)

    def path_is_directory():
        return reso.path_stat.is_directory

    def path_is_file():
        return reso.path_stat.is_file

    def format_adapter_name_was_specified():
        return format_name is not None

    class wrap_result_for_pass_thru:
        # when not directory based, no schema file to close. but look same
        def __enter__(self):
            if reso.storage_adapter is None:
                return
            return reso

        def __exit__(self, *_3):
            pass
    # --

    class Resolution:  # [#510.2] blank state
        pass
    reso = Resolution()
    if filesystem is None:
        from kiss_rdb import real_filesystem_read_only_
        reso.filesystem = real_filesystem_read_only_()
    else:
        reso.filesystem = filesystem
    reso.path_stat = None
    return main()


def __open_directory_based_storage_adapter_resolution(
        reso, meta_collection, collection_path, listener):

    class ContextManager:
        def __enter__(self):
            self._close_me = None
            _schema_path = os_path.join(collection_path, 'schema.rec')
            try:
                opened = reso.filesystem.open_file_for_reading(_schema_path)
                self._close_me = opened
            except FileNotFoundError as e:
                return _emit_about_no_schema_file(listener, e)

            return _enter_directory_based_storage_adapter(
                    opened, reso, meta_collection, listener)

        def __exit__(self, *_3):
            if self._close_me is None:
                return
            self._close_me.close()
            self._close_me = None

    return ContextManager()


def _enter_directory_based_storage_adapter(
        opened, reso, meta_collection, listener):

    def main():
        if not resolve_first_field_line():
            return
        if not check_that_first_field_line_has_a_particular_name():
            return
        return resolve_storage_adapter_given_name()

    def resolve_storage_adapter_given_name():

        def contextualize(dct):
            scanner.contextualize_about_field_value(dct, reso.field)

        def validate(sa):
            if sa.module.STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES:
                return True
            return _emit_about_not_directory_based(listener, sa, contextualize)

        reso.storage_adapter = meta_collection.storage_adapter_via_key(
            reso.field.field_value_string, listener, contextualize, validate)
        return None if reso.storage_adapter is None else reso

    def check_that_first_field_line_has_a_particular_name():
        if 'storage_adapter' == reso.field.field_name:
            return True

        def contextualize(dct):
            scanner.contextualize_about_field_name(dct, reso.field)
        return _emit_about_first_field_name(listener, contextualize)

    def resolve_first_field_line():
        if there_is_another_block():
            if its_a_separator_block():
                if there_is_another_block():
                    if its_a_field_line():
                        return found_it()  # (Case1418)
                    else:
                        assert_and_whine_about_effectively_empty_file()
            elif its_a_field_line():
                return found_it()
            else:
                assert_and_whine_about_literally_empty_file()

    def found_it():
        reso.field = reso.block
        del reso.block
        return True

    def its_a_field_line():
        return reso.block.is_field_line

    def its_a_separator_block():
        return reso.block.is_separator_block

    def there_is_another_block():
        reso.block = scn.next_block(listener)
        return False if reso.block is None else True  # (Case1414)

    def assert_and_whine_about_effectively_empty_file():
        assert reso.block.is_end_of_file
        whine_empty('effectively_empty_file')  # (Case1417)

    def assert_and_whine_about_literally_empty_file():
        assert reso.block.is_end_of_file
        whine_empty('literally_empty_file')  # (Case1415)

    def whine_empty(which):
        _emit_about_empty_schema_file(listener, which, scn)

    from kiss_rdb.magnetics_.schema_file_scanner_via_recfile_scanner import (
            schema_file_scanner_via_recfile_scanner)

    from kiss_rdb.storage_adapters_.rec import ErsatzScanner

    scn = ErsatzScanner(opened)
    scanner = schema_file_scanner_via_recfile_scanner(scn)
    reso.schema_file_scanner = scanner

    return main()


class _StatLexicon:

    def __init__(self, path, filesystem):

        try:
            stat = filesystem.stat_via_path(path)
            self.path_exists = True
        except FileNotFoundError as e:
            self.path_exists = False
            self.exception = e
            return

        self.is_directory = False
        self.is_file = False

        from stat import S_ISDIR, S_ISREG
        if S_ISDIR(stat.st_mode):
            self.is_directory = True
        elif S_ISREG(stat.st_mode):
            self.is_file = True


# == models

class _StorageAdapter:  # move this to its own file if it gets big

    def __init__(self, module, key):
        self.module = module
        self.key = key

    def _collection_via_schema_(self, these_N_args):
        _ = self.module.COLLECTION_IMPLEMENTATION_VIA_SCHEMA(** these_N_args)
        return _wrap_collection(_)

    def _collection_via_file_(self, these_N):
        _ = self.module.COLLECTION_IMPLEMENTATION_VIA_SINGLE_FILE(** these_N)
        return _wrap_collection(_)

    def collection_for_pass_thru_write__(self, stdout):
        _ = self.module.COLLECTION_IMPLEMENTATION_FOR_PASS_THRU_WRITE(stdout)
        return _wrap_collection(_)

    def collection_via_open_read_only__(self, stdin, monitor):
        _ = self.module.COLLECTION_IMPLEMENTATION_VIA_READ_ONLY_STREAM(
                stdin, monitor)
        return _wrap_collection(_)

    is_loaded = True


def _wrap_collection(impl):
    if impl is None:
        return
    return _Collection(impl)


class _NOT_YET_LOADED:  # #as-namespace-only
    is_loaded = False


class _CollectionIdentity:  # for error messages from collection

    def __init__(self, collection_path, adapter_variant, adapter_key):
        self.collection_path = collection_path
        self.adapter_variant = adapter_variant
        self.adapter_key = adapter_key


# == whiners

def _emit_about_nonworking_stub(listener, sa, contextualize=None):
    def structurer():  # #not-covered, kind of crazy
        dct = {}
        mod = sa.module
        moniker = repr(sa.key)
        if hasattr(mod, 'STORAGE_ADAPTER_UNAVAILABLE_REASON'):
            def f(s):
                return f"the {moniker} storage adapter is"
            msg = mod.STORAGE_ADAPTER_UNAVAILABLE_REASON
            import re
            use_msg = re.sub(r"^[Ii]t( is|'s)\b", f, msg)
            dct['reason_tail'] = use_msg
        else:
            dct['reason_tail'] = repr(sa.key)
        if contextualize is not None:
            contextualize(dct)
        return dct
    listener(*_EC_for_cannot_load,
             'storage_adapter_is_not_available', structurer)


def _emit_about_not_directory_based(listener, sa, contextualize):
    def structurer():  # (Case1421)
        _long_reason = ''.join(__pieces_for_not_dir_based(sa))
        dct = {'reason': _long_reason}
        contextualize(dct)
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


def _emit_about_first_field_name(listener, contextualize):
    def structurer():  # (Case1418)
        dct = {}
        dct['expecting'] = '"storage_adapter" as field name'
        contextualize(dct)
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
        return _payload_via_file_not_found_error(file_not_found)
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
    # raise Exception("cover me - worked once at visual test")  # [#876]
    listener(*_EC_for_cannot_load, 'unrecognized_format_name', structurer)


def _same_splay_reason(noun_singular, wrong, key_via_what):
    _head = f"unrecognized {noun_singular} '{wrong}'"
    _these = ', '.join(f"'{s}'" for s in sorted(key_via_what.keys()))
    _tail = f"known {noun_singular}(s): ({_these})"
    _reason = f'{_head}. {_tail}'
    return {'reason': _reason}


def _emit_about_SA_key(listener, key, order, contextualize):
    def structurer():  # (Case1419)
        dct = {}
        _these = ', '.join(repr(s) for s in order)
        dct['reason'] = (f"unknown storage adapter {repr(key)}. "
                         f"known storage adapters: ({_these})")
        contextualize(dct)
        return dct
    listener(*_EC_for_cannot_load, 'unknown_storage_adapter', structurer)


def _emit_about_collection_not_found_because_noent(listener, file_not_found):
    def structurer():  # (Case1409)
        return _payload_via_file_not_found_error(file_not_found)
    listener(*_EC_for_not_found, 'no_such_file_or_directory', structurer)


def _payload_via_file_not_found_error(file_not_found):
    _reason = file_not_found.strerror  # str(file_not_found) no "[Errno 2]"
    return {'reason': _reason,
            'filename': file_not_found.filename,
            'errno': file_not_found.errno}


def _say_extname_collision(en, first_key, second_key):
        _reason = (f"Extname collison: '{en}' associated with both"
                   f"'{first_key}' and '{first_key}'. There can only be one.")
        return _reason


_this_shape = ('error', 'structure')
_EC_for_cannot_load = (*_this_shape, 'cannot_load_collection')
_EC_for_not_found = (*_this_shape, 'collection_not_found')

# #history-A.2: massive refactor for clarity
# #history-A.1
# #born.
