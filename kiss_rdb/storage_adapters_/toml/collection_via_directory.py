from os import path as os_path

"""NOTES

as of file birth, this is a "rumspringa" playground that's mushing together
several different *separate* responsibilities:
  - schema
  - collection
  - "native digits"
"""


class collection_via_directory_and_schema:

    def __init__(
            self, collection_directory, collection_schema,
            random_number_generator=None, filesystem=None):

        if random_number_generator is not None:
            self._random_number_generator = random_number_generator

        if filesystem is not None:
            self._filesystem = filesystem

        self._schema_pather = collection_schema.build_pather_(
                collection_identity.collection_path)

        self.collection_identity = collection_identity
        self._schema = collection_schema

    def update_entity_as_storage_adapter_collection(self, iden, tup, listener):

        path = self._path_that_must_already_exist_for(iden, listener, 'update')
        if path is None:
            return

        with self._open_locked_mutable_entities_file(path) as lmef:
            return _update_entity(lmef, iden, tup, self, listener)

    # == BEGIN create and delete are more complicated

    def delete_entity_as_storage_adapter_collection(self, iden, listener):

        # certainly, the entities file must first exist

        # before attempting to lock the index file, see if we can resolve the
        # valid path for the entities file (so we get nicer error message)

        path = self._path_that_must_already_exist_for(iden, listener, 'delete')
        if path is None:
            return

        # then after the above, try to get the two locks:

        with self._open_locked_mutable_indexy_file() as indexy_file:

            if indexy_file.is_of_single_file_schema:  # as #here5
                locked_file = _pass_thru_context_manager(indexy_file.handle)
            else:
                locked_file = self._open_locked_mutable_entities_file(path)

            with locked_file as lmef:
                return _delete_entity(
                        lmef, indexy_file, iden, self._filesystem, listener)

    def create_entity_as_storage_adapter_collection(self, dct, listener):
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

        # DISCUSSION: because in Python 3.7 dictionaries are insertion-ordered,
        # the KISS-iest interface here is that CREATE should take an isomorphic
        # dictionary as an argument in the expected way..

        assert(isinstance(dct, dict))  # #[#022] wish for strong types

        # internally we want to use our "prepare & flush edit" pattern which
        # is fine, but we have to upgrade the dict into:

        cuds = tuple(('create_attribute', k, v) for k, v in dct.items())

        cuds_request = _request_via_cuds(cuds, listener)
        if cuds_request is None:
            # #not-covered, but attribute names are too similar will hit this
            return

        # with the index file locked, provision a new identifier

        with self._open_locked_mutable_indexy_file() as indexy_file:
            from kiss_rdb.magnetics_ import (
                provision_ID_randomly_via_identifiers as _)

            def identifierser():
                return indexy_file.to_identifier_stream(listener)

            tup = _.provision_new_identifier_(
                    random_number_generator=self._random_number_generator,
                    identifierser=identifierser,
                    identifier_depth=self._schema.identifier_number_of_digits,
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
                return  # (Case6250) (CLI) #here6

            # from the identifier derive the entities path

            _pieces = self._file_path_pieces_via_identifier(iid)
            path = os_path.join(*_pieces)

            # to avoid the bad thing, obtain a lock before mutating the file.
            # in cases where the file doesn't yet exist and so will be created,
            # the locking idiom requires that the file already exist, so in
            # those cases we create an empty file first. doing so incurs a
            # cleanup responsibility: if something fails, don't leave behind
            # the empty file. es muss sein. more at (Case4260) (ghost)

            if indexy_file.is_of_single_file_schema:

                # in single file mode, the index file *is* the entities file.
                # we are already in a locked session for that file. we should
                # not want (and can not obtain) a second lock for that same
                # file below. here we "back hack" it so the 2nd lock session
                # below can remain unaware of this. :#here5

                locked_file = _pass_thru_context_manager(indexy_file.handle)
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

                        listener=listener)

            if res is not None:
                assert(res is True)
                res = mde  # (Case6129)

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

    def retrieve_entity_as_storage_adapter_collection(self, iden, listener):
        """NOTICE

        to retrieve one entity; this opens a file, reads some or all of the
        file line-by-line, and then closes it (ALL just for that one entity.)
        do not use this as written if you need to retrieve multiple entities
        in one invocation.. :#here2
        """

        path = self._path_that_must_already_exist_for(iden, listener)
        if path is None:
            return
        return _retrieve_entity(iden, path, listener)

    def _path_that_must_already_exist_for(self, iden, listener, verb=None):

        _ok = self._schema.check_depth(iden, listener)
        if not _ok:
            return

        pieces = self._file_path_pieces_via_identifier(iden)
        path = os_path.join(*pieces)

        if not os_path.exists(path):  # :##here1
            def structurer():
                return _whine_about_no_path(pieces, iden, verb)
            listener('error', 'structure', 'entity_not_found', structurer)
            return

        return path

    def _open_locked_mutable_indexy_file(self):
        path, wrapper = self._schema_pather.to_indexy_path_and_wrapper__()
        return self._filesystem.open_locked_file_in_wrapper(path, wrapper)

    def _create_and_open_mutable_entit_etc(self, path):
        return self._filesystem.CREATE_AND_OPEN_LOCKED_FILE(path)

    def _open_locked_mutable_entities_file(self, path):
        return self._filesystem.open_locked_file(path)

    def to_identifier_stream_as_storage_adapter_collection(self, listener):
        return self._schema_pather.to_identifier_stream(listener)

    to_identifier_stream = to_identifier_stream_as_storage_adapter_collection

    def _file_path_pieces_via_identifier(self, iid):
        return self._schema_pather.file_path_pieces_via__(iid)

    def BUSINESS_SCHEMA(self):
        from . import business_schema_via_definition as lib
        return lib.DEFAULT_BUSINESS_SCHEMA


# ==

def _update_entity(locked_ents_file, identifier, cuds, coll, listener):

    before_and_after = []  # nonlocаl adjacent

    def new_lines_via_entity(doc_ent, my_listener):
        # unlike both CREATE and DELETE, UPDATE determines its modified entity
        # lines *as a function of* the existing entity, so more complicated.

        req = _request_via_cuds(cuds, my_listener)
        if req is None:
            return  # not covered - blind faith

        _busi_schema = coll.BUSINESS_SCHEMA()
        new_de = req.update_document_entity__(
                doc_ent, _busi_schema, my_listener)

        if new_de is None:
            return  # not covered - blind faith

        assert(0 == len(before_and_after))
        before_and_after.append(doc_ent)
        before_and_after.append(new_de)

        return tuple(new_de.to_line_stream())

    def rewrite_ents_file(orig_lines, my_listener):
        return _sib_lib().new_lines_via_update_and_existing_lines(
                identifier_string=identifier.to_string(),
                new_lines_via_entity=new_lines_via_entity,
                existing_file_lines=orig_lines,
                listener=my_listener)

    with coll._filesystem.FILE_REWRITE_TRANSACTION(listener) as trans:
        trans.rewrite_file(locked_ents_file, rewrite_ents_file)
        res = trans.finish()

    if res is None:
        return
    assert(res is True)
    return tuple(before_and_after)


def _delete_entity(locked_ents_file, indexy_file, identifier, fs, listener):

    class _RewriteEntsFile:  # avoid use of nonlocаl lol

        def __call__(self, orig_lines, my_listener):
            two = _sib_lib().new_lines_and_future_deleted_via_existing_lines(
                    identifier_string=identifier.to_string(),
                    existing_file_lines=orig_lines,
                    listener=my_listener)
            lines, future = two
            for line in lines:
                yield line
            self.deleted_document_entity_IFF_succeeded = future()  # None IFF f

    rewrite_ents_file = _RewriteEntsFile()

    def rewrite_index_file(orig_lines, my_listener):
        from kiss_rdb.magnetics_ import index_via_identifiers as _
        return _.new_lines_via_delete_identifier_from_index_(
                orig_lines, identifier, my_listener)

    with fs.FILE_REWRITE_TRANSACTION(listener) as trans:
        # (per [#867.Q] do index file second)

        trans.rewrite_file(locked_ents_file, rewrite_ents_file)

        if indexy_file.is_of_single_file_schema:
            pass  # hi. in single-file mode, no no index to update (Case4364)
        else:
            trans.rewrite_file(indexy_file.handle, rewrite_index_file)

        ok = trans.finish()

    if ok is None:
        return

    assert(ok is True)

    return rewrite_ents_file.deleted_document_entity_IFF_succeeded


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
                pass  # because transaction OK, no cleanup to do (Case4303)
            else:
                # ==
                cover_me('NEVER BEEN COVERED - LEAVING BLANK FILE! (readme)')
                """(Case4260): the whole purpose of "cleanup functions" is to
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
            pass  # hi. (Case4302)

    trans.REGISTER_CLEANUP_FUNCTION(f)

    # --

    _new_entity_lines = mutable_document_entity.to_line_stream()

    def rewrite_ents_file(orig_lines, my_listener):
        return _sib_lib().new_lines_via_create_and_existing_lines(
                new_entity_lines=_new_entity_lines,
                identifier_string=identifier_string,
                existing_file_lines=orig_lines,
                listener=my_listener)

    def rewrite_index_file(orig_lines, my_listener_NOT_USED):
        from kiss_rdb.magnetics_ import index_via_identifiers as _
        return _.new_lines_via_add_identifier_into_index_(identifier, iids)

    if indexy_file.is_of_single_file_schema:
        # it was at the end because we read it to provision the id.
        # re-read the whole file. meh. (Case4368)
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

    from .mutable_document_entity_via_table_start_line import MDE_via_TSLO

    mde = MDE_via_TSLO(_tslo)

    _business_schema = coll.BUSINESS_SCHEMA()

    _ok = req.mutate_created_document_entity__(mde, _business_schema, listener)

    if not _ok:
        return  # (Case6250) (CLI) #here6

    return mde  # (Case4302)


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
            entity_via_identifier_and_file_lines as DE_via)

    _id_s = identifier.to_string()

    with open(file_path) as lines:  # file existed last we checked #here1
        return DE_via(_id_s, lines, listener)


"""
:#here6: a new kind of UI error (attribute value validaton). we don't want
CLI to be the one covering this. also this test case covers legitamate work
that's only in CLI so etc
"""


# == whiners

def _whine_about_no_path(pieces, iden, verb):
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
        reason = f'no such file - {no_ent}'  # (Case4284)
    else:
        _ = os_path.join(*pieces[num:])
        reason = f'for {repr(_)}, no such directory - {no_ent}'  # (Case4126)

    if verb is not None:
        reason = f"cannot {verb} '{iden.to_string()}' because {reason}"

    return {'reason': reason}


# ==

def _pass_thru_context_manager(x):
    from data_pipes import ThePassThruContextManager
    return ThePassThruContextManager(x)


def cover_me(msg=None):  # #open [#876] cover me
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


def _sib_lib():
    from . import file_lines_via_CUD_entity_and_file_lines as _
    return _


_okay = True


# #history-A.2 (can be temporary)
# #history: production only: create directories
# #born.
