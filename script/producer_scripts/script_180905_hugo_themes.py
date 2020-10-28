#!/usr/bin/env python3 -W default::Warning::0

"""produce a list of hugo themes by scraping {_this_one_url}

this is a "shallow scrape", in contrast to a "deep scrape"
available in a sibling script.
"""
# This producer script is covered by (Case3395DP)

import soupsieve as sv


_domain = 'https://themes.gohugo.io'
_url = _domain + '/'


def _formals():
    yield ('-s', '--for-sync',
           'translate to a stream suitable for use in [#447] syncing')
    yield '-h', '--help', 'this screen'


def _my_CLI(sin, sout, serr, is_for_sync, rscer):
    mon = rscer().monitor
    with open_traversal_stream(mon.listener) as dcts:
        if is_for_sync:
            dcts = stream_for_sync_via_stream(dcts)
        _ps_lib().flush_JSON_stream_into(sout, serr, dcts)
    return 0 if mon.OK else 456


_my_CLI.__doc__ = __doc__


stream_for_sync_is_alphabetized_by_key_for_sync = True


def stream_for_sync_via_stream(dcts):
    from kiss_rdb.storage_adapters.markdown import markdown_link_via
    left = len(_url)
    for dct in dcts:
        url = dct['url']
        assert(_url == url[0:left])
        assert('/' == url[-1])
        _ = url[left:-1].replace('-', '')
        yield (_, {'hugo_theme': markdown_link_via(dct['label'], url)})


class open_traversal_stream:

    def __init__(self, listener, cached_document_path=None):
        self._cached_document_path = cached_document_path
        self._listener = listener
        self._OK = True

    def __enter__(self, *_3):
        self._OK and self.__resolve_soup()
        self._OK and self.__find_the_root_section()
        if not self._OK:
            return
        for a in _direct_children(self._the_root_section):
            assert('a' == a.name)
            dct = {}
            _write_url_and_label(dct, a)
            yield dct

    def __exit__(self, *_3):
        return False  # do not swallow exceptions

    def __find_the_root_section(self):

        # in body, main. in main, one div. in that one div, one div (flex),
        # in that, a first and a second..

        main_section, _tail_section = self._soup.find_all('section')
        del(self._soup)
        self._the_root_section = main_section

    def __resolve_soup(self):
        soup = _ps_lib().soup_via_locators_(
                url=_url,
                html_document_path=self._cached_document_path,
                listener=self._listener)
        if not soup:
            self._OK = False
            return
        self._soup = soup


def _write_url_and_label(dct, a):

    span, = _filter('span', a)
    dct['label'] = span.string

    s = a['href']
    if False:
        pass
    else:
        dct['url'] = s


def _direct_children(node):  # #cp
    return _filter('*', node)  # omit strings


def _filter(sel, el):
    return sv.filter(sel, el)


def _ps_lib():
    import data_pipes.format_adapters.html.script_common as lib
    return lib


if __name__ == '__main__':
    formals = _formals()
    kwargs = {'description_valueser': lambda: {'_this_one_url': _url}}
    import sys as o
    from script_lib.cheap_arg_parse import cheap_arg_parse as func
    exit(func(_my_CLI, o.stdin, o.stdout, o.stderr, o.argv, formals, **kwargs))

# #born
