#!/usr/bin/env python3 -W error::Warning::0


class open_dictionary_stream:
    """(example with no metadata)"""

    def __init__(self, cache_path, listener):
        pass

    def __enter__(self):
        yield {'choovo chavo': 'fuu fee'}

    def __exit__(*_):
        return False  # no, we don't trap exceptions


if __name__ == '__main__':
    import exe_150_json_stream_via_bernstein_html as _  # #[410.H]
    exit(_.execute_as_CLI_(open_dictionary_stream))


# #born.
