def cli_for_production():
    from sys import stdout, stderr, argv
    exit(CLI(None, stdout, stderr, argv))


def _commands():
    yield 'things-for-document', lambda: _command_zizzy


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
        amt = rec.number_of_lines_inserted + rec.number_of_lines_deleted
        n = rec.number_of_notecards
        pcs.append(" ±%3d" % (amt,))
        if 1 != n:
            pcs.append(f"in {n} notecards")
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
        c = execute(
            'SELECT NBDC.* FROM notecard_based_document_commit as NBDC '
            'JOIN notecard_based_document AS NBD '
            'USING (notecard_based_document_ID) '
            'WHERE NBD.document_title_from_vendor=? '
            'ORDER BY datetime(NBDC.normal_datetime)',
            (vendor_document_title,))

        first_row = c.fetchone()
        if first_row is None:
            return

        def rows():
            yield first_row
            for row in c:
                yield row

        def mutable_threes():
            for row in rows():
                rec = rec_via_row(row)
                rec.tzinfo  # hi
                dt = strptime(rec.normal_datetime, '%Y-%m-%d %H:%M:%S')
                yield [dt, 'edit', rec]

        def use_these():
            itr = mutable_threes()
            first = next(itr)
            first[1] = 'create'
            yield first
            for this in itr:
                yield this

        return (_DocumentCommit(*ary) for ary in use_these())

    from datetime import datetime as _
    strptime = _.strptime

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

    rec_via_row = db.notecard_based_document_commit_table.NBD_CI_via_row_
    execute = db.conn.execute

    # == BEGIN meh
    from dataclasses import dataclass as _dataclass
    from collections import namedtuple as _nt

    @_dataclass
    class _Statistician:
        mean: float
        std: float
        document_commits_via_title: callable
        db: object
    _DocumentCommit = _nt('_DocumentCommit', ('datetime', 'verb', 'record'))
    # == END

    return _Statistician(mean, std, document_commits_via_title, db)


# ==

def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))


if '__main__' == __name__:
    cli_for_production()

# #born
