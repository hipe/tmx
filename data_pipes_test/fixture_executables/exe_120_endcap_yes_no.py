#!/usr/bin/env python3 -W default::Warning::0


def stream_for_sync_via_stream(dcts):
    for dct in dcts:
        yield (dct['col_A'], dct)


near_keyerer = None  # #open [#458.N] producer script shouldn't have knowledge


class open_traversal_stream:
    """(RUM)"""

    def __init__(self, listener, cache_path=None):
        pass

    def __enter__(self):
        yield {'col_A': 'thing B', 'col_B': 'y'}  # (Case2850)

    def __exit__(*_):
        return False  # no, don't trap exceptions


stream_for_sync_is_alphabetized_by_key_for_sync = True


if __name__ == '__main__':
    from exe_150_json_stream_via_bernstein_html import exit_code_via_path
    exit(exit_code_via_path(__file__))

# #born.
