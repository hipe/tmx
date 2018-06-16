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
        _rc = OPEN_DICTIONARY_STREAM_VIA(
                url=url,
                selector=selector,
                listener=listener,
                )

        nonlocal exitstatus
        with _rc as lines:
            exitstatus = flush_JSON_stream_into(sout, serr, lines)

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


_my_CLI.__doc__ = __doc__


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

class OPEN_DICTIONARY_STREAM_VIA:  # #[#410.F]

    def __init__(
            self,
            url,
            first_selector,
            second_selector,
            listener,
            html_document_path=None,
            ):

        self.url = url
        self.first_selector = first_selector
        self.second_selector = second_selector
        self.html_document_path = html_document_path

        self._emit = _emitters_via_listener(listener)

        self._enter_mutex = None
        self._exit_mutex = None
        self._ok = True

    def __enter__(self):
        self._ok and self.__resolve_cached_url()
        self._ok and self.__resolve_soup()
        self._ok and self.__maybe_use_first_selector()
        if self._ok:
            x = pop_property(self, '_arg_to_2nd_selector')
            _itr = self.second_selector(x, self._emit)
            return _itr
        else:
            return iter(())  # [#412]

    def __maybe_use_first_selector(self):
        soup = pop_property(self, '_soup')
        first_selector = pop_property(self, 'first_selector')
        if first_selector is None:
            arg_to_2nd_selector = soup
        else:
            rs = soup.find_all(* first_selector)
            le = len(rs)
            if le is 1:
                arg_to_2nd_selector = rs[0]
            else:
                _tmpl = 'needed 1 had {}: {}'
                self._emit.error(_tmpl, le, repr(first_selector))
        self._required('_arg_to_2nd_selector', arg_to_2nd_selector)

    def __resolve_soup(self):
        from bs4 import BeautifulSoup
        cached_url = pop_property(self, '_cached_url')
        with open(cached_url.cache_path) as fh:
            soup = BeautifulSoup(fh, 'html.parser')  # ..
        self._required('_soup', soup)

    def __resolve_cached_url(self):
        if self.html_document_path is None:
            self.__resolve_cached_url_normally()
        else:
            _tmpl = '(reading HTML from filesystem - {})'
            self._emit.info(_tmpl, self.html_document_path)
            self._cached_url = _CachedURL(self.html_document_path)

    def __resolve_cached_url_normally(self):
        _x = _cached_url(self.url, self._emit)
        self._required('_cached_url', _x)

    def _required(self, s, x):
        if x is None:
            self._ok = False
        else:
            setattr(self, s, x)

    def __exit__(self, *_):
        del(self._exit_mutex)


# -- X

def selector_via_string(s):
    okay()


# -- CACHED URL

def _cached_url(url, emit):
    import script_lib as sl
    import re
    sanitized_name = re.sub(r'[^a-zA-Z0-9]', '_', url)
    from os import path as p
    path = p.join(sl.TEMPORARY_DIR, sanitized_name)
    if p.exists(path):
        _tmpl = '(using cached web page (remove file to clear cache) - {})'
        emit.info(_tmpl, path)
        return _CachedURL(path)
    else:
        emit.info('(nothing cached for this url, caching - {})', path)
        return __make_cached_url(path, url, emit)


def __make_cached_url(cache_path, url, emit):

    import requests

    with open(cache_path, 'w') as fh:
        r = requests.get(url)
        status_code = r.status_code
        if status_code == 200:
            x = fh.write(r.text)
            emit.info('wrote {} ({} bytes)', cache_path, x)
            ok = True
        else:
            _tmpl = 'failed - got HTTP status {} from {}'
            emit.error(_tmpl, status_code, url)
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


# -- ..

def markdown_link_via(label, url):
    return '[{}]({})'.format(label, url)


def label_via_string_via_max_width(max_width):  # #coverpoint8.1
    def f(s):
        use_s = s[:(max_width-1)] + '…' if max_width < len(s) else s
        # (could also be accomplished by that one regex thing maybe)
        use_s = use_s.replace('*', '\\*')
        use_s = use_s.replace('_', '\\_')
        return use_s
    return f


def url_via_href_via_domain(domain):  # #coverpoint8.1
    def f(href):
        _escaped_href = href.replace(' ', '%20')
        return url_head_format.format(_escaped_href)
    url_head_format = '{}{}'.format(domain, '{}')  # or just ''.join((a,b))
    return f


def _emitters_via_listener(listener):

    from modality_agnostic import listening as li

    class emitters:  # namespace only
        error = li.leveler_via_listener('error', listener)
        info = li.leveler_via_listener('info', listener)
        # log = li.logger_via_listener(listener) # at #historyA.1

    return emitters


def _this_lazy(f):  # experiment (copy-paste)

    def g(*a):
        return f_pointer(*a)

    def f_pointer(*a):
        import importlib
        lib = importlib.import_module('sakin_agac')
        nonlocal f_pointer
        f_pointer = getattr(lib, f.__name__)
        return f_pointer(*a)

    return g


@_this_lazy
def pop_property(o, s):
    pass


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

# #historyA.1: got rid of use of `log`
# #born: abstracted from sibling
