class open_dictionary_stream:
    """(RUM)"""

    def __init__(self, cache_path, listener):
        pass

    def __enter__(self):
        yield {'_is_sync_meta_data': True, 'natural_key_field_name': 'col_a'}  # noqa: E501
        yield {'col_a': 'thing B', 'col_b': 'y'}

    def __exit__(*_):
        return False  # no, don't trap exceptions


if __name__ == '__main__':
    raise Exception('(see [#410.H])')

# #born.
