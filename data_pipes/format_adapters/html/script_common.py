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


def _required(self, s, x):
    if x is None:
        self._become_not_OK()
    else:
        setattr(self, s, x)


def flush_JSON_stream_into(sout, serr, itr):
    """convenience guy for this pattern ETC"""

    from kiss_rdb import dictionary_dumper_as_JSON_via_output_stream
    visit = dictionary_dumper_as_JSON_via_output_stream(sout)
    count = 0
    for obj in itr:
        count += 1
        visit(obj)
        sout.write('\n')
    serr.write('({} items(s))\n'.format(count))


def the_function_called_markdown_link_via():
    from kiss_rdb.storage_adapters_.markdown_table.LEGACY_markdown_document_via_json_stream import (  # noqa: E501
        markdown_link_via)
    return markdown_link_via


def the_function_called_normal_field_name_via_string():
    from kiss_rdb import normal_field_name_via_string
    return normal_field_name_via_string


def the_function_called_simple_key_via_normal_key():
    from kiss_rdb.storage_adapters_.markdown_table.LEGACY_markdown_document_via_json_stream import (  # noqa: E501
            simple_key_via_normal_key)
    return simple_key_via_normal_key


# -- EXPERIMENT..

class open_dictionary_stream_via:  # #[#459.3] class as context manager

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


def pop_property(obj, attr):
    x = getattr(obj, attr)
    delattr(obj, attr)
    return x

# --

# #history-A.5: sunset this as an entrypoint script
# #history-A-4: key simplifier (reads markdown links) left to be with friends
# #history-A.3: abstracted common CLI for producers
# #history-A.2: function transplanted to here
# #historyA.1: got rid of use of `log`
# #born: abstracted from sibling
