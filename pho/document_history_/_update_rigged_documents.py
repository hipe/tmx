def _update_rigged_documents(db, bcoll, stop, listener):

    def main():
        if not we_have_latest_SHA_in_the_singleton_table():
            update_the_document_table()
            if any_are_missing():
                quit_with_who_is_missing()
            the_long_walk_back()

        scn = _scanner_via_iterator(rigged_docu_table.to_every_stale_record())
        if scn.empty:
            _say_no_stale_rigged_documents(listener)
            return

        create_temp_table()

        count = 0
        while scn.more:
            docu = scn.next()
            count += 1
            last_OID = fill_the_temp_stack(docu)
            n = flush_the_temp_stack(last_OID, docu)
            _say_updated_rigged_document(listener, n, docu)
        _say_updated_rigged_docs(listener, count)

        """
        ☝️ Update the audit trail for one rigged document in two passes:
        1) a backwards pass (load up a stack)
        2) a forwards pass (flush the stack into the table)

        Writing the items first to a stack (a temp table) and then popping
        each item off the stack has the effect of reversing the order of the
        items in a way that scales by utilizing the database rather than
        needing to load every item in to memory all at once. But why do we
        want to reverse the order of the items?

        `git log` flows in reverse chronological order: it starts and now
        and procedes backwards through time.

        But if we can process the items in *forwards* chronological order
        (with the oldest (more correctly "parentmost") unseen commits first),
        then, after processing each item, the database is still in a valid
        state in the same manner that it would be once we've processed the
        most recent item.

        This allows us to commit our transactions in smaller, more incremental
        steps, so that we don't fill up the transactional buffer as much and
        we get more saveable (data integral) work done mid-way through the
        traversal, so that we can save in progressive steps even when the
        inevitable mid-indexing error occurs.
        """

    def flush_the_temp_stack(temp_OID, docu):

        is_first_ever = docu.parentmost_rigged_document_commit_ID is None
        former_HEAD_ci_ID = docu.childmost_rigged_document_commit_ID
        docu_ID = docu.rigged_document_ID

        count = 0
        while temp_OID:
            count += 1

            # Pop the next item off the stack
            c = conn.execute(
                'SELECT * FROM temp.rigged_stack WHERE OID=?', (temp_OID,))
            _, sha, ndt, tzi, nli, nld, next_temp_OID = c.fetchone()
            conn.execute(
                'DELETE FROM temp.rigged_stack WHERE OID=?', (temp_OID,))

            # Create the commit
            c = conn.execute(
                'INSERT INTO rigged_document_commit '
                'VALUES (NULL, ?, ?, ?, ?, ?, ?, NULL)',
                (docu_ID, sha, ndt, tzi, nli, nld))

            # Maybe tell the parent this is its first ever child
            ci_ID = c.lastrowid
            if is_first_ever:
                is_first_ever = False
                conn.execute(
                    'UPDATE rigged_document '
                    'SET parentmost_rigged_document_commit_ID=? '
                    'WHERE rigged_document_ID=?', (ci_ID, docu_ID))

            # Always tell the parent this is its last child
            conn.execute(
                'UPDATE rigged_document '
                'SET childmost_rigged_document_commit_ID=? '
                'WHERE rigged_document_ID=?', (ci_ID, docu_ID))

            # Tell the one child who is its next
            if former_HEAD_ci_ID:
                conn.execute(
                    'UPDATE rigged_document_commit '
                    'SET next_ID=? '
                    'WHERE rigged_document_commit_ID=?',
                    (ci_ID, former_HEAD_ci_ID))

            former_HEAD_ci_ID = ci_ID

            conn.commit()  # whew!
            temp_OID = next_temp_OID

        # Once you've flushed the temp table of the zero or more commits,
        # change state (from 'stale' probably) to this
        conn.execute(
            'UPDATE rigged_document SET state="exists" '
            'WHERE rigged_document_ID=?', (docu_ID,))
        conn.commit()
        return count

    def fill_the_temp_stack(docu):

        # Immutables used in iteration
        from ._common import normalize_datetime_from_git_ as norm_dt_via

        # Args for call then call
        any_stop_SHA = None
        rdci_ID = docu.childmost_rigged_document_commit_ID
        if rdci_ID:
            c = conn.execute(
                'SELECT SHA from rigged_document_commit '
                'WHERE rigged_document_commit_ID=?', (rdci_ID,))
            ((any_stop_SHA,),) = c
        rootie = produce_rootie()

        cmd = 'git', 'log', '--numstat', '--follow', '--', docu.file_path
        itr = git_log_numstat(rootie, any_stop_SHA, cmd)
        next(itr)  # #HERE1 we don't use the proc, no terminate early

        last = 0  # just because NOT NULL constraint but be careful
        for ci in itr:
            norm_dt, tzinfo = norm_dt_via(ci.header.datetime_string)

            # (because we did --follow, we only one file path record?
            #  what about a rename commit? we'll see..)

            fpr, = ci.file_path_records
            num_lines_ins = fpr.before_num_lines or 0
            num_lines_del = fpr.after_num_lines or 0  # null if binary

            c = conn.execute(
                'INSERT INTO temp.rigged_stack VALUES '
                '(NULL, ?, ?, ?, ?, ?, ?)',
                (ci.SHA, norm_dt, tzinfo, num_lines_ins, num_lines_del, last))
            last = c.lastrowid
            conn.commit()
        return last

    def create_temp_table():
        conn.execute(
            'CREATE TEMPORARY TABLE rigged_stack( '
            'OID INTEGER PRIMARY KEY, '
            'SHA TEXT NOT NULL, '
            'normal_datetime TEXT NOT NULL, '
            'tzinfo TEXT NOT NULL, '
            'number_of_lines_inserted INTEGER NOT NULL, '
            'number_of_lines_deleted INTEGER NOT NULL, '
            'next_ID INTEGER NOT NULL)')

    def the_long_walk_back():
        """For each commit we walk backwards over (on a fresh database, we
        walk over EVERY commit EVER), for each file path mentioned in the
        commit (some may be no longer there), if it's in our hash of every
        path to a rigged document (in VCS HEAD), add to another hash (the
        "stale" hash) that path (maybe redundantly). Once we get either to
        the first commit ever or the last known HEAD, 1) flag all those in
        the hash as stale, 2) update last known HEAD 3) commit. woot!
        """

        leng, rows = every_mentioned_document_file_path_in_the_long_walk()
        if leng:
            conn.executemany(
                'UPDATE rigged_document SET state="stale" '
                'WHERE file_path=?', rows)  # #here3

        singleton_text.set_no_commit(_last_indexed_SHA_key, self.next_last_SHA)
        conn.commit()

    def every_mentioned_document_file_path_in_the_long_walk():
        stale_hash = {}
        c = conn.execute('SELECT file_path FROM rigged_document')
        # (state is either 'exists', 'added' or 'stale' per `any_are_missing`)

        docu_paths = {fp: True for (fp,) in c}  # fill memory #here2

        scn = self.scn
        del self.scn

        self.next_last_SHA = scn.peek.SHA

        num_commits = num_ci_files = 0

        while scn.more:
            real_ci = scn.next()
            num_commits += 1
            for file_path in real_ci.file_paths:
                num_ci_files += 1
                if docu_paths.get(file_path):
                    stale_hash[file_path] = None

        _say_long_walk(listener, len(stale_hash), num_ci_files, num_commits)
        return len(stale_hash), ((k,) for k in stale_hash.keys())  # #here3

    def any_are_missing():
        c = conn.execute('SELECT * FROM rigged_document WHERE state="missing"')
        first_row = c.fetchone()
        if first_row is None:
            return False

        def rows_missing():
            yield first_row
            for row in c:
                yield row
        self.rows_missing = rows_missing()
        return True

    def quit_with_who_is_missing():
        rec_via = rigged_docu_table.record_via_row
        recs = (rec_via(row) for row in self.rows_missing)
        _say_who_is_missing(listener, recs)
        raise stop()

    def update_the_document_table():
        ncs = to_EVERY_PARTICIPATING_document_head_notecard()
        pool = {nc.heading: nc for nc in ncs}

        num_OK = num_added = 0

        # For each record currently in the table
        for rec in rigged_docu_table.to_EVERY_record():
            vtitle = rec.document_title_from_vendor
            state = rec.state

            # If the KISS collection has a document by this title
            if pool.pop(vtitle, False):

                # Make sure the state is one of these (idk..)
                if state not in ('exists', 'stale', 'added'):
                    xx(f'oopsie: {state!r}')
                num_OK += 1
            else:

                # Otherwise flag it as missing
                if 'missing' != state:
                    c = conn.execute(
                        'UPDATE rigged_document SET state="missing" '
                        'WHERE document_title_from_vendor=?', (vtitle,))
                    c.commit()

        if pool:
            rootie = produce_rootie()
            rootie_length = len(rootie)
            rootie_length_plus_one = rootie_length + 1

        # Whatever is left in the pool, populate the database with it
        for vtitle, nc in pool.items():
            doc_abspath = bcoll.call_value_function_(
                nc.body_function, nc, listener, just_path=True)
            act = doc_abspath[:rootie_length]
            if rootie != act:
                xx(f"not inside repository? {doc_abspath!r}")
            file_path = doc_abspath[rootie_length_plus_one:]
            row_middle = nc.heading, file_path
            conn.execute(
                'INSERT INTO rigged_document VALUES '
                '(NULL, ?, ?, "added", NULL, NULL)', row_middle)
            conn.commit()
            num_added += 1

        _say_num_OK_num_added(listener, num_OK, num_added)

    def produce_rootie():
        if self.rootie is None:
            self.rootie = determine_rootie()
        return self.rootie

    def determine_rootie():
        from ._common import open_git_subprocess_ as func
        itr = func(('rev-parse', '--show-toplevel'), cwd=coll_path)
        proc = next(itr)
        k, v = next(itr)
        assert 'sout' == k
        k, _ = next(itr)
        assert 'done' == k
        proc.terminate()
        assert 0 == proc.returncode
        return v[:-1]

    def to_EVERY_PARTICIPATING_document_head_notecard():

        from re import compile
        rx = compile(r'^get_body_from_document\b')

        from pho.notecards_.notecard_via_definition import \
            notecard_via_definition as notecard_via
        with bcoll.KISS_COLLECTION_.open_entity_traversal(listener) as ents:
            for ent in ents:
                eid = ent.identifier.to_string()
                nc = notecard_via(eid, ent.core_attributes, listener)
                if 'document' != nc.hierarchical_container_type:
                    continue
                bf = nc.body_function
                if bf is None:
                    continue
                if not rx.match(bf):
                    continue
                yield nc

    def we_have_latest_SHA_in_the_singleton_table():

        any_stop_SHA = singleton_text.get(_last_indexed_SHA_key)

        func = git_log_numstat
        itr = func(coll_path, any_stop_SHA, ('git', 'log', '--numstat'))
        next(itr)  # #HERE1 we don't hold on to the proc

        # If real HEAD was the stop HEAD, scanner is empty
        scn = _scanner_via_iterator(itr)
        if scn.empty:
            return True

        self.scn = scn
        return False

    self = main  # #watch-the-world-burn
    self.rootie = None

    singleton_text = db.singleton_text
    rigged_docu_table = db.rigged_document_table

    conn = db.conn

    coll_path = bcoll.KISS_COLLECTION_.mixed_collection_identifier

    from ._common import GIT_LOG_NUMSTAT_ as git_log_numstat

    return main()


func = _update_rigged_documents


def _say_updated_rigged_docs(listener, count):
    def lines():
        yield f"updated {count} rigged document(s)"
    listener('info', 'expression', 'tally', 'updated_rigged_documents', lines)


def _say_updated_rigged_document(listener, n, docu):
    def lines():
        yield "updated with %2d commit(s): %s" % (n, docu.file_path)
    listener('info', 'expression', 'tally', 'updated_rigged_document', lines)


def _say_no_stale_rigged_documents(listener):
    def lines(): return ("All rigged documents (already) up-to-date",)
    listener('info', 'expression', 'tally', 'rigged_already_up_to_date', lines)


def _say_long_walk(listener, num_stale, num_ci_files, num_CIs):
    def lines():
        yield (f"found {num_stale} document(s) to stale among "
               f"{num_ci_files} file mention(s) in {num_CIs} commit(s)")
    listener('info', 'expression', 'tally', 'long_walk_numbers', lines)


def _say_who_is_missing(listener, recs):

    first_few = [next(recs)]
    the_rest = None
    for second in recs:
        first_few.append(second)
        for third in recs:
            first_few.append(third)
            the_rest = tuple(recs)  # migtht fill mem with 97 docs meh #here2
            break
        break

    def lines():
        yield "ERROR: This/these documents moved:"
        for rec in first_few:
            yield ' '.join(('-', rec.file_path))
        if the_rest:
            yield ''.join(('- (', len(the_rest), ' more)'))
        yield "For now, please address this manually in the database"
        yield "(or blow it all awayor whatever)"

    listener('error', 'expression', 'documents_have_moved', lines)


def _say_num_OK_num_added(listener, num_OK, num_added):
    def lines():
        pcs = []
        if 0 < num_OK:
            pcs.append(f"{num_OK} existing rigged docu(s)")

        if 0 < num_added:
            pcs.append(f"{num_added} rigged docu(s) added")

        if 0 == len(pcs):
            pcs.append("no rigged docus added or existing??")

        yield ' '.join(pcs)

    listener('info', 'expression', 'tally', 'num_rigged_added', lines)


_last_indexed_SHA_key = 'last_indexed_SHA_for_rigged'


def _scanner_via_iterator(itr):
    assert hasattr(itr, '__next__')
    from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    return func(itr)


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
