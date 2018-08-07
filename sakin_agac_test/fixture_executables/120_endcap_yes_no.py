#!/usr/bin/env python3 -W error::Warning::0


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
    import exe_150_json_stream_via_bernstein_html as _  # #[410.H]
    exit(_.execute_as_CLI_(open_dictionary_stream))

# #born.
