class open_dictionary_stream:
    """(example with extra cel)"""

    def __init__(self, listener):
        pass

    def __enter__(self):
        yield {'_is_sync_meta_data': True, 'natural_key_field_name': 'field_name_one'}  # noqa: E501
        yield {'field_name_one': 'one', 'ziff_davis': 'xixjf'}

    def __exit__(*_):
        return False  # no, we don't trap exceptions


if __name__ == '__main__':
    raise Exception('(see [#410.H])')

# #born.
