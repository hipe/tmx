#!/usr/bin/env python3 -W error::Warning::0

"""
generate a stream of JSON from {url}

(this is the content-producer of the producer/consumer pair)
"""
# This producer script is covered by (Case1855DP).


_domain = 'https://wiki.python.org'

_url = _domain + '/moin/LanguageParsing'

_first_selector = ('div', {'id': 'content'})

_my_doc_string = __doc__


def open_dictionary_stream(html_document_path, listener):

    def my_generator(el, _listener):

        table, = el.select('table')

        from data_pipes.format_adapters.html.magnetics import (
                dictionary_stream_via_table
                )

        table_o = dictionary_stream_via_table(
                string_via_td_for_header_row=_string_via_td_STRICT,
                string_via_td_for_body_row=_string_via_td_LOOSE,
                special_field_instructions={
                    'name': ('string_via_cel', _this_more_complicated_string_via_td()),  # noqa: E501
                    },
                table=table,
                )

        field_names = table_o.field_names

        yield {
                '_is_sync_meta_data': True,
                'natural_key_field_name': field_names[0],
                'field_names': field_names,  # coverpoint [#708.2.2]
                'traversal_will_be_alphabetized_by_human_key': False,
                'custom_keyer_for_syncing': 'data_pipes.format_adapters.html.script_common.simplify_keys_',  # noqa: E501
                # above is broken for syncing,
                # #not-covered since #history-A.2 or before
                }

        for dct in table_o:
            yield dct

    _cm = _top_html_lib().OPEN_DICTIONARY_STREAM_VIA(
        url=_url,
        first_selector=_first_selector,
        second_selector=my_generator,
        html_document_path=html_document_path,
        listener=listener)

    return _cm


def _this_more_complicated_string_via_td():

    o = _md_lib()
    markdown_link_via = o.markdown_link_via
    url_via_href = o.url_via_href_via_domain(_domain)
    # label_via_string = o.label_via_string_via_max_width(70)
    del(o)

    def f(td):
        _p, = _filter('p', td)
        a_tag, = _filter('a', _p)
        url = a_tag['href']
        if '/' == url[0]:  # ick/meh coverpoint [#708.2.3]
            url = url_via_href(url)
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


def _md_lib():
    from data_pipes import common_producer_script as mod
    return mod.LEGACY_markdown_lib()


def _top_html_lib():
    import data_pipes.format_adapters.html.script_common as lib
    return lib


if __name__ == '__main__':
    common_CLI_for_json_stream_ = _top_html_lib().common_CLI_for_json_stream_
    _exitstatus = common_CLI_for_json_stream_(
            traversal_function=open_dictionary_stream,
            doc_string=_my_doc_string,
            help_values={'url': _url},
            )
    exit(_exitstatus)


# #history-A.3: beaut. soup changed
# #history-A.2: key simplifier found to be not covered and left broken
# #history-A.1: key simplifier gets extracted
# #born
