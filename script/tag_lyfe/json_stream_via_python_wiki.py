#!/usr/bin/env python3 -W error::Warning::0

"""
generate a stream of JSON from {url}

(this is the content-producer of the producer/consumer pair)
"""


_domain = 'https://wiki.python.org'

_url = _domain + '/moin/LanguageParsing'

_first_selector = ('div', {'id': 'content'})


def _my_CLI(listener, sin, sout, serr):

    _cm = open_dictionary_stream(None, listener)
    with _cm as lines:
        exitstatus = _lib().flush_JSON_stream_into(sout, serr, lines)
    return exitstatus


_my_CLI.__doc__ = __doc__


def open_dictionary_stream(html_document_path, listener):

    def my_generator(el, _emit):

        table, = el.select('table')

        from sakin_agac.format_adapters.html.magnetics import (
                dictionary_stream_via_table
                )

        table_o = dictionary_stream_via_table(
                value_via_td_for_header_row=_string_via_td_STRICT,
                default_function_for_value_via_td=_string_via_td_LOOSE,
                value_via_td_via_field_name={
                    'name': _this_more_complicated_string_via_td(),
                    },
                table=table,
                )

        field_names = table_o.field_names

        yield {
                '_is_sync_meta_data': True,
                'natural_key_field_name': field_names[0],
                'field_names': field_names,  # coverpoint [#708.2.2]
                'traversal_will_be_alphabetized_by_human_key': False,
                }

        for dct in table_o:
            yield dct

    _cm = _lib().OPEN_DICTIONARY_STREAM_VIA(
        url=_url,
        first_selector=_first_selector,
        second_selector=my_generator,
        html_document_path=html_document_path,
        listener=listener,
        )

    return _cm


def _this_more_complicated_string_via_td():

    o = _lib()
    markdown_link_via = o.markdown_link_via
    url_via_href = o.url_via_href_via_domain(_domain)
    # label_via_string = o.label_via_string_via_max_width(70)
    del(o)

    def f(td):
        a_tag, = td.select('> p > a')
        url = a_tag['href']
        if '/' == url[0]:  # ick/meh coverpoint [#708.2.3]
            url = url_via_href(url)
        return markdown_link_via(_string_via_el(a_tag), url)

    return f


def _string_via_td_LOOSE(td):
    p, = td.select('> p')
    return p.text.strip()


def _string_via_td_STRICT(td):
    p, = td.select('> p')
    return _string_via_el(p)


def _string_via_el(el):  # td.text() would be same, but this gives sanity
    navigable_string, = el.children
    return navigable_string.strip()


def _lib():
    import script.json_stream_via_url_and_selector as lib
    return lib


if __name__ == '__main__':
    import sys as o
    o.path.insert(0, '')
    import script_lib as _
    _exitstatus = _.CHEAP_ARG_PARSE(
        cli_function=_my_CLI,
        std_tuple=(o.stdin, o.stdout, o.stderr, o.argv),
        help_values={'url': _url},
        )
    exit(_exitstatus)

# #born
