"""helper functions for all things related to testings format adapters..

we want it be that there are no format-adapter-specific doo-hahs
"""


def some_natural_key_of_first_item(snapshot, test_context):

    _first_item = snapshot.items[0]
    x = _first_item.natural_key
    test_context.assertIsNotNone(x)
    return x


class SOME_SNAPSHOT:

    def __init__(self, item_stream):

        # == == ==

        """NOTE this will **look like** we are doing indexing ..

        but that is not quite the idea. at this point we are only trying to
        "flush"/"flatten" the collection into a big, immutable, in-memory
        snapshot.
        """

        seen_keys = {}
        items = []

        for item in item_stream:
            seen_keys[item.natural_key] = True
            items.append(item)

        self.SEEN_KEYS = seen_keys  # #todo - not used
        self.items = items


# #born.
