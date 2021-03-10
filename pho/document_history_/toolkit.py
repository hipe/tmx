def cli_for_production():
    from sys import stdout, stderr, argv
    exit(CLI(None, stdout, stderr, argv))


def _commands():
    yield 'docu-hist', lambda: _command_zizzy


def CLI(sin, sout, serr, argv):
    """
    A custom client for developing with and troubleshooting the data we
    have in the database about document history.

    (We want this tooling to stay close to the API functions we expose for
    clients.)
    """

    from script_lib.cheap_arg_parse import prepare_tail_call_for_branch as func
    func_argv, rc = func(serr, argv, _commands(), lambda: CLI.__doc__)
    if not func_argv:
        return rc
    func, ch_argv = func_argv
    efx = _ExternalFunctions(serr)
    return func(sin, sout, serr, ch_argv, efx)


def _formals_for_zizzy(efx):
    yield '-l', '--list', 'ignore <title>, list titles in some rando order'
    yield _formal_option_for_help
    yield _formal_argument_for_collection_path
    yield '<title>', 'Shoop eye oop'


def _command_zizzy(sin, sout, serr, argv, efx):
    """ See things for the document indicated by <title> """

    def docer(): return _command_zizzy.__doc__
    defns = _formals_for_zizzy(efx)

    from script_lib.cheap_arg_parse import \
        prepare_tail_call_for_terminal as func

    fv, rc = func(serr, argv, defns, docer)
    if fv is None:
        return rc
    _foz, vals = fv

    coll_path = vals.pop(_coll_path_key)
    doc_title = vals.pop('title')
    do_list = vals.pop('list', False)
    assert not vals

    # mon = efx.produce_monitor()
    # listener = mon.listener

    stato = statistitican_via_collection_path(coll_path)

    if do_list:
        c = stato.db.conn.execute(
            'SELECT '
            'head_notecard_EID, document_title_from_vendor '
            'FROM notecard_based_document '
            'ORDER BY head_notecard_EID DESC')
        for (eid, title) in c:
            sout.write(''.join((eid, ' ', title, '\n')))
        return 0

    count = 0
    itr = stato.document_commits_via_title(doc_title)
    if itr is None:
        serr.write(f"(none found for {doc_title!r})\n")
        return 123

    pcs = []
    for o in itr:  # o = document commit
        count += 1
        pcs.append(o.datetime.isoformat())
        pcs.append('%7s' % (o.verb,))
        rec = o.record
        nli = rec.number_of_lines_inserted
        nld = rec.number_of_lines_deleted

        nlis = ''.join(('+', str(nli))) if nli else ''
        nlds = ''.join(('-', str(nld))) if nld else ''
        pcs.append(" %4s  %4s" % (nlis, nlds))

        pcs.append('  ')
        pcs.append(o.record.SHA[:8])

        if 'docu_type_common' == rec.document_type:
            n = rec.number_of_notecards
            if 1 != n:
                pcs.append(f"in {n} notecards")
        else:
            assert 'docu_type_rigged' == rec.document_type

        sout.write(' '.join(pcs))
        pcs.clear()
        sout.write('\n')

    serr.write(f"(seen {count} things)\n")
    return 0


_formal_argument_for_collection_path = '<coll-path>', 'path to collection'
_coll_path_key = 'coll_path'
_formal_option_for_help = '-h', '--help', 'this screen'


# ==

def _ExternalFunctions(serr):

    class external_functions:  # #class-as-namespace

        def produce_monitor():
            from script_lib.magnetics.error_monitor_via_stderr import func
            return func(serr)

    return external_functions


# ==

def statistitican_via_collection_path(coll_path):

    def document_commits_via_title(vendor_document_title):
        """(before #history-B.4 we could get the history in one commit
        with a JOIN. but now (to accomodate rigged documents) we do it in
        two which is fine.)
        """

        c = execute(
            'SELECT notecard_based_document_ID, just_kidding_document_type '
            'FROM notecard_based_document '
            'WHERE document_title_from_vendor=?',
            (vendor_document_title,))

        # Maybe we have no record of this document at all (strange)
        first_row = c.fetchone()
        if first_row is None:
            return
        assert c.fetchone() is None

        docu_ID, typ, = first_row

        if 'docu_type_common' == typ:
            return for_notecard_based_document(docu_ID)
        assert 'docu_type_rigged' == typ
        return for_rigged_document(vendor_document_title)  # ick/meh

    def for_rigged_document(vendor_document_title):
        c = execute(
            'SELECT RDC.* '
            'FROM rigged_document_commit AS RDC '
            'JOIN rigged_document AS RD USING (rigged_document_ID) '
            'WHERE RD.document_title_from_vendor=? '
            'ORDER BY datetime(RDC.normal_datetime) ',
            (vendor_document_title,))

        # (we want to make it be commit-graph order not chrono order,
        #  but not badly enough to do it knowing that it's not covered)

        def mutable_threes():
            while True:
                row = c.fetchone()
                if not row:
                    break
                rec = RD_commit_record(*row)
                dt = datetime_via_record(rec)
                yield [dt, 'edit', rec]

        scn = _scanner_via_iterator(mutable_threes())

        # If there are no commits in the database for this docu, strange
        if scn.empty:
            return

        return docu_CIs_via_threes_scanner(scn, 'docu_type_rigged')

    def for_notecard_based_document(docu_ID):
        c = execute(
            'SELECT NBDC.* FROM notecard_based_document_commit as NBDC '
            'WHERE NBDC.notecard_based_document_ID=? '
            'ORDER BY datetime(NBDC.normal_datetime)',
            (docu_ID,))

        def mutable_threes():
            while True:
                row = c.fetchone()
                if not row:
                    break
                rec = NB_commit_rec_via_row(row)
                dt = datetime_via_record(rec)
                yield [dt, 'edit', rec]

        scn = _scanner_via_iterator(mutable_threes())

        # If there are no commits in the database for this docu, strange
        if scn.empty:
            return

        return docu_CIs_via_threes_scanner(scn, 'docu_type_common')

    def docu_CIs_via_threes_scanner(scn, typ):

        scn.peek[1] = 'create'  # meh

        while True:
            three = scn.next()
            yield _DocumentCommit(*three, typ)
            if scn.empty:
                break

    # Datetime via record
    def datetime_via_record(rec):
        rec.tzinfo  # hi
        return strptime(rec.normal_datetime, '%Y-%m-%d %H:%M:%S')
    from datetime import datetime as _
    strptime = _.strptime

    # Connect to database
    from pho.document_history_._model import \
        database_via_collection_path_ as func
    # (it's a sibling file to us but we are an entrypoint file)

    db = func(coll_path)
    assert db

    # Prepare statistics
    sing = db.singleton_text

    k = 'mean_and_std'
    two_as_string = sing.get(k)
    if two_as_string is None:
        xx(f"Did you generate the statistics? Not found: {k!r}")
    mean_s, std_s = two_as_string.split(' ')
    mean, std = float(mean_s), float(std_s)

    k = 'mean_and_std_for_rigged'
    two_as_string = sing.get(k)
    if two_as_string is None:
        xx(f"Did you generate the statistics? Not found: {k!r}")
    mean_s, std_s = two_as_string.split(' ')
    mean_for_rigged, std_for_rigged = float(mean_s), float(std_s)

    from pho.document_history_._model import \
        RiggedDocumentCommitRecord_ as RD_commit_record

    NB_commit_rec_via_row = \
        db.notecard_based_document_commit_table.NBD_CI_via_row_

    execute = db.conn.execute

    # == BEGIN meh
    from dataclasses import dataclass as _dataclass
    from collections import namedtuple as _nt

    @_dataclass
    class _Statistician:
        mean: float
        std: float
        mean_for_rigged: float
        std_for_rigged: float
        document_commits_via_title: callable
        db: object

    _DocumentCommit = _nt(
        '_DocumentCommit',
        ('datetime', 'verb', 'record', 'document_type'))

    # == END

    return _Statistician(
        mean=mean,
        std=std,
        mean_for_rigged=mean_for_rigged,
        std_for_rigged=std_for_rigged,
        document_commits_via_title=document_commits_via_title,
        db=db)


def _scanner_via_iterator(itr):
    assert hasattr(itr, '__next__')
    from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    return func(itr)


# ==

def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))


if '__main__' == __name__:
    cli_for_production()

# #history-B.4
# #born
