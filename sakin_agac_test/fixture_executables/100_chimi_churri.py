class open_dictionary_stream:
    """(minimal example. in yours you should etc)"""

    def __init__(self, listener):
        pass

    def __enter__(self):
        yield {'_is_sync_meta_data': True, 'natural_key_field_name': 'xx yy'}
        yield {'choo cha': 'foo fa'}

    def __exit__(*_):
        pass


if __name__ == '__main__':
    raise Exception('cover me')

# #born.
