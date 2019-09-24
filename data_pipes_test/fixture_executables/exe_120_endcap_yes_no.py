#!/usr/bin/env python3 -W error::Warning::0


def stream_for_sync_via_stream(dcts):
    for dct in dcts:
        yield (dct['col_a'], dct)


near_keyerer = None  # #open [#458.N] producer script shouldn't have knowledge


class open_traversal_stream:
    """(RUM)"""

    def __init__(self, listener, cache_path):
        pass

    def __enter__(self):
        yield {'col_a': 'thing B', 'col_b': 'y'}  # (Case1322DP)

    def __exit__(*_):
        return False  # no, don't trap exceptions


stream_for_sync_is_alphabetized_by_key_for_sync = True


if __name__ == '__main__':
    import exe_150_json_stream_via_bernstein_html as _  # #[410.H]
    exit(_.execute_as_CLI_(open_traversal_stream))

# #born.
