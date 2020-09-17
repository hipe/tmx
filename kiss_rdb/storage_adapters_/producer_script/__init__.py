"""why this file is anemic:

👉 The official home of the "producer script" format adapter is in
   "data-pipes". As such, this file should live there not here.

👉 "data-pipes" is sub-ordinate to here: we want that the dependency is
   one-way: where this sub-project shouldn't depend on on that one.

👉 But the below code violates that.

👉 To do this "right" we would "mount" the other location

👉 But for historical reasons (the two adapter "variants" we have for
   markdown files), rather than "mounting" we just do it "by hand" for now.

:[#873.M]
"""

STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = False
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = True
STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS = ('.py',)
STORAGE_ADAPTER_IS_AVAILABLE = True


def COLLECTION_IMPLEMENTATION_VIA_SINGLE_FILE(
        collection_path, listener=None, opn=None, rng=None):

    from data_pipes.format_adapters.producer_script import \
            COLLECTION_IMPLEMENTATION_VIA_SINGLE_FILE

    return COLLECTION_IMPLEMENTATION_VIA_SINGLE_FILE(
        collection_path, listener, opn=opn, rng=rng)

# #born.
