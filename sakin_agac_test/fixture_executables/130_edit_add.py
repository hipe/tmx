class open_dictionary_stream:
    """
    purpose built for this story:

      - update a record
      - add a record
      - [a diff will be output]
    """

    def __init__(self, *_, **__):
        pass

    def __enter__(self):
        yield {'_is_sync_meta_data': True, 'natural_key_field_name': 'field_name_one'}  # noqa: E501
        yield {'header_level': 99, 'no_see': 'no_see'}
        yield {'field_name_one': 'four', 'cha_cha': 'SIX'}
        yield {'field_name_one': 'seven', 'field_2': 'EIGHT'}

    def __exit__(*_):
        return False  # no, don't trap exceptions


if __name__ == '__main__':
    raise Exception('(see [#410.H])')

# #born.
