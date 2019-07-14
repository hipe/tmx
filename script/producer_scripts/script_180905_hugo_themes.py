#!/usr/bin/env python3 -W error::Warning::0

"""produce a list of hugo themes by scraping {_this_one_url}

this is a "shallow scrape", in contrast to a "deep scrape"
available in a sibling script.
"""
# #[#410.1.2] this is a producer script.

import soupsieve as sv


_domain = 'https://themes.gohugo.io'
_url = _domain + '/'

_my_doc_string = __doc__


def _required(self, attr, x):
    if x is None:
        self._OK = False  # often `_become_not_OK`
    else:
        setattr(self, attr, x)


class open_dictionary_stream:

    def __init__(self, cached_document_path, listener):
        import script.json_stream_via_url_and_selector as _
        self._cached_document_path = cached_document_path
        self._listener = listener
        self._lib = _
        self._OK = True

    def __enter__(self, *_3):
        self._OK and self.__resolve_soup()
        self._OK and self.__find_the_root_section()
        if not self._OK:
            return

        yield {
                '_is_sync_meta_data': True,
                'natural_key_field_name': 'hugo_theme',
                'custom_far_keyer_for_syncing': 'script.markdown_document_via_json_stream.COMMON_FAR_KEY_SIMPLIFIER_',  # noqa: E501
                'custom_near_keyer_for_syncing': 'script.markdown_document_via_json_stream.COMMON_NEAR_KEY_SIMPLIFIER_',  # noqa: E501
                'custom_mapper_for_syncing': 'script.markdown_document_via_json_stream.this_one_mapper_("hugo_theme")',   # noqa: E501
                'far_deny_list': ('url', 'label'),  # documented @ [#418.I.3.2]
                }

        for a in _direct_children(self._the_root_section):
            if 'a' != a.name:
                cover_me()
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
        _soup = self._lib.soup_via_locators_(
                url=_url,
                html_document_path=self._cached_document_path,
                listener=self._listener,
                )
        self._required('_soup', _soup)

    _required = _required


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


def cover_me():
    raise Exception('cover me')


def sanity(s):
    raise Exception(f'sanity - {s}')


if __name__ == '__main__':
    import script.json_stream_via_url_and_selector as _
    _exitstatus = _.common_CLI_for_json_stream_(
            traversal_function=open_dictionary_stream,
            doc_string=_my_doc_string,
            help_values={'_this_one_url': _url},
            )
    exit(_exitstatus)

# #born
