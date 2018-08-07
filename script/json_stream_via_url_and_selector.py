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

    cover_me('not used')

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


def selector_via_string(*_):
    cover_me('gone a long time ago')


_my_CLI.__doc__ = __doc__


def flush_JSON_stream_into(sout, serr, itr):
    """convenience guy for this pattern ETC"""

    visit = JSON_object_writer_via_IO_downstream(sout)
    count = 0
    for obj in itr:
        count += 1
        visit(obj)

    serr.write('({} items(s))\n'.format(count))


def JSON_object_writer_via_IO_downstream(io):
    def f(obj):
        io.write(f'{json.dumps(obj)}\n')
    import json
    return f


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

        from modality_agnostic import listening
        self._emit = listening.emitter_via_listener(listener)

        self._enter_mutex = None
        self._exit_mutex = None
        self._ok = True

    def __enter__(self):
        self._ok and self.__resolve_cached_doc()
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
                self._emit(
                        'error', 'expression', 'selection_arity_mismatch',
                        _tmpl, (le, repr(first_selector)))
        self._required('_arg_to_2nd_selector', arg_to_2nd_selector)

    def __resolve_soup(self):
        from bs4 import BeautifulSoup
        cached_doc = pop_property(self, '_cached_doc')
        with open(cached_doc.cache_path) as fh:
            soup = BeautifulSoup(fh, 'html.parser')  # ..
        self._required('_soup', soup)

    def __resolve_cached_doc(self):
        from sakin_agac.format_adapters.html.magnetics import (
                cached_doc_via_url_via_temporary_directory as cachelib,
                )
        path = self.html_document_path
        if path is None:
            from script_lib import TEMPORARY_DIR
            _cached_doc_via = cachelib(TEMPORARY_DIR)
            _x = _cached_doc_via(self.url, self._emit)
            self._required('_cached_doc', _x)
        else:
            _tmpl = '(reading HTML from filesystem - {})'
            self._emit(
                    'info', 'expression', 'reading_from_filesystem',
                    _tmpl, self.html_document_path)
            self._cached_doc = cachelib.Cached_HTTP_Document(path)

    def _required(self, s, x):
        if x is None:
            self._ok = False
        else:
            setattr(self, s, x)

    def __exit__(self, *_):
        del(self._exit_mutex)


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


def listener_and_exitstatuser_for_CLI(io):

    from script_lib.magnetics import listener_via_resources as _
    downstream_listener = _.listener_via_stderr(io)

    exitstatus = 0  # innocent until proven guilty

    def listener(head_channel, *a):
        if 'error' == head_channel:
            nonlocal exitstatus
            exitstatus = 5
        downstream_listener(head_channel, *a)

    def exitstatuser():
        return exitstatus

    return listener, exitstatuser


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


def normalize_sys_path_():
    """we want the `sys.path` to start with the universal monoproject

    directory, nod the dirname of the entrypoint file (which we assert).
    this is the first formal implementation of what is now recognized
    as the pattern :[#019.E].
    """

    import os.path as os_path
    from sys import path as sys_path
    dn = os_path.dirname
    here = os_path.abspath(dn(__file__))
    if here != sys_path[0]:
        sanity('sanity - in the future, default sys.path may change')
    sys_path[0] = dn(here)


@_this_lazy
def pop_property(o, s):
    pass


@_this_lazy
def cover_me(s):
    pass


@_this_lazy
def sanity(s=None):
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

# #pending-rename: at (-4) maybe put this in format_adapters/html
# #historyA.1: got rid of use of `log`
# #born: abstracted from sibling
