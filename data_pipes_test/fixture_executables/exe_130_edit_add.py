#!/usr/bin/env python3 -W default::Warning::0

stream_for_sync_is_alphabetized_by_key_for_sync = True


def stream_for_sync_via_stream(dcts):
    for dct in dcts:
        if 'header_level' in dct:
            continue
        yield (dct['field_name_one'], dct)


near_keyerer = None  # #open [#458.N] producer script shouldn't have knowledge


class open_traversal_stream:
    """
    purpose built for this story:

      - update a record
      - add a record
      - [a diff will be output]
    """

    def __init__(self, *_, **__):
        pass

    def __enter__(self):
        yield {'header_level': 99, 'no_see': 'no_see'}
        yield {'field_name_one': 'four', 'cha_cha': 'SIX'}
        yield {'field_name_one': 'seven', 'field_2': 'EIGHT'}

    def __exit__(*_):
        return False  # no, don't trap exceptions


if __name__ == '__main__':
    from exe_150_json_stream_via_bernstein_html import exit_code_via_path
    exit(exit_code_via_path(__file__))

# #born.
