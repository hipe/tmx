"""(based entirely on the pseudocode in [#429.3])"""


from dataclasses import dataclass as _dataclass


def do_them_stats(coll_path, listener, dry_run=False):

    # Do the query
    db = _database_via_collection_path(coll_path, listener)
    c = db.conn.execute(
        'SELECT number_of_lines_inserted + number_of_lines_deleted '
        'FROM notecard_based_document_commit')

    def only_value(row):
        ocd, = row
        return ocd

    # Calculate them (bruskly for now)
    nums = tuple((only_value(row) for row in c))
    from numpy import std as std_via, mean as mean_via
    mean = mean_via(nums)
    std = std_via(nums)

    # Read existing
    table = db.singleton_text
    k = 'mean_and_std'
    one_string_before = table.get(k)
    one_string_now = ' '.join((str(mean), str(std)))

    # Expresss
    def lines():
        if one_string_before:
            use = one_string_before
        else:
            use = '(none)'
        yield f"Mean and standard deviation before: {use}"
        yield f"Mean and standard deviation now:    {one_string_now}"
    listener('info', 'expression', 'mean_and_std', lines)

    # Maybe save
    if dry_run:
        return
    if one_string_before:
        table.update(k, one_string_now)
        verb = 'updated'
    else:
        table.insert(k, one_string_now)
        verb = 'inserted'

    listener('info', 'expression', 'stored', lambda: (f"({verb} values)",))


def update_document_history(coll_path, listener):
    try:
        return _main(coll_path, listener)
    except _Stop:
        pass


func = update_document_history


def _main(coll_path, listener):

    db = _database_via_collection_path(coll_path, listener)

    # First pass: load changed file queue from any new commits from HEAD
    num = _populate_temporary_table(db, coll_path, listener)
    _say_number_of_new_commits(listener, num)

    if num:
        # If there were some, add files to the files queue
        num = _transfer_from_temp_table_to_changed_file_queue(db, listener)
        _say_number_of_new_changed_files(listener, num)

    # Second pass: touch and stale notecard records from changed file queue
    from modality_agnostic import ModalityAgnosticErrorMonitor as cls
    mon = cls(listener)
    bcoll = _resolve_business_collection(coll_path, listener)
    nnn, nn, n = _index_each_file_that_changed(db, bcoll, mon)
    _say_number_of_entities_to_audit(listener, nnn, nn, n)

    # Third pass: run the audit trail on each stale notecard
    nn, n = _run_the_audit_trail_on_each_stale_notecard(db, bcoll, mon)
    _say_num_entity_edits(listener, nn, n)

    # Fourth pass: populate document & document ci tables via unseen commits
    nnn, nn, n = _update_document_commit_table(bcoll, db, listener)
    _say_document_commits(listener, nnn, nn, n)


# === The Four or so Big Passes in the Algorithm ===

# == Fourth pass: populate document & document commit tables via unseen commits

def _update_document_commit_table(bcoll, db, listener):

    # Do the set MINUS operation to know all commit IDs not in this one table
    execute, commit = (getattr(db.conn, k) for k in ('execute', 'commit'))
    c = execute(
        'SELECT commit_ID from "commit" EXCEPT '
        'SELECT DISTINCT commit_ID FROM notecard_based_document_commit '
        'ORDER BY commit_ID')  # (ordering just so errors replay consistently)

    # If there are no commits not already in this one table, you're done
    scn = _scanner_via_iterator(c)
    if scn.empty:
        return 0, 0, 0

    set_of_seen_docu_heads = set()

    from pho.notecards_.abstract_document_via_notecards import \
        find_document_root_node

    execute('CREATE TEMPORARY TABLE notecard_parent ('
            'notecard_ID integer unique, '
            'notecard_based_document_ID integer not null)')

    def touch_the_associated_document(nc):
        # notecards are one-to-many to documents so maybe we saw it already
        # #no-object-mapper
        # peid = parent entity identifier (document head EID)

        # Do the vendor lookup to determine peid (imagine it's expensive)
        doc_head_notecard = find_document_root_node(
                nc.entity_identifier, bcoll, listener)  # :#here4
        if doc_head_notecard:
            peid = doc_head_notecard.identifier_string
            set_of_seen_docu_heads.add(peid)
        else:
            # If notecard is not part of a document do #hack10 for explained
            peid = '222'  # the number zero, in kiss-code

        # If we already had one in the table, use that
        docu_rec = NB_docu_table.get_via_document_head_EID(peid)
        if docu_rec:
            return docu_rec

        # Since we don't have one, do more work to determine the title

        # (How the SSG vendor adapter comes up with a title is … complicated
        # but, pray that this simple way keeps working while it's working)

        use_title = doc_head_notecard.heading
        assert use_title

        return NB_docu_table.insert_NB_document(peid, use_title)

    def document_via_notecard(nc):

        # If you already have an entry in the temp table, join it and done
        c = execute('SELECT nbd.* from notecard_based_document AS nbd '
                    'JOIN temp.notecard_parent '
                    'USING (notecard_based_document_ID) '
                    'WHERE notecard_parent.notecard_ID=?', (nc.notecard_ID,))
        row = c.fetchone()
        assert c.fetchone() is None
        if row:
            return NB_docu_table.record_via_row(row)
            # #no-object-mapper

        docu_rec = touch_the_associated_document(nc)
        NB_doc_ID = docu_rec.notecard_based_document_ID

        # Now add the relationship to the temp table so we find it subsequently
        execute('INSERT INTO temp.notecard_parent '
                'VALUES (?, ?)', (nc.notecard_ID, NB_doc_ID))
        commit()
        return docu_rec

    NB_docu_table = db.notecard_based_document_table
    NB_docu_ci_table = db.notecard_based_document_commit_table

    num_ci = num_d_ci = 0
    notecard_ci_table = db.notecard_commit_table
    ci_table = db.commit_table

    while True:
        ci_ID, = scn.peek
        ci = ci_table.via_OID(ci_ID)
        num_ci += 1

        # HERE IS THE CENTER OF THE WORLD: for every notecard commit,
        # touch the corresponding document commit and add in to it

        # Do the work of touching documents (& committing) up front b.c we can
        def these():
            for nc_ci in notecard_ci_table.notecard_CIs_for_commit(ci_ID):
                NB_docu = document_via_notecard(nc_ci.notecard)
                yield NB_docu, nc_ci
        these = tuple(these())

        # If there are no notecard commits to this commit, #hack10 the answers
        # so we get the commit out of those EXCEPT results
        if 0 == len(these):
            NB_docu = NB_docu_table.touch_via_head_EID('222')
            these = ((NB_docu, None),)

        # imagine BEGIN a transaction:
        for NB_docu, nc_ci in these:

            # Touch the final target product record
            did_create, docu_ci = NB_docu_ci_table.touch_NBDC(
                NB_docu.notecard_based_document_ID, ci)
            if did_create:
                num_d_ci += 1
            # (no commit till #commit3)

            if '222' == NB_docu.head_notecard_EID:
                continue  # don't do stats on the dummy #hack10

            kw = {}
            for k in ('number_of_lines_inserted', 'number_of_lines_deleted'):
                existing = getattr(docu_ci, k)
                add_me = getattr(nc_ci, k)
                kw[k] = existing + add_me
            kw['number_of_notecards'] = docu_ci.number_of_notecards + 1

            execute('UPDATE notecard_based_document_commit SET '
                    'number_of_lines_inserted=?, number_of_lines_deleted=?, '
                    'number_of_notecards=? '
                    'WHERE notecard_based_document_commit_ID=?',
                    (*kw.values(), docu_ci.OID))  # YIKES
            # (no commit till #commit3)

        # This is key: don't commit the transaction until ALL notecard commits
        # have been tallied up for this commit, so the EXCEPT sql above is
        # accurate and does not reflect incomplete work #commit3
        commit()
        scn.advance()
        if scn.empty:
            break
    return num_d_ci, len(set_of_seen_docu_heads), num_ci


# == Third pass: run the audit trail on each stale notecard

def _run_the_audit_trail_on_each_stale_notecard(db, bcoll, mon):
    num_edits = num_notecards = 0
    run_the_audit_trail = _build_the_big_audit_trail_function(db, bcoll, mon)
    notecard_table = db.notecard_table
    listener = mon.listener

    # Experiment in mutating a table while traversing it lol
    for rec in notecard_table.to_stale_notecards():
        _say_doing_audit_trail(listener, rec)
        num_notecards += 1
        num_edits += run_the_audit_trail(rec)
        notecard_table.update_to_be_not_stale(rec)
        db.conn.commit()  # :#commit2

    return num_edits, num_notecards


def _build_the_big_audit_trail_function(db, bcoll, mon):

    def run_the_audit_trail(notecard_rec):
        num_edits = 0
        notecard_ID = notecard_rec.notecard_ID
        itr = vendor_audit_trail(notecard_rec.entity_identifier, mon)

        # First item is always the snapshot of the entity at HEAD
        typ, _ess = next(itr)
        assert 'entity_snapshot' == typ

        for typ, ee_ast in itr:

            # Second and every subsequent (2*N) is the interesting one
            assert 'entity_edit' == typ

            # Skip every subsequent entity snapshot (including the oldest one)
            typ, _ess = next(itr)
            assert 'entity_snapshot' == typ
            del _ess

            # Retrieve the existing real commit
            hh_AST = ee_ast.hunk_header_AST
            SHA = hh_AST.git_patch_header.SHA
            ci_rec = commit_table.get_commit_via_SHA(SHA)

            # == BEGIN hotfix
            #    The initial `git-log` won't catch changes from when the
            #    notecards directory had existed somewhere else, but
            #    `git-log --follow` for the audit trail *does*, so the latter
            #    can have commits the former doesn't know about. This
            #    introduces data holes for those commits we insert here
            #    (they won't know their pevious and next) but meh
            if ci_rec:
                ci_ID = ci_rec.commit_ID
                del ci_rec
            else:
                msg_ind = ''.join(hh_AST.message_lines)
                ci_ID = commit_table.insert_commit(
                    hh_AST.SHA, hh_AST.datetime_string, msg_ind)
            # == END

            # (we could confirm our re-parse of the hunk header but why)

            # See if we have created a notecard commit for it already
            nc_tup = nc_table.lookup_by_two(notecard_ID, ci_ID)
            if nc_tup:
                last_rowid = None
                print("STRANGE: already seen this edit in the audit trail")
                continue

            # Count up the inserts/deletes
            num_rem = num_ins = 0
            for typ, line in ee_ast.hunk.hunk_body_line_sexps:
                if 'context_line' == typ:
                    continue
                if 'insert_line' == typ:
                    num_ins += 1
                    continue
                assert 'remove_line' == typ
                num_rem += 1

            last_rowid = nc_table.insert_notecard_commit(
                notecard_ID=notecard_ID,
                commit_ID=ci_ID,
                verb='edit_notecard',
                number_of_lines_inserted=num_ins,
                number_of_lines_deleted=num_rem)

            # (no commit of above til #commit2)
            num_edits += 1

        if last_rowid:
            nc_table.change_the_verb_lol(last_rowid)
            # (there might be a better way)

        return num_edits

    commit_table = db.commit_table
    nc_table = db.notecard_commit_table

    vendor_audit_trail = \
        bcoll.KISS_COLLECTION_.custom_functions.AUDIT_TRAIL_FOR
    return run_the_audit_trail


# == Second pass: touch and stale notecard records

def _index_each_file_that_changed(db, bcoll, mon):
    num_ents_staled = num_ents_created = file_count = 0
    queue_table = db.changed_file_queue
    process_file = _build_touch_and_stale_notecards_via_file(db, bcoll, mon)

    while True:
        rec = queue_table.head_of_queue
        if rec is None:
            break
        if not rec.does_exist:
            _say_skipped_noent_file(mon.listener, rec.file_path)
            queue_table.remove_item_from_head(rec)
            continue
        num_staled, num_created = process_file(rec.file_path)
        num_ents_staled += num_staled
        num_ents_created += num_created
        file_count += 1
        queue_table.remove_item_from_head(rec)
        db.conn.commit()  # :#commit1
    return num_ents_staled, num_ents_created, file_count


def _build_touch_and_stale_notecards_via_file(db, bcoll, mon):

    def touch_and_stale_notecards_in_file(path):
        num_entities_staled = num_entities_created = 0
        caching_file_reader = fsr.PRODUCE_FILE_READER_FOR_PATH(path, mon)
        eids = caching_file_reader.to_EIDs_in_file()
        for eid in eids:
            num = notecard_table.touch_and_stale(eid)
            num_entities_created += num
            num_entities_staled += 1
        return num_entities_staled, num_entities_created

    notecard_table = db.notecard_table
    coll = bcoll.KISS_COLLECTION_
    fsr = coll.custom_functions.PRODUCE_FILESYSTEM_READER()
    return touch_and_stale_notecards_in_file


# == First pass: populate the changed files queue (and commits table)

def _transfer_from_temp_table_to_changed_file_queue(db, listener):
    """Assume there is one or more items in the temporary commit table.
    The objective is to have the `change_file_queue` and the `commit` table
    fully populated with the data in the temporary table, and the temp table
    empty.

    For each item from parent-most commit first up to new HEAD,
    1. For each of the paths in the commit, insert into the change file
       queue table the zero or more paths of it that are not already there.
       (It's to be expected to see the same paths over and over redundantly
       over time in any timeline.) For each new path, determine whether it
       exists now, and include that boolean in the insertion.
       Now there's queue logic too.
    2. If you were passed a `parent_SHA`, assume (because of everything)
       it already exists in the `commit` table; so look it up to get its
       primary key.
    3. In a single transaction:
       1. Insert an appropriate record in the `commit` table, one which
          points back to its parent with the correct ID (that we grabbed
          above) for all but the first record inserted in to this table.
          (We must leave its `child_ID` cell NULL, even though we may
          know the SHA there #here3)
       2. Again for all but the first ever record, we want to tell this
          new commit's parent about its only child; so update *that* record
          with the new `oid` you just got from this last insert
       3. Remove the record from the temporary commit table
       4. Update singleton text table to have this new HEAD
    """

    sings = db.singleton_text
    temp_table = db.commit_queue
    commit_table = db.commit_table
    queue_table = db.changed_file_queue

    from os.path import exists as path_exists

    temp_rec = temp_table.read_next_temp_commit()
    tot = 0
    while True:
        count = 0
        file_paths = temp_rec.file_paths.split('\n')  # #here2
        for file_path in file_paths:
            yn = queue_table.has_file(file_path)
            if yn:
                continue
            count += 1
            yn = path_exists(file_path)
            queue_table.enqueue_valid_file_path(file_path, yn)

        tot += count

        _say_zub_zub(listener, count, temp_rec)

        # (each iteration of the above loop committed.)
        # == (image BEGIN) ==

        parent_ID = None
        parent_SHA = temp_rec.parent_SHA
        LNHS = sings.any_last_known_HEAD_SHA

        assert (all((parent_SHA, LNHS)) or
                not any((parent_SHA, LNHS)))

        if parent_SHA:
            assert LNHS == parent_SHA
            parent_ID = commit_table.ID_via_SHA(parent_SHA)
        new_ID = commit_table.accept_commit(temp_rec, parent_ID)

        if parent_SHA:
            commit_table.tell_parent_about_child(parent_ID, new_ID)

        wat = temp_table.delete_temp_record(temp_rec)
        type(wat)

        sings.set_last_known_HEAD_SHA(temp_rec.SHA)

        db.conn.commit()

        # == (imagine COMMIT) ==

        temp_rec = temp_table.read_next_temp_commit()
        if temp_rec is None:
            break
    return tot


def _populate_temporary_table(db, coll_path, listener):
    """For a "normal" traversal of three or more new commits that need to be
    indexed (probably not normal IRL), we implement a 3-element rotating
    buffer consisting of variables named (PARENT, FOCUS, CHILD).

    (It turns out this was overkill (#here3): having two-way links isn't
    helpful when we're building a queue. But it's a cheap mistake.
    Also maybe one day it would help troubleshooting.)

    At each step, we insert FOCUS while telling it who its PARENT and
    CHILD are. After each step, we shift the values over on all the variables
    to each other appropriately. Special handling for the first item and the
    last and all the edge cases.

    At the end we have all the unseen commits in the temporary table,
    knowing who their parent SHA and child SHA is.
    """

    HEAD_SHA = db.singleton_text.any_last_known_HEAD_SHA
    proc, scn = _scanner_of_commits_not_in_the_commits_table(
        HEAD_SHA, coll_path)

    def return_this(num):
        proc.terminate()  # don't keep child process open this whole time
        return num

    # If no new commits between here and previous HEAD, you're done
    if scn.empty:
        return return_this(0)

    # Since at least one new commit, create temporary commit table
    db.create_temporary_commit_table()

    def insert_commit(ci, parent=None, child=None):
        db.commit_queue.insert_commit(ci, parent_SHA=parent, child_SHA=child)

    # If there was only one new commit between here and previous HEAD,
    # put this one commit in the temp table and tell it who its parent is
    child = scn.next()
    if scn.empty:
        insert_commit(child, parent=HEAD_SHA)
        return return_this(1)

    # Since there's at least two new commits, `child` will be the only one
    # with no child of its own (new HEAD). Insert child with parent of focus
    focus = scn.next()
    insert_commit(child, parent=focus.SHA)

    if scn.empty:
        # Since only two new commits, insert focus with child
        # and parent of any previous HEAD
        ch_SHA = child.SHA
        insert_commit(focus, child=ch_SHA, parent=HEAD_SHA)
        return return_this(2)

    # Since there's more than two we can do the "normal" loop
    count = 2
    while True:
        count += 1
        parent = scn.next()
        ch_SHA = child.SHA
        pa_SHA = parent.SHA
        insert_commit(focus, child=ch_SHA, parent=pa_SHA)
        if scn.empty:
            break
        child = focus
        focus = parent

    # Insert parent with focus as child and parent as any previous head
    ch_SHA = focus.SHA
    insert_commit(parent, child=ch_SHA, parent=HEAD_SHA)
    return return_this(count)





# == Git Layer

def _lazy(orig_f):  # #[#510.4]
    def use_f():
        if not hasattr(use_f, 'x'):
            use_f.x = orig_f()
        return use_f.x
    return use_f


def _scanner_of_commits_not_in_the_commits_table(HEAD_SHA, coll_path):
    itr = _commits_not_in_the_commits_table(HEAD_SHA, coll_path)
    proc = next(itr)  # #here1
    scn = _scanner_via_iterator(itr)
    return proc, scn


def _commits_not_in_the_commits_table(HEAD_SHA, coll_path):

    # Start the git-log subprocess
    sout_lines = _STDOUT_lines_via_git_subprocess(
        ('log', '--numstat', '--', 'entities'), cwd=coll_path)
    # #open #todo we need to normalize datetime format

    yield next(sout_lines)  # #here1

    # There should always be at least one commit in the git log
    scn = _scanner_via_iterator(sout_lines)
    assert scn.more

    # Here is how we determine when to stop walking the git log
    if HEAD_SHA is None:
        def this_commit_is_already_in_the_commit_table():
            return False
    else:
        def this_commit_is_already_in_the_commit_table():
            assert HEAD_SHA_leng == len(hdr.SHA)  # every time meh
            return HEAD_SHA == hdr.SHA
        HEAD_SHA_leng = len(HEAD_SHA)

    # Here is how we parse out the file paths (will happen 2x meh #here2)
    import re as _re
    rx = _re.compile(r"""
        (?P<before_num_lines>\d+)
        \t
        (?P<after_num_lines>\d+)
        \t
        (?P<file_path>\S+)
        \n\Z
    """, _re.VERBOSE)

    def parse_file_paths():
        assert scn.more
        md = rx.match(scn.peek)
        assert md
        yield md['file_path']
        while True:
            scn.advance()

            # The only time you get to an empty scanner is when you've just
            # finished parsing the parent-most commit ever in git-log
            if scn.empty:
                break

            # If it matches another file, this is normal
            md = rx.match(scn.peek)
            if md:
                yield md['file_path']
                continue

            # Otherwise, it must be a separator between this commit and the
            # next one:
            assert '\n' == scn.peek
            scn.advance()
            break

    # Money
    parse_header_lines = _produce_git_patch_header_parser()
    while scn.more:
        hdr = parse_header_lines(scn)
        yn = this_commit_is_already_in_the_commit_table()
        if yn:
            break
        file_paths = tuple(parse_file_paths())
        yield _RealCommit(hdr, file_paths)


@_dataclass
class _RealCommit:
    header: object
    file_paths: tuple

    @property
    def SHA(self):
        return self.header.SHA


@_lazy
def _produce_git_patch_header_parser():
    from text_lib.diff_and_patch.parse import \
        produce_git_patch_header_parser as func
    return func()


def _STDOUT_lines_via_git_subprocess(cmd_tail, cwd=None):
    itr = _open_git_subprocess(cmd_tail, cwd)
    yield next(itr)  # #here1

    for typ, val in itr:
        if 'sout' == typ:
            yield val
            continue

        if 'serr' == typ:
            xx(f"Oops handle failure here: {val!r}")

        assert 'done' == typ
        break


def _open_git_subprocess(cmd_tail, cwd=None):
    # (this is supposed to be in [kiss] but we hack some things)

    cmd = 'git', *cmd_tail
    with _open_subprocess(cmd, cwd=cwd) as proc:

        yield proc  # #here1

        for line in proc.stdout:
            yield 'sout', line

        for line in proc.stderr:
            yield 'serr', line

        yield 'done', None


# == Whiners and related

def _say_document_commits(listener, num_d_ci, num_d, num_ci):
    def lines():
        if 0 == num_ci:
            yield "All commits already reflected in document commits table"
            return
        yield (f"{num_ci} new commit(s) turned in to {num_d_ci} "
               f"document commit(s) across {num_d} document(s)")
    listener('info', 'expression', 'tally', 'num_doohas', lines)


def _say_num_entity_edits(listener, nn, n):
    def lines():
        yield f"{nn} edit(s) on {n} notecard(s) added to database"
    listener('info', 'expression', 'tally', 'num_notecard_edits', lines)


def _say_doing_audit_trail(listener, rec):
    def lines():
        yield f"Running audit trail on {eid}"
    eid = rec.entity_identifier
    listener('verbose', 'expression', 'about_to_run_audit_trail', lines)


def _say_number_of_entities_to_audit(listener, nnn, nn, n):
    def lines():
        yield f"{nnn} entit{{y|ies}} staled ({n} created) in {n} file(s)"
    listener('info', 'expression', 'tally', 'num_ents_to_audit', lines)


def _say_skipped_noent_file(listener, file_path):
    def lines(): return f'skipping because file not exist: {file_path}'
    listener('info', 'expression', 'skipping_no_ent_file', lines)


def _say_zub_zub(listener, count, temp_rec):
    def lines():
        dt = temp_rec.datetime
        yield f"{count} new changed file(s) from {temp_rec.SHA[:16]} {dt}"
    listener('info', 'expression', 'tally', 'num_new_changed_files', lines)


def _say_number_of_new_changed_files(listener, num):
    def lines():
        if 0 == num:
            yield "No new changed files to index"
            return
        yield f"{num} new changed files(s) to index"
    listener('info', 'expression', 'tally', 'total_new_changed_files', lines)


def _say_number_of_new_commits(listener, num):
    def lines():
        if 0 == num:
            yield "No new commits to index, commit table up-to-date"
            return
        yield f"{num} new commit(s) to index"
    listener('info', 'expression', 'tally', 'num_new_commits', lines)


# == Support and smalls

def _resolve_business_collection(coll_path, listener):
    from pho import read_only_business_collection_via_path_ as func
    # (read-only is especially important for #here4)

    bcoll = func(coll_path, listener)
    if bcoll:
        return bcoll
    raise _Stop()


def _database_via_collection_path(coll_path, listener):
    from ._model import database_after_updating_schema_ as func
    db = func(coll_path, listener)
    if db is None:
        raise _Stop()
    return db


def _open_subprocess(cmd, cwd=None):  # c/p
    import subprocess as sp
    return sp.Popen(
        args=cmd, stdin=sp.DEVNULL, stdout=sp.PIPE, stderr=sp.PIPE,
        text=True,  # don't give me binary, give me utf-8 strings
        cwd=cwd)  # None means pwd


def _scanner_via_iterator(itr):
    assert hasattr(itr, '__next__')
    return _scanner_via_iterator_function()(itr)


@_lazy
def _scanner_via_iterator_function():
    from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    return func


class _Stop(RuntimeError):
    pass


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
