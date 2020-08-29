#!/usr/bin/env python3 -W error::Warning::0

"""produce a list of articles for learning electron from

the "awesome" list here: {_this_one_url}
(spoiler: this wasn't that helpful 🙃 —
see pho-doc fragment "E2B", content added at #birth)
"""

import soupsieve as sv
import re


_url = 'https://github.com/sindresorhus/awesome-electron#boilerplates'


def _my_CLI(error_monitor, sin, sout, serr, is_for_sync):
    with open_traversal_stream(error_monitor.listener) as dcts:
        if is_for_sync:
            dcts = stream_for_sync_via_stream(dcts)
        _ps_lib().flush_JSON_stream_into(sout, serr, dcts)
    return 0 if error_monitor.OK else 456


_my_CLI.__doc__ = __doc__


stream_for_sync_is_alphabetized_by_key_for_sync = False


def near_keyerer(key_via_row, schema_index, listener):
    def use_me(row_DOM):
        hi = row_DOM.children[0].content_string()
        md = re.match(r'^\[([^\]]+)\]', hi)  # fallible, meh
        hey = md[1]
        return _sync_key_via_label(hey)
    return use_me


def stream_for_sync_via_stream(dcts):
    from kiss_rdb.storage_adapters.markdown import markdown_link_via
    for dct in dcts:
        label = dct['label']
        _ = _sync_key_via_label(label)
        yield (_, {'resource': markdown_link_via(label, dct['url'])})


def _sync_key_via_label(label):
    pcs = []
    for word in label.split(' '):
        pcs.append(re.sub(r'[^a-z0-9]+', '', word.lower()))
    return '_'.join(pcs)


class open_traversal_stream:

    def __init__(self, listener, cached_document_path=None):
        self._cached_document_path = cached_document_path
        self._listener = listener

    def __enter__(self, *_3):
        return _work(self._listener, self._cached_document_path)

    def __exit__(self, *_3):
        return False  # do not swallow exceptions


def _work(listener, cached_doc_path):

    soup = _ps_lib().soup_via_locators_(
            url=_url,
            html_document_path=cached_doc_path,
            listener=listener)

    if soup is None:
        return

    readme, = soup.find_all('div', id='readme')

    # find the H2 called "Articles"

    for el in readme.find_all('h2'):
        if 'Articles' != el.text:
            continue
        ul = el.find_next_sibling()  # not the H2 but whatever is after it
        assert('ul' == ul.name)
        break

    for li in sv.filter('li', ul):
        these = sv.filter('*', li)  # immediate children, skipping strings
        if 1 == len(these):
            a, = these
            assert('a' == a.name)
            yikes = None
        else:
            a, desc = these
            assert('a' == a.name)
            yikes = desc.name
        # NOTE this skips over some interesting strings that are like descs
        dct = {'label': a.text, 'url': a['href']}
        if yikes is not None:
            assert('code' == yikes)  # meh
        yield dct


def _ps_lib():
    import data_pipes.format_adapters.html.script_common as lib
    return lib


if __name__ == '__main__':
    from script_lib.cheap_arg_parse import cheap_arg_parse
    import sys as o
    exit(cheap_arg_parse(
            CLI_function=_my_CLI,
            stdin=o.stdin, stdout=o.stdout, stderr=o.stderr, argv=o.argv,
            formal_parameters=(
                ('-s', '--for-sync',
                 'translate to a stream suitable for use in [#447] syncing'),),
            description_template_valueser=lambda: {'_this_one_url': _url},
            ))

# #birth
