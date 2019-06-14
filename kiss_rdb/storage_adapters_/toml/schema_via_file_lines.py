from modality_agnostic.memoization import memoize


# (this is :[#867.K] the main place we use the toml vendor lib
# but there may be more.)


def SCHEMA_VIA_COLLECTION_PATH(collection_path, listener):
    from os import path as os_path
    import toml  # stay close to #here2.

    schema_path = os_path.join(collection_path, 'schema.rec')

    e = None
    try:
        doc = toml.load(schema_path)  # for once in our lives we
        # want to use the thing that reads from the filesystem itself
    except FileNotFoundError as e_:
        e = e_

    if e is not None:
        __whine_about_schema_file_not_found(listener, e)
        return

    storage_schema = doc.pop('storage schema')  # ..

    assert(0 == len(doc))  # ..

    return _Schema(storage_schema)


# == injection for locking and mutating index

# we do plain old injection for this simplest of stuff, but a
# lot of it is hard-coded inline because yikes and meh


class _IndexyFileWhenDeepTree:

    def __init__(self, fh):
        self.handle = fh

    def to_identifier_stream(self, listener_NOT_USED):
        # if there's an error in your index file it's considered corruption
        # and we just raise the exception

        from kiss_rdb.magnetics_ import identifiers_via_index as _
        return _.identifiers_via_lines_of_index(self.handle)

    is_of_single_file_schema = False


class _IndexyFileWhenSingleFile:

    def __init__(self, fh, to_identifier_stream):
        self.handle = fh
        self._to_id_stream = to_identifier_stream

    def to_identifier_stream(self, listener):
        return self._to_id_stream(listener)  # hi.

    is_of_single_file_schema = True


# ==

class _SchemaPather:
    """schemas aren't associated with a particular directory. this is.
    """

    def __init__(self, coll_path, schema):

        import os.path as os_path

        storage_schema = schema._storage_schema

        if 1 == storage_schema.filetree_depth:
            is_single_file_schema = True
            self._entities_file = os_path.join(coll_path, 'entities.toml')
            # #here4
        else:
            is_single_file_schema = False
            self._entities_directory_path = os_path.join(coll_path, 'entities')
            # #here3

            self._index_file = os_path.join(coll_path, '.entity-index.txt')

        self._check_depth = schema.check_depth
        self._is_single_file_schema = is_single_file_schema
        self._dir_path = coll_path
        self._storage_schema = storage_schema

    def to_indexy_path_and_wrapper__(self):

        if self._is_single_file_schema:
            def wrapper(filehandle):
                return _IndexyFileWhenSingleFile(
                        filehandle, self.to_identifier_stream)
            path = self._entities_file
        else:
            wrapper = _IndexyFileWhenDeepTree
            path = self._index_file

        return path, wrapper

    def to_identifier_stream(self, listener):

        # == moved here now #history-A.1
        from kiss_rdb.magnetics_.identifier_via_string import (
           identifier_via_string_)

        def id_via_string(s, my_listener):
            iden = identifier_via_string_(s, my_listener)
            if iden is None:
                return
            if not check_depth(iden, my_listener):
                return
            return iden
        check_depth = self._check_depth
        # ==

        from . import entities_via_collection as _
        return _.identifiers_via__(
                paths_function=self._to_entities_file_paths,
                id_via_string=id_via_string,
                listener=listener)

    def _to_entities_file_paths(self, when_no_entries):
        _name = self._storage_schema.name_of_paths_function
        _func = _paths_functions()[_name]
        return _func(self, when_no_entries)  # #here1

    def file_path_pieces_via__(self, identifier):

        nds = identifier.native_digits
        length = len(nds)
        assert(1 < length)

        if self._is_single_file_schema:  # (Case4364)
            # single file path doesn't derive from iid, but we play along
            return (self._dir_path, 'entities.toml')  # #here4

        # get all but the last component. "ABC" -> "A/B.toml"
        these = [nds[i].character for i in range(0, (length - 1))]

        these[-1] = f'{these[-1]}.toml'

        return (self._dir_path, 'entities', *these)  # #here3


class _Schema:  # #testpoint
    """EXPERIMENTAL. at #birth this was a pure abstraction"""

    def __init__(self, storage_schema):
        o = _storage_schemas[storage_schema]()
        self.check_depth = o._build_check_depth()
        self._storage_schema = o

    def build_pather_(self, coll_path):
        return _SchemaPather(coll_path, self)

    @property
    def identifier_depth(self):
        return self._storage_schema.identifier_depth


# == populate the storage schemas with lazy definitions

o = {}


@memoize
def _32_32_32():
    return _StorageSchema(
            identifier_depth=3,
            filetree_depth=3,
            paths_function='paths_when_three_deep',
            )


o['32x32x32'] = _32_32_32


@memoize
def _32_32():
    return _StorageSchema(
            identifier_depth=2,
            filetree_depth=2,
            paths_function='paths_when_two_deep',
            )


o['32x32'] = _32_32


@memoize
def _32up2():
    return _StorageSchema(
            identifier_depth=2,
            filetree_depth=1,
            paths_function='paths_when_single_file',
            )


o['32^2'] = _32up2


_storage_schemas = o
del o


# ==

class _StorageSchema:

    def __init__(
            self,
            identifier_depth,
            filetree_depth,
            paths_function,
            ):
        self.name_of_paths_function = paths_function
        self.identifier_depth = identifier_depth
        self.filetree_depth = filetree_depth

    def _build_check_depth(self):
        def check_depth(id_obj, listener):
            length = len(id_obj.native_digits)
            if identifier_depth != length:
                _whine_about_ID_depth(id_obj, identifier_depth, listener)
                return
            return id_obj
        identifier_depth = self.identifier_depth
        return check_depth


# ==

@memoize
def _paths_functions():
    """DISCUSSION:

    these functions all have in common that they are short and similar and
    we don't want to have to load at load time if we don't have to

    pp=posix path
    """

    from pathlib import Path

    def paths_when_three_deep(pather, when_no_entries):  # #here1

        entities_dir_pp = Path(pather._entities_directory_path)
        dirs = sorted_entries_of(entities_dir_pp)

        if not len(dirs):
            when_no_entries(entities_dir_pp)
            return

        for dir_pp in dirs:
            for posix_path in sorted_entries_of(dir_pp):
                yield posix_path

    def paths_when_two_deep(pather, when_no_entries):  # #here1 #cover-me

        entities_dir_pp = Path(pather._entities_directory_path)
        files = sorted_entries_of(entities_dir_pp)

        if not len(files):
            when_no_entries(entities_dir_pp)
            return ()

        return files

    def paths_when_single_file(pather, when_no_entries):  # #here1

        entities_file_pp = Path(pather._entities_file)

        """we follow suit here with how this is written for the deeper
        (more common) storage schemas: the deeper schemas yield out only
        posix paths derives from entires the filesystem reported as existing.
        a disadvantage here is that it may mean hitting the filesystem 2x for
        the same question of "does this path exist?" but meh
        ...
        """

        if not entities_file_pp.exists():
            cover_me('the language will need to change a little for this')
            when_no_entries(entities_file_pp)
            return

        yield entities_file_pp  # lovely

    def sorted_entries_of(posix_path):
        """DISCUSSION

        absolutely do *not* rely on the filesystem to sort dir listings!

        (Case4298)
        """
        _generator = posix_path.glob('*')  # ..
        _entries = list(_generator)
        return sorted(_entries, key=lambda pp: pp.as_posix())

    return {
            'paths_when_three_deep': paths_when_three_deep,
            'paths_when_two_deep': paths_when_two_deep,
            'paths_when_single_file': paths_when_single_file,
            }


# ==

def vendor_parse_toml_or_catch_exception__(big_string):
    import toml

    e = None
    res = None
    try:
        res = toml.loads(big_string)  # #here2
    except toml.TomlDecodeError as e_:
        e = e_

    return e, res


# == whiners

def _whine_about_ID_depth(identifier, expected_length, listener):
    def f():  # (Case4126)
        act = len(identifier.native_digits)
        if act < expected_length:
            head = 'not enough'
        elif act > expected_length:
            head = 'too many'
        _id_s = identifier.to_string()
        _reason = (
                f'{head} digits in identifier {repr(_id_s)} - '
                f'need {expected_length}, had {act}'
                )
        return {'reason': _reason}  # ..
    _emit_input_error_structure(f, listener)


def __whine_about_schema_file_not_found(listener, e):
    def structer():
        assert(e.strerror == 'No such file or directory')
        _head = "collection does not exist because no schema file"
        _path = e.filename
        return {
                'reason': f'{_head} - {_path}',
                'errno': e.errno,
                'input_error_type': 'collection_not_found',
                }

    _emit_input_error_structure(structer, listener)


def _emit_input_error_structure(f, listener):
    listener('error', 'structure', 'input_error', f)


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #history-A.1
# #birth: abstracted
