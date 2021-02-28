def _main(coll_path, listener):
    bcoll = _resolve_business_collection(coll_path, listener)
    conn = _OMG(coll_path, listener)
    xx("this is the tip of work")
    return conn, bcoll


def update_document_history(coll_path, listener):
    try:
        return _main(coll_path, listener)
    except _Stop:
        pass
    return


func = update_document_history


def _OMG(coll_path, listener):
    from os.path import dirname as dn, join as _path_join
    db_path = _path_join(coll_path, 'document-history-cache.sqlite3')
    mono_repo = dn(dn(dn(__file__)))
    schema_path = _path_join(
        mono_repo, 'pho-doc', 'documents', '429.4-document-history-schema.dot')
    from kiss_rdb.storage_adapters.sqlite3.connection_via_graph_viz_lines \
        import func
    with open(schema_path) as fh:
        db_conn = func(db_path, fh, listener)
    if db_conn:
        return db_conn
    raise _Stop()


def _resolve_business_collection(coll_path, listener):
    from pho import read_only_business_collection_via_path_ as func
    bcoll = func(coll_path, listener)
    if bcoll:
        return bcoll
    raise _Stop()


class _Stop(RuntimeError):
    pass


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
