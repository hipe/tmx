from os import path as os_path

"""NOTES

as of file birth, this is a "rumspringa" playground that's mushing together
several different *separate* responsibilities:
  - schema
  - collection
  - "native digits"
"""


class collection_via_directory_and_filesystem:

    def __init__(self, dir_path, fs):

        identifier_depth = 3  # #open #[#867.K]

        def f(id_s, listener):

            from . import identifier_via_string as _
            id_obj = _.identifier_via_string__(id_s, listener)
            if id_obj is None:
                return

            length = len(id_obj.native_digits)
            if identifier_depth != length:
                _whine_about_ID_depth(id_obj, identifier_depth, listener)
                return
            return id_obj
        self._depthly_valid_identifier_via_string = f
        self._dir_path = dir_path
        self._filesystem = fs

    def update_entity(self, id_s, cuds, listener):
        tup = self._ID_and_path(_file_must_already_exist, id_s, listener)
        if tup is None:
            return
        iid, path = tup

        with self._open_locked_mutable_entities_file(path) as lmef:
            res = _update_entity(lmef, iid, cuds, self._filesystem, listener)

        return res

    # == BEGIN create and delete are more complicated

    def delete_entity(self, id_s, listener):

        # certainly, the entities file must first exist

        # before attempting to lock the index file, see if we can resolve the
        # valid path for the entities file (so we get nicer error message)

        tup = self._ID_and_path(_file_must_already_exist, id_s, listener)
        if tup is None:
            return
        iid, path = tup

        # then after the above, try to get the two locks:

        with self._open_locked_mutable_index() as lmif:
            with self._open_locked_mutable_entities_file(path) as lmef:
                res = _delete_entity(
                        lmef, lmif, iid, self._filesystem, listener)
        return res

    def create_entity(self, cuds, random_number_generator, listener):
        """
        create is the most complicated per [#864.C] this table.

        obtain a mutex lock the of the index file for writing
        read the index file
        provision a new id
        get the path of the entities file from the new id
        obtain a mutex lock for mutating the index (it may not have existed)
        determine the new lines of the entity given the provisioned id
        determine the new lines of the entities file given above
        determine the new lines of the index file given the above
        (probably write both the above to temp files)
        ATOMICALLY, flush the new lines to both files
        release both locks
        """

        req = _request_via_cuds(cuds, listener)
        if req is None:
            cover_me('like what')
            return

        with self._open_locked_mutable_index() as lmif:

            tup = _provision_new_IID(random_number_generator, lmif, listener)
            if tup is None:
                cover_me('maybe numberspace is full for current schema')
                return
            iid, iids = tup

            path = self._path_via_ID(
                    iid, _file_need_not_already_exist, listener)
            if path is None:
                cover_me('idk')
                return
            with self._open_locked_mutable_entities_file(path) as lmef:
                res = _create_entity(
                        lmef, lmif, iid, iids, req, self._filesystem, listener)
        return res

    # == END

    def retrieve_entity(self, id_s, listener):
        """NOTICE

        to retrieve one entity; this opens a file, reads some or all of the
        file line-by-line, and then closes it (ALL just for that one entity.)
        o not use this as written if you need to retrieve multiple entities
        in one invocation.. :#here2
        """

        tup = self._ID_and_path(_file_must_already_exist, id_s, listener)
        if tup is None:
            return
        iid, path = tup
        return _retrieve_entity(iid, path, self._filesystem, listener)

    def _ID_and_path(self, file_must_already_exist, id_s, listener):

        id_obj = self._depthly_valid_identifier_via_string(id_s, listener)
        if id_obj is None:
            return
        path = self._path_via_ID(id_obj, file_must_already_exist, listener)
        if path is None:
            return
        return id_obj, path

    def _path_via_ID(self, iid, file_must_already_exist, listener):
        return _valid_path_for(
                iid, file_must_already_exist, self._dir_path, listener)

    def _open_locked_mutable_index(self):
        _ = os_path.join(self._dir_path, '.entity-index.txt')
        return self._filesystem.open_locked_file(_)

    def _open_locked_mutable_entities_file(self, path):
        return self._filesystem.open_locked_file(path)

    def to_identifier_stream(self, listener):
        from .entities_via_collection import identifiers_via_collection as _
        return _(self._dir_path, self._depthly_valid_identifier_via_string, listener)  # noqa: E501


# ==


def _update_entity(locked_ents_file, identifier, cuds, fs, listener):

    def new_lines_via_entity(mde, my_listener):
        # unlike both CREATE and DELETE, UPDATE determines its modified entity
        # lines *as a function of* the existing entity, so more complicated.

        req = _request_via_cuds(cuds, my_listener)
        if req is None:
            return  # not covered - blind faith

        _ok = req.edit_mutable_document_entity_(mde, my_listener)

        if not _ok:
            return  # not covered - blind faith

        return tuple(mde.to_line_stream())

    def rewrite_ents_file(orig_lines, my_listener):
        return _sib_lib().new_lines_via_update_and_existing_lines(
                identifier.to_string(),
                new_lines_via_entity,
                orig_lines,
                my_listener)

    with fs.FILE_REWRITE_TRANSACTION(listener) as trans:
        trans.rewrite_file(locked_ents_file, rewrite_ents_file)
        res = trans.finish()

    return res


def _delete_entity(locked_ents_file, locked_index_file, identifier, fs, listener):  # noqa: E501

    def rewrite_ents_file(orig_lines, my_listener):
        return _sib_lib().new_lines_via_delete_and_existing_lines(
                identifier.to_string(),
                orig_lines,
                my_listener)

    def rewrite_index_file(orig_lines, my_listener):
        from . import index_via_identifiers as _
        return _.new_lines_via_delete_identifier_from_index__(
                orig_lines, identifier, my_listener)

    with fs.FILE_REWRITE_TRANSACTION(listener) as trans:
        # (per [#867.Q] do index file second)
        trans.rewrite_file(locked_ents_file, rewrite_ents_file)
        trans.rewrite_file(locked_index_file, rewrite_index_file)
        res = trans.finish()

    return res


def _create_entity(
        locked_ents_file, locked_index_file,
        identifier, iids, req, filesystem, listener):

    id_s = identifier.to_string()

    mde = __create_MDE_via_ID_and_request(id_s, req, listener)
    if mde is None:
        return

    _new_entity_lines = mde.to_line_stream()

    def rewrite_ents_file(orig_lines, my_listener):
        return _sib_lib().new_lines_via_create_and_existing_lines(
                id_s,
                _new_entity_lines,
                orig_lines,
                my_listener)

    def rewrite_index_file(orig_lines, my_listener):
        from . import index_via_identifiers as _
        return _.new_lines_via_add_identifier_into_index__(
                identifier, iids, my_listener)

    with filesystem.FILE_REWRITE_TRANSACTION(listener) as trans:
        # (per [#867.Q] do index file second)
        trans.rewrite_file(locked_ents_file, rewrite_ents_file)
        trans.rewrite_file(locked_index_file, rewrite_index_file)
        res = trans.finish()

    return res


def __create_MDE_via_ID_and_request(identifier_string, req, listener):

    from .entity_via_open_table_line_and_body_lines import (
        mutable_document_entity_via_identifer_and_body_lines as _,
        )

    mde = _((), identifier_string, 'attributes', listener)
    assert(mde)

    _ok = req.edit_mutable_document_entity_(mde, listener)

    if not _ok:
        cover_me('like when?')
        return

    return mde


def _provision_new_IID(random_number_generator, lmif, listener):
    from . import provision_ID_randomly_via_identifiers as _
    return _.NEW_THING(random_number_generator, lmif, listener)


def _request_via_cuds(cuds, listener):
    from .CUD_attributes_request_via_tuples import request_via_tuples as _
    return _(cuds, listener)


def _retrieve_entity(identifier, file_path, filesystem, listener):
    """DISCUSSION

    - the founding purpose of the "collection" idiom was to centralize
      operations that mutate the file (CUD).
    - but it seems to make sense to expose also the read-only verb (R in CRUD)
    - the "filesystem" argument is only for injecting a spy. we do not bother
      with the extra complexity of injecting spies when doing read-only on FS.
    - see #here2 about gross inefficiency in calling this multiple times.
    """

    from .entity_via_identifier_and_file_lines import (
            entity_via_identifier_and_file_lines as MDE_via,
            entity_dict_via_entity_big_string__ as dict_via,
            )

    id_s = identifier.to_string()

    with open(file_path) as lines:  # file existed last we checked #here1
        mde = MDE_via(id_s, lines, listener)

    if mde is None:
        return  # (Case710)

    # (Case711):

    assert(mde.table_type == 'attributes')
    assert(mde.identifier_string == id_s)

    _big_string = ''.join(mde.to_line_stream())

    return dict_via(_big_string, listener)


# == individual identifier stuff

def _valid_path_for(identifier, file_must_already_exist, dir_path, listener):
    pieces = __file_path_pieces_via_identifier(identifier, dir_path)
    file_path = os_path.join(*pieces)
    if file_must_already_exist:
        if os_path.exists(file_path):  # :#here1
            return file_path
        else:
            __whine_about_no_path(pieces, listener)
            return
    else:
        # == BEGIN temporary
        if os_path.exists(file_path):
            pass  # hi. (Case764)
        else:
            cover_me('have fun creating a file')
        # == END
        return file_path


def __file_path_pieces_via_identifier(identifier, dir_path):

    # this will absolutely change when we abstract schema-ism out

    nds = identifier.native_digits
    length = len(nds)
    assert(1 < length)

    # get all but the last component. "ABC" -> "A/B.toml"
    these = [nds[i].character for i in range(0, (length - 1))]

    these[-1] = f'{these[-1]}.toml'

    return (dir_path, 'entities', *these)


# == whiners

def __whine_about_no_path(pieces, listener):
    """given a filesystem path that does not exist, determine the longest

    head of the path that *does*.

    (you could either do deep-to-shallow or shallow-to-deep. tradeoffs each)
    """

    length = len(pieces)
    assert(1 < length)

    num_not_exist = length
    no_ent = os_path.join(*pieces)

    for num in reversed(range(1, length)):
        path = os_path.join(*pieces[0:num])
        if os_path.exists(path):
            break
        no_ent = path
        num_not_exist = num

    if length == num_not_exist:
        reason = f'no such file - {no_ent}'  # (Case704)
    else:
        _ = os_path.join(*pieces[num:])
        reason = f'for {repr(_)}, no such directory - {no_ent}'  # (Case703)

    _emit_input_error_structure(lambda: {'reason': reason}, listener)


def _whine_about_ID_depth(identifier, expected_length, listener):
    def f():  # (Case703)
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


def _emit_input_error_structure(f, listener):
    listener('error', 'structure', 'input_error', f)


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


def _sib_lib():
    from . import file_lines_via_CUD_entity_and_file_lines as _
    return _


_file_need_not_already_exist = False
_file_must_already_exist = True

_okay = True

# #born.
