"""SO:

๐ Before you can do anything interesting with the typical collection, you
   have to parse its schema file. toml *used to* be the format of schema files.
   At that time this module was the first point of contact with the vendor
   library, so it came to hold the dual responsibility of schema stuff *and*
   the internal API/faรงade through which we interact with vendor (#here2).

๐ at #history-A.2 we switched from toml- to recfiles-based schema files,
   leaving this file with two disparate purposes that are no longer related
   to each other. We're leaving this nonsensical dual-purpose intact for now,
   but as soon as there's a compelling reason to, we'll probably push this
   vendor lib abstraction layer to (e.g) the storage adapter root module.

๐ So this is :[#867.K] the main internal API for doing vendor stuff, but
   we use this same tag to mark the (at writing) one other place we have too.
"""
from modality_agnostic import lazy


# == injection for locking and mutating index

# we do plain old injection for this simplest of stuff, but a
# lot of it is hard-coded inline because yikes and meh


class _IndexyFileWhenDeepTree:

    def __init__(self, fh):
        self.handle = fh

    def open_idens_(self, listener_NOT_USED):
        # if there's an error in your index file it's considered corruption
        # and we just raise the exception

        from kiss_rdb.magnetics_.identifiers_via_index import \
            identifiers_via_lines_of_index as func
        idens = func(self.handle)
        from contextlib import nullcontext as func
        return func(idens)

    is_of_single_file_schema = False


class _IndexyFileWhenSingleFile:

    def __init__(self, fh, open_iden_trav):
        self.open_idens_ = open_iden_trav
        self.handle = fh

    is_of_single_file_schema = True


# ==

class _SchemaPather:
    """schemas aren't associated with a particular directory. this is.
    """

    def __init__(self, coll_path, schema):

        storage_schema = schema._storage_schema

        if 1 == storage_schema.filetree_depth:
            is_single_file_schema = True
            self._entities_file = _os_path_join(coll_path, 'entities.toml')
            # #here4
        else:
            is_single_file_schema = False
            self._entities_directory_path = _os_path_join(
                    coll_path, 'entities')
            # #here3
            self._index_file_value = None

        self._check_depth = schema.check_depth
        self._is_single_file_schema = is_single_file_schema
        self._dir_path = coll_path
        self._storage_schema = storage_schema

    def to_indexy_path_and_wrapper__(self):

        if self._is_single_file_schema:
            def wrapper(filehandle):
                return _IndexyFileWhenSingleFile(
                        filehandle, self.open_identifier_traversal)
            path = self._entities_file
        else:
            wrapper = _IndexyFileWhenDeepTree
            path = self._index_file

        return path, wrapper

    @property
    def _index_file(self):
        if self._index_file_value is None:
            from kiss_rdb.magnetics_.identifiers_via_index import \
                index_file_path_via_collection_path_ as func
            self._index_file_value = func(self._dir_path)
        return self._index_file_value

    def open_identifier_traversal(self, listener):

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

        from .entities_via_collection import open_identifier_traveral__ as func
        pathser = self._to_entities_file_paths
        return func(pathser, id_via_string, listener)

    def _to_entities_file_paths(self, when_no_entries):
        _name = self._storage_schema.name_of_paths_function
        _func = _paths_functions()[_name]
        return _func(self, when_no_entries)  # #here1

    def file_path_pieces_via__(self, identifier):

        nds = identifier.native_digits
        length = identifier.number_of_digits
        assert(1 < length)

        if self._is_single_file_schema:  # (Case4364)
            # single file path doesn't derive from iid, but we play along
            return (self._dir_path, 'entities.toml')  # #here4

        # get all but the last component. "ABC" -> "A/B.toml"
        these = [nds[i].character for i in range(0, (length - 1))]

        these[-1] = f'{these[-1]}.toml'

        return (self._dir_path, 'entities', *these)  # #here3


class Schema_:
    """EXPERIMENTAL. at #birth this was a pure abstraction"""

    def __init__(self, storage_schema):
        o = _storage_schemas[storage_schema]()
        self.check_depth = o._build_check_depth()
        self._storage_schema = o

    def build_pather_(self, coll_path):
        return _SchemaPather(coll_path, self)

    @property
    def identifier_number_of_digits(self):
        return self._storage_schema.identifier_number_of_digits


# == populate the storage schemas with lazy definitions

o = {}


@lazy
def _32_32_32():
    return _StorageSchema(
            identifier_depth=3,
            filetree_depth=3,
            paths_function='paths_when_three_deep')


o['32x32x32'] = _32_32_32


@lazy
def _32_32():
    return _StorageSchema(
            identifier_depth=2,
            filetree_depth=2,
            paths_function='paths_when_two_deep')


o['32x32'] = _32_32


@lazy
def _32up2():
    return _StorageSchema(
            identifier_depth=2,
            filetree_depth=1,
            paths_function='paths_when_single_file')


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
        self.identifier_number_of_digits = identifier_depth
        self.filetree_depth = filetree_depth

    def _build_check_depth(self):
        def check_depth(id_obj, listener):
            length = id_obj.number_of_digits
            if identifier_depth != length:
                _whine_about_ID_depth(id_obj, identifier_depth, listener)
                return
            return id_obj
        identifier_depth = self.identifier_number_of_digits
        return check_depth


# ==

@lazy
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
            xx('the language will need to change a little for this')
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
        res = toml.loads(big_string)  # :#here2
    except toml.TomlDecodeError as e_:
        e = e_

    return e, res


# == whiners

def _whine_about_ID_depth(identifier, expected_length, listener):
    def structer():  # (Case4318)
        act = identifier.number_of_digits
        if act < expected_length:
            head = 'not enough'
        elif act > expected_length:
            head = 'too many'
        id_s = identifier.to_string()
        reason = (
                f'{head} digits in identifier {repr(id_s)} - '
                f'need {expected_length}, had {act}')
        return {'reason': reason}  # ..
    listener('error', 'structure', 'entity_not_found', structer)


def _os_path_join(*a):
    from os.path import join
    return join(*a)


def xx(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #history-A.2 toml is no longer used to parse schema files
# #history-A.1
# #birth: abstracted
