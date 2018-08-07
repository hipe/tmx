#!/usr/bin/env python3 -W error::Warning::0


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
    import exe_150_json_stream_via_bernstein_html as _  # #[410.H]
    exit(_.execute_as_CLI_(open_dictionary_stream))

# #born.
