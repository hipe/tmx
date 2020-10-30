#!/usr/bin/env python3 -W default::Warning::0


def stream_for_sync_via_stream(dcts):
    for dct in dcts:
        if 'header_level' in dct:
            continue
        yield (dct['lesson'], dct)


stream_for_sync_is_alphabetized_by_key_for_sync = False


near_keyerer = None


class open_traversal_stream:
    def __init__(self, listener, cached_document_path=None):
        pass

    def __enter__(self):
        yield {'header_level': 99, 'no_see': 'no_see'}
        yield {'lesson': '[choo chah](foo fa)'}
        yield {'lesson': '[boo bah](loo la)'}

    def __exit__(self, *_3):
        pass


if __name__ == '__main__':
    from data_pipes_test.fixture_executables.exe_150_json_stream_via_bernstein_html import exit_code_via_path  # noqa: E501
    exit(exit_code_via_path(__file__))


# #history-A.2: moved from another subproject to here
# #history-A.1: no more sync-side entity mapping
# #born.
