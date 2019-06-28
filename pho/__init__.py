def errorer(listener):
    def f(error_symbol, msg):
        return emit_error(listener, error_symbol, msg)
    return f


def emit_error(listener, error_symbol, msg):
    _head = error_symbol.replace('_', ' ')
    _reason = f'{_head}: {msg}'
    listener('error', 'structure', error_symbol, lambda: {'reason': _reason})


# == stowaway support for magnetics

def big_index_and_collection_via_path(collection_path, listener):
    import kiss_rdb
    coll = kiss_rdb.COLLECTION_VIA_COLLECTION_PATH(collection_path, listener)
    if coll is None:
        return

    from pho.magnetics_.big_index_via_collection import (
            big_index_via_collection,
            )

    big_index = big_index_via_collection(coll, listener)
    if big_index is None:
        return

    return big_index, coll

# #born.
