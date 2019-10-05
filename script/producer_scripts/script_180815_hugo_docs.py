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
# This producer script is covered by (Case3306DP).


import soupsieve as sv


_domain = 'https://gohugo.io'  # no trailing slash because #here1
_url = _domain + '/documentation/'


def _my_CLI(error_monitor, sin, sout, serr, is_for_sync):
    with open_traversal_stream(error_monitor.listener) as dcts:
        if is_for_sync:
            dcts = stream_for_sync_via_stream(dcts)
        _ps_lib().flush_JSON_stream_into(sout, serr, dcts)
    return 0 if error_monitor.OK else 456


_my_CLI.__doc__ = __doc__


stream_for_sync_is_alphabetized_by_key_for_sync = False


def stream_for_sync_via_stream(dcts):

    expected_head = f'{_domain}/'
    leng = len(expected_head)

    for dct in dcts:
        if '_is_branch_node' in dct:
            continue
        s = dct['url']
        assert(expected_head == s[0:leng])
        yield (s[leng:], dct)


class open_traversal_stream:

    def __init__(self, listener, cached_document_path=None):
        from data_pipes.format_adapters.html.script_common import (
                soup_via_locators_ as _)
        self._soup_via_locators = _
        self._cached_document_path = cached_document_path
        self._listener = listener

    def __enter__(self, *_3):
        if not self.__resolve_soup():
            return
        self.__find_the_root_UL()

        for level_one_node in _direct_children(self._the_root_UL):
            assert('li' == level_one_node.name)
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
        return _okay

    def __resolve_soup(self):
        soup = self._soup_via_locators(
                url=_url,
                html_document_path=self._cached_document_path,
                listener=self._listener)
        if not soup:
            return
        self._soup = soup
        return _okay


def _write_anchor_tag(dct, a):
    dct['label'] = a.string.strip()
    s = a['href']
    if 'javascript:void(0)' == s:
        pass  # ..
    else:
        dct['url'] = _domain + s  # :#here1


def _direct_children(node):
    return sv.filter('*', node)  # omit strings, `_filter`


def _ps_lib():
    import data_pipes.format_adapters.html.script_common as x
    return x


_okay = True


if __name__ == '__main__':
    import sys as o
    from script_lib.cheap_arg_parse import cheap_arg_parse
    exit(cheap_arg_parse(
            CLI_function=_my_CLI,
            stdin=o.stdin, stdout=o.stdout, stderr=o.stderr, argv=o.argv,
            formal_parameters=(
                ('-s', '--for-sync',
                 'translate to a stream suitable for use in [#447] syncing'),),
            description_template_valueser=lambda: {'hugo_docs_url': _url},
            ))

# #history-A.1: no more sync-side stream mapping
# #born.
