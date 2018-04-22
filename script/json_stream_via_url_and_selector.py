#!/usr/bin/env python3 -W error::Warning::0

"""ASPIRATIONAL: break common scraping tasks up into reusable parts..

so:
  - let's have this be the only place where we do `requests`
  - cache the HTTP result body for sane development
  - EXPERIMENT with beautiful soup stuff..
  - (reminder: the commit message of the birth commit of the document)

NOTE - this is NOT yet useful as a standalone CLI script..
"""


"""
dependencies (TODO):
    - requests 2.18.4
"""


def _my_CLI(url, selector_string, listener, sin, sout, serr):

    def __main():
        ok and __resolve_selector()
        ok and __get_busy()
        return exitstatus

    def __get_busy():
        itr = EXPERIMENT(url, selector, None, listener)
        if itr is not None:
            nonlocal exitstatus
            exitstatus = flush_JSON_stream_into(sout, serr, itr)

    def __resolve_selector():
        my_selector = selector_via_string(selector_string, listener)
        if my_selector is None:
            _stop_early()
        else:
            nonlocal selector
            selector = my_selector

    def _stop_early():
        nonlocal ok
        ok = False

    selector_string = None
    selector = None
    exitstatus = 5
    ok = True

    return __main()


def flush_JSON_stream_into(sout, serr, itr):
    """convenience guy for this pattern ETC"""

    import json
    count = 0
    for obj in itr:
        count += 1
        _line = json.dumps(obj)
        sout.write(_line + '\n')
    serr.write('({} items(s))\n'.format(count))


# -- EXPERIMENT..

def EXPERIMENT(url, first_selector, second_selector, listener):

    def __main():
        ok and __resolve_cached_url()
        ok and __resolve_first_selection()
        if ok:  # ..
            _generator = second_selector(first_selection)
            return _generator

    def __resolve_first_selection():

        from bs4 import BeautifulSoup
        with open(cached_url.cache_path) as fh:
            soup = BeautifulSoup(fh, 'html.parser')  # ..

        x = soup.find_all(* first_selector)
        le = len(x)
        if le is not 1:
            error = sl.leveler_via_listener('error', listener)  # ..
            error('needed 1 had {}: {}', le, repr(first_selector))
            _stop_early()
        else:
            nonlocal first_selection
            first_selection = x

    def __resolve_cached_url():
        x = _cached_url(url, listener)
        if x is None:
            _stop_early()
        else:
            nonlocal cached_url
            cached_url = x

    def _stop_early():
        nonlocal ok
        ok = False

    import script_lib as sl

    first_selection = None
    cached_url = None
    ok = True

    return __main()


# -- X

def selector_via_string(s):
    okay()


# -- CACHED URL

def _cached_url(url, listener):
    import script_lib as sl
    info = sl.leveler_via_listener('info', listener)
    import re
    sanitized_name = re.sub(r'[^a-zA-Z0-9]', '_', url)
    from os import path as p
    path = p.join(sl.TEMPORARY_DIR, sanitized_name)
    if p.exists(path):
        info('(using cached web page (remove file to clear cache) - {})', path)
        return _CachedURL(path)
    else:
        info('(nothing cached for this url, caching - {})', path)
        return __make_cached_url(path, url, listener)


def __make_cached_url(cache_path, url, listener):

    import script_lib as sl
    log = sl.logger_via_listener(listener)
    import requests

    with open(cache_path, 'w') as fh:
        r = requests.get(url)
        status_code = r.status_code
        if status_code == 200:
            x = fh.write(r.text)
            log('info', 'wrote {} ({} bytes)', cache_path, x)
            ok = True
        else:
            _tmpl = 'failed - got HTTP status {} from {}'
            log('error', _tmpl, status_code, url)
            ok = False
    if ok:
        return _CachedURL(cache_path)
    else:
        import os
        os.remove(cache_path)


class _CachedURL:

    def __init__(self, path):
        self.cache_path = path


def okay():
    raise('foo')


# --

if __name__ == '__main__':
    import sys as o
    o.path.insert(0, '')
    import script_lib
    _exitstatus = script_lib.CHEAP_ARG_PARSE(
        cli_function=_my_CLI,
        std_tuple=(o.stdin, o.stdout, o.stderr, o.argv),
        )
    exit(_exitstatus)

# #born: abstracted from sibling
