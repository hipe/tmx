#!/usr/bin/env python3 -W error::Warning::0


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
        yield {
                '_is_sync_meta_data': True,
                'custom_pass_filter_for_syncing': 'data_pipes.YIKES_SKIP_HEADERS',  # noqa: E501
                'natural_key_field_name': 'field_name_one',
                }
        yield {'header_level': 99, 'no_see': 'no_see'}
        yield {'field_name_one': 'four', 'cha_cha': 'SIX'}
        yield {'field_name_one': 'seven', 'field_2': 'EIGHT'}

    def __exit__(*_):
        return False  # no, don't trap exceptions


if __name__ == '__main__':
    import exe_150_json_stream_via_bernstein_html as _  # #[410.H]
    exit(_.execute_as_CLI_(open_dictionary_stream))

# #born.
