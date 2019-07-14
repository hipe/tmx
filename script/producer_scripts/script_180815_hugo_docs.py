#!/usr/bin/env python3 -W error::Warning::0

"""here we experiment with "multi-table"

produces a JSON dump from the outline of documentation
that can be found here: {hugo_docs_url}

NOTE this could also be accomplished by doing a git checkout
of the whole hugo documentation repository and looking at the
filesystem tree or whatever but we see the way we do it here
as better because it uses the presentation structure which is
presumably the most representative of yadda..
"""
# [#874.4] tracks multi-tablism, which this script engages in
# #[#410.1.2] this is a producer script.


import soupsieve as sv


_domain = 'https://gohugo.io'  # no trailing slash because #here1
_url = _domain + '/documentation/'

_my_doc_string = __doc__


def _required(self, attr, x):
    if x is None:
        self._OK = False  # often `_become_not_OK`
    else:
        setattr(self, attr, x)


class open_dictionary_stream:

    def __init__(self, cached_document_path, listener):
        from data_pipes.format_adapters.html.script_common import (
                soup_via_locators_ as _)
        self._soup_via_locators = _
        self._cached_document_path = cached_document_path
        self._listener = listener
        self._OK = True

    def __enter__(self, *_3):
        self._OK and self.__resolve_soup()
        self._OK and self.__find_the_root_UL()
        if not self._OK:
            return

        yield {
                '_is_sync_meta_data': True,
                'natural_key_field_name': 'la_la',
                }

        for level_one_node in _direct_children(self._the_root_UL):
            if 'li' != level_one_node.name:
                cover_me()
            for level_two_node in _direct_children(level_one_node):
                name = level_two_node.name
                if 'a' == name:
                    dct = {'_is_branch_node': True}
                    _write_anchor_tag(dct, level_two_node)
                    yield dct
                else:
                    assert('ul' == name)
                    for item_li in _direct_children(level_two_node):
                        a, = tuple(_direct_children(item_li))
                        assert('a' == a.name)
                        dct = {}
                        _write_anchor_tag(dct, a)
                        yield dct

    def __exit__(self, *_3):
        return False  # do not swallow exceptions

    def __find_the_root_UL(self):

        # find all tags of this one name that have this one attribute
        # with this one value

        def has_this_one_attr_value(tag):

            if 'nav' != tag.name:
                return False  # #hi (so we can say below)

            # (at the time of writing, all tags that get this far also
            # match the below criteria, but it is here for expressiveness
            # and future-protecting it)

            return tag.has_attr('role') and 'navigation' == tag['role']

        _neet = self._soup.find_all(has_this_one_attr_value)
        del(self._soup)
        _, nav = _neet  # assert 2 navs, we want only 2nd (compare nth-of-type)

        ul, = tuple(_direct_children(nav))  # assert
        assert('ul' == ul.name)
        self._the_root_UL = ul

    def __resolve_soup(self):
        _soup = self._soup_via_locators(
                url=_url,
                html_document_path=self._cached_document_path,
                listener=self._listener)
        self._required('_soup', _soup)

    _required = _required


def _write_anchor_tag(dct, a):
    dct['label'] = a.string.strip()
    s = a['href']
    if 'javascript:void(0)' == s:
        pass  # ..
    else:
        dct['url'] = _domain + s  # :#here1


def _direct_children(node):
    return sv.filter('*', node)  # omit strings, `_filter`


def cover_me():
    raise Exception('cover me')


if __name__ == '__main__':
    from data_pipes.format_adapters.html.script_common import (
            common_CLI_for_json_stream_)
    _exitstatus = common_CLI_for_json_stream_(
            traversal_function=open_dictionary_stream,
            doc_string=_my_doc_string,
            help_values={'hugo_docs_url': _url},
            )
    exit(_exitstatus)

# #born.
