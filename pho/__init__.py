

# == stowaway support for magnetics

def big_index_via_collection_(coll, listener):
    from pho.magnetics_.big_index_via_collection import \
            big_index_via_collection
    return big_index_via_collection(coll, listener)


def collection_via_path_(collection_path, listener):
    from kiss_rdb import collectionerer
    return collectionerer().collection_via_path(collection_path, listener)


HELLO_FROM_PHO = "hello from pho"

# #history-A.1: archive all C, swift and PythonKit experiments
# #born.
