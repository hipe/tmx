#!/usr/bin/env python3 -W error::Warning::0

"""generate a stream of JSON from the heroku page {url}

(this is the content-producer of the producer/consumer pair)
"""


"""about coverage: this is not covered. it is similar enough to khong
(which is covered excessively) that we held off on doing so here; but
if this script is ever broken, probably that means it's time to cover
"""


_domain = 'https://devcenter.heroku.com'

_url = _domain + '/categories/add-on-documentation'

_first_selector = ('ul', {'class': 'list-icons'})

_my_doc_string = __doc__


def open_dictionary_stream(html_document_path, listener):

    def my_generator(el, _listener):

        yield {
                '_is_sync_meta_data': True,
                'natural_key_field_name': 'add_on',
                'custom_keyer_for_syncing': 'script.json_stream_via_url_and_selector.simplify_keys_',  # noqa: E501
                }

        for el in el.find_all('li', recursive=False):
            a_el = el.findChild('a')
            _href = a_el['href']
            _label = a_el.text
            # the old way:
            # yield {'href': _href, 'label': _label}

            _use_label = label_via_string(_label)
            _url = url_via_href(_href)
            _add_on = markdown_link_via(_use_label, _url)
            yield {'add_on': _add_on}

    o = _lib()
    markdown_link_via = o.markdown_link_via
    url_via_href = o.url_via_href_via_domain(_domain)
    label_via_string = o.label_via_string_via_max_width(70)

    _cm = o.OPEN_DICTIONARY_STREAM_VIA(
        url=_url,
        first_selector=_first_selector,
        second_selector=my_generator,
        html_document_path=html_document_path,
        listener=listener,
        )
    return _cm


def _lib():
    import script.json_stream_via_url_and_selector as lib
    return lib


if __name__ == '__main__':
    import sys as _
    _.path.insert(0, '')
    import script.json_stream_via_url_and_selector as _
    _exitstatus = _.common_CLI_for_json_stream_(
            traversal_function=open_dictionary_stream,
            doc_string=_my_doc_string,
            help_values={'url': _url},
            )
    exit(_exitstatus)

# #born
