"""(based entirely on the pseudocode in [#429.3])"""

# (tables roughly in their order of first appearance in pseudocode)


from collections import namedtuple as _nt


class _Table:  # (try to be like "Collection")
    def __init__(self, db):
        self._db = db

    def _execute(self, sql, *tup):
        return self._db.conn.execute(sql, *tup)

    def _commit(self):
        self._db.conn.commit()


class _SingletonTable(_Table):

    def __init__(self, *a):
        super().__init__(*a)
        s = self._table_name
        self._SQL_for_UPDATE = f'UPDATE {s} SET value=? WHERE name=?'
        self._SQL_for_INSERT = f'INSERT INTO {s} VALUES (?, ?)'
        self._SQL_for_SELECT = f'SELECT value FROM {s} WHERE name=?'

    def _set_no_commit(self, k, num):
        exi = self._get(k)
        if exi is None:
            return self._insert_no_commit(k, num)
        return self._update_no_commit(k, num)

    def update(self, k, num):
        self._update_no_commit(k, num)
        self._commit()

    def insert(self, k, num):
        self._insert_no_commit(k, num)
        self._commit()

    def _update_no_commit(self, k, num):
        self._execute(self._SQL_for_UPDATE, (num, k))

    def _insert_no_commit(self, k, num):
        self._execute(self._SQL_for_INSERT, (k, num))

    def _delete_existent(self, *names):
        leng = len(names)
        assert leng
        terrifying = ', '.join('?' for _ in range(0, leng))
        sql = f'DELETE FROM "{self._table_name}" WHERE name IN ({terrifying})'
        c = self._execute(sql, names)
        assert leng == c.rowcount
        # (no commit till #commit1)

    def _get(self, k):
        row = self._execute(self._SQL_for_SELECT, (k,)).fetchone()
        if row is None:
            return
        val, = row
        return val

    get = _get


class _SingletonInteger(_SingletonTable):

    @property
    def file_queue_head_ID(self):
        return self._get('file_queue_head_ID')

    @property
    def file_queue_tail_ID(self):
        return self._get('file_queue_tail_ID')

    def set_file_queue_head_ID(self, oid):  # DOES NOT COMMIT
        self._set_no_commit('file_queue_head_ID', oid)

    def set_file_queue_tail_ID(self, oid):  # DOES NOT COMMIT
        self._set_no_commit('file_queue_tail_ID', oid)

    def delete_existent_file_queue_head_and_tail(self):
        self._delete_existent('file_queue_head_ID', 'file_queue_tail_ID')

    _table_name = 'singleton_integer'


class _SingletonText(_SingletonTable):

    @property
    def any_last_known_HEAD_SHA(self):
        return self._get('last_known_HEAD_SHA')

    def set_last_known_HEAD_SHA(self, SHA):
        return self._set_no_commit('last_known_HEAD_SHA', SHA)

    _table_name = 'singleton_text'


class _TemporaryCommitQueue(_Table):

    def delete_temp_record(self, temp_rec):
        return self._execute(
            'DELETE from temp.commit_queue WHERE SHA=?', (temp_rec.SHA,))

    def insert_commit(self, ci, parent_SHA=None, child_SHA=None):
        hdr = ci.header
        SHA = hdr.SHA
        datetime = hdr.datetime_string
        msg_big_string = ''.join(hdr.message_lines)
        files_big_string = '\n'.join(ci.file_paths)

        a = (SHA, parent_SHA, child_SHA, datetime,
             msg_big_string, files_big_string)

        self._execute(
            'INSERT INTO temp.commit_queue VALUES (?, ?, ?, ?, ?, ?)', a)
        self._commit()
        return

    def read_next_temp_commit(self):
        # The temp commit at HEAD is the one with no children.
        # The parent-most one is the one with no parent OR ..

        sing = self._db.singleton_text
        HEAD_SHA = sing.any_last_known_HEAD_SHA

        if HEAD_SHA is None:
            c = self._execute('SELECT * FROM temp.commit_queue '
                              'WHERE parent_SHA IS NULL')
        else:
            c = self._execute('SELECT * FROM temp.commit_queue '
                              'where parent_SHA=?', (HEAD_SHA,))

        row = c.fetchone()
        if row is None:
            c = self._execute('SELECT COUNT() FROM temp.commit_queue')
            ((num,),) = c
            assert 0 == num
            return
        return _TempCommitRecord(*row)

    def _create_table_(self):
        self._execute(
            """CREATE TEMPORARY TABLE commit_queue (
            SHA TEXT PRIMARY KEY,
            parent_SHA TEXT,
            child_SHA TEXT,
            datetime TEXT NOT NULL,
            message_indented TEXT NOT NULL,
            file_paths TEXT NOT NULL)""")
        self._commit()  # ??
        return


_TempCommitRecord = _nt(
    '_TempCommitRecord',
    'SHA parent_SHA child_SHA datetime message_indented file_paths'.split())


class _CommitTable(_Table):

    def accept_commit(self, temp_rec, parent_ID):
        SHA, parent_SHA, child_SHA, datetime, message_indented, file_paths = \
            temp_rec
        return self.insert_commit(
            SHA, datetime, message_indented, parent_ID=parent_ID)

    def insert_commit(
            self, SHA, datetime, message_indented,
            parent_ID=None, child_ID=None):
        c = self._execute(
            'INSERT INTO "commit" VALUES (?, ?, ?, ?, ?, ?)',
            (None, parent_ID, child_ID, SHA, datetime, message_indented))
        return c.lastrowid

    def tell_parent_about_child(self, parent_ID, new_ID):
        self._execute(
            'UPDATE "commit" SET child_ID=? WHERE commit_ID=?',
            (new_ID, parent_ID))

    def get_commit_via_SHA(self, SHA):
        c = self._execute('SELECT * FROM "commit" WHERE SHA=?', (SHA,))
        row = c.fetchone()
        if row:
            assert c.fetchone() is None
            return _CommitRecord(*row)

    def via_OID(self, ci_ID):
        c = self._execute('SELECT * from "commit" WHERE commit_ID=?', (ci_ID,))
        row = c.fetchone()
        assert c.fetchone() is None
        return _CommitRecord(*row)

    def ID_via_SHA(self, SHA):
        c = self._execute('SELECT commit_ID FROM "commit" WHERE SHA=?', (SHA,))
        row = c.fetchone()
        if row is None:
            xx(f"whoopsie, no commit with SHA: {SHA!r}")
        oid, = row
        return oid


_CommitRecord = _nt(
    '_CommitRecord',
    'commit_ID parent_ID child_ID SHA datetime message'.split())


class _ChangedFileQueue(_Table):

    def enqueue_valid_file_path(self, file_path, file_exists):
        sings = self._db.singleton_integer

        queue_head_ID = sings.file_queue_head_ID
        queue_tail_ID = sings.file_queue_tail_ID

        assert (all((queue_head_ID, queue_head_ID)) or
                not any((queue_head_ID, queue_tail_ID)))

        file_exists = 1 if file_exists else 0
        vals = None, file_path, file_exists, None
        my_ID = self._execute('INSERT INTO changed_file_queue '
                              'VALUES (?, ?, ?, ?)', vals).lastrowid

        if queue_tail_ID:
            # If I had someone in front of me, let them know I'm here
            self._execute('UPDATE changed_file_queue SET next_item_ID=? '
                          'WHERE item_ID=?', (my_ID, queue_tail_ID))
        else:
            # Otherwise, i'm first in line
            sings.set_file_queue_head_ID(my_ID)

        # No matter what, i'm last in line now
        sings.set_file_queue_tail_ID(my_ID)
        self._commit()

    def remove_item_from_head(self, rec):
        # == FROM abstracting queue logic would be great
        sings = self._db.singleton_integer
        next_ID = rec.next_item_ID

        self._execute(
            'DELETE FROM changed_file_queue WHERE item_ID=?', (rec.item_ID,))

        if next_ID:
            # If someone was in line after me, update the HEAD pointer
            sings.set_file_queue_head_ID(next_ID)
        else:
            # Otherwise, assert we were the last one
            assert 0 == self._count_the_table()
            sings.delete_existent_file_queue_head_and_tail()

        # (no commit till #commit1)

    @property
    def head_of_queue(self):
        oid = self._db.singleton_integer.file_queue_head_ID
        if oid is None:
            assert 0 == self._count_the_table()
            assert self._db.singleton_integer.file_queue_tail_ID is None
            return
        c = self._execute(
            'SELECT * FROM changed_file_queue WHERE item_ID=?', (oid,))
        row, = c
        return _ChangedFileRecord(*row)

    def has_file(self, file_path):
        c = self._execute('SELECT COUNT() FROM changed_file_queue '
                          'WHERE file_path = ?', (file_path,))
        (count,), = c
        assert count < 2
        return count

    def _count_the_table(self):
        c = self._execute('SELECT COUNT() FROM changed_file_queue')
        ((count,),) = c
        return count


_ChangedFileRecord = _nt(
    '_ChangedFileRecord',
    ('item_ID', 'file_path', 'does_exist', 'next_item_ID'))


class _NotecardTable(_Table):

    def touch_and_stale(self, eid):
        c = self._execute(
            'SELECT notecard_ID FROM notecard WHERE entity_identifier=?',
            (eid,))
        row = c.fetchone()
        assert c.fetchone() is None
        if row:
            oid, = row
            self._execute(
                'UPDATE notecard SET state="is_stale" WHERE notecard_ID=?',
                (oid,))
            num = 0
        else:
            self._execute(
                'INSERT INTO notecard VALUES (NULL, ?, "is_stale")', (eid,))
            num = 1
        # (no commit till #commit1)
        return num

    def update_to_be_not_stale(self, rec):
        c = self._execute(
            'UPDATE notecard SET state="is_prepared" WHERE notecard_ID=?',
            (rec.notecard_ID,))
        assert 1 == c.rowcount
        # (no commit till #commit2)

    def to_stale_notecards(self):
        # experiment in mutating a table while traversing lol
        c = self._execute('SELECT * from notecard WHERE state="is_stale" '
                          'ORDER BY entity_identifier DESC')
        for row in c:
            yield _NotecardRecord(*row)

    def via_OID(self, oid):
        c = self._execute('SELECT * FROM notecard WHERE notecard_ID=?', (oid,))
        row = c.fetchone()
        assert c.fetchone() is None
        return _NotecardRecord(*row)


_NotecardRecord = _nt(
    '_NotecardRecord', ('notecard_ID', 'entity_identifier', 'status'))


class _NotecardCommitTable(_Table):

    def notecard_CIs_for_commit(self, ci_ID):
        c = self._execute('SELECT * FROM notecard_commit WHERE '
                          'commit_ID=?', (ci_ID,))

        nc_table = self._db.notecard_table
        for row in c:
            oid, nc_ID, ci_ID, verb, num_lines_ins, num_lines_del, state = row
            nc = nc_table.via_OID(nc_ID)  # #no-object-mapper
            yield _NotecardCommitRecord_CUSTOM(
                oid, nc, ci_ID, verb, num_lines_ins, num_lines_del, state)

    def insert_notecard_commit(
            self, notecard_ID, commit_ID, verb,
            number_of_lines_inserted, number_of_lines_deleted):

        row = (None, notecard_ID, commit_ID, verb,
               number_of_lines_inserted, number_of_lines_deleted,
               'NC_STATE_NOT_USED')

        c = self._execute('INSERT INTO notecard_commit VALUES '
                          '(?, ?, ?, ?, ?, ?, ?)', row)

        # (no commit till #commit2)
        return c.lastrowid

    def change_the_verb_lol(self, nc_id):
        c = self._execute(
            'UPDATE notecard_commit SET verb="create_notecard" '
            'WHERE notecard_commit_ID=?', (nc_id,))
        assert 1 == c.rowcount
        # (no commit til #commit2)

    def lookup_by_two(self, nc_id, ci_id):
        c = self._execute('SELECT * from notecard_commit WHERE '
                          'notecard_ID=? and commit_ID=?', (nc_id, ci_id))
        # #todo: waiting for formal treatment of indexing
        row = c.fetchone()
        two = c.fetchone()
        assert two is None
        return row


_NotecardCommitRecord_CUSTOM = _nt(
    '_NotecardCommitRecord',
    ('notecard_commit_ID', 'notecard', 'commit_ID', 'verb_text_NOT_USED',
     'number_of_lines_inserted', 'number_of_lines_deleted', 'state_NOT_USED'))


class _NotecardBasedDocumentTable(_Table):

    def touch_via_head_EID(self, peid):
        row = self.get_via_document_head_EID(peid)
        if row:
            return self.record_via_row(row)
        return self.insert_NB_document(peid)

    def insert_NB_document(self, peid, vendor_document_title=None):
        if vendor_document_title is None:
            vendor_document_title = ''  # NOTE unique constraint will bite you

        c = self._execute('INSERT INTO notecard_based_document '
                          'VALUES (NULL, ?, ?)', (peid, vendor_document_title))
        self._commit()
        return self.record_via_row((c.lastrowid, peid, vendor_document_title))

    def get_via_document_head_EID(self, peid):
        c = self._execute('SELECT * from notecard_based_document '
                          'WHERE head_notecard_EID=?', (peid,))
        row = c.fetchone()
        if row is None:
            return
        assert c.fetchone() is None
        return self.record_via_row(row)  # #no-object-mapper

    def record_via_row(self, row):
        return _NotecardBasedDocumentRecord(*row)


_NotecardBasedDocumentRecord = _nt(
    '_NotecardBasedDocumentRecord',
    ('notecard_based_document_ID',
     'head_notecard_EID', 'document_title_from_vendor'))


class _NotecardBasedDocumentCommitTable(_Table):

    def touch_NBDC(self, NB_docu_ID, ci):
        ci_ID = ci.commit_ID
        c = self._execute('SELECT * FROM notecard_based_document_commit '
                          'WHERE notecard_based_document_ID=?  '
                          'AND commit_ID=?', (NB_docu_ID, ci_ID))
        row = c.fetchone()
        if row:
            assert c.fetchone() is None
            return False, self._via_row(row)

        """NORMALIZE datetime

        We want to store the commit datetime in a way that sqlite can work
        with with its datetime functions, so we're trying to follow [here][1]

        We're parsing the datetimes exactly as we got them from git-log, which
        formats them locale-specifically so this will break in production:
        The below is hard-coded to parse dates as git produces them in
        our locale, e.g.: 'Sun Feb 28 15:20:56 2021 -0500'

        Also we don't know how we want to handle timezone stuff so we're
        just throwing a string into a cell for now

        [1]: https://sqlite.org/quirks.html#no_separate_datetime_datatype
        """

        from datetime import datetime as lib
        dt = lib.strptime(ci.datetime, '%a %b %d %H:%M:%S %Y %z')
        norm_dt_s = dt.strftime('%Y-%m-%d %H:%M:%S')
        tzinfo = str(dt.tzinfo)

        row = [None, NB_docu_ID, ci_ID, norm_dt_s, tzinfo, 0, 0, 0]
        c = self._execute('INSERT INTO notecard_based_document_commit '
                          'VALUES (?, ?, ?, ?, ?, ?, ?, ?)', row)
        # (no commit till #commit3)
        row[0] = c.lastrowid
        return True, self.NBD_CI_via_row_(row)

    def NBD_CI_via_row_(self, row):
        return _NC_Based_Docu_CI_Record(*row)


_NC_Based_Docu_CI_Record = _nt(
    '_NC_Based_Docu_CI_Record',
    ('OID', 'notecard_based_document_ID', 'commit_ID',
     'normal_datetime', 'tzinfo',
     'number_of_lines_inserted', 'number_of_lines_deleted',
     'number_of_notecards'))


def _table(cls):  # #decorator
    def decorator(orig_f):
        def use_f(self):
            if attr not in self._memo:
                self._memo[attr] = cls(self)
            return self._memo[attr]
        attr = orig_f.__name__
        return property(use_f)
    return decorator


class Database_:
    def __init__(self, conn):
        self.conn = conn
        self._memo = {}

    def create_temporary_commit_table(self):
        self.commit_queue._create_table_()

    # ==

    @_table(_SingletonInteger)
    def singleton_integer(self):
        pass

    @_table(_SingletonText)
    def singleton_text(self):
        pass

    @_table(_TemporaryCommitQueue)
    def commit_queue(self):
        pass

    @_table(_CommitTable)
    def commit_table(self):
        pass

    @_table(_ChangedFileQueue)
    def changed_file_queue(self):
        pass

    @_table(_NotecardTable)
    def notecard_table(self):
        pass

    @_table(_NotecardCommitTable)
    def notecard_commit_table(self):
        pass

    @_table(_NotecardBasedDocumentTable)
    def notecard_based_document_table(self):
        pass

    @_table(_NotecardBasedDocumentCommitTable)
    def notecard_based_document_commit_table(self):
        pass


"""
:#no-object-mapper: maybe we are making the same record over and over
but meh. we don't have "object mapper" and it would be nontrivial
"""


def database_after_updating_schema_(coll_path, listener):

    db_path = _database_path_via_collection_path(coll_path)
    schema_path = _build_schema_path()

    from kiss_rdb.storage_adapters.sqlite3.connection_via_graph_viz_lines \
        import func

    with open(schema_path) as lines:
        db_conn = func(db_path, lines, listener)

    if not db_conn:
        return
    # from sqlite3 import Row
    # db_conn.row_factory = Row  # #todo this is cool but not used
    return Database_(db_conn)


def database_via_collection_path_(coll_path):
    """(Alternative to the above that skips the schema update)"""

    db_path = _database_path_via_collection_path(coll_path)
    from sqlite3 import connect  # meh. redundant w/ elsewhere
    return Database_(connect(db_path))


def _database_path_via_collection_path(coll_path):
    from os.path import join as _path_join
    return _path_join(coll_path, 'document-history-cache.sqlite3')


def _build_schema_path():
    from os.path import dirname as dn, join as _path_join
    mono_repo = dn(dn(dn(__file__)))
    return _path_join(
        mono_repo, 'pho-doc', 'documents', '429.4-document-history-schema.dot')


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
