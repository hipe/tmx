from os import path as os_path

"""NOTES

as of file birth, this is a "rumspringa" playground that's mushing together
several different *separate* responsibilities:
  - schema
  - collection
  - "native digits"
"""


class INJECTIONS:
    """for several reasons, certain facilities are injected as dependencies.

    not every operation uses every facility. if you know before you build
    the collection that you will be doing only certain operation(s), you can
    avoid some unnecessary coupling and overhead.. #[#867.U]
    """

    def __init__(
            self,
            random_number_generator,
            filesystemer):

        o = {}

        def fs():
            nonlocal filesystemer
            res = filesystemer()
            del(filesystemer)
            return res
        o['filesystem'] = fs

        def rng():
            nonlocal random_number_generator
            res = random_number_generator
            del(random_number_generator)
            return res
        o['random_number_generator'] = rng

        def release(names):
            return {k: o[k]() for k in names}

        self.RELEASE_THESE = release


class collection_via_directory_and_schema:

    def __init__(
            self, collection_directory_path, collection_schema,
            random_number_generator=None,
            filesystem=None):

        # -- depthly valid identifier string

        identifier_depth = collection_schema.identifier_depth

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

        # --

        if random_number_generator is not None:
            self._random_number_generator = random_number_generator

        if filesystem is not None:
            self._filesystem = filesystem

        self._dir_path = collection_directory_path
        self._schema = collection_schema

    def update_entity(self, id_s, cuds, listener):
        tup = self._ID_and_path_that_must_already_exist(id_s, listener)
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

        tup = self._ID_and_path_that_must_already_exist(id_s, listener)
        if tup is None:
            return
        iid, path = tup

        # then after the above, try to get the two locks:

        with self._open_locked_mutable_index() as lmif:
            with self._open_locked_mutable_entities_file(path) as lmef:
                res = _delete_entity(
                        lmef, lmif, iid, self._filesystem, listener)
        return res

    def create_entity(self, cuds, listener):
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

        and the above is only for if the entities file already exists
        """

        cuds_request = _request_via_cuds(cuds, listener)
        if cuds_request is None:
            # #not-covered, but attribute names are too similar will hit this
            return

        # with the index file locked, provision a new identifier

        with self._open_locked_mutable_index() as lmif:

            from . import provision_ID_randomly_via_identifiers as _

            tup = _.PROVISION_NEW_IDENTIFIER(
                    random_number_generator=self._random_number_generator,
                    locked_mutable_index_file=lmif,
                    identifier_depth=self._schema.identifier_depth,
                    listener=listener)

            if tup is None:
                cover_me('maybe numberspace is full for current schema')
                return
            iid, iids = tup

            # from identifier and cuds request build mutable document entity

            id_s = iid.to_string()

            mde = _create_MDE_via_ID_and_request(id_s, cuds_request, listener)
            if mde is None:
                cover_me('idk')
                return

            # from the identifier derive the entities path

            _pieces = self._file_path_pieces_via_identifier(iid)
            path = os_path.join(*_pieces)

            # to avoid the bad thing, obtain a lock before mutating the file.
            # in cases where the file doesn't yet exist and so will be created,
            # the locking idiom requires that the file already exist, so in
            # those cases we create an empty file first. doing so incurs a
            # cleanup responsibility: if something fails, don't leave behind
            # the empty file. es muss sein. more at (Case765) (ghost)

            if os_path.exists(path):  # :#here3
                locked_file = self._open_locked_mutable_entities_file(path)
                yes_do_cleanup = False
            else:  # :#here4:
                locked_file = self._create_and_open_mutable_entit_etc(path)
                yes_do_cleanup = True

            with self._filesystem.FILE_REWRITE_TRANSACTION(listener) as tr:

                with locked_file as lmef:

                    res = _create_entity(
                        locked_ents_file=lmef,
                        locked_index_file=lmif,

                        identifier_string=id_s,
                        identifier=iid,

                        mutable_document_entity=mde,
                        iids=iids,

                        yes_do_cleanup=yes_do_cleanup,
                        files_rewrite_transaction=tr,

                        listener=listener,
                        )

            if res is not None:
                assert(res is True)
                res = mde  # (Case819)

        return res

    # == END

    def retrieve_entity(self, id_s, listener):
        """NOTICE

        to retrieve one entity; this opens a file, reads some or all of the
        file line-by-line, and then closes it (ALL just for that one entity.)
        o not use this as written if you need to retrieve multiple entities
        in one invocation.. :#here2
        """

        tup = self._ID_and_path_that_must_already_exist(id_s, listener)
        if tup is None:
            return
        iid, path = tup
        return _retrieve_entity(iid, path, listener)

    def _ID_and_path_that_must_already_exist(self, id_s, listener):

        iid = self._depthly_valid_identifier_via_string(id_s, listener)
        if iid is None:
            return

        pieces = self._file_path_pieces_via_identifier(iid)
        path = os_path.join(*pieces)

        if not os_path.exists(path):  # :##here1
            _whine_about_no_path(pieces, listener)
            return

        return iid, path

    def _open_locked_mutable_index(self):
        _ = os_path.join(self._dir_path, '.entity-index.txt')
        return self._filesystem.open_locked_file(_)

    def _create_and_open_mutable_entit_etc(self, path):
        return self._filesystem.CREATE_AND_OPEN_LOCKED_FILE(path)

    def _open_locked_mutable_entities_file(self, path):
        return self._filesystem.open_locked_file(path)

    def to_identifier_stream(self, listener):
        from . import entities_via_collection as _
        return _.identifiers_via_collection(
                directory_path=self._dir_path,
                id_via_string=self._depthly_valid_identifier_via_string,
                schema=self._schema,
                listener=listener)

    def _file_path_pieces_via_identifier(self, iid):
        return self._schema.FILE_PATH_PIECES_VIA(iid, self._dir_path)  # noqa: E501


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
        identifier_string, identifier,
        mutable_document_entity, iids,
        yes_do_cleanup, files_rewrite_transaction,
        listener):

    trans = files_rewrite_transaction  # (shorter name)

    transaction_almost_completed = False

    def f(filesystem):
        # this is called when exiting every such files rewrite transaction,
        # even when an exception was thrown (we think)..

        if yes_do_cleanup:  # the file did not exist #here4
            if transaction_almost_completed:
                pass  # because transaction OK, no cleanup to do (Case766)
            else:
                # ==
                cover_me('NEVER BEEN COVERED - LEAVING BLANK FILE! (readme)')
                """(Case765): the whole purpose of "cleanup functions" is to
                enable us to handle the case of when we have created a new
                entities file and the transaction fails. as it turns out, this
                case is perhaps logically impossible for us to trigger except
                under exceedingly contrived circumstances. see test
                """
                # something like this:
                # ==
                import os
                os.unlink(locked_ents_file.name)  # can u do this when locked?
        else:  # if the file already existed, no cleanup (#here)
            pass  # hi. (Case764)

    trans.REGISTER_CLEANUP_FUNCTION(f)

    # --

    _new_entity_lines = mutable_document_entity.to_line_stream()

    def rewrite_ents_file(orig_lines, my_listener):
        return _sib_lib().new_lines_via_create_and_existing_lines(
                identifier_string,
                _new_entity_lines,
                orig_lines,
                my_listener)

    def rewrite_index_file(orig_lines, my_listener):
        from . import index_via_identifiers as _
        return _.new_lines_via_add_identifier_into_index__(
                identifier, iids, my_listener)

    # (per [#867.Q] do index file second)
    trans.rewrite_file(locked_ents_file, rewrite_ents_file)
    trans.rewrite_file(locked_index_file, rewrite_index_file)
    if trans.OK:
        transaction_almost_completed = True
    return trans.finish()


def _create_MDE_via_ID_and_request(identifier_string, req, listener):

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


def _request_via_cuds(cuds, listener):
    from .CUD_attributes_request_via_tuples import request_via_tuples as _
    return _(cuds, listener)


def _retrieve_entity(identifier, file_path, listener):
    """DISCUSSION

    - the founding purpose of the "collection" idiom was to centralize
      operations that mutate the file (CUD).
    - but it seems to make sense to expose also the read-only verb (R in CRUD)
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


# == whiners

def _whine_about_no_path(pieces, listener):
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


_okay = True

# #born.
