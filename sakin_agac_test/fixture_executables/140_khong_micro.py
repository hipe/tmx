class open_dictionary_stream:
    """
    purpose built for this story:

      - be like mike
    """

    def __init__(self, *_, **__):
        pass

    def __enter__(self):
        yield {'_is_sync_meta_data': True, 'natural_key_field_name': 'lesson'}  # noqa: E501
        yield {'header_level': 99, 'no_see': 'no_see'}
        yield {'lesson': '[choo chah](foo fa)'}
        yield {'lesson': '[boo bah](loo la)'}

    def __exit__(*_):
        return False  # no, don't trap exceptions


if __name__ == '__main__':
    raise Exception('(see [#410.H])')

# #born.
