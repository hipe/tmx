

# == stowaway support for magnetics

def big_index_and_collection_via_path(collection_path, listener):
    from kiss_rdb import collectionerer
    coll = collectionerer().collection_via_path(collection_path, listener)
    if coll is None:
        return

    from pho.magnetics_.big_index_via_collection import (
            big_index_via_collection)

    big_index = big_index_via_collection(coll, listener)
    if big_index is None:
        return

    return big_index, coll

# #born.
