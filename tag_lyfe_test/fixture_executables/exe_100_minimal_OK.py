#!/usr/bin/env python3 -W error::Warning::0


raise Exception('never loaded but may be useful for visual testing..')


class open_dictionary_stream:

    def __init__(self, *_):
        pass

    def __enter__(self):
        _big_poppa = {
                '_is_sync_meta_data': True,
                'natural_key_field_name': 'hi',
                'tag_lyfe_field_names': ('main_tag', 'abstract'),
                }
        yield _big_poppa

        yield {
                'hi': 'x1',
                'main_tag': '#purple',
                'abstract': 'this is #orange too',
                }
        yield {
                'hi': 'x2',
                'main_tag': '#green',
                'abstract': 'this is #red #orange',
                'also': 'hello',
                }

    def __exit__(*_):
        return False  # no, we don't trap exceptions


# == BEGIN (see same in sakin_agac: [#410.H])

def execute_as_CLI_(open_dictionary_stream):
    from script.json_stream_via_url_and_selector import (
            flush_JSON_stream_into as flush_into)
    import sys as o
    with open_dictionary_stream(None, None) as dcts:
        flush_into(o.stdout, o.stderr, dcts)
    return 0


# == END


if __name__ == '__main__':
    exit(execute_as_CLI_(open_dictionary_stream))

# #born.
