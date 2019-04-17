from modality_agnostic.memoization import (
        memoize,
        )


def SCHEMA_VIA_COLLECTION_PATH(collection_path, listener):
    from os import path as os_path
    import toml  # stay close to #here2.

    schema_path = os_path.join(collection_path, 'schema.toml')

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


class _Schema:  # #testpoint
    """EXPERIMENTAL. at #birth this was a pure abstraction"""

    def __init__(self, storage_schema):
        self._storage_schema = _storage_schemas[storage_schema]()

    def ENTITIES_FILE_PATHS_VIA(self, dir_path, when_no_entries):
        _name = self._storage_schema.name_of_paths_function
        return _paths_functions()[_name](dir_path, when_no_entries)  # #here1

    def FILE_PATH_PIECES_VIA(self, identifier, dir_path):

        nds = identifier.native_digits
        length = len(nds)
        assert(1 < length)

        # get all but the last component. "ABC" -> "A/B.toml"
        these = [nds[i].character for i in range(0, (length - 1))]

        these[-1] = f'{these[-1]}.toml'

        return (dir_path, 'entities', *these)

    @property
    def identifier_depth(self):
        return self._storage_schema.identifier_depth


# == populate the storage schemas with lazy definitions

o = {}


@memoize
def _32_32_32():
    return _StorageSchema(
            identifier_depth=3,
            paths_function='paths_when_three_deep',
            )


o['32x32x32'] = _32_32_32


_storage_schemas = o
del o


# ==

class _StorageSchema:

    def __init__(
            self,
            identifier_depth,
            paths_function,
            ):
        self.name_of_paths_function = paths_function
        self.identifier_depth = identifier_depth


# ==

@memoize
def _paths_functions():
    """DISCUSSION:

    at writing there is only one schema, however, hopefully:
    these functions all have in common that they are short and similar and
    we don't want to have to load at load time if we don't have to

    pp=posix path
    """

    from pathlib import Path
    import os.path as os_path

    def paths_when_three_deep(dir_path, when_no_entries):  # :#here1

        entities_dir_pp = Path(os_path.join(dir_path, 'entities'))
        dirs = sorted_entries_of(entities_dir_pp)

        if not len(dirs):
            when_no_entries(entities_dir_pp)
            return

        for dir_pp in dirs:
            for posix_path in sorted_entries_of(dir_pp):
                yield posix_path

    def sorted_entries_of(posix_path):
        """DISCUSSION

        absolutely do *not* rely on the filesystem to sort dir listings!

        (Case720)
        """
        _generator = posix_path.glob('*')  # ..
        _entries = list(_generator)
        return sorted(_entries, key=lambda pp: pp.as_posix())

    return {
            'paths_when_three_deep': paths_when_three_deep,
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

    listener('error', 'structure', 'input_error', structer)

# #birth: abstracted
