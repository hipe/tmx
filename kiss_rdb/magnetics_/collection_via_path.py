from os import path as os_path


class _ResolveCollection:

    def __init__(self, path, listener, fs, meta_collection):
        self.path = path
        self.listener = listener
        self.meta_collection = meta_collection
        self.FS = fs

    def execute(self):
        st = self.__stat_via_path()
        if st is None:
            return
        import stat
        if stat.S_ISDIR(st.st_mode):
            return self.__when_directory()
        if stat.S_ISREG(st.st_mode):
            return self.__when_file()
        # #not-covered:
        raise Exception(f'neither file nor directory - {self.path}')

    # -- when directory

    def __when_directory(self):
        open_file = self.__resolve_open_schema_file()
        if open_file is None:
            return
        from kiss_rdb.magnetics_.schema_file_scanner_via_recfile_scanner import (  # noqa: E501
                schema_file_scanner_via_recfile_scanner)
        from kiss_rdb.storage_adapters_.rec import ErsatzScanner

        with open_file as fh:
            scn = ErsatzScanner(fh)
            self._scanner = schema_file_scanner_via_recfile_scanner(scn)
            return self.__via_schema_file_scanner()

    def __via_schema_file_scanner(self):

        field = self.__scan_first_field_line()
        if field is None:
            return
        self._field = field
        fn = field.field_name
        if 'storage_adapter' != fn:
            def contextualize(dct):
                self._scanner.contextualize_about_field_name(dct, field)
            return _emit_about_first_field_name(self.listener, contextualize)

        def contextualize(dct):
            self._scanner.contextualize_about_field_value(dct, field)

        sa = self.meta_collection._storage_adapter_via_key_(
                field.field_value_string, self.listener, contextualize)
        if sa is None:
            return
        if not sa.module.STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES:
            return _emit_about_not_directory_based(
                    self.listener, sa, contextualize)
        if sa.module.STORAGE_ADAPTER_IS_NONWORKNG_STUB:
            _emit_about_nonworking_stub(self.listener, sa, contextualize)
            return
        return self.__finish_for_schema_based_collection(sa)

    def __scan_first_field_line(self):
        scn = self._scanner.recfile_scanner
        blk = scn.next_block(self.listener)
        if blk is None:
            return  # (Case1414)

        if blk.is_separator_block:
            blk = scn.next_block(self.listener)
            if blk is None:
                return  # assume field parse error #not-covered, see (Case1414)
            if blk.is_field_line:
                return blk  # (Case1418)
            assert(blk.is_end_of_file)  # (Case1417)
            return self._whine_empty('effectively_empty_file')

        if blk.is_field_line:
            return blk  # #blind-faith

        assert(blk.is_end_of_file)
        self._whine_empty('literally_empty_file')  # (Case1415)

    def _whine_empty(self, which):
        _parse_state = self._scanner.recfile_scanner
        _emit_about_empty_schema_file(self.listener, which, _parse_state)

    def __resolve_open_schema_file(self):
        path = os_path.join(self.path, 'schema.rec')
        failed = True
        try:
            fh = self.FS.open_file_for_reading(path)
            failed = False
        except FileNotFoundError as e_:
            e = e_
        if failed:
            return _emit_about_no_schema_file(self.listener, e)
        return fh

    # -- when file

    def __when_file(self):
        head, tail = os_path.splitext(self.path)
        if not len(tail):
            return _emit_about_no_extname(self.listener, self.path)
        self._extname = tail
        return self.__when_extname()

    def __when_extname(self):
        sa = self.meta_collection._storage_adapter_via_extname_(
                self._extname, self.listener)
        if sa is None:
            return
        return self.__finish_for_single_file_based_collection(sa)

    # -- shared/similar/low-level

    def __finish_for_schema_based_collection(self, sa):
        return sa.module.RESOLVE_SCHEMA_BASED_COLLECTION_AS_STORAGE_ADAPTER(
                schema_file_scanner=self._scanner,
                collection_path=self.path,
                listener=self.listener)

    def __finish_for_single_file_based_collection(self, sa):
        return sa.module.RESOLVE_SINGLE_FILE_BASED_COLLECTION_AS_STORAGE_ADAPTER(  # noqa: E501
                collection_path=self.path,
                listener=self.listener)

    def __stat_via_path(self):
        did_fail = True
        try:
            stat = self.FS.stat_via_path(self.path)
            did_fail = False
        except FileNotFoundError as e_:
            e = e_
        if did_fail:
            _emit_about_collection_not_found_because_noent(self.listener, e)
            return
        return stat


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

    def COLLECTION_VIA_PATH(self, path, listener, fs):
        return _ResolveCollection(path, listener, fs, self).execute()

    def _storage_adapter_via_extname_(self, extname, listener):
        if self._key_via_extname is None:
            self.__init_extname_index()
        if extname not in self._key_via_extname:
            _emit_about_extname(listener, extname, self._key_via_extname)
            return
        return self._dereference(self._key_via_extname[extname])

    def _storage_adapter_via_key_(self, key, listener, contextualize):
        if key not in self._reference_via_key:
            _emit_about_SA_key(listener, key, self._order, contextualize)
            return
        return self._dereference(key)

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


# == models

class _StorageAdapter:  # move this to its own file if it gets big

    def __init__(self, module, key):
        self.module = module
        self.key = key

    def RESOLVE_COLLECTION(
            self, collection_path, listener, schema_file_scanner):
        # bad to use the existence/absense of scanner
        raise Exception("HERE IS NOW")

    is_loaded = True


class _NOT_YET_LOADED:  # #as-namespace-only
    is_loaded = False


# == whiners

def _emit_about_nonworking_stub(listener, sa, contextualize):
    def structurer():  # #not-covered
        dct = {'reason_tail': repr(sa.key)}
        contextualize(dct)
        return dct
    listener(*_this_head, 'storage_adapter_is_nonworking_stub', structurer)


def _emit_about_not_directory_based(listener, sa, contextualize):
    def structurer():  # (Case1421)
        _long_reason = ''.join(__pieces_for_not_dir_based(sa))
        dct = {'reason': _long_reason}
        contextualize(dct)
        return dct
    listener(*_this_head, 'storage_adapter_is_not_directory_based', structurer)


def __pieces_for_not_dir_based(sa):
    mod = sa.module
    can_single = mod.STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES
    if can_single:
        extensions = mod.STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS
    is_nonworking_stub = mod.STORAGE_ADAPTER_IS_NONWORKNG_STUB
    if can_single:
        yield f"the '{sa.key}' storage adapter is single-file only, "
        yield "so the collection cannot have a directory and a schema file"
        if len(extensions):
            _these = ' or '.join(repr(s) for s in extensions)
            yield f". the collection should be in a file ending in {_these}"
        else:
            yield ", however there are no file extensions associated with "
            yield "the storage adapter, so nothing makes any sense"
    elif is_nonworking_stub:
        yield f"the '{sa.key}' storage adapter is a non-working stub"
    else:
        yield f"the '{sa.key}' storage adapter "
        yield "has no relationship to the filesystem"


def _emit_about_first_field_name(listener, contextualize):
    def structurer():  # (Case1418)
        dct = {}
        dct['expecting'] = '"storage_adapter" as field name'
        contextualize(dct)
        return dct
    listener(*_this_head, 'unexpected_first_field_of_schema_file', structurer)


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
    listener(*_this_head, 'first_field_of_schema_file_not_found', structurer)


def _emit_about_no_schema_file(listener, file_not_found):
    def structurer():  # (Case1413)
        return _payload_via_file_not_found_error(file_not_found)
    listener(*_this_head, 'no_schema_file', structurer)


def _emit_about_no_extname(listener, path):

    def structurer():  # (Case1411)
        _reason = (
            f"cannot infer storage adapter from file with no extension - "
            f"{path}")
        return {'reason': _reason}
    listener(*_this_head, 'file_has_no_extname', structurer)


def _emit_about_extname(listener, extname, key_via_extname):
    def structurer():  # (Case1410)
        _head = f"unrecognized extension '{extname}'"
        _these = ', '.join(f"'{s}'" for s in sorted(key_via_extname.keys()))
        _tail = f"known extension(s): ({_these})"
        _reason = f'{_head}. {_tail}'
        return {'reason': _reason}
    listener(*_this_head, 'unrecognized_extname', structurer)


def _emit_about_SA_key(listener, key, order, contextualize):
    def structurer():  # (Case1419)
        dct = {}
        _these = ', '.join(repr(s) for s in order)
        dct['reason'] = (f"uknown storage adapter {repr(key)}. "
                         f"known storage adapters: ({_these})")
        contextualize(dct)
        return dct
    listener(*_this_head, 'unknown_storage_adapter', structurer)


def _emit_about_collection_not_found_because_noent(listener, file_not_found):
    def structurer():  # (Case1409)
        return _payload_via_file_not_found_error(file_not_found)
    listener(*_this_head, 'no_such_file_or_directory', structurer)


def _payload_via_file_not_found_error(file_not_found):
    _reason = file_not_found.strerror  # str(file_not_found) no "[Errno 2]"
    return {'reason': _reason,
            'filename': file_not_found.filename,
            'errno': file_not_found.errno}


def _say_extname_collision(en, first_key, second_key):
        _reason = (f"Extname collison: '{en}' associated with both"
                   f"'{first_key}' and '{first_key}'. There can only be one.")
        return _reason


_this_head = ('error', 'structure', 'collection_not_found')

# #born.
