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

    _normalize_sys_path()
    from script.json_stream_via_url_and_selector import (
            flush_JSON_stream_into as flush_into,
            )
    import sys as o
    with open_dictionary_stream(None, None) as dcts:
        flush_into(o.stdout, o.stderr, dcts)
    return 0


def _normalize_sys_path():  # #[#019.file-type-E]
    from sys import path as sys_path
    from os import path as os_path
    dn = os_path.dirname

    here = os_path.abspath(dn(__file__))
    if here != sys_path[0]:
        raise Exception('sanity - in the future, default sys.path may change')

    sys_path[0] = dn(dn(here))

# == END


if __name__ == '__main__':
    exit(execute_as_CLI_(open_dictionary_stream))

# #born.
