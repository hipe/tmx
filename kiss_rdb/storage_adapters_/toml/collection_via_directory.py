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

        if random_number_generator is not None:
            self._random_number_generator = random_number_generator

        if filesystem is not None:
            self._filesystem = filesystem

        self._schema_pather = collection_schema.build_pather_(
                collection_directory_path)

        self._schema = collection_schema

    def update_entity(self, id_s, cuds, listener):
        tup = self._ID_and_path_that_must_already_exist(id_s, listener)
        if tup is None:
            return
        iid, path = tup

        with self._open_locked_mutable_entities_file(path) as lmef:
            res = _update_entity(lmef, iid, cuds, self, listener)

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

        with self._open_locked_mutable_indexy_file() as indexy_file:

            if indexy_file.is_of_single_file_schema:  # as #here5
                locked_file = _PassthruContextManager(indexy_file.handle)
            else:
                locked_file = self._open_locked_mutable_entities_file(path)

            with locked_file as lmef:
                res = _delete_entity(
                        lmef, indexy_file, iid, self._filesystem, listener)
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

        with self._open_locked_mutable_indexy_file() as indexy_file:
            from kiss_rdb.magnetics_ import (
                provision_ID_randomly_via_identifiers as _)

            tup = _.PROVISION_NEW_IDENTIFIER(
                    random_number_generator=self._random_number_generator,
                    indexy_file=indexy_file,
                    identifier_depth=self._schema.identifier_depth,
                    listener=listener)

            if tup is None:
                cover_me('maybe numberspace is full for current schema')
                return
            iid, iids = tup

            # from identifier and cuds request build mutable document entity

            id_s = iid.to_string()

            mde = _create_MDE_via_ID_and_request(
                    id_s, cuds_request, self, listener)
            if mde is None:
                return  # (Case830) (CLI) #here6

            # from the identifier derive the entities path

            _pieces = self._file_path_pieces_via_identifier(iid)
            path = os_path.join(*_pieces)

            # to avoid the bad thing, obtain a lock before mutating the file.
            # in cases where the file doesn't yet exist and so will be created,
            # the locking idiom requires that the file already exist, so in
            # those cases we create an empty file first. doing so incurs a
            # cleanup responsibility: if something fails, don't leave behind
            # the empty file. es muss sein. more at (Case765) (ghost)

            if indexy_file.is_of_single_file_schema:

                # in single file mode, the index file *is* the entities file.
                # we are already in a locked session for that file. we should
                # not want (and can not obtain) a second lock for that same
                # file below. here we "back hack" it so the 2nd lock session
                # below can remain unaware of this. :#here5

                locked_file = _PassthruContextManager(indexy_file.handle)
                yes_do_cleanup = False

            elif os_path.exists(path):  # :#here3
                locked_file = self._open_locked_mutable_entities_file(path)
                yes_do_cleanup = False

            else:  # :#here4:

                # == BEGIN production only eek. no rollback eek but meh
                parent_dir = os_path.dirname(path)
                if not os_path.exists(parent_dir):
                    self.__CREATE_DIRECTORIES(parent_dir)
                # == end

                locked_file = self._create_and_open_mutable_entit_etc(path)
                yes_do_cleanup = True

            with self._filesystem.FILE_REWRITE_TRANSACTION(listener) as tr:

                with locked_file as lmef:

                    res = _create_entity(
                        locked_ents_file=lmef,
                        indexy_file=indexy_file,

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
                res = mde  # (Case822)

        return res

    # == END

    def __CREATE_DIRECTORIES(self, parent_dir):
        import os
        ents_dir = self._schema_pather._entities_directory_path
        ft_depth = self._schema._storage_schema.filetree_depth
        if ft_depth < 2:
            cover_me('you madman')
        elif ft_depth == 2:
            assert(ents_dir == parent_dir)
            os.mkdir(parent_dir)
        elif ft_depth == 3:
            if not os_path.exists(ents_dir):
                os.mkdir(ents_dir)  # madman #cover-me
            os.mkdir(parent_dir)
        else:
            cover_me('eek you want mkdir -p')

    def retrieve_entity(self, id_s, listener):
        """NOTICE

        to retrieve one entity; this opens a file, reads some or all of the
        file line-by-line, and then closes it (ALL just for that one entity.)
        do not use this as written if you need to retrieve multiple entities
        in one invocation.. :#here2
        """

        tup = self._ID_and_path_that_must_already_exist(id_s, listener)
        if tup is None:
            return
        iid, path = tup
        return _retrieve_entity(iid, path, listener)

    def _ID_and_path_that_must_already_exist(self, id_s, listener):

        iid = self._schema.identifier_via_string(id_s, listener)
        if iid is None:
            return

        pieces = self._file_path_pieces_via_identifier(iid)
        path = os_path.join(*pieces)

        if not os_path.exists(path):  # :##here1
            _whine_about_no_path(pieces, listener)
            return

        return iid, path

    def _open_locked_mutable_indexy_file(self):

        path, wrapper = self._schema_pather.to_indexy_path_and_wrapper__()
        return self._filesystem.open_locked_file_in_wrapper(path, wrapper)

    def _create_and_open_mutable_entit_etc(self, path):
        return self._filesystem.CREATE_AND_OPEN_LOCKED_FILE(path)

    def _open_locked_mutable_entities_file(self, path):
        return self._filesystem.open_locked_file(path)

    def to_identifier_stream(self, listener):
        return self._schema_pather.to_identifier_stream(listener)

    def _file_path_pieces_via_identifier(self, iid):
        return self._schema_pather.file_path_pieces_via__(iid)

    def BUSINESS_SCHEMA(self):
        from . import business_schema_via_definition as lib
        return lib.DEFAULT_BUSINESS_SCHEMA


class _PassthruContextManager:

    def __init__(self, x):
        self._mixed = x

    def __enter__(self):
        return self._mixed

    def __exit__(self, *_3):
        return False

# ==


def _update_entity(locked_ents_file, identifier, cuds, coll, listener):

    doc_ent = None

    def recv_new_doc_ent(de):
        nonlocal doc_ent  # oops
        doc_ent = de

    def new_lines_via_entity(mde, my_listener):
        # unlike both CREATE and DELETE, UPDATE determines its modified entity
        # lines *as a function of* the existing entity, so more complicated.

        req = _request_via_cuds(cuds, my_listener)
        if req is None:
            return  # not covered - blind faith

        _bs = coll.BUSINESS_SCHEMA()
        _ok = req.edit_mutable_document_entity_(mde, _bs, my_listener)

        if not _ok:
            return  # not covered - blind faith

        return tuple(mde.to_line_stream())

    def rewrite_ents_file(orig_lines, my_listener):
        return _sib_lib().new_lines_via_update_and_existing_lines(
                identifier.to_string(),
                new_lines_via_entity,
                orig_lines,
                my_listener,
                recv_new_doc_ent,
                )

    with coll._filesystem.FILE_REWRITE_TRANSACTION(listener) as trans:
        trans.rewrite_file(locked_ents_file, rewrite_ents_file)
        res = trans.finish()

    if res is not None:
        assert(res is True)
        res = doc_ent

    return res


def _delete_entity(locked_ents_file, indexy_file, identifier, fs, listener):

    deleted_doc_ent = None

    def rec_deleted_doc_ent(de):
        nonlocal deleted_doc_ent  # oops
        deleted_doc_ent = de

    def rewrite_ents_file(orig_lines, my_listener):
        return _sib_lib().new_lines_via_delete_and_existing_lines(
                identifier.to_string(),
                orig_lines,
                my_listener,
                rec_deleted_doc_ent,
                )

    def rewrite_index_file(orig_lines, my_listener):
        from kiss_rdb.magnetics_ import index_via_identifiers as _
        return _.new_lines_via_delete_identifier_from_index__(
                orig_lines, identifier, my_listener)

    with fs.FILE_REWRITE_TRANSACTION(listener) as trans:
        # (per [#867.Q] do index file second)

        trans.rewrite_file(locked_ents_file, rewrite_ents_file)

        if indexy_file.is_of_single_file_schema:
            pass  # hi. in single-file mode, no no index to update (Case775)
        else:
            trans.rewrite_file(indexy_file.handle, rewrite_index_file)

        res = trans.finish()

    if res is not None:
        assert(res is True)
        res = deleted_doc_ent

    return res


def _create_entity(
        locked_ents_file, indexy_file,
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
                under exceedingly contrived circumstances. see ghost test case
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
        from kiss_rdb.magnetics_ import index_via_identifiers as _
        return _.new_lines_via_add_identifier_into_index__(
                identifier, iids, my_listener)

    if indexy_file.is_of_single_file_schema:
        # it was at the end because we read it to provision the id.
        # re-read the whole file. meh. (Case779)
        locked_ents_file.seek(0)

    # (per [#867.Q] do index file second)
    trans.rewrite_file(locked_ents_file, rewrite_ents_file)

    if not indexy_file.is_of_single_file_schema:
        trans.rewrite_file(indexy_file.handle, rewrite_index_file)

    if trans.OK:
        transaction_almost_completed = True
    return trans.finish()


def _create_MDE_via_ID_and_request(identifier_string, req, coll, listener):

    from . import identifiers_via_file_lines as ids_lib

    _tslo = ids_lib.TSLO_via(identifier_string, 'attributes')

    from . import blocks_via_file_lines as blk_lib

    mde = blk_lib.MDE_via_TSLO_(_tslo)

    _bs = coll.BUSINESS_SCHEMA()

    _ok = req.edit_mutable_document_entity_(mde, _bs, listener)

    if not _ok:
        return  # (Case830) (CLI) #here6

    return mde  # (Case764)


def _request_via_cuds(cuds, listener):
    from kiss_rdb.magnetics_.CUD_attributes_request_via_tuples import (
            request_via_tuples as _)
    return _(cuds, listener)


def _retrieve_entity(identifier, file_path, listener):
    """DISCUSSION

    - the founding purpose of the "collection" idiom was to centralize
      operations that mutate the file (CUD).
    - but it seems to make sense to expose also the read-only verb (R in CRUD)
    - see #here2 about gross inefficiency in calling this multiple times.
    """

    from .entity_via_identifier_and_file_lines import (
            entity_via_identifier_and_file_lines as DE_via,
            entity_dict_via_entity_big_string__ as dict_via,
            )

    id_s = identifier.to_string()

    with open(file_path) as lines:  # file existed last we checked #here1
        de = DE_via(id_s, lines, listener)

    if de is None:
        return  # (Case710)

    # (Case711):

    assert(de.table_type == 'attributes')
    assert(de.identifier_string == id_s)

    _big_string = ''.join(de.to_line_stream())

    return dict_via(_big_string, listener)


"""
:#here6: a new kind of UI error (attribute value validaton). we don't want
CLI to be the one covering this. also this test case covers legitamate work
that's only in CLI so etc
"""


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


def _emit_input_error_structure(f, listener):
    listener('error', 'structure', 'input_error', f)


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


def _sib_lib():
    from . import file_lines_via_CUD_entity_and_file_lines as _
    return _


_okay = True

# #history: production only: create directories
# #born.
