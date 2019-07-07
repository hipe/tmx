"""helper functions for all things related to testings format adapters..

we want it be that there are no format-adapter-specific doo-hahs
"""


class SOME_SNAPSHOT:

    def __init__(self, native_object_stream, format_adapter):

        # == == ==

        """NOTE this will **look like** we are doing indexing ..

        but that is not quite the idea. at this point we are only trying to
        "flush"/"flatten" the collection into a big, immutable, in-memory
        snapshot.
        """

        read, = format_adapter.value_readers_via_field_names('field_one')

        self.field_ones = [read(item) for item in native_object_stream]


# #history-A.1: this file simplifies even more when reader not natural key
# #born.
