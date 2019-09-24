#!/usr/bin/env python3 -W error::Warning::0


def stream_for_sync_via_stream(dcts):
    for dct in dcts:
        if 'header_level' in dct:
            continue
        yield (dct['lesson'], dct)


stream_for_sync_is_alphabetized_by_key_for_sync = False


near_keyerer = None


class open_traversal_stream:
    def __init__(self, listener, cached_document_path):
        pass

    def __enter__(self):
        yield {'header_level': 99, 'no_see': 'no_see'}
        yield {'lesson': '[choo chah](foo fa)'}
        yield {'lesson': '[boo bah](loo la)'}

    def __exit__(self, *_3):
        pass


if __name__ == '__main__':
    import exe_150_json_stream_via_bernstein_html as _  # #[410.H]
    exit(_.execute_as_CLI_(open_traversal_stream))

# #history-A.1: no more sync-side entity mapping
# #born.
