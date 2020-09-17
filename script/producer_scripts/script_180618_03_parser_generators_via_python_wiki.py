#!/usr/bin/env python3 -W error::Warning::0

"""
generate a stream of JSON from {url}

(this is the content-producer of the producer/consumer pair)
"""
# This producer script is covered by (Case1855DP).


_domain = 'https://wiki.python.org'

_url = _domain + '/moin/LanguageParsing'

_first_selector = ('div', {'id': 'content'})


def _my_CLI(error_monitor, sin, sout, serr, is_for_sync):
    with open_traversal_stream(error_monitor.listener) as dcts:
        if is_for_sync:
            dcts = stream_for_sync_via_stream(dcts)
        _ps_lib().flush_JSON_stream_into(sout, serr, dcts)
    return 0 if error_monitor.OK else 456


_my_CLI.__doc__ = __doc__


stream_for_sync_is_alphabetized_by_key_for_sync = False


def stream_for_sync_via_stream(dcts):
    # #not-covered since #history-A.2 or before
    from kiss_rdb.storage_adapters.markdown import (
            simplified_key_via_markdown_link_er)
    key_via = simplified_key_via_markdown_link_er()
    for dct in dcts:
        yield (key_via(dct['name']),  dct)


def open_traversal_stream(listener, html_document_path=None):

    def my_generator(el, _listener):

        table, = el.select('table')

        from data_pipes.format_adapters.html.magnetics import (
                dictionary_stream_via_table)

        return dictionary_stream_via_table(
                string_via_td_for_header_row=_string_via_td_STRICT,
                string_via_td_for_body_row=_string_via_td_LOOSE,
                special_field_instructions={
                    'name': ('string_via_cel', _this_more_complicated_string_via_td()),  # noqa: E501
                    },
                table=table)

    return _ps_lib().open_dictionary_stream_via(
        url=_url,
        first_selector=_first_selector,
        second_selector=my_generator,
        html_document_path=html_document_path,
        listener=listener)


def _this_more_complicated_string_via_td():

    from kiss_rdb.storage_adapters.markdown import (
            markdown_link_via,
            url_via_href_via_domain)

    url_via_href = url_via_href_via_domain(_domain)

    def f(td):
        _p, = _filter('p', td)
        a_tag, = _filter('a', _p)
        url = a_tag['href']
        if '/' == url[0]:
            url = url_via_href(url)  # ick/meh (Case1855DP) (test 400)
        return markdown_link_via(_string_via_el(a_tag), url)

    return f


def _string_via_td_LOOSE(td):
    p, = _filter('p', td)
    return p.text.strip()


def _string_via_td_STRICT(td):
    p, = _filter('p', td)
    return _string_via_el(p)


def _string_via_el(el):  # td.text() would be same, but this gives sanity
    navigable_string, = el.children
    return navigable_string.strip()


def _filter(sel, el):
    import soupsieve as sv
    return sv.filter(sel, el)


def _ps_lib():
    import data_pipes.format_adapters.html.script_common as lib
    return lib


if __name__ == '__main__':
    import sys as o
    from script_lib.cheap_arg_parse import cheap_arg_parse
    exit(cheap_arg_parse(
            CLI_function=_my_CLI,
            stdin=o.stdin, stdout=o.stdout, stderr=o.stderr, argv=o.argv,
            formal_parameters=(
                ('-s', '--for-sync',
                 'translate to a stream suitable for use in [#447] syncing'),),
            description_template_valueser=lambda: {'url': _url}))

# #history-A.4: no more sync-side entity-mapping
# #history-A.3: beaut. soup changed
# #history-A.2: key simplifier found to be not covered and left broken
# #history-A.1: key simplifier gets extracted
# #born
