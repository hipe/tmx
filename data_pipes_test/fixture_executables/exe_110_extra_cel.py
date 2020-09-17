#!/usr/bin/env python3 -W default::Warning::0


stream_for_sync_is_alphabetized_by_key_for_sync = True


def stream_for_sync_via_stream(dcts):
    for dct in dcts:
        yield (dct['field_name_one'], dct)


near_keyerer = None  # #open [#458.N] producer script shouldn't have knowledge


class open_traversal_stream:
    """(example with extra cel)"""

    def __init__(self, listener, cache_path=None):
        pass

    def __enter__(self):
        yield {'field_name_one': 'one', 'ziff_davis': 'xixjf'}

    def __exit__(*_):
        return False  # no, we don't trap exceptions


if __name__ == '__main__':
    from exe_150_json_stream_via_bernstein_html import exit_code_via_path
    exit(exit_code_via_path(__file__))

# #born.
