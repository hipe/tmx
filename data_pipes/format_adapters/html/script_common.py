"""ASPIRATIONAL: break common scraping tasks up into reusable parts..

so:
  - let's have this be the only place where we do `requests`
  - cache the HTTP result body for sane development
  - EXPERIMENT with beautiful soup stuff..
  - (reminder: the commit message of the birth commit of the document)

NOTE - this is NOT yet useful as a standalone CLI script..
"""
# #[#874.5] file used to be executable script and may need further changes


"""
dependencies (TODO):
    - requests 2.18.4
"""


def _required(self, s, x):
    if x is None:
        self._become_not_OK()
    else:
        setattr(self, s, x)


def selector_via_string(*_):
    cover_me('gone a long time ago')


def common_CLI_for_json_stream_(  # via abstraction at #history-A.3
        traversal_function,
        doc_string,
        help_values=None,
        ):

    def my_CLI(listener, sin, sout, serr):

        _rc = traversal_function(None, listener=listener)

        with _rc as itr:
                result = flush_JSON_stream_into(sout, serr, itr)
        return result

    my_CLI.__doc__ = doc_string

    import script_lib as _
    import sys as o

    _exitstatus = _.CHEAP_ARG_PARSE(
        cli_function=my_CLI,
        std_tuple=(o.stdin, o.stdout, o.stderr, o.argv),
        help_values=help_values,
        )

    return _exitstatus


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

class OPEN_DICTIONARY_STREAM_VIA:  # #[#410.F] class as context manager

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
        self._listener = listener
        self.html_document_path = html_document_path

        self._enter_mutex = None
        self._exit_mutex = None
        self._ok = True

    def __enter__(self):
        self._ok and self.__resolve_soup()
        self._ok and self.__maybe_use_first_selector()
        if self._ok:
            x = pop_property(self, '_arg_to_2nd_selector')
            _itr = self.second_selector(x, self._listener)
            return _itr
        else:
            return iter(())  # [#412]

    def __exit__(self, *_):
        del(self._exit_mutex)
        return False  # don't absorb exceptions

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
                def msg():
                    yield f'needed 1 had {le}: {first_selector!r}'
                self._listener(
                        'error', 'expression', 'selection_arity_mismatch', msg)
        self._required('_arg_to_2nd_selector', arg_to_2nd_selector)

    def __resolve_soup(self):
        _soup = soup_via_locators_(
                url=self.url,
                html_document_path=self.html_document_path,
                listener=self._listener)
        self._required('_soup', _soup)

    _required = _required

    def _become_not_OK(self):
        self._ok = False


def soup_via_locators_(**kwargs):
    return _soup_via_things(**kwargs).execute()


class _soup_via_things:
    # abstracted from above thing at #history-A.3

    def __init__(self, url, html_document_path, listener):
        self.url = url
        self.html_document_path = html_document_path
        self._listener = listener
        self._OK = True

    def execute(self):
        self._OK and self.__resolve_cached_doc()
        self._OK and self.__resolve_soup()
        if self._OK:
            return self._soup

    def __resolve_soup(self):
        from bs4 import BeautifulSoup
        cached_doc = pop_property(self, '_cached_doc')
        with open(cached_doc.cache_path) as fh:
            soup = BeautifulSoup(fh, 'html.parser')  # ..
        self._required('_soup', soup)

    def __resolve_cached_doc(self):
        _cached_doc = _cached_doc_via_url_or_local_path(
                self.url, self.html_document_path, self._listener)
        self._required('_cached_doc', _cached_doc)

    _required = _required

    def _become_not_OK(self):
        self._OK = False


def _cached_doc_via_url_or_local_path(url, filesystem_path, listener):
    from script_lib import CACHED_DOCUMENT_VIA_TWO as _
    return _(filesystem_path, url, 'HTML', listener)


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


@_this_lazy
def cover_me(s):
    pass

# --

# #history-A.5: sunset this as an entrypoint script
# #history-A-4: key simplifier (reads markdown links) left to be with friends
# #history-A.3: abstracted common CLI for producers
# #history-A.2: function transplanted to here
# #historyA.1: got rid of use of `log`
# #born: abstracted from sibling
